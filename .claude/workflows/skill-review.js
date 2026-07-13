export const meta = {
  name: 'skill-review',
  description: 'Skill-PR pipeline v3: draft raw notes if needed, probe default behavior, review, arbitrate noise, fix-verify loop, land — merge stays the human gate',
  whenToUse: 'After checking out a skill PR branch: run with {skill: "<dir>", pr: <number>}. RAW note drafts get formed first; probes classify default vs non-default directives; replay + adversarial findings pass an arbiter (BLOCKER/CHEAP accepted, NOISE rejected with reasons); a fix⇄verify loop (≤2 rounds) edits without committing; Land commits, undrafts only on a clean pass, and posts the verdict. The user only squash-merges (or closes a REJECT).',
  phases: [
    { title: 'Identify', detail: 'read draft + standards; maturity, budgets, directives, scenarios, siblings' },
    { title: 'Draft', detail: 'RAW notes only: form the skill per standards, then re-identify' },
    { title: 'Probe', detail: 'unaided sonnet probes → default/non-default per directive', model: 'sonnet' },
    { title: 'Review', detail: 'replay and adversarial attack in parallel' },
    { title: 'Arbitrate', detail: 'BLOCKER / CHEAP accepted — NOISE rejected with reasons' },
    { title: 'Fix & Verify', detail: 'edit-only fixer ⇄ per-item verifier, ≤2 rounds, no commit' },
    { title: 'Re-audit', detail: 'conditional second adversary — fires on noise ≥3, exhausted loop, or unresolved items' },
    { title: 'Land', detail: 'commit, push, undraft on clean pass, verdict comment' },
  ],
}

// args: { skill: '<skill directory name on the checked-out PR branch>', pr: <PR number> }
const a = typeof args === 'string' ? JSON.parse(args) : args
const skill = a && a.skill
const pr = a && a.pr
if (!skill || !pr) throw new Error("args {skill, pr} required, e.g. {skill: 'AIL-foo', pr: 12}")

