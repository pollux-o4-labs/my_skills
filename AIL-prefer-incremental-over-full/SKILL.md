---
name: AIL-prefer-incremental-over-full
description: "Checks whether the codebase already declares a cheaper, targeted/incremental path before defaulting to an obviously-named bulk operation (full rebuild/reindex/reprocess/migration/resync). Use before running or recommending a large-scope operation when separate tooling, docstrings, comments, or policy docs already describe a delta/incremental alternative for the same goal; do not use when no incremental path exists, there's no valid checkpoint to diff from, or the full operation is genuinely the only way to reach the goal."
version: 0.1.0
metadata:
  platforms: [claude-code]
  provenance: AI-generated from session lessons (vector-graph-ontology, 2026-07-11)
---

<!-- TODO(추상화 미완): 초안이 이번 세션 사례(watermark/graph-build vs update)에 여전히 밀착돼 있음.
     "전체 재처리 vs 이미 선언된 증분 경로"라는 일반 패턴으로 한 단계 더 뽑아내는 후속 작업 필요 —
     다른 도메인(DB 마이그레이션, 캐시 워밍, ETL 등) 사례로 리플레이해서 절차·함정 문구가
     여전히 들어맞는지 검증하고 다듬을 것. 지금은 replay 1건(이번 세션)만 통과한 상태. -->

# Prefer Incremental Over Full

When a status check reports something stale or incomplete, the reflex is to reach for the command whose *name* best matches the goal ("build" the graph, "reindex" the corpus). But many systems deliberately split "build everything from scratch" and "catch up just the delta" into two different operations. Picking the full one by name-association, without checking whether the incremental one already applies, burns real cost (time, tokens, API calls) reprocessing work that was already correct.

## When to Use

- You're about to run or recommend a large-scope operation (full rebuild, full reindex, full reprocess, migration, resync) to fix something reported as stale/incomplete/out-of-date.
- The codebase has more than one operation touching the same data (e.g. an initial-build command and a sync/update/delta command) and you haven't checked which one is designed for this situation.
- You're about to execute a recommendation inherited from a prior session, handoff note, or teammate — even one that sounds authoritative — without re-deriving it against current code.

**Do NOT use when:**
- No incremental path exists for this operation — the full run is the only option.
- There's no valid prior checkpoint to diff from (first build, or the checkpoint itself is corrupt/missing) — incremental has nothing to anchor to.
- The operation is already cheap/small enough that the distinction doesn't matter.

## Procedure

1. **Before picking a command, ask: is there a second way to reach this goal that processes only the delta?** Grep the module implementing the operation, its `--help`/usage text, and adjacent policy docs (ADRs, CONTRIBUTING, project instructions) for words like *incremental, delta, since, sync, partial, update* — not just the operation whose name matches your goal word.
2. **Read the docstring/comment of the operation you're about to run, not just its name.** A name like "build" often describes what the tool is *capable* of (building from scratch), not what's *appropriate* right now. Implementers frequently already documented the full-vs-incremental boundary in a comment sitting right next to the code.
3. **If an incremental path exists, confirm it actually applies** — there must be a real prior checkpoint/watermark to diff from. If so, that's almost always cheaper and the intended path; use it instead of full.
4. **Treat a stale bookkeeping pointer (watermark, last-synced marker) as "there's a delta to process," not "the underlying data is wrong."** Staleness in the tracking metadata does not imply the previously-built data needs to be redone — only that recent changes haven't been folded in yet.
5. **Don't trust an inherited recommendation just because it sounds already-investigated.** If a handoff note, prior session, or teammate says "run the full X," re-check that against the current code/docs yourself before executing — a plausible-sounding sequence is not proof the incremental alternative was considered.
6. **If you find a dead giveaway that this exact mistake was anticipated** (a stale comment naming the correct incremental command, an unwired confirmation flag, a TODO) **— don't just note it and move on.** Wire it into an enforced guard (the operation refuses to run full-scope without explicit confirmation, and prints the incremental command) so the next person or agent can't repeat the mistake by not noticing the comment.

## Pitfalls

- **Name-matching bias.** Reaching for the command whose name echoes the goal word ("build" because the graph needs to be "built") instead of the command whose semantics match the situation (a delta since a known checkpoint).
- **Trusting inherited recommendations.** Copying a "known good" sequence from a handoff note or prior session without re-verifying it against current code — the note itself can be the source of the mistake.
- **Confusing bookkeeping staleness with data corruption.** A stale watermark/pointer means more delta needs folding in, not that existing data is broken and must be rebuilt.
- **Soft reminders that don't fire at the decision point.** A written policy elsewhere (project instructions, an ADR) doesn't help if it isn't surfaced where the choice is actually made (e.g., in the status/error output itself). Prefer a runtime guard over a doc nobody re-reads mid-task.
- **Finding the note but not enforcing it.** Spotting a comment or dead flag that already names the right answer, and treating that discovery as the fix — instead of turning it into code that blocks the wrong path.

## Verification

- [ ] Did I check whether the codebase already has an incremental/delta/targeted alternative to the full operation I'm about to run?
- [ ] Did I read the actual docstring/comment of the operation, not just infer intent from its name?
- [ ] If a prior recommendation or handoff note pointed at the full operation, did I re-derive that choice against current code/docs myself?
- [ ] Is there a valid checkpoint to diff from — does incremental actually apply here, or is full genuinely required?
- [ ] If I found a stale comment/dead flag already describing the correct incremental path, did I wire it into an enforced guard rather than just noting it?

---
*Provenance: distilled from a session where an inherited handoff recommendation to "run the full rebuild" was carried forward unverified across two agent sessions, triggering a multi-hour full reprocessing of an entire corpus via a real paid backend — when a purpose-built incremental command (already documented in the target module's own docstring, and referenced by a dead, unwired confirmation flag in the full command's own code) would have processed only the actual delta in minutes. Caught only when the user asked why already-built content was being rebuilt from scratch.*
