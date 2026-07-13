export const meta = {
  name: 'skill-review',
  description: 'Replay + adversarial review of one skill draft against repo authoring standards',
  whenToUse: 'After checking out a skill PR branch: measures budgets, derives replay scenarios (origin/analogue/boundary incl. mandatory user-override), runs replay and adversarial attack in parallel, returns a consolidated severity-sorted fix list. Applying fixes and merging stay manual.',
  phases: [
    { title: 'Identify', detail: 'read draft + standards, measure budgets, derive scenarios and siblings' },
    { title: 'Review', detail: 'replay and adversarial attack in parallel' },
  ],
}

// args: { skill: '<directory name of the skill under review, on the checked-out branch>' }
const skill = args && args.skill
if (!skill) throw new Error("args.skill required, e.g. {skill: 'AIL-isolate-format-noise'}")

const ID_SCHEMA = {
  type: 'object',
  required: ['summary', 'budgets', 'triggerType', 'scenarios', 'siblings'],
  properties: {
    summary: { type: 'string', description: 'two-sentence identification of what the skill does and its origin' },
    budgets: {
      type: 'object',
      required: ['bodyWords', 'descChars', 'verificationItems', 'violations'],
      properties: {
        bodyWords: { type: 'number' },
        descChars: { type: 'number' },
        verificationItems: { type: 'number' },
        violations: { type: 'array', items: { type: 'string' }, description: 'each budget/frontmatter/section-shape violation, one line each; empty if clean' },
      },
    },
    triggerType: { type: 'string', description: "'model-invoked' or 'user-invoked', with a one-line justification per the standards' discriminator" },
    scenarios: {
      type: 'array',
      items: {
        type: 'object',
        required: ['kind', 'prompt'],
        properties: {
          kind: { type: 'string', description: 'original | analogue | boundary | boundary-user-override' },
          prompt: { type: 'string', description: 'self-contained replay scenario paragraph' },
        },
      },
    },
    siblings: { type: 'array', items: { type: 'string' }, description: 'repo skills whose scope borders this one (paths to their SKILL.md)' },
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
          target: { type: 'string', description: 'scenario kind or attack vector name' },
          verdict: { type: 'string', description: 'PASS | AMBIGUOUS | FAIL | SURVIVES' },
          decidingText: { type: 'string', description: 'exact quoted sentence(s) that decide it' },
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
          fix: { type: 'string', description: 'concrete minimal fix' },
        },
      },
    },
  },
}

phase('Identify')
const id = await agent(
  `Identify a skill draft for review. Working directory is the my_skills repo root with the PR branch checked out.
Read: ./${skill}/SKILL.md (the draft), ./skillify-session-lessons/authoring-standards.md (caps and conventions), and any side files in ./${skill}/ (RATIONALE.md etc.).
Produce:
1. budgets — measure body words (frontmatter excluded), description chars (content only, without the "description:" key and quotes), Verification item count; list every violation of the standards (caps, AIL frontmatter fields, section shape, one-line Origin, platforms convention: host-agnostic skills use [claude-code, codex, gemini-cli]).
2. triggerType — judge model- vs user-invoked per the standards' discriminator, one-line justification.
3. siblings — scan the repo's AIL-*/SKILL.md descriptions plus skills named in this draft's Scope/pointer lines; return paths of skills whose scope borders or overlaps this one.
4. scenarios — replay scenarios as self-contained paragraphs: one 'original' reconstructed from the Origin line and Example, at least one 'analogue' in a genuinely different domain, at least one 'boundary' where the skill's advice must NOT apply, and exactly one 'boundary-user-override' (the user explicitly instructs against the skill's rule; the draft must comply with a one-line transparency delta — mandated by authoring-standards).
Return only the structured object.`,
  { schema: ID_SCHEMA, label: `identify:${skill}`, phase: 'Identify' }
)

phase('Review')
const scenarioBlock = id.scenarios
  .map((s, i) => `SCENARIO ${i + 1} [${s.kind}]: ${s.prompt}`)
  .join('\n\n')
const siblingBlock = id.siblings.join(', ')

const [replay, adversarial] = await parallel([
  () =>
    agent(
      `You are a replay verifier for the skill draft ./${skill}/SKILL.md (read it first; repo root is the working directory).
Replay the skill text against each scenario below and judge whether an agent following ONLY the SKILL.md would act correctly.

${scenarioBlock}

For each scenario: verdict PASS / AMBIGUOUS / FAIL, the exact deciding sentence(s), and any MISS (needed guidance absent) or MISLEAD (text pushes the wrong action) folded into the fixes list. Judge strictly; charity readings don't count as text.`,
      { schema: FIX_SCHEMA, label: `replay:${skill}`, phase: 'Review' }
    ),
  () =>
    agent(
      `You are an adversarial reviewer of the skill draft ./${skill}/SKILL.md (repo root is the working directory). ATTACK it; find real defects, don't praise.
Also read ./skillify-session-lessons/authoring-standards.md and these sibling skills for discriminability attacks: ${siblingBlock}.

Attack vectors in order:
1. PARSING/EXECUTION — sentences an executing agent could misread; internal contradictions; terms not defined in this file (skills cannot load each other, so every term of art must be self-sufficient or glossed); steps assuming context the session won't have.
2. SIBLING DISCRIMINABILITY — overlap or boundary gaps with each sibling; could two skills tell the reader different things in the same moment; are pointer lines in the right place.
3. STANDARDS COMPLIANCE — verify the budget/frontmatter/shape violations independently.
4. CONTENT CORRECTNESS — is every claimed mechanism real (no nonexistent tool parameters or APIs); is each procedure step decidable, not vibes; does the Example match the Origin.
5. KARPATHY CONFLICTS — overcomplication, speculative generality, non-surgical tendencies.

For every finding: severity FIX-FIRST / SHOULD / NIT, the exact quoted text, why defective, concrete minimal fix. Sections that survive attack get one SURVIVES verdict line each.`,
      { schema: FIX_SCHEMA, label: `adversarial:${skill}`, phase: 'Review' }
    ),
])

const order = { 'FIX-FIRST': 0, SHOULD: 1, NIT: 2 }
const fixes = [
  ...(replay ? replay.fixes.map(f => ({ ...f, source: 'replay' })) : []),
  ...(adversarial ? adversarial.fixes.map(f => ({ ...f, source: 'adversarial' })) : []),
].sort((a, b) => (order[a.severity] ?? 3) - (order[b.severity] ?? 3))

log(`${skill}: ${fixes.filter(f => f.severity === 'FIX-FIRST').length} FIX-FIRST / ${fixes.filter(f => f.severity === 'SHOULD').length} SHOULD / ${fixes.filter(f => f.severity === 'NIT').length} NIT`)

return {
  skill,
  identify: id,
  replayVerdicts: replay ? replay.verdicts : null,
  adversarialVerdicts: adversarial ? adversarial.verdicts : null,
  fixes,
}
