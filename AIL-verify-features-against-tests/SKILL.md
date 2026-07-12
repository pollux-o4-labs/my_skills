---
name: AIL-verify-features-against-tests
description: "Verifies a codebase's features are genuinely tested rather than merely green — enumerate features in one index, write per-feature must-hold and must-not invariants, map each to the test that exercises it, and reproduce the suite before trusting it. Use when auditing test coverage, building a feature or verification spec, hunting edge cases, or before citing a green suite as proof a feature works."
version: 1.1.0
metadata:
  provenance: AIL
  platforms: [claude-code, codex, gemini-cli]
---

# Verify Features Against Tests

A green suite certifies the paths its fixtures exercise — **not** that a feature's invariants hold. Turn "is it tested?" into an audit that ties every feature invariant to a real test and refuses to trust green blindly.

## When to Use

- You're about to claim a feature is correct or covered because the suite is green.
- You're auditing test coverage, or writing a feature / verification spec.
- You're hunting edge cases or hardening a codebase.

**Do NOT use** for a one-off test run with no coverage claim, or a plain bug that already reproduces in the suite (just fix it). For post-hoc "fix looks right but reality is unchanged" checks, use `AIL-verify-against-reality` — this skill is its proactive counterpart.

## Procedure

1. **Feature index first.** Enumerate every feature in one thin index (name, entry point, status). Features scattered across milestones, commits, and handoffs are invisible; the enumeration is what makes coverage auditable and prevents duplication.
2. **Per feature, write invariants in both directions.** ✔️ **must-hold** = what it must do; ⛔ **must-not** = what must never happen. The must-not list is where edge cases live — derive them from the **usage flow**, not from reading the code (code anchors you to what it does, not to what it must never do).
3. **Map each invariant to the actual test.** Tag every ✔️/⛔ with the specific `test_file::function` that verifies it. An invariant with no test tag is a **coverage gap = first-class defect candidate**, not a footnote.
4. **Do not over-trust green — reproduce and interrogate the suite.** Run the tests yourself; judge by the real exit code in the correct shell (pipes or `;` can mask it). Confirm the fixtures actually **instantiate the invariant's precondition** — an invariant about N>1 (multi-item, mixed, heterogeneous) proven only by single-instance fixtures is unproven. Confirm nothing is **excluded from the run you trusted** — marker/config-gated tests (DB, GPU, integration) drop out of the default run and rot red unseen while it stays green.
5. **Convert gaps to confirmed defects.** For each ⛔ with no test, or invariant whose fixtures never instantiate the failing condition, reproduce the failure in isolation before declaring it. A prose "confirmed" without a reproduction is still a claim.

> Example: feature *incremental update*, invariant ⛔ "must not delete unchanged items' data" → tagged `[⚠️ no test]` because every fixture used a single item; reproduced in isolation with two items → confirmed data loss. The green suite never covered it.

## Pitfalls

- **Green = exercised paths, not invariants.** Two silent killers: single-instance fixtures (miss the multi-instance failure) and marker-gated exclusion (stale tests rot unseen; a schema/API change quietly breaks them).
- **Untested must-not is the finding.** Don't let a stated ⛔ sit without a test citation; that gap *is* the defect candidate.
- **Self-reported test results.** Reproduce yourself — a subagent's report or your own recollection of "passed" is not evidence.
- **Reading code to find edge cases.** Derive must-not from the usage flow; code reading biases you toward implemented behavior and hides the missing cases.

## Verification

- [ ] Is every feature enumerated in one index?
- [ ] Does each feature carry ✔️ must-hold and ⛔ must-not derived from the usage flow?
- [ ] Is each invariant tagged with a real `test::function`, or explicitly flagged as a gap?
- [ ] Did I reproduce the suite myself (real exit code), not trust a report?
- [ ] Did I confirm fixtures instantiate multi-instance / edge preconditions, and check for marker/config-excluded tests dropping out of the default run?
- [ ] Did I reproduce each gap in isolation before calling it a defect?

---
*Origin: a session building a feature-index doc for a hybrid-RAG codebase — mapping each feature's must-not invariants to tests surfaced a data-loss bug (incremental update deleted unchanged documents, hidden behind single-document fixtures) and a stale test rotting behind a marker gate, neither caught by the green default suite.*
