---
name: AIL-calibrate-agent-spend
description: "Checks that the effort level or fan-out width of a multi-agent or effort-leveled tool call is derived from the measured task size and the project's declared review policy, not left at a default. Use before passing an effort/depth/parallelism argument to a cost-scaling tool, or before spawning several parallel agents for review, audit, or research."
version: 0.2.0
metadata:
  platforms: [claude-code, codex]
  provenance: AIL
---

# Calibrate Agent Spend

An effort level or fan-out width is a **spend decision, not a default**. A named skill call at `effort=high` spawns the same agents and burns the same tokens as manual fan-out, and carries the same duty to justify. The defect this skill targets is a bounded, well-formed fan-out that was **oversized for the job** — chosen without measuring the task or checking whether the project already answered "how much review does this need."

## When to Use

- About to pass an effort/depth/mode/agent-count argument to a tool whose cost scales with it: `/code-review`, `comprehensive-review`, `deep-research`, `agent-teams:*`, `conductor:*`, orchestration skills.
- About to spawn several parallel `Agent`/`Workflow` calls for review, audit, or research.
- The level is a default, copied from a prior call, or picked because it "sounds thorough" — or the tool was picked because its name matches the goal word ("review" → heaviest reviewer).

**Skip for**: a single call with no effort knob; a size just fixed by explicit user instruction; work plainly large, cross-cutting, or high-risk where heavy effort is self-evident. For the mechanics of an already-decided fan-out, use `AIL-subagent-fanout-guard`; for full-vs-incremental bulk data ops, `AIL-prefer-incremental-over-full`.

## Procedure

1. **Measure the task before naming a tool.** `git diff --stat` or equivalent: file count, line count, blast radius (leaf logic vs shared/critical path, schema/API surface). Size off the object of work, not the goal word.
2. **Read (don't recall) every level of the project's supervision policy for work this size** — CLAUDE.md, formal rules, ADRs, and nearby session/campaign notes. These can disagree; read the actual text of each.
3. **Branch on what the policy says** — the matching case:
   - unambiguous cheaper path declared → use it, no "extra thoroughness"
   - documents in conflict → name the conflict, then decide deliberately or ask
   - review mandated but scale unstated → smallest scale that meets the task
   - task exceeds the cheap scope, or high blast radius → escalate deliberately
4. **Write a one-sentence justification tying level to measured scope, before invoking.** "Small diff but touches auth + plugin ABI, so independent angles on both" qualifies; "it's a review so effort=high" does not. Can't write it → drop a tier.
5. **State the calibration in one auditable line before go**: task size → chosen level → why the cheaper path was or wasn't used.

## Pitfalls

- **Effort autopilot** — inheriting a default or the last-used level instead of re-deriving it for the current diff.
- **"More thorough" treated as free** — 8 parallel angles on a 60-line diff burn real tokens for near-zero marginal finding.
- **Boundedness mistaken for justification** — passing `AIL-subagent-fanout-guard`'s mechanics checklist says nothing about whether the width was warranted.
- **Overclaiming a "declared convention"** — asserting a cheaper path exists (or doesn't) without reading every doc level; a campaign note and a formal rule are both real artifacts.
- **Retroactive rationalization** — a justification constructed only after the user asks was not a decision.

## Verification

- [ ] Blast radius stated in your own words before the call, not inferred from the tool's menu?
- [ ] Policy docs read at every relevant level — and any conflict between them named, not silently resolved?
- [ ] Smallest scale that meets the task, not the default or top tier?
- [ ] Justification written before invocation — and would it survive "why this many agents for a change this size"?

## Example

About to call `/code-review effort=high` (≈8 parallel finders) on a 3-file, ~60-line, single-subrepo diff, because high was used last time. Measuring first: no cross-module blast radius. Reading policy finds *two* documents — a formal rule ("implementation output gets adversarial review", no size floor) and a campaign handoff note ("small bundles → supervisor reviews directly"). Conflict branch: name both, then decide — "campaign note governs here (we're in that campaign and the diff is small; supervisor-as-reviewer still satisfies the rule); reviewing directly, skipping effort=high." Calling high anyway — as actually happened — is exactly the miscalibration this skill catches: the fan-out mechanics were fine; nobody measured the 60 lines or read both policy levels.

---
*Origin: AIL — /code-review effort=high fan-out on a ~60-line diff (vector-graph-ontology, 2026-07-11); synthesized from 3 proposals + 2 adversarial judges, who themselves failed to reconcile the two conflicting policy docs.*
