---
name: AIL-approval-expires
description: "A record that the user approved or directed an action in the past — a handoff note, an earlier turn, a prior session — is history, not standing consent to do it now. Use before a hard-to-reverse or outward-facing step whose only justification is something written or said earlier, not something the user just said."
version: 1.1.0
metadata:
  provenance: AIL
---

# Approval Expires

A handoff note or an earlier turn saying "user directed X" is evidence about the past, not a substitute for asking now. Treating a recorded directive as freshly issued the instant you notice it skips the one check only the user can pass: do they still want this, here, today.

## When to Use

- About to take a hard-to-reverse or outward-facing action (merge, delete, force-push, publish, send, pay) and the only "go-ahead" on hand is a line in a handoff doc, rules file, or an earlier turn — not something the user just said.
- About to tell a teammate or subagent "we're cleared to do X," citing a document instead of the live conversation.
- A prior instruction and a more recent user statement could conflict — the newer one wins even when it looks more general than the specific-sounding record (e.g. "review the branch that lands next," said after a handoff note naming a specific PR).

**Do NOT use for**: a directive the user restated or reconfirmed in the current conversation — that is live consent, needing no re-ask. Durably authorized standing policies the user set up to run without a fresh ask each time (a CI gate, a post-merge hook, an ADR-approved automation). Low-stakes, reversible actions where re-confirming is pure overhead. Choosing the right technique for an inherited bulk operation (full vs delta) → `AIL-prefer-incremental-over-full`; this skill governs whether you're still authorized to act at all, not which command. Judging whether code/build state is stale (→ `AIL-verify-against-reality`); calibrating how deep to verify a general inferred conclusion (→ `AIL-calibrate-verification-depth`).

## Procedure

1. **Classify the action.** Hard-to-reverse or outward-facing → a record never suffices alone. Reversible and internal → proceed; re-asking would be friction, not diligence.
2. **Name the source of the go-ahead.** User, in *this* conversation — or a citation from a doc, earlier turn, or prior session? A citation is a record, not consent.
3. **Check for a more recent signal that might supersede it.** A separate, newer user statement can reverse an old directive — recency wins even when the newer statement looks more general than the specific-sounding record. If the two could conflict, surface it — don't quietly pick the more convenient one.
4. **State the delta and ask — one line, then wait.** "The handoff says [prior instruction]. Should I still do this now?" If the user has a durable standing instruction that covers this, proceed instead of asking — but note the delta so the skipped check stays visible: "Merging per your standing instruction — skipping the usual re-ask."
5. **Confirm before handing a record-sourced directive to a teammate.** Passing it downstream unconfirmed turns your assumption into their instruction, and the doubt never resurfaces.

## Pitfalls

- **Reading a past instruction in present tense** — "next session should merge PR #3," written sessions ago, gets executed as "merge it now," and the citation stands in for an ask that never happens.
- **A newer, more general statement overridden by an older, more specific-looking one** — the old citation wins by looking more targeted, not by being more current.
- **Compounding through delegation** — citing the record to a teammate propagates the assumption before anyone re-checks it.

## Verification

- [ ] The plan does not contain the record-sourced action as an already-approved step.

## Example

A handoff doc read "다음 세션 착수 1순위(사장 지시): PR #3 리뷰·머지." The supervisor announced it would merge on its own authority once the reviewer reported zero blockers. The user had never given that instruction, and had more recently said they would review the branch about to land personally. That newer statement was the current instruction, and it named a human review step the citation would have skipped.

---
*Origin: a supervisor session cited a handoff doc's record of a past directive as authorization to merge a PR on its own initiative; the user's reply was "내가 언제 pr3 머지하라고 함?" — no such instruction existed, and a separate, more recent user statement about reviewing that exact branch had already claimed the decision (2026-07-15).*
