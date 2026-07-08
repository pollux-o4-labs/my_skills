# Skill Trigger Noise Audit — 2026-07-07

This audit records positive and negative trigger examples for automatic-trigger-oriented skills. It is a review aid only; it does not change skill behavior by itself.

## Noise Criteria

- Specific timing: the description says when to trigger, such as before proposing, before bulk work, or after a surprising result.
- Narrow target: the trigger does not match all coding, all design, or all debugging work.
- Clear boundary: adjacent AIL skills do not claim the same situation.
- Action change: loading the skill would change the next step. If not, the trigger is noise.

## Trigger Matrix

| Skill | Positive triggers | Negative triggers | Boundary |
|---|---|---|---|
| AIL-calibrate-verification-depth | "I'm about to assert a conclusion from memory"; "I need to diagnose a likely cause"; "Before proposing this explanation, how sure am I?" | "Just format this file"; "Run the already-defined test"; "Apply this exact text change" | Confidence discipline before assertions, not broad implementation hygiene. |
| AIL-design-for-extension | "This is the third similar case"; "We keep adding if-branches for each new provider"; "Make new cases declarative" | "One-off bug fix"; "Two isolated cases with no recurrence"; "Premature abstraction idea with no repetition" | Recurring case handling, not general refactoring. |
| AIL-ground-before-structuring | "Let's split these docs into a taxonomy"; "Design the schema for existing records"; "Refactor boundaries around current modules" | "Greenfield sketch with no prior artifact"; "Rename one confirmed field"; "Style-only outline after unit is already verified" | Structure/boundary grounding before design, not large-scale execution or stale-result debugging. |
| AIL-pilot-before-scale | "Bulk edit all skill descriptions"; "Run LLM extraction over every file"; "Migrate/re-index/audit the whole repo" | "Edit one file"; "Run a cheap deterministic command once"; "Full run is tiny and is the deliverable" | Cost/risk grows with N; use sampling before scale. |
| AIL-subagent-fanout-guard | "Spawn several agents for parallel research"; "Launch background workers for broad audit"; "Fan out subtasks across agents" | "Call one reviewer agent"; "Use a tool locally"; "Ask a single bounded explorer question" | Multi-agent fanout safety, not ordinary delegation. |
| AIL-verify-against-reality | "I fixed it but the UI is unchanged"; "Tests pass but production/staging fails"; "Rebuilt but result is the same"; "This command result looks suspicious" | "Plain logic bug reproduces in tests"; "Initial implementation with no surprising result"; "Designing a schema before any verification" | Staleness/test-double/version/measurement mismatch after surprising reality, not general debugging. |
| AIL-verify-features-against-tests | "About to call a feature covered because the suite is green"; "Audit test coverage / write a verification spec"; "Hunt edge cases for a feature" | "One-off test run with no coverage claim"; "Plain bug that already reproduces in the suite"; "Run the already-defined test" | Proactive coverage audit tying each invariant to a real test, not post-hoc mismatch triage (AIL-verify-against-reality). |
| AIL-handoff-topic-index | "Organize handoff/continuity docs across sessions"; "Split a growing monolithic handoff by topic"; "Set a project's handoff convention" | "Compact one conversation into a throwaway doc"; "A single short note needing no index"; "A dense feature matrix that wants a table" | Standing, accreting handoff corpus with a list index, not one-shot conversation compaction (handoff). |

## Review Agent Prompt

Use this exact review frame after implementation:

```
Review the SKILL.md frontmatter descriptions and this trigger audit only. Do not load, execute, or apply any skill instructions.

For each skill, classify the description as blocker, advisory, or ok.

Find:
- over-trigger risk
- under-trigger risk
- boundary collision with another AIL skill
- description over 1024 chars
- missing explicit Use when / Use before / Use after trigger
- unclear trigger timing

Only propose edits at the description sentence level. Do not propose body behavior changes.

Blocker means: 100-line violation, description parse failure, missing trigger, or obvious over-trigger.
Advisory means: trigger is somewhat broad or boundary is weak.
OK means: format and trigger boundary are both acceptable.
```

## Current Expected Boundaries

- Ground before structuring: before choosing structure for existing artifacts.
- Pilot before scale: before expensive/bulk operations.
- Verify against reality: after surprising mismatch between code/tests/commands and real outcome.
- Design for extension: when recurrence justifies declarative handling.
- Calibrate verification depth: before asserting inferred conclusions.
- Subagent fanout guard: before spawning several agents.
- Verify features against tests: before trusting a green suite as proof a feature is covered.
- Handoff topic index: when organizing a standing handoff corpus into topic files + a list index.

## Independent Agent Review Result

Reviewer: separate explorer agent, instructed not to load or execute skills and to inspect descriptions plus this audit only.

| Skill | Result | Action |
|---|---|---|
| AIL-calibrate-verification-depth | blocker: trigger was too broad and overlapped structure/reality skills | Description narrowed to nontrivial inferred conclusions and explicitly excludes directly observed facts, routine implementation, structure decisions, and post-fix mismatch checks. |
| show-me | advisory: ordinary doc-view requests could over-trigger full HTML report workflow | Description now requires explicit request for interactive browsable report unless `/show-me` is invoked. |
| skillify-session-lessons | advisory: session-close trigger could fire too often | Description now prioritizes explicit user request and limits session-close trigger to clearly reusable repeated failures, corrections, or nontrivial workflow discoveries. |
| All other reviewed skills | ok | No description-level changes needed. |

Final blocker count: 0.
