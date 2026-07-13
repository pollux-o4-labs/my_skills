---
name: AIL-isolate-format-noise
description: "Separates formatter noise from real content changes in a dirty working tree before committing: classify each file by whether formatter(HEAD) equals the working copy, commit format-only files as a proven no-op, and route content files to their own concerns. Use before committing in a tree with large or mixed uncommitted diffs, when introducing a formatter, or when a diff looks suspiciously large."
version: 0.1.0
metadata:
  platforms: [claude-code]
  provenance: AIL
---

# Isolate Format Noise

A huge uncommitted diff is not evidence of huge uncommitted *work* — a single past `prettier --write .` inflates thousands of lines of pure noise. Committing by concern in such a tree fails two ways: format noise buries real changes, or real changes sneak into a "style no-op" commit. The classifier below splits them mechanically.

## When to Use

- About to commit in a tree with large uncommitted diffs of unclear provenance (inherited session, long-running branch).
- Introducing or re-running a formatter in a repo that has pending work.
- A diff's size contradicts the known work ("+7,877 lines" for a docs session).

**Skip for**: a clean tree (format freely, commit directly); a single-concern diff you authored entirely this session.

## Procedure

1. **Classify every modified file**: `git show HEAD:$f | formatter --stdin-filepath $f | diff -q - $f`. Equal → FORMAT-ONLY (working copy is exactly the formatted commit); different → CONTENT (real change present).
2. **Token equality is the proof — nothing weaker.** `git diff -w` false-positives on line-wraps (a wrapped CSS value changes line structure with identical tokens); a green runtime suite can't see user-visible string changes. Only formatter(HEAD)==working proves no-op.
3. **Stage explicitly — never `-a`/`-A`.** The style commit takes: FORMAT-ONLY files + the formatter's own config (package manifest, lockfile, ignore file). CONTENT files stay uncommitted for their own concern and their own review.
4. **Don't format files belonging to an uncommitted feature** — formatting them mixes style churn into that feature's future diff. Leave them dirty; note them as the format gate's expected residue.
5. **Scope the ignore file narrowly**: exclude user-owned/scratch spaces; prefer `dir/specific-*.ext` over directory-wide globs that would silently swallow future legitimate assets.
6. **Re-validate executables after formatting** (HTML demos, scripts): rerun their verification suite — formatting is provably token-equal, but the rerun catches formatter bugs and stale servers cheaply.
7. **Approval binds to a diff state, not a concern label.** If the diff changes after review approval (more formatting, compression), re-review before committing.

## Pitfalls

- **Judging work by diff size** — inherited trees lie; classify before planning.
- **`git diff -w` as a no-op proof** — line-wrap reflow survives `-w` and looks like change.
- **`commit -a` on a style pass** — buries in-flight feature work inside a commit labeled "no-op", where no reviewer will look for it.
- **Formatting the feature-in-progress file** because the gate flags it — the gate's red on that file is correct and temporary.
- **Ratio panic** — treating the inflated line count as scope before separating noise from muscle.

## Verification

- [ ] Every file in the style commit proven formatter(HEAD)==working?
- [ ] Zero CONTENT-classified files staged into the style commit?
- [ ] Formatter config committed with the format pass; ignore patterns narrow?
- [ ] Runtime suites re-run green on formatted executables?

## Example

A maintenance team fears "+7,877 uncommitted lines" of product code. Classification shows 28 files are FORMAT-ONLY (a prior session's formatter run) and only 18 carry real content — the feared bulk was noise. The style commit takes the 28 + prettier config via explicit staging; `src/machine.ts`, `src/web/index.html` and 16 others stay out for their own concerns. An adversarial reviewer's conditional approval — "no-op proven, but commit scope must be re-cut" — is exactly steps 1–3 enforced.

---
*Origin: AIL — doc-maintenance team (prompt-gen, 2026-07-13): adversarial reviewer split a feared +7,877-line tree into 28 format-only vs 18 content files via the formatter(HEAD)==working test; leader reproduced the classification before committing.*