const ID_SCHEMA = {
  type: 'object',
  required: ['summary', 'maturity', 'budgets', 'triggerType', 'coreDirective', 'coreDirectives', 'probeScenarios', 'replayScenarios', 'siblings'],
  properties: {
    summary: { type: 'string', description: 'two-sentence identification: what the skill does, its origin' },
    maturity: { type: 'string', description: "'FORMED' if the file follows the standards' skill shape; 'RAW' if it is a bare lesson/notes dump needing drafting first" },
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
    coreDirective: { type: 'string', description: "THE one-sentence rule that carries the skill's central lesson — used as the hint in the derivability probe" },
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

const ARB_SCHEMA = {
  type: 'object',
  required: ['rulings'],
  properties: {
    rulings: {
      type: 'array',
      items: {
        type: 'object',
        required: ['index', 'class', 'accept', 'reason'],
        properties: {
          index: { type: 'number', description: '0-based index into the findings list given to you' },
          class: { type: 'string', description: 'BLOCKER (real defect, must fix) | CHEAP (valid, low-cost improvement) | NOISE (adversarial artifact, style opinion, or duplicate)' },
          accept: { type: 'boolean', description: 'BLOCKER and CHEAP → true; NOISE → false' },
          reason: { type: 'string', description: 'one line; for NOISE, why it does not survive scrutiny' },
        },
      },
    },
  },
}

const VERIFY_SCHEMA = {
  type: 'object',
  required: ['items', 'loadBearingLoss'],
  properties: {
    items: {
      type: 'array',
      items: {
        type: 'object',
        required: ['index', 'resolved', 'note'],
        properties: {
          index: { type: 'number', description: '0-based index into the accepted-findings list' },
          resolved: { type: 'boolean' },
          note: { type: 'string', description: 'where in the new text it is resolved, or what is still missing' },
        },
      },
    },
    loadBearingLoss: { type: 'array', items: { type: 'string' }, description: 'directives/examples present before the edit that vanished without a declared deletion-test rationale' },
  },
}

const identifyPrompt = `Identify the skill draft ./${skill}/SKILL.md for pipeline review. Working directory = my_skills repo root, PR branch checked out.
Read the draft, ./skillify-session-lessons/authoring-standards.md, and any side files in ./${skill}/.
Produce (per the schema): maturity (FORMED skill vs RAW notes dump); budgets incl. Origin line count and violations; triggerType; coreDirectives (each behavioral rule as one line); probeScenarios (reconstruct the origin situation with NO hints — do not name tools, commands, or suspicions the skill teaches; the probe must be able to fail); replayScenarios (original + analogue + boundary + exactly one boundary-user-override where the user explicitly instructs against the skill's rule); siblings (scan AIL-*/SKILL.md descriptions and this draft's pointer lines).`

phase('Identify')
let id = await agent(identifyPrompt, { schema: ID_SCHEMA, label: `identify:${skill}`, phase: 'Identify', model: 'opus', effort: 'high' })

if (id.maturity === 'RAW') {
  phase('Draft')
  await agent(
    `EDIT mode — DRAFT. ./${skill}/SKILL.md is a raw lesson/notes dump, not a formed skill. Form it per your DRAFT discipline. Identification context: ${id.summary}`,
    { agentType: 'skill-fixer', label: `draft:${skill}`, phase: 'Draft', model: 'opus', effort: 'high' }
  )
  id = await agent(identifyPrompt, { schema: ID_SCHEMA, label: `re-identify:${skill}`, phase: 'Draft', model: 'opus', effort: 'high' })
}

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
UNAIDED PROBE ANSWERS (a mid-tier model answered the origin scenario with no access to the skill):\n${probeAnswers.map((p, i) => `--- PROBE ${i + 1} ---\n${p}`).join('\n')}
A directive is DEFAULT only if the probe answers actually exhibit it (deletion test: the skill sentence would change nothing). If a probe does the opposite or reaches for a weaker method, that directive is NON-DEFAULT — quote the mistake as evidence. Judge strictly.`,
  { schema: JUDGE_SCHEMA, label: 'probe-judge', phase: 'Probe', model: 'opus', effort: 'high' }
)

let nonDefault = judge.classifications.filter(c => !c.isDefault)

// Derivability probe — zero-knowledge probing over-values elaborations: a directive can be
// non-default from scratch yet fully derivable once the core rule is given. Measure that.
let derivable = []
if (nonDefault.length >= 3) {
  const hinted = await agent(
    `${id.probeScenarios[0]}\n\nAdditionally, you follow this one team rule: "${id.coreDirective}"\n\nDesign the implementation in full — every distinct outcome and behavior, edge cases you would handle, and how you would prove it works. Do NOT enumerate topics you were not asked about; just design. Return your plan only.`,
    { agentType: 'skill-prober', label: 'probe:hinted', phase: 'Probe' }
  )
  const judge2 = await agent(
    `A model was given ONLY this core rule: "${id.coreDirective}" plus the working scenario, and produced the plan below. Classify each remaining directive: does the plan already exhibit it (derivable from the core — the extra sentence would change nothing), or is it absent/contradicted (needs its own sentence)?
DIRECTIVES:\n${nonDefault.map((c, i) => `${i + 1}. ${c.directive}`).join('\n')}
HINTED-PROBE PLAN:\n${hinted}
Mark isDefault=true when the plan exhibits the directive (derivable), false when absent or contradicted. The core rule itself, if listed, is always isDefault=false. Beware prompt contamination: if the directive only appears because the scenario text seeded it, judge conservatively (isDefault=false). Quote evidence.`,
    { schema: JUDGE_SCHEMA, label: 'derivability-judge', phase: 'Probe', model: 'opus', effort: 'high' }
  )
  derivable = judge2.classifications.filter(c => c.isDefault)
  const derivableSet = new Set(derivable.map(c => c.directive))
  nonDefault = nonDefault.filter(c => !derivableSet.has(c.directive))
  log(`derivability: ${derivable.length} directives derivable from the core → cut candidates; ${nonDefault.length} retained`)
}

let verdict, fixes = [], rulings = [], accepted = [], remaining = [], rounds = 0, replay = null, adversarial = null

if (nonDefault.length === 0) {
  verdict = 'REJECT' // every directive is default behavior — the skill is a no-op
  log(`${skill}: verdict=REJECT — all ${judge.classifications.length} directives default; skipping review`)
} else {
  phase('Review')
  const scenarioBlock = id.replayScenarios.map((s, i) => `SCENARIO ${i + 1} [${s.kind}]: ${s.prompt}`).join('\n\n')
  ;[replay, adversarial] = await parallel([
    () =>
      agent(`Skill under replay: ./${skill}/SKILL.md (repo root = working directory).\n\n${scenarioBlock}`, {
        agentType: 'skill-replayer',
        schema: FIX_SCHEMA,
        label: `replay:${skill}`,
        phase: 'Review',
        model: 'opus',
        effort: 'high',
      }),
    () =>
      agent(
        `Skill under attack: ./${skill}/SKILL.md (repo root = working directory).\nStandards: ./skillify-session-lessons/authoring-standards.md.\nSiblings to check: ${id.siblings.join(', ')}.\nKnown probe result (attack vector 4 context): non-default directives = ${JSON.stringify(nonDefault.map(c => c.directive))}.`,
        { agentType: 'skill-adversary', schema: FIX_SCHEMA, label: `adversarial:${skill}`, phase: 'Review', model: 'opus', effort: 'high' }
      ),
  ])

  const order = { 'FIX-FIRST': 0, SHOULD: 1, NIT: 2 }
  fixes = [
    ...(replay ? replay.fixes.map(f => ({ ...f, source: 'replay' })) : []),
    ...(adversarial ? adversarial.fixes.map(f => ({ ...f, source: 'adversarial' })) : []),
  ].sort((x, y) => (order[x.severity] ?? 3) - (order[y.severity] ?? 3))

  phase('Arbitrate')
  if (fixes.length) {
    const arb = await agent(
      `You arbitrate review findings against a skill draft. Reviewers are prompted adversarially — they always produce findings; your job is separating real defects from adversarial artifacts.
Read ./${skill}/SKILL.md, ./skillify-session-lessons/authoring-standards.md, ./skill-refactor/RATIONALE.md, and the named siblings (${id.siblings.join(', ')}) — they are your judgment basis, not your memory.
FINDINGS (0-indexed):\n${fixes.map((f, i) => `${i}. [${f.severity}|${f.source}] ${f.finding} → fix: ${f.fix}`).join('\n')}
Rule on every index: BLOCKER (would mislead or break an executing agent), CHEAP (valid, low-cost, no downside), NOISE (style opinion, duplicate of another finding, speculative edge case, or contradicts the standards/repo precedent). Accept BLOCKER+CHEAP, reject NOISE with a one-line reason. Do not rubber-stamp: a wrong "fix" that would bloat or distort the skill is NOISE even if the observation is true.`,
      { schema: ARB_SCHEMA, label: 'arbitrate', phase: 'Arbitrate', model: 'opus', effort: 'high' }
    )
    rulings = arb.rulings
    accepted = rulings.filter(r => r.accept).map(r => ({ ...fixes[r.index], class: r.class }))
  }

  verdict = nonDefault.length * 2 < judge.classifications.length ? 'COMPRESS' : accepted.length || id.budgets.violations.length ? 'FIX' : 'REGISTER'
  log(`${skill}: verdict=${verdict} — non-default ${nonDefault.length}/${judge.classifications.length}, findings ${fixes.length} → accepted ${accepted.length} (noise ${rulings.filter(r => !r.accept).length})`)

  phase('Fix & Verify')
  remaining = accepted.map((f, i) => ({ ...f, index: i }))
  if (verdict === 'COMPRESS' || remaining.length || id.budgets.violations.length) {
    while (rounds < 2) {
      rounds++
      const editKind = verdict === 'COMPRESS' && rounds === 1 ? 'COMPRESS' : 'FIX'
      await agent(
        `EDIT mode — ${editKind}. Target: ./${skill}/SKILL.md on the checked-out PR branch.
${editKind === 'COMPRESS' ? `Probe-proven non-default core to keep: ${JSON.stringify(nonDefault.map(c => c.directive))}.\n` : ''}${derivable.length ? `Derivable-from-core directives — cut or fold into the core step (a Verification outcome check may stay): ${JSON.stringify(derivable.map(c => c.directive))}.\n` : ''}Budget violations to cure: ${JSON.stringify(id.budgets.violations)}.
Accepted findings to apply (round ${rounds}):\n${remaining.map(f => `[${f.index}|${f.severity}|${f.class}] ${f.finding} → ${f.fix}`).join('\n') || '(none — budgets only)'}`,
        {
          agentType: 'skill-fixer',
          label: `fix:round${rounds}`,
          phase: 'Fix & Verify',
          ...(editKind === 'COMPRESS' ? { model: 'opus', effort: 'high' } : { model: 'sonnet' }),
        }
      )
      const check = await agent(
        `Verify an edited skill against its accepted findings. Read ./${skill}/SKILL.md (post-edit).
ACCEPTED FINDINGS (verify each is genuinely resolved in the current text, quoting where):\n${accepted.map((f, i) => `${i}. [${f.severity}] ${f.finding} → agreed fix: ${f.fix}`).join('\n')}
Also check load-bearing loss: compare against the finding list's implied original content — any directive or example that vanished without a declared deletion-test rationale goes in loadBearingLoss. Judge strictly; cosmetic acknowledgment is not resolution.`,
        { schema: VERIFY_SCHEMA, label: `verify:round${rounds}`, phase: 'Fix & Verify', model: 'opus', effort: 'high' }
      )
      const unresolvedIdx = check.items.filter(it => !it.resolved).map(it => it.index)
      remaining = accepted.map((f, i) => ({ ...f, index: i })).filter(f => unresolvedIdx.includes(f.index))
      for (const loss of check.loadBearingLoss) remaining.push({ index: -1, severity: 'FIX-FIRST', class: 'BLOCKER', finding: `load-bearing loss: ${loss}`, fix: 'restore it (or declare the deletion-test rationale)' })
      log(`round ${rounds}: ${remaining.length} unresolved`)
      if (!remaining.length) break
    }
  }
}

