---
name: AIL-caveman-docs
description: "Compression discipline for prose a future agent session will re-read — handoffs, guides, runbooks, READMEs, ADR/session notes, and inter-agent messages: strip filler via a load-bearing whitelist, gate by item preservation (never ratio), keep evidence verbatim. Use when drafting, extending, or shrinking such text — not only when explicitly asked to compress."
version: 0.5.0
metadata:
  provenance: AIL
---

# Caveman for Documents

Docs for agents are read many times but written once, so compression at write time compounds — but a dropped constant or verification directive silently corrupts every future session that trusts the doc. Gate by what survives, not how much shrinks.

## When to Use

- Drafting, extending, or shrinking prose a future agent session re-reads: handoffs, guides, runbooks, READMEs, ADR/session notes — while writing fresh, not only when compression is asked for.
- Reducing token cost of a doc corpus; retrofit a section when already editing it (no mass-rewrite campaigns).
- Structuring a handoff corpus (index/topic split) → `AIL-handoff-topic-index`; this skill owns only word-level compression within.

**Skip for**: user-authored files (never touch unprompted — but an explicit request to tidy their own file is consent: comply, snapshot first, report what changed); historical point-in-time records (annotate, don't rewrite); code, quoted errors, data tables (verbatim by definition). Conversation terseness is the base `caveman` skill.

## Procedure

Steps 1–2 apply to all writing (new prose and edits); 3–4 additionally govern compressing existing text; messages follow the Agent-to-Agent (A2A) profile below.

1. **Strip only filler; keep the whitelist verbatim.** Filler dies: hedging, pleasantries, duplicate restatement, decorative adjectives. These survive unchanged: constants, numbers, units, dates, URLs, `file:line` citations, identifiers, inline commands, ordering constraints, judgment/verification criteria, do-NOT warnings, event/flag names. Gate the diff by item preservation, never a ratio target — any whitelist item changed, ambiguity introduced, or a reader who would act differently → relax that spot to the original.
2. **Keep sentences whole.** Docs lack conversational context; a fragment ("confirm panel stays open" — which panel? open after what?) outlives the session as ambiguity. Compress to the shortest complete sentence, not a fragment.
3. **Snapshot before irreversible compression.** Compress only version-controlled text, or copy the original first — an untracked file compressed in place has no baseline to prove nothing was lost.
4. **Don't force low-yield docs.** Load-bearing reference prose yields ~5–10%; only marketing-ish narrative yields 20%+. Little filler → declare "already dense, unchanged" rather than trade correctness for single-digit savings. An explicit user-accepted lossy cut ("cut 50%, I accept losses") overrides: comply, but snapshot first and return the item diff as what was dropped.

## Agent-to-Agent (A2A) Messages

Same whitelist, different profile — messages are read few times, but their evidence sections are the diagnostics.

- **Directives, status, acks**: full caveman — fragments OK, drop articles and filler, whitelist items still verbatim. Parse-friendly markers (`[A]/[B]`, `verdict: PASS`, key: value); box art, banners, progress bars are token waste between agents.
- **Report framing** (restating the instruction, transitions, pleasantries): compress away.
- **Evidence and verdict rationale: verbatim, never compressed** — outranks any report length cap. Reversals are caught only because verbose evidence exposed a stale run, a tool bug, or a false claim; compressed evidence deletes that trail.
- Subagent scope discipline → `efficient-subagent`; report delivery / re-verification mechanics → `organize-agent-team` Team Runtime.

## Pitfalls

- **Compressing a report's evidence to hit a style rule** — the framing was the fat, the evidence was the muscle.
- **Rewriting history** — an audit snapshot's stale numbers are evidence of what was observed, not errors to fix.
- **Mistaking cross-document duplication for filler** — a fact stated more precisely elsewhere is a second source that will drift; link to the original (`write-a-rule`'s "one rule, one home") instead of compressing the restatement.

## Verification

- [ ] Item-preservation diff run old→new (every whitelist item unchanged, no reader would act differently) — not a ratio check?

## Example

A team compresses a regression-prevention guide and a handoff. Dense sections yield only 7.9% — reported as structural, not failure; all level-of-detail thresholds, stage constants, and "verify by replaying real drag events both directions" directives survive the item gate. A scratch review file compresses 25% but is untracked: its "lossless" claim is ruled unverifiable, no baseline to diff. In the same team's messaging, three judgment reversals were caught only because evidence stayed verbatim.

---
*Origin: AIL — doc-maintenance team (2026-07-13): measured 7.9% vs 25% compression by filler density; an adversarial reviewer proved an untracked file's lossless claim unverifiable; three judgment reversals in team messaging were caught only via uncompressed evidence sections.*
