---
name: AIL-verify-against-reality
description: "Checks surprising verification results against the real execution path — stale intermediate layers and your own command or measurement — before re-debugging target code. Use when a fix looks correct but reality is unchanged, tests pass while reality fails, a rebuild shows no effect, a result looks suspicious, or you're about to cite a measured number in a commit message or report."
version: 1.6.0
metadata:
  provenance: AIL
  platforms: [claude-code, codex, gemini-cli]
---

# Verify Against Reality

If a fix works in code and tests but not in reality, the bug is **usually not in the fixed code — it's in a stale or mismatched intermediate layer** between the code and reality. Rule that layer out before re-digging the fix. And whenever you rely on a result — it looks strange, or you're about to commit a measured number — suspect **your own command or measurement** before the target.

## When to Use

- "I fixed the code but reality is unchanged."
- Tests / doubles (sandbox, mock) pass but the real environment breaks.
- You reinstalled / reloaded / redeployed / rebuilt but see no change.
- You're building or verifying state-transition UI (before/after, hover, focus).
- About to cite a measured number (word count, size, timing) in a commit message, report, or PR comment.

**Do NOT use** for a plain logic bug that reproduces in the real environment (tests fail too) — just fix the code. This skill is for the *mismatch* case (tests pass but only reality breaks) and for distrusting your own command or measurement before the target.

## Procedure

0. **Is it your command/measurement?** Before suspecting the target, self-test the harness on a known answer (does `false` report failure?) and measure through the same path the real consumer uses. Then, for each suspect layer, form a prediction ("if this layer is the culprit, measuring X yields Y") and **disprove it by measurement** — never fix code on a plausible hypothesis. A cited number is a measurement too: re-measure the final artifact right before writing it into a commit message or report — a figure from before the last edit, or predicted from a planned change, is stale.
1. **Rule out staleness — is reality actually seeing the latest code?**
   - **Cache**: a layer (client, proxy, CDN, embedded view) serving the old asset. If the identifier doesn't change, the cache never busts → force a **version-independent bust key** (content hash / timestamp).
   - **Version shadow**: an older *higher* version masking the new lower one — the runtime loads "the highest", so the new deploy is void → remove the orphan or bump above it.
   - **Un-rebuilt artifact**: source fixed but the output (bundle, binary, cached compile) not regenerated → check the artifact's mtime/hash.
2. **Does the double reproduce reality?** First confirm the sandbox / mock / stub reproduces reality's *known* behavior. Hand-cloned config/fixtures always drift → **reuse the tuned real value from a single source**, never invent values. Reproduce interactions via the **real input path** (actual click/keypress, Playwright / computer-use), not synthetic events — `dispatchEvent`-style firing skips focus, bubbling, default actions, and IME, so a "passing" check can be illusory. A double that can't reproduce reality isn't qualified to verify the change.
3. **Feature-passing ≠ visual correctness** — for state-transition UI, don't just check logical state; **quantitatively measure size/position/spacing** of both states, and eyeball a screenshot.
4. **Double-verify** — double (fast measurement) + real environment (eyeball). Never trust the double alone.

## Pitfalls

- **Chasing a bug that isn't there**: the code is fine but the command was wrong (typo, flag, quoting, path) or the harness gives a false signal. Anchor: `wsl bash -lc "cmd; echo $?"` reported exit 0 for a failing gate — the reproduction method, not the code, was the culprit.
- **Logic right, visuals wrong**: state is correct but size/alignment differs — the user still sees "broken".
- **Citing a pre-edit measurement**: true when measured, stale when committed — a commit message said 949w, the final file held 955w. Measure, then write, nothing in between.

---
*Origin: frontend sessions where "fixed but reality unchanged" kept tracing to hidden staleness (cache, double divergence, version shadow), a supervision session where a false exit-0 harness — not the code — was the bug, and a review session where a commit cited a pre-edit word count (949 vs the final 955).*
