---
name: AIL-living-decision-doc
description: During a long multi-turn task where decisions pile up through back-and-forth, keep a living decision doc grounded in the project's existing doc conventions, and update it the moment each decision is confirmed — recording the choice, its why, AND its concrete form (the actual shape the decision takes in the domain's own terms — UI: layout/motion; API: signatures; schema: field types; process: the exact steps), not just the verbal gist. Record in-flux state too ("not final yet" is not a reason to omit — long conversations dilute original intent). Graduate settled items into the permanent docs (ADR / design system / spec) on finalize. Fires when a single task's conversation gets long, when the user confirms decisions mid-flow ("ok do it this way, next"), or asks to write things down so intent isn't lost.
version: 1.1.0
metadata:
  provenance: AIL
  platforms: [claude-code, codex, gemini-cli]
---

# Living Decision Doc

When one task stretches across many back-and-forth turns, **decisions accumulate faster than memory keeps them — and the conversation's own length dilutes the original intent.** "We decided X" survives; *why* X, and the concrete shape of X (layout, dimensions, where each animation fires, the interaction/state model), evaporate. Weeks later "let's fix it back to the original idea" has no original to return to. The fix is a living decision doc, updated at each confirmed step — not written up at the end.

## When to Use

- A **single task** runs long with decisions accruing through iteration (design, spec, UX flow, schema, API shape) and no durable record yet.
- The user **confirms a decision mid-flow** ("ok, this way — next") and the conversation is about to ping-pong onward.
- The user says to **write it down / stop losing intent / not let the original goal dilute**.
- A decision has a **concrete form** worth pinning down — its actual shape in the domain (layout/motion, an API signature, field types, the exact steps), not just a one-line gist.

**Do not fire** for: a short task settled in a couple of turns; throwaway exploration nobody will build on; recording that belongs in code comments or a commit message. Don't spin up a parallel doc when the project already has a live one for this task — update that.

## Procedure

1. **Ground before structuring.** Before creating the doc, read the project's existing decision/design records (ADR log, design-system doc, spec/PRD, handoff) to match their format and pick the right *home* — do not invent a new structure or location. (See [[AIL-ground-before-structuring]].) A living doc that ignores the repo's conventions won't get absorbed later.
2. **Create it when the conversation crosses the threshold — not at the end.** The point is to catch mid-flow confirmations, so the doc must exist *before* them. If you notice you're several decisions deep with nothing written, that's the signal — propose it now.
3. **Structure for full state, not just a decision list:**
   - **Confirmed decisions** — each = the choice + **why** + link to the source constraint/spec + any **conflict flag** (e.g. "contradicts spec §X → revision needed").
   - **Concrete form** — the actual shape each decision takes, in the domain's own terms (UI: layout/dimensions, where each animation fires + its transition, state model, copy; API: signatures + error shape; schema: field types/constraints; process: the exact ordered steps). This is the part most easily skipped and most easily lost — "we decided to use a modal" preserves nothing; the modal's trigger, size, and dismissal *are* the decision.
   - **Open questions** — what still needs a decision, with the leading proposal.
   - **Gaps found** — missing values/holes surfaced while building (e.g. tokens the design system never defined).
   - **Upstream-doc revisions needed** — what must change in the permanent docs once confirmed.
4. **Update at each confirm, before moving on.** When the user says "ok, do it this way, next," write it to the doc *before* the next ping-pong — not "later." Capture the **intent/why**, not just the outcome; the why is what the long conversation is about to bury.
5. **Record in-flux state too.** "Not finalized yet" is *not* a reason to omit — that's the reasoning that loses intent in a long session. Log it as a **snapshot + why this choice** (explicitly not a locked decision), so a later "fix it to the original" has something to anchor to.
6. **Absorb on finalize — by removing the duplicate, not stamping it.** When an item locks, move it into its permanent home (ADR / design system / spec) and **delete it from the living doc** (or reduce it to a one-line pointer to where the truth now lives). Do **not** leave "absorbed ✓ (date)" markers — version control already records what moved, when, and why; a completion stamp is pure ceremony *and* leaves the duplicate in place. The living doc is a **staging area, not a permanent parallel source**: the whole point of touching it on absorption is to eliminate the second copy (drift), so what remains is only open questions and not-yet-absorbed in-flux notes.

## Pitfalls (real)

- **Deferring the write** ("I'll document it later"). By "later" the *why* is gone; the long conversation buried it. Write at the moment of confirmation.
- **Recording only verbal decisions, omitting the concrete form** — the decision's actual shape (whatever its substance: layout/motion, an API signature, field types, the exact steps) — because "it's still changing." That in-flux shape is exactly the intent that dilutes — snapshot it with rationale. *(This skill exists because that omission was made and corrected in its origin session: only decisions + rationale were logged, and the layout/animation was left out as "still in flux.")*
- **Two permanent sources.** A finalized item left in full in both the living doc and its permanent home → they drift apart. On absorption, delete the duplicate; keep at most a pointer.
- **Absorbed-stamp ceremony.** Annotating the living doc with "absorbed ✓ (date)" badges *instead of* removing the duplicated content. Version control already holds the what/when/why — the stamp adds nothing and the duplicate still drifts. Delete, don't decorate.
- **Inventing structure/location** instead of matching the project's existing decision/design docs → the doc never gets absorbed and reads as a foreign artifact.
- **Creating the doc at session end** → mid-flow confirmations were never captured; you reconstruct from a diluted memory.
- **Over-documenting** a short task → churn with no payoff. Threshold is "long + accumulating + will be built on."

## Verification

- [ ] Did I read the project's existing decision/design docs and match their format/home before creating the doc?
- [ ] Does the doc capture **why** and the **concrete snapshot** (layout/animation/state), not just a decision list?
- [ ] Is in-flux state recorded as "snapshot + why" rather than omitted?
- [ ] Did I update it **at each confirmation**, before the next ping-pong?
- [ ] Are conflicts with upstream docs (spec/PRD/design system) flagged?
- [ ] On finalize, did I move items to their permanent home and **delete the duplicate** from the living doc (a pointer at most — no "absorbed"/date stamps; git is the history)?
