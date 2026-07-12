---
name: AIL-prefer-incremental-over-full
description: "Checks whether the codebase already declares a cheaper incremental or targeted path before defaulting to an obviously-named bulk operation (full rebuild, reindex, reprocess, migration, resync). Use before running or recommending a large-scope operation to fix something reported stale or incomplete, especially when acting on an inherited recommendation."
version: 0.2.0
metadata:
  platforms: [claude-code]
  provenance: AIL
---

<!-- TODO(abstraction): draft still hews to its origin case (watermark/graph-build vs update). Replay against
     other domains (DB migration, cache warming, ETL) and generalize wording; only 1 replay passed so far. -->

# Prefer Incremental Over Full

When a status check reports something stale, the reflex is the command whose *name* matches the goal ("build" the graph, "reindex" the corpus). But many systems deliberately split "build everything from scratch" and "catch up just the delta" into two operations. Picking the full one by name-association burns real cost (time, tokens, API calls) reprocessing work that was already correct.

## When to Use

- About to run or recommend a large-scope operation (full rebuild/reindex/reprocess/migration/resync) to fix something reported stale or incomplete.
- The codebase has more than one operation touching the same data (an initial-build command and a sync/update/delta command) and you haven't checked which one is designed for this situation.
- About to execute a recommendation inherited from a prior session, handoff note, or teammate — even one that sounds authoritative — without re-deriving it against current code.

**Do NOT use when**: no incremental path exists; there's no valid checkpoint to diff from (first build, or the checkpoint is corrupt/missing); the operation is cheap enough that the distinction doesn't matter.

## Procedure

1. **Ask for the second path first.** Grep the implementing module, its `--help`/usage text, and adjacent policy docs (ADRs, project instructions) for *incremental, delta, since, sync, partial, update* — not just the operation whose name matches your goal word.
2. **Read the docstring/comment, not just the name.** "Build" describes what the tool is *capable* of (from scratch), not what's appropriate now; the full-vs-incremental boundary is often documented right next to the code.
3. **Confirm the incremental path applies** — a real prior checkpoint/watermark must exist. If so, it's almost always the cheaper, intended path; use it instead of full.
4. **Treat a stale bookkeeping pointer as "there's a delta to process," not "the data is wrong."** Staleness in tracking metadata does not imply the previously-built data must be redone.
5. **Re-derive inherited recommendations.** "Run the full X" from a handoff or teammate is a claim, not proof the incremental alternative was considered — check it against current code/docs yourself before executing.
6. **If the mistake was anticipated in-code** (a stale comment naming the right incremental command, an unwired confirmation flag, a TODO), **wire it into an enforced guard** — the operation refuses to run full-scope without explicit confirmation and prints the incremental command — instead of just noting the discovery.

## Pitfalls

- **Name-matching bias** — the command name echoes the goal word while its semantics don't match the situation (a delta since a known checkpoint).
- **Trusting inherited recommendations** — the handoff note itself can be the source of the mistake.
- **Confusing bookkeeping staleness with data corruption** — a stale watermark means more delta to fold in, not broken data.
- **Soft reminders that don't fire at the decision point** — a policy doc nobody re-reads mid-task loses to a runtime guard in the status/error output itself.
- **Finding the note but not enforcing it** — discovery is not the fix; code that blocks the wrong path is.

## Verification

- [ ] Checked for an incremental/delta/targeted alternative before running the full operation?
- [ ] Read the operation's docstring/comment, not just inferred intent from its name?
- [ ] Re-derived any inherited recommendation against current code/docs myself?
- [ ] Confirmed a valid checkpoint exists — does incremental actually apply, or is full genuinely required?
- [ ] Wired any discovered stale-comment/dead-flag giveaway into an enforced guard rather than just noting it?

---
*Provenance: an inherited "run the full rebuild" recommendation, carried unverified across two sessions, triggered multi-hour paid reprocessing of an entire corpus — when an incremental command, documented in the target module's own docstring, would have processed the actual delta in minutes (vector-graph-ontology, 2026-07-11).*
