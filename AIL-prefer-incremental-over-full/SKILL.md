---
name: AIL-prefer-incremental-over-full
description: "Checks whether the system already declares a cheaper incremental or delta path before defaulting to an obviously-named bulk operation (full rebuild, reindex, reprocess, resync). Use before running or recommending a large-scope operation to fix something reported stale or incomplete, especially when acting on an inherited recommendation (handoff note, runbook, teammate)."
version: 1.1.0
metadata:
  platforms: [claude-code]
  provenance: AIL
---

# Prefer Incremental Over Full

When a status check reports something stale, the reflex is the operation whose *name* matches the goal ("build" the graph, "reindex" the corpus) or that precedent suggests. But many systems deliberately split "rebuild from scratch" and "catch up the delta" into two paths. Picking full by association burns real cost redoing correct work — and is often destructive, discarding state incremental would preserve.

## When to Use

- About to run or recommend a large-scope operation (full rebuild/reindex/reprocess/resync) to fix something reported stale or incomplete.
- The system has both a from-scratch path and a delta/sync path over the same data — separate commands or flags of one command — and you haven't checked which fits this situation.
- About to execute a large-scope recommendation inherited from a prior session, handoff note, runbook/wiki page, or teammate without re-deriving it against current code.

**Do NOT use when**: no incremental path exists; there's no valid checkpoint to diff from (first build, or the checkpoint is corrupt/missing); the transformation logic itself changed (analyzer/schema/parser version) — incremental catches up new *inputs*, not outputs whose rule changed, so full is required there; or the operation is cheap enough that the distinction doesn't matter.

## Procedure

1. **Ask for the second path first.** Search the implementing code, its help text or docstrings, and adjacent docs (runbooks, ADRs, project instructions) for *incremental, delta, since, sync, partial, update* — not just the operation whose name matches your goal word.
2. **Read the docstring/comment, not just the name.** "Build" describes what the tool is *capable* of (from scratch), not what's appropriate now; the boundary is often documented right next to the code (e.g. Django schema drift: `reset_db`'s own docstring says drift is `migrate`'s job).
3. **Confirm the incremental path applies — three checks**: a prior checkpoint exists (watermark, migration-state table, sync cursor); the delta source (change-feed, log, journal) still covers the interval since it; the processing logic/version is unchanged since the last full run — the operation's own docs ("not sufficient after X") override checkpoint freshness. All three hold → use it.
4. **A staleness signal means "delta to process," not "prior work invalid"** — unless the staleness is relative to a logic/schema version, where prior outputs really are invalid (see skip conditions).
5. **Re-derive inherited recommendations.** "Run the full X" — or "the delta is enough" — from a handoff, runbook, or teammate is a claim, not proof the alternative was considered; check it (and the doc's last-edited date) against current code yourself before executing.
6. **Turn anticipated-mistake artifacts into enforcement.** A stale comment naming the right command, an unwired confirmation flag, an outdated runbook: where in scope, wire a guard (full path refuses without explicit confirmation, prints the incremental command) and correct the stale doc; if out of scope (shared production tooling, mid-incident), propose it explicitly instead of silently noting it.

## Pitfalls

- **Name- or precedent-matching bias** — the name echoes the goal word, or "we did it last time," but its semantics don't match a delta-since-checkpoint situation.
- **Misreading the staleness signal in either direction** — input-lag staleness means more delta to fold in, not broken data; version-relative staleness means broken outputs, not mere lag.
- **Soft reminders that don't fire at the decision point** — a policy doc nobody re-reads mid-task loses to a runtime guard in the status/error output itself.

## Verification

- [ ] Does the chosen operation's scope match the size of the actual delta, not the operation's name?
- [ ] Is no valid prior state or checkpoint discarded by the chosen path?
- [ ] If full was chosen, is the specific skip condition that holds (no checkpoint / gap uncovered / logic changed) stated, not assumed?
- [ ] Was any inherited recommendation confirmed against current code before execution?
- [ ] Were artifacts that steered toward the wrong path fixed or explicitly escalated?

---
*Origin: an inherited "run the full rebuild" recommendation, carried unverified across two sessions, reprocessed an entire corpus for hours on a paid backend — while an incremental command documented in the target module's own docstring would have processed the delta in minutes (vector-graph-ontology, 2026-07-11).*
