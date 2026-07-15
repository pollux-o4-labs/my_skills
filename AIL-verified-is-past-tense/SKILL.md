---
name: AIL-verified-is-past-tense
description: "A document's status field (tests green, reviewer blockers, review complete) records a check you personally ran and watched succeed — never the expected, scheduled, or templated value written ahead of the actual event. Use when filling in a status/state line in a handoff, ADR, or ledger, especially one copied from a sibling entry or written before the check it names has actually run."
version: 1.0.0
metadata:
  provenance: AIL
---

# Verified Is Past Tense

A status field ("tests: green", "reviewer: 0 blockers", "review: done") claims a specific check already happened and you watched it happen. Writing that value before the check runs — because it's the expected outcome, the next scheduled step, or copied from a template — turns the field from a record into a forecast. The next reader can't tell the difference; they trust the field and skip the check themselves.

## When to Use

- Filling in a status/state field in a handoff, ADR, or ledger that names a specific verification event (tests passed, reviewer signed off, reproduction confirmed).
- The field is templated from a sibling entry, or from a plan that already states what the value will be once the step runs.
- About to write a status update before running the command/review it describes — "I'll run it right after" is the moment this fires.

**Do NOT use for**: a plan or next-step sentence about future work — that's meant to be prospective, not a status field. A status field updated immediately after directly observing the event — that's the correct order. General confidence-calibration for an inferred conclusion (→ `AIL-calibrate-verification-depth`). A reader deciding whether to trust someone else's report (→ `AIL-verify-features-against-tests`, "self-reported test results") — this skill is the writer's discipline, not the reader's.

## Procedure

1. **Run it, then write it.** Never write the value first. If the check hasn't executed yet, the field stays blank, `pending`, or `not yet run` — never the anticipated pass value.
2. **Watch the copied template.** A field templated from a sibling entry inherits that entry's value unless explicitly overwritten — check every copied field against what you actually did, not what the template said.
3. **Separate the plan sentence from the record sentence.** "Next: supervisor reproduces and merges" is a plan (future tense, fine to write ahead). "Supervisor reproduced: green" is a record — write it only after you did that and saw the result.
4. **State what you observed, not what you expect.** A partial check (one test file, not the suite) gets recorded as partial — not rounded up to "tests: green."

## Pitfalls

- **Tense slip from plan to record** — a line drafted as "will be green after the next run" gets tightened to "green" for brevity, and the qualifier that made it honest disappears.
- **Template inheritance** — copying a finished entry's shape for a new one carries over its `done`/`green` values unless each is individually re-earned.
- **Writing ahead of someone else's step** — filling in a field that names another person's or role's not-yet-taken action (e.g. "supervisor reproduced: green") pre-commits an outcome you don't control and haven't seen.

## Verification

- [ ] Did I personally run or observe the specific event this field claims, before writing it?
- [ ] Any copied/templated field re-earned, not inherited from its source?
- [ ] Is a plan sentence (future) kept separate from a record sentence (past), with no blending?
- [ ] Does the field state what was actually observed (partial vs. full), not a rounded-up claim?

## Example

A handoff note and an ADR status line both read as if a supervisor's reproduction check and a code adversarial review had already completed — "감독 재현: green", "코드 적대리뷰: 통과." Neither had actually run yet; both were the next scheduled steps, written into the record early. A downstream reviewer caught it by looking for the review artifact the line implied should exist, and found none.

---
*Origin: a handoff doc and an ADR status line both recorded a supervisor reproduction check and a code adversarial review as complete before either had actually run — caught by a reviewer who looked for the artifact the claim implied and found none (2026-07-15).*
