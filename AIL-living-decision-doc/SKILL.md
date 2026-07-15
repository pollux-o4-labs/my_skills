---
name: AIL-living-decision-doc
description: "Keeps a living decision doc during a long multi-turn task — recording each confirmed decision the moment it lands, with its why and its concrete form, and graduating settled items into the permanent docs. Use when a single task runs long with decisions accruing, when the user confirms decisions mid-flow (\"ok this way, next\"), or asks to write things down so intent isn't lost."
version: 1.2.0
metadata:
  provenance: AIL
---

# Living Decision Doc

When one task stretches across many turns, **decisions accumulate faster than memory keeps them — and the conversation's own length dilutes the original intent.** "We decided X" survives; *why* X and the concrete shape of X evaporate. Weeks later, "fix it back to the original idea" has no original to return to. The fix is a living decision doc, updated at each confirmed step — not written up at the end.

## When to Use

- A **single task** runs long with decisions accruing through iteration (design, spec, UX flow, schema, API shape) and no durable record yet.
- The user **confirms a decision mid-flow** ("ok, this way — next") and the conversation is about to ping-pong onward.
- The user says to **write it down / stop losing intent / not let the original goal dilute**.
- A decision just took a **concrete form worth pinning** — its actual shape in the domain, not just a one-line gist.

**Do not fire** for: a short task settled in a couple of turns; throwaway exploration; recording that belongs in code comments or a commit message. If the project already has a live doc for this task, update that — don't spawn a parallel one.

## Procedure

1. **Ground before structuring.** Read the project's existing decision/design records (ADR log, design system, spec, handoff) and match their format and home — do not invent a new structure or location (see [[AIL-ground-before-structuring]]). A doc that ignores repo conventions never gets absorbed.
2. **Create it when the conversation crosses the threshold — not at the end.** Several decisions deep with nothing written is the signal; propose it now, so mid-flow confirmations get caught.
3. **Structure for full state, not just a decision list**:
   - Confirmed decisions — choice + **why** + source link + conflict flag ("contradicts spec §X → revision needed")
   - **Concrete form** — the decision's actual shape in the domain's own terms (UI: layout/dimensions, where each animation fires, state model, copy; API: signatures + error shape; schema: field types/constraints; process: the exact ordered steps). "We decided to use a modal" preserves nothing; the modal's trigger, size, and dismissal *are* the decision.
   - Open questions (with the leading proposal) · gaps found while building · upstream-doc revisions needed
4. **Update at each confirm, before the next ping-pong** — capture the intent/why, not just the outcome; the why is what the long conversation is about to bury.
5. **Record in-flux state too.** "Not finalized yet" is not a reason to omit — log a **snapshot + why this choice** (explicitly not locked), so a later "fix it to the original" has an anchor.
6. **Absorb on finalize by removing the duplicate.** Move locked items to their permanent home (ADR / design system / spec) and delete them from the living doc (a one-line pointer at most). No "absorbed ✓ (date)" stamps — version control already holds the what/when/why, and the stamp leaves the duplicate in place to drift. The living doc is a staging area, not a permanent parallel source.

## Pitfalls

- **Deferring the write** ("I'll document it later") — by later, the *why* is gone; the long conversation buried it.
- **Recording only verbal decisions, omitting the concrete form** because "it's still changing" — that in-flux shape is exactly the intent that dilutes. *(The origin session made this omission: decisions + rationale were logged, the layout/animation left out as "in flux.")*
- **Two permanent sources / stamp ceremony** — a finalized item left in full in both places drifts apart; delete the duplicate, don't decorate it with badges.
- **Inventing structure or location** — the doc reads as a foreign artifact and never gets absorbed.
- **Creating the doc at session end** — mid-flow confirmations were never captured; you reconstruct from diluted memory.
- **Over-documenting a short task** — the threshold is "long + accumulating + will be built on."

## Verification

- [ ] Existing decision/design docs read, and their format/home matched?
- [ ] Does the doc capture **why** and the **concrete form**, not just a decision list?
- [ ] In-flux state recorded as "snapshot + why," not omitted?
- [ ] Updated **at each confirmation**, before the next ping-pong?
- [ ] Conflicts with upstream docs (spec/PRD/design system) flagged?
- [ ] On finalize, duplicates deleted from the living doc (a pointer at most — no stamps; git is the history)?
