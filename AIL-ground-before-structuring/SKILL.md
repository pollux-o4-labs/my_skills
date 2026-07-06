---
name: AIL-ground-before-structuring
description: Before proposing a structure — hierarchy, schema, split unit, data model, taxonomy — read the existing artifacts it will sit on top of (already-written content, data, samples, current schema/config, naming conventions, design records) to pin down "what is one unit" and the existing boundaries and naming. Prevents inferring the atomic unit / nesting depth / boundaries, or skipping that check under a "keep it simple" bias. Fires when designing a new structure, taxonomy, or split unit, or when refactoring/migrating on top of existing assets.
version: 1.1.0
metadata:
  provenance: AIL
  platforms: [claude-code, codex, gemini-cli]
---

# Ground Before Structuring

When you design or propose a structure (hierarchy, schema, split unit, data model), **"what counts as one unit / what are the existing boundaries and names" is not a design choice to reason out — it is a fact that may already be decided.** If you infer it instead of reading the existing artifacts first, you propose a structure that looks right but is wrong.

## When to Use
- Proposing/designing a hierarchy, schema, split unit, data model, or category taxonomy
- Deciding "how do I split this / how many levels / what is one unit"
- Laying a structure on top of assets that already exist (content, data, prior decisions), or fixing a unit/boundary in a refactor or migration

**Do not fire**: true greenfield with no prior artifact to consult; a pure style debate after the unit is already confirmed from the source.

## Procedure
1. **Ask the unit question first.** "What is the atomic unit this work sits on — one file / record / entity?" Treat it as a fact to *find*, not a choice to *make*.
2. **Actually open the source — nearest first.** Read where the unit/boundaries/naming are defined (written items — content/data/samples, schema/config, naming conventions, design records). A related folder / catalog / index usually settles it; drop to the raw original only for a must-resolve it can't answer — and since summaries go stale, get the user's ok before that raw dive. Confirm by grep/opening, never "there's probably…".
3. **Compare, and let the artifact win.** If your mental model ≠ the real unit, the artifact wins (drop your inference). If an intent doc and the actually-built artifact disagree, the built one wins.
4. **Only then design / simplify.** Debate structure, depth, and simplification on top of the confirmed unit — never before.
5. **A repeated pushback = go to the source.** If someone asks "isn't this actually X?" / "wouldn't that fail to cover it?" — especially twice — that's a signal you fixed the unit by inference. Stop arguing; open the source.

## Pitfalls
- **Simplify-bias**: "simpler is better" races ahead of the check and under-estimates the unit, yielding a structure coarser than the real one.
- **The "feels derivable" trap**: units and boundaries feel reasoned-out, but they were usually already set → do not infer.
- **Using the other party as your validator**: throwing a proposal and waiting to be corrected costs round-trips and trust. Reading the source first saves them.
- **Intent vs. built**: a design doc saying "it should be X" doesn't override an artifact that is actually Y → check both, prefer the built one.
- **Raw-diving past the index**: skipping the dedicated folder/catalog and burrowing into the raw original (or a backup copy) burns trust and often reads a stale or wrong version → nearest summary first, raw last and gated.
- Sibling `AIL-verify-against-reality` is for *a fix that passes but breaks at runtime*; this skill is for *a design proposal with no grounded basis yet* — different timing.

## Verification
- [ ] Did I **actually open** the existing artifacts to confirm "what is one unit" (not infer it)?
- [ ] Did I eyeball the naming / nesting / boundary conventions?
- [ ] When my inference and the artifact disagreed, did I take the artifact (and the built one over the intent doc)?
- [ ] Did I defer the simplify/depth call until after the basis was confirmed?
- [ ] When pushed back twice, did I open the source instead of arguing?
- [ ] Did I enter nearest-first (related folder/catalog before raw), gating any raw dive on real need + user sign-off?
