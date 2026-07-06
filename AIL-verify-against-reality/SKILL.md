---
name: AIL-verify-against-reality
description: Diagnostic discipline for when a result looks wrong — before digging back into the target code, rule out (a) stale intermediate layers between code and reality (cache, test-double divergence, version shadow, un-rebuilt artifacts) and (b) your own command / measurement method itself, by measuring rather than assuming. Fires on "I fixed it but nothing changed", "rebuilt and still the same", a command result that looks off, or verifying state-transition UI.
version: 1.2.0
metadata:
  provenance: AIL
  platforms: [claude-code, codex, gemini-cli]
---

# Verify Against Reality

If a fix works in code and tests but not in reality, the bug is **usually not in the fixed code — it's in a "stale or mismatched intermediate layer" between the code and reality.** Rule that layer out before re-digging the fix. And if the result itself looks strange, suspect **your own command or measurement** before you suspect the target.

## When to Use

- You get a report of "I fixed the code but reality is unchanged".
- Tests / doubles (sandbox, mock) pass but the real environment breaks.
- You reinstalled / reloaded / redeployed / rebuilt but see no change.
- You're building or verifying state-transition UI (before/after, hover, focus, etc.).

**Do NOT use** for a plain logic bug that reproduces in the real environment (tests fail too) — just fix the code. This skill is for the *mismatch* case: tests pass but only reality breaks.

## Procedure

0. **Rule out by measuring, not hypothesizing — but first, is it your command/measurement?** For each suspect layer, form a prediction ("if this layer is the culprit, measuring X yields Y") and **disprove it by measurement**. Don't fix code on a plausible hypothesis. **And before the target code, check "did I run the command correctly / is my measurement faithful?"** — self-test the harness on a known answer (e.g. does `false` report failure?) and measure through the same path the real consumer uses.
1. **Rule out staleness first — is reality actually seeing the latest code?**
   - **Cache**: is some cache layer (client, proxy, CDN, embedded view) serving the old asset? If the identifier doesn't change, the cache never busts → force refresh with a **version-independent cache-bust key** (content hash / timestamp).
   - **Version shadow**: is a higher old version masking the new (lower) one? When multiple versions coexist, the runtime may load "the highest" → remove the old higher version or bump above it.
   - **Un-rebuilt artifact**: source fixed but the output (bundle, binary, cached compile) not regenerated? Check the artifact's mtime/hash.
2. **Does the test double reproduce reality?** — first check that the sandbox / mock / stub / staging **reproduces reality's known behavior**. Hand-cloned config/fixtures always drift → don't invent config/values, **reuse the already-tuned real value from a single source** (no cloning). Same for interaction checks — reproduce via the **real input path** (actual click/keypress, Playwright / computer-use), not synthetic events (`dispatchEvent` and other programmatic firing). A double that can't reproduce reality isn't qualified to verify the change.
3. **Feature-passing ≠ visual correctness** — for state-transition UI, don't just check "what's visible" (logical state); **quantitatively measure size/position/spacing** of both states and confirm alignment. Also eyeball a screenshot.
4. **Double-verify** — double (fast measurement) + real environment (eyeball). **Don't trust the double alone.**

## Pitfalls

- **Cache serves the old asset**: if the identifier (version) doesn't change, no refresh → "rebuilt but same". Force with a cache-bust key.
- **Double divergence**: a cloned double differs subtly from reality (config, environment, data), so "passes on the double" breaks in production → inject the real value as the single source.
- **Version shadow**: an older higher version masks the new lower one → the new deploy is void. Remove the orphan or bump to the top.
- **Logic right, visuals wrong**: state is correct but size/alignment differs, so the user sees "broken".
- **Synthetic event passes ≠ real input passes**: programmatically fired events differ from the real input path (focus, bubbling, default action, IME), so a "passing" check can be illusory → re-check with real click/keypress.
- **Strange result = suspect your command/measurement first**: the code is fine but you ran the command wrong (typo, flag, quoting, path) or your measurement gives a false signal, so you chase a bug that isn't there. Before fixing the target, confirm the command and harness are right. (Anchor: putting `cmd; echo $?` in one shell call showed a false exit code of 0 — the culprit was the reproduction method, not the code.)

## Verification

- [ ] Did I rule out each suspect layer by measurement, not hypothesis?
- [ ] When the result looked strange, did I check **my own command/measurement** before the target?
- [ ] Did I confirm reality loads the latest (cache, version, artifact)?
- [ ] Did I compare the double against reality's known behavior at least once (reusing real values)?
- [ ] Did I quantitatively measure the state transition + screenshot?
- [ ] Did I verify in **both** the double and the real environment, via the real input path?

---
*Origin: a long frontend-debugging session where "fixed but only reality unchanged" kept recurring, and the cause was not the code but "hidden staleness" — cache, double divergence, version shadow. v1.2: a backend supervision session where a CLI gate looked like "rejected but exit 0", yet the culprit was not the code but the reproduction method — `wsl bash -lc "cmd; echo $?"` corrupting the exit code to a false 0 — adding the "your measurement can lie" angle.*
