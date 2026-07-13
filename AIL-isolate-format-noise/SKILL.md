---
name: AIL-isolate-format-noise
description: "Proves which files in a dirty working tree are pure formatter noise before committing: re-run the formatter on the HEAD version and compare with the working copy — the only no-op proof. Use when a diff's size contradicts the known work, or before committing a tree where a formatter may have run (inherited session, long-running branch)."
version: 0.3.0
metadata:
  platforms: [claude-code, codex, gemini-cli]
  provenance: AIL
---

# Isolate Format Noise

A diff whose size contradicts the known work is format noise until classified. Classify first, then commit by concern.

## When to Use

- A diff's size contradicts the known work ("+7,877 lines" for a docs session).
- Committing in a tree where a formatter may have run (inherited session, long-running branch).

**Skip for**: a clean tree; a single-concern diff you authored entirely this session.

## Procedure

1. **Classify every modified file by formatter re-run comparison** — `git show HEAD:$f | formatter --stdin-filepath $f | diff -q - $f` — the **only** no-op proof (line-wrap reflow and quote changes escape whitespace-based comparison). Equal → FORMAT-ONLY; different → CONTENT, routed to its own concern and review.
2. **The style commit takes FORMAT-ONLY files plus the formatter's own config, explicitly staged.** Files belonging to an uncommitted feature stay unformatted — they are the gate's expected residue, not failures.

## Pitfalls

- **Whitespace-ignoring diff as proof** — it surfaces candidates, never proves a no-op; reflow and quote changes pass through it looking like real change.

## Example

A team fears "+7,877 uncommitted lines"; classification shows 28 files FORMAT-ONLY against 18 CONTENT — the bulk was a prior session's formatter run. The style commit takes the 28 plus prettier config; the 18 stay out for their own concerns.

---
*Origin: AIL — doc-maintenance team (prompt-gen, 2026-07-13): the formatter(HEAD)==working test split a feared +7,877-line tree into 28 format-only vs 18 content files.*