// Conditional re-audit — only on risk signals (rejection-overturn risk, unstable fix loop, human-pending items)
let reaudit = null
const noiseCount = rulings.filter(r => !r.accept).length
if (verdict !== 'REJECT' && (noiseCount >= 3 || rounds >= 2 || remaining.length)) {
  phase('Re-audit')
  reaudit = await agent(
    `Second-opinion audit of ./${skill}/SKILL.md AFTER fixes were applied (repo root = working directory). Standards: ./skillify-session-lessons/authoring-standards.md.
APPLIED FIXES (audit each is genuinely resolved, not cosmetic):\n${accepted.map(f => `- [${f.severity}] ${f.finding} → ${f.fix}`).join('\n') || '(none)'}
ARBITER'S NOISE REJECTIONS (audit each: wrongly dismissed? NOTE especially where an applied fix changed the calculus — new concrete code can invalidate a rejection that was sound against the old abstract text):\n${rulings.filter(r => !r.accept).map(r => `- ${fixes[r.index].finding} | rejected because: ${r.reason}`).join('\n') || '(none)'}
Also fresh-attack the newly added material for contradictions and self-sufficiency. Report only findings that survive scrutiny.`,
    { agentType: 'skill-adversary', schema: FIX_SCHEMA, label: 're-audit', phase: 'Re-audit', model: 'opus', effort: 'high' }
  )
  const blockers = reaudit ? reaudit.fixes.filter(f => f.severity === 'FIX-FIRST') : []
  if (blockers.length) {
    await agent(
      `EDIT mode — FIX. Target: ./${skill}/SKILL.md on the checked-out PR branch. Re-audit blockers to apply:\n${blockers.map(f => `[FIX-FIRST] ${f.finding} → ${f.fix}`).join('\n')}`,
      { agentType: 'skill-fixer', label: 'fix:reaudit', phase: 'Re-audit', model: 'sonnet' }
    )
  }
  log(`re-audit: ${reaudit ? reaudit.fixes.length : 0} findings, ${blockers.length} blockers applied`)
}

