export const meta = {
  name: 'skill-review',
  description: 'Full skill-PR pipeline: probe default behavior, replay + adversarial review, triage verdict, apply fixes and undraft — merge stays the human gate',
  whenToUse: 'After checking out a skill PR branch: run with {skill: "<dir>", pr: <number>}. Probes an unaided mid-tier model to classify default vs non-default directives, replays scenarios (incl. mandatory user-override boundary), adversarially attacks, then a fixer agent commits the verdict (REGISTER/FIX/COMPRESS/REJECT) to the branch and undrafts. The user only squash-merges (or closes a REJECT).',
  phases: [
    { title: 'Identify', detail: 'read draft + standards; budgets, directives, scenarios, siblings' },
    { title: 'Probe', detail: 'unaided sonnet probes → default/non-default per directive', model: 'sonnet' },
    { title: 'Review', detail: 'replay and adversarial attack in parallel' },
    { title: 'Apply', detail: 'triage verdict → fixer commits to PR branch, undrafts, comments' },
  ],
}

// args: { skill: '<skill directory name on the checked-out PR branch>', pr: <PR number> }
const skill = args && args.skill
const pr = args && args.pr
if (!skill || !pr) throw new Error("args {skill, pr} required, e.g. {skill: 'AIL-foo', pr: 12}")

const ID_SCHEMA = {
  type: 'object',
  required: ['summary', 'budgets', 'triggerType', 'coreDirectives', 'probeScenarios', 'replayScenarios', 'siblings'],
  properties: {
    summary: { type: 'string', description: 'two-sentence identification: what the skill does, its origin' },
    budgets: {
      type: 'object',
      required: ['bodyWords', 'descChars', 'verificationItems', 'originLines', 'violations'],
      properties: {
        bodyWords: { type: 'number' },
        descChars: { type: 'number' },
        verificationItems: { type: 'number' },
        originLines: { type: 'number' },
        violations: { type: 'array', items: { type: 'string' }, description: 'each budget/frontmatter/shape violation; empty if clean' },
      },
    },
    triggerType: { type: 'string', description: "'model-invoked' or 'user-invoked' + one-line justification per the standards' discriminator" },
    coreDirectives: { type: 'array', items: { type: 'string' }, description: "the skill's behavioral directives, one line each — the units the probe classifies" },
    probeScenarios: {
      type: 'array',
      items: { type: 'string' },
      description: '1-2 self-contained scenario prompts reconstructing the origin situation WITHOUT hinting any directive (no tool names, no suspicions seeded) — the probe measures whether an unaided model derives the directives itself',
    },
    replayScenarios: {
      type: 'array',
      items: {
        type: 'object',
        required: ['kind', 'prompt'],
        properties: {
          kind: { type: 'string', description: 'original | analogue | boundary | boundary-user-override' },
          prompt: { type: 'string' },
        },
      },
      description: 'original + ≥1 analogue (different domain) + ≥1 boundary (advice must NOT apply) + exactly one boundary-user-override',
    },
    siblings: { type: 'array', items: { type: 'string' }, description: 'paths of repo skills whose scope borders this one' },
  },
}

const JUDGE_SCHEMA = {
  type: 'object',
  required: ['classifications'],
  properties: {
    classifications: {
      type: 'array',
      items: {
        type: 'object',
        required: ['directive', 'isDefault', 'evidence'],
        properties: {
          directive: { type: 'string' },
          isDefault: { type: 'boolean', description: 'true if the unaided probe answers already exhibit this directive' },
          evidence: { type: 'string', description: 'quoted probe-answer text proving default, or the gap/mistake proving non-default' },
        },
      },
    },
  },
}

const FIX_SCHEMA = {
  type: 'object',
  required: ['verdicts', 'fixes'],
  properties: {
    verdicts: {
      type: 'array',
      items: {
        type: 'object',
        required: ['target', 'verdict', 'decidingText'],
        properties: {
          target: { type: 'string' },
          verdict: { type: 'string', description: 'PASS | AMBIGUOUS | FAIL | SURVIVES' },
          decidingText: { type: 'string' },
        },
      },
    },
    fixes: {
      type: 'array',
      items: {
        type: 'object',
        required: ['severity', 'finding', 'fix'],
        properties: {
          severity: { type: 'string', description: 'FIX-FIRST | SHOULD | NIT' },
          finding: { type: 'string' },
          fix: { type: 'string' },
        },
      },
    },
  },
}

phase('Identify')
const id = await agent(
  `Identify the skill draft ./${skill}/SKILL.md for pipeline review. Working directory = my_skills repo root, PR branch checked out.
Read the draft, ./skillify-session-lessons/authoring-standards.md, and any side files in ./${skill}/.
Produce (per the schema): budgets incl. Origin line count and violations; triggerType; coreDirectives (each behavioral rule as one line); probeScenarios (reconstruct the origin situation with NO hints — do not name tools, commands, or suspicions the skill teaches; the probe must be able to fail); replayScenarios (original + analogue + boundary + exactly one boundary-user-override where the user explicitly instructs against the skill's rule); siblings (scan AIL-*/SKILL.md descriptions and this draft's pointer lines).`,
  { schema: ID_SCHEMA, label: `identify:${skill}`, phase: 'Identify' }
)

