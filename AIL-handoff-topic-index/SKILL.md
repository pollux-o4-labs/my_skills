---
name: AIL-handoff-topic-index
description: "Structures session or project handoff as a directory of per-topic detail files fronted by one list-format index — each entry item, description, status; a list, not a table. Every topic file gets exactly one index line, and unlisted means forgotten; update by splicing one topic file plus its index line, never rewriting the whole. Use when writing or organizing handoff/continuity docs, splitting a growing monolithic handoff by topic, or setting a project's handoff convention. Distinct from the `handoff` skill (one-shot conversation compaction); this governs a standing, accreting handoff corpus."
version: 1.0.0
metadata:
  provenance: AIL
  platforms: [claude-code, codex, gemini-cli]
---

# Structured Handoff: Topic Files + List Index

Handoff survives across sessions only if it is organized so nothing is silently dropped. The anti-forgetting device is **not the splitting — it is the index enumeration.**

## When to Use

- Writing or organizing handoff / continuity docs meant to outlive one session.
- A single handoff file is growing and should be split by topic.
- Setting a project's handoff convention.

**Do NOT use** for compacting one conversation into a single throwaway document — that is the plain `handoff` skill.

## Procedure

1. **Dedicated directory, not a monolith.** Handoff lives in one folder (name it per project, e.g. `docs/handoff/`), one detail file per **topic** — not per session, not per atomic fact. Topic slug = a short content summary.
2. **Index is a list.** The index (e.g. `README.md`) lists every topic, each entry being **item · one-line description (BLUF) · status** (freshness date or state). A list, not a table — a table is heavier than the job needs.
3. **Unlisted = forgotten.** Every topic file must carry its one index line. A file absent from the index will be lost.
4. **Splice, don't rewrite.** On update, touch only the affected topic file and its single index line — never rewrite the whole index or fold topics together.

> Example index line: `- graph-rollup — hierarchical rollup design; P1–P3 done, Phase 4 next — updated 2026-07-08`

## Pitfalls

- **Splitting without an index.** The enumeration prevents forgetting, not the split itself; topic files with no index line vanish.
- **Table instead of list.** Keep the handoff index a list (item / description / status); reserve tables for dense feature matrices, not handoff.
- **Over-splitting.** Topic-level granularity; atomic per-fact files fragment and multiply.
- **Rewriting the index wholesale on each update.** Splice the single affected line.

## Verification

- [ ] Do handoff docs live in a dedicated directory, one file per topic?
- [ ] Is the index a list (item · description · status), not a table?
- [ ] Does every topic file have exactly one index line?
- [ ] On update, did I splice only the affected file + its one line, not rewrite the whole?
- [ ] Is granularity topic-level (not per-session, not atomic)?

---
*Origin: a session that split a monolithic handoff into per-topic files fronted by a list index; the recurring lesson was that the index enumeration — not the act of splitting — is what keeps topic files from being forgotten.*
