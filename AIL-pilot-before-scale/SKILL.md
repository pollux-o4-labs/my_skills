---
name: AIL-pilot-before-scale
description: "Requires a small representative pilot or cheaper deterministic/mock proof before expensive or large-scope operations such as bulk LLM calls, mass edits, full re-index/reprocess, migrations, audits, or batch generation. Use before the agent is about to run work whose cost scales with many items or whose wrong approach would waste significant tokens, time, or irreversible edits; do not use for one small deterministic change."
version: 0.1.0
metadata:
  platforms: [claude-code]
  provenance: AI-generated from session lessons (vector-graph-ontology, 2026-07-06)
---

# Pilot Before Scale

Being told to "do X" over a large set is **not** a license to run the full, expensive X on the first pass. Form a hypothesis, run on a small representative sample, verify it, **then** scale. The goal is to not spend large cost (tokens, time, irreversible edits) before you know the approach is right.

A second, cheaper move often makes the pilot itself unnecessary: if you're only trying to **verify a property** (does the logic work? does the pipeline connect?), a deterministic or mocked path proves it for free — you don't need the real expensive run at all.

## When to Use

- You're about to run an operation whose cost scales with N items and N is large: **bulk LLM calls, mass edits, full re-index/re-extract, migration, audit, batch generation**.
- The instruction names a large target ("process the docs", "migrate the repo", "re-extract everything") but the *point* of this step could be proven on a fraction of it.
- You're tempted to run the **full** pipeline just to get a baseline for testing a **partial/incremental** change — that's self-contradictory (you're violating the very thing you're testing).
- A test or verification needs only to confirm behavior, not produce the full output.

**Do NOT use when:**
- The operation is already small/cheap (N tiny, or one deterministic pass).
- The full run *is* the deliverable, sampling would miss the point, **and** it's cheap enough that a pilot adds no value.
- A pilot genuinely can't represent the whole (rare — usually a stratified sample still can).

## Procedure

1. **State the hypothesis.** What do you expect this operation to produce or prove? Write it in one line. If you can't, you're not ready to run anything at scale.
2. **Can a cheap path prove it?** If the goal is to verify *logic/wiring* (not generate real output), use a deterministic or mocked substitute (fake LLM, `--no-llm`, a stub, dry-run). Prefer this over any real expensive run.
3. **Pick a minimal representative sample.** 1–3 items that exercise the real path end-to-end (include an edge case if one is known).
4. **Run the pilot, verify.** Check correctness *and* cost/behavior (how many calls did it actually make? any surprise?). Confidence must come from an observed result, not from "it should work."
5. **Scale only after the pilot validates.** Then expand to the full set. If the pilot fails, you fixed the approach before paying for N.
6. **Log what you scoped.** State "piloted on X of N; scaling to the rest" so a silent full-run doesn't masquerade as a validated one.

## Pitfalls

- **Instruction-literalism.** "Verify the update works" → running the *full* rebuild. The instruction asked for a proof, not the whole job at full cost. Scope to what proves the point.
- **Baseline self-contradiction.** Running a full reprocess to set up a test of *incremental* processing violates the incremental property you're testing. Use existing state or a tiny fixture instead.
- **Real calls where a mock suffices.** Paying real LLM/API cost to test control-flow that a deterministic stub verifies for free. Reserve real calls for the one "does the real backend actually work" smoke test.
- **Sunk-cost repeat.** Letting a wasteful full run finish is sometimes right (avoid half-state); *repeating* it is not. Once is an accident, twice is a choice.
- **Silent full-scope.** Scaling to the full set without saying so — reads as "validated everything" when only a sample was checked. Always log the scope.
- **Over-piloting.** Endlessly sampling a cheap, low-risk operation instead of just running it. The discipline is for *expensive/irreversible* scope, not everything.

## Verification

- [ ] Is this operation's cost large enough that a wrong approach would hurt (tokens/time/irreversible)?
- [ ] Did I state the hypothesis this run is meant to confirm?
- [ ] Could a deterministic/mock path prove the property without the real cost? If so, did I use it?
- [ ] Did I verify on a small representative sample *before* the full run?
- [ ] Did the pilot's observed result (not assumption) justify scaling?
- [ ] Did I log what was piloted vs. scaled?

---
*Provenance: distilled from a session where agents repeatedly ran a full 20-item LLM re-extraction to test a partial-update path — burning ~20 calls to prove something a 1–2 item pilot (or a deterministic no-LLM path) would have shown, and contradicting the "no full rebuild" property under test.*