phase('Probe')
const probeAnswers = (
  await parallel(
    id.probeScenarios.map((s, i) => () =>
      agent(`${s}\n\nAnswer with your exact plan and the exact commands you would run. Return your plan only.`, {
        agentType: 'skill-prober',
        label: `probe:${i + 1}`,
        phase: 'Probe',
      })
    )
  )
).filter(Boolean)

const judge = await agent(
  `Classify each directive of a skill as default or non-default model behavior, using unaided probe answers as evidence.
DIRECTIVES:\n${id.coreDirectives.map((d, i) => `${i + 1}. ${d}`).join('\n')}
UNAIDED PROBE ANSWERS (a mid-tier model answered the origin scenario with no access to the skill):\n${probeAnswers.map((a, i) => `--- PROBE ${i + 1} ---\n${a}`).join('\n')}
A directive is DEFAULT only if the probe answers actually exhibit it (deletion test: the skill sentence would change nothing). If a probe does the opposite or reaches for a weaker method, that directive is NON-DEFAULT — quote the mistake as evidence. Judge strictly.`,
  { schema: JUDGE_SCHEMA, label: 'probe-judge', phase: 'Probe' }
)

phase('Review')
const scenarioBlock = id.replayScenarios.map((s, i) => `SCENARIO ${i + 1} [${s.kind}]: ${s.prompt}`).join('\n\n')
const [replay, adversarial] = await parallel([
  () =>
    agent(`Skill under replay: ./${skill}/SKILL.md (repo root = working directory).\n\n${scenarioBlock}`, {
      agentType: 'skill-replayer',
      schema: FIX_SCHEMA,
      label: `replay:${skill}`,
      phase: 'Review',
    }),
  () =>
    agent(
      `Skill under attack: ./${skill}/SKILL.md (repo root = working directory).\nStandards: ./skillify-session-lessons/authoring-standards.md.\nSiblings to check: ${id.siblings.join(', ')}.\nKnown probe result (attack vector 4 context): non-default directives = ${JSON.stringify(
        judge.classifications.filter(c => !c.isDefault).map(c => c.directive)
      )}.`,
      { agentType: 'skill-adversary', schema: FIX_SCHEMA, label: `adversarial:${skill}`, phase: 'Review' }
    ),
])

// Triage — deterministic script logic
const order = { 'FIX-FIRST': 0, SHOULD: 1, NIT: 2 }
const fixes = [
  ...(replay ? replay.fixes.map(f => ({ ...f, source: 'replay' })) : []),
  ...(adversarial ? adversarial.fixes.map(f => ({ ...f, source: 'adversarial' })) : []),
].sort((a, b) => (order[a.severity] ?? 3) - (order[b.severity] ?? 3))

const nonDefault = judge.classifications.filter(c => !c.isDefault)
const mustFix = fixes.filter(f => f.severity === 'FIX-FIRST' || f.severity === 'SHOULD')

let verdict
if (nonDefault.length === 0) verdict = 'REJECT' // fully default behavior — skill is a no-op
else if (nonDefault.length * 2 < judge.classifications.length) verdict = 'COMPRESS' // minority non-default core
else if (mustFix.length > 0 || id.budgets.violations.length > 0) verdict = 'FIX'
else verdict = 'REGISTER'

log(`${skill}: verdict=${verdict} — non-default ${nonDefault.length}/${judge.classifications.length} directives, ${fixes.filter(f => f.severity === 'FIX-FIRST').length} FIX-FIRST / ${fixes.filter(f => f.severity === 'SHOULD').length} SHOULD`)

phase('Apply')
const applied = await agent(
  `Apply this skill-review verdict to PR #${pr} (branch already checked out; skill file ./${skill}/SKILL.md).
VERDICT: ${verdict}
PROBE CLASSIFICATIONS:\n${JSON.stringify(judge.classifications, null, 1)}
BUDGETS/VIOLATIONS:\n${JSON.stringify(id.budgets, null, 1)}
FIX LIST (severity-sorted):\n${JSON.stringify(fixes, null, 1)}
Follow your discipline for this verdict, then report what you committed/pushed/commented in a few lines.`,
  { agentType: 'skill-fixer', label: `apply:${verdict}`, phase: 'Apply' }
)

return {
  skill,
  pr,
  verdict,
  nonDefaultDirectives: nonDefault,
  fixes,
  replayVerdicts: replay ? replay.verdicts : null,
  adversarialVerdicts: adversarial ? adversarial.verdicts : null,
  applied,
}
