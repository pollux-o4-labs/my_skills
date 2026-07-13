---
name: AIL-caveman-docs
description: "Compression discipline for agent-read documents (handoffs, guides, runbooks): strip filler at write time, preserve every load-bearing element via a whitelist, and gate by item-preservation check — never by compression ratio. Use when writing or editing docs that agents will re-read across sessions, or when asked to shrink a doc corpus to cut token spend."
version: 0.1.0
metadata:
  platforms: [claude-code]
  provenance: AIL
---

# Caveman for Documents

Docs written for agents are **read many times but written once** — savings compound as `rate × future reads`, so compression at write time is almost always worth it. But document compression fails differently from chat compression: a dropped constant or verification directive silently corrupts every future session that trusts the doc. The discipline is a whitelist and a preservation gate, not a style preference.

## When to Use

- Writing new prose into handoffs, regression guides, runbooks, ADR notes, session records — anything agents re-read.
- Asked to reduce token cost of an existing doc corpus.
- Retrofit opportunistically: compress a doc's section when already editing it (no mass-rewrite campaigns).

**Skip for**: user-authored files (never touch); historical point-in-time records (audit snapshots — rewriting history destroys evidence); code blocks, quoted errors, data tables (verbatim by definition). Conversation-response terseness is the base `caveman` skill, not this.

## Procedure

1. **Whitelist first.** These survive verbatim: constants, numbers, units, file paths, `file:line` citations, identifiers, judgment criteria ("pass when…"), verification directives ("must reproduce with…"), do-NOT warnings, event/flag names. Only filler dies: hedging, pleasantries, duplicate restatement, decorative adjectives, throat-clearing.
2. **Keep sentences whole.** Docs lack conversational context; fragments create ambiguity that outlives the session. Compress to the shortest *complete* sentence, not to fragments.
3. **Snapshot before irreversible compression.** Compress only version-controlled text, or commit/copy the original first. An untracked file compressed in place has no baseline — "nothing was lost" becomes unverifiable and unrecoverable.
4. **Gate by item preservation, not ratio.** Diff old→new as a checklist: every whitelist item present and unchanged? Ambiguity introduced anywhere? A future reader acts identically on both versions? Any failed item → relax that spot to the original.
5. **Expect low ratios on dense docs and don't force them.** Load-bearing reference prose yields ~5–10%; only marketing-ish narrative yields 20%+. If little filler exists, declare "already dense, unchanged" — forced compression past that point trades correctness for single-digit savings.

## Pitfalls

- **Ratio as target** — chasing a percentage strips judgment criteria dressed as "wordiness". The gate is the checklist, never the number.
- **Fragmenting handoff prose** — "패널 열림 유지 확인" (whose panel? after what?) reads three ways; the original sentence read one way.
- **Compressing the unversioned** — the loss is invisible at compression time and permanent afterward.
- **Rewriting history** — an audit snapshot's stale numbers are evidence of what was observed, not errors to fix; annotate, don't rewrite.
- **Touching user files** — a user's scratch note is theirs even when verbose.

## Verification

- [ ] Every constant, path, citation, criterion, and warning from the original present verbatim?
- [ ] Zero fragments where a complete sentence carried disambiguating context?
- [ ] Baseline recoverable (git history or explicit snapshot) before the write?
- [ ] Dense sections declared unchanged instead of force-compressed?

## Example

A maintenance team compresses a regression-prevention guide and a session handoff. Dense sections yield only 7.9% — correctly reported as structural, not failure; all LOD thresholds, stage constants, and "verify by replaying real drag events both directions" directives survive an item-by-item gate (verified independently by an adversarial reviewer). A separate scratch review file compresses 25% — but it was untracked, so the "lossless" claim was later ruled *unverifiable*: no baseline existed to diff against. Both lessons are this skill: gate by preservation, and never compress without a recoverable original.

---
*Origin: AIL — doc-maintenance team (prompt-gen, 2026-07-13): measured 7.9% vs 25% compression by filler density; adversarial reviewer proved an untracked file's lossless claim unverifiable; user-file and history-rewrite boundaries held.*