phase('Land')
const clean = verdict !== 'REJECT' && remaining.length === 0
const landed = await agent(
  `LAND mode — PR #${pr}, skill ./${skill}/SKILL.md.
SKILL SUMMARY (use this to open the comment in plain language): ${id.summary}
VERDICT: ${verdict} | CLEAN PASS: ${clean}${remaining.length ? ` | UNRESOLVED: ${JSON.stringify(remaining.map(f => f.finding))}` : ''}
PROBE: ${JSON.stringify(judge.classifications)}
APPLIED: ${JSON.stringify(accepted.map(f => f.finding))}
NOISE REJECTED: ${JSON.stringify(rulings.filter(r => !r.accept).map(r => ({ finding: fixes[r.index].finding, reason: r.reason })))}${reaudit && reaudit.fixes.length ? `\nRE-AUDIT ADVISORIES (non-blocking — include in the comment): ${JSON.stringify(reaudit.fixes.filter(f => f.severity !== 'FIX-FIRST').map(f => f.finding))}` : ''}
Follow your LAND discipline: ${verdict === 'REJECT' ? 'comment only.' : clean ? 'version bump, commit, push, gh pr ready, comment.' : 'version bump, commit, push, KEEP DRAFT, comment marking unresolved items as needing human judgment.'}`,
  { agentType: 'skill-fixer', label: `land:${verdict}`, phase: 'Land', model: 'sonnet' }
)

return { skill, pr, verdict, clean, rounds, nonDefaultDirectives: nonDefault, accepted: accepted.map(f => f.finding), noise: rulings.filter(r => !r.accept).map(r => ({ finding: fixes[r.index] && fixes[r.index].finding, reason: r.reason })), reaudit: reaudit ? reaudit.fixes : null, unresolved: remaining.map(f => f.finding), landed }
