---
name: AIL-pilot-before-scale
description: "Requires a small representative pilot — or a cheaper deterministic/mock proof — before operations whose cost scales with many items (bulk LLM calls, mass edits, full reprocessing, migrations, audits, batch generation). Use before work where a wrong approach would waste significant tokens, time, or irreversible edits; not for one small deterministic change."
version: 0.2.0
metadata:
  provenance: AIL
---

# Pilot Before Scale

Being told to "do X" over a large set is **not** a license to run the full, expensive X on the first pass. Form a hypothesis, run on a small representative sample, verify, **then** scale — and if the goal is only to *verify a property* (does the logic work? does the pipeline connect?), a deterministic or mocked path often proves it for free, making even the pilot unnecessary.

## When to Use

- You're about to run an operation whose cost scales with N items and N is large: bulk LLM calls, mass edits, full re-index/re-extract, migration, audit, batch generation.
- The instruction names a large target ("process the docs", "re-extract everything") but the *point* could be proven on a fraction of it.
- You're tempted to run the **full** pipeline just to get a baseline for testing a **partial/incremental** change — that contradicts the very property you're testing; use existing state or a tiny fixture instead.
- A test or verification needs only to confirm behavior, not produce the full output.

**Do NOT use when:** the operation is already small/cheap; the full run *is* the deliverable and cheap enough that a pilot adds nothing; or a pilot genuinely can't represent the whole (rare — a stratified sample usually can).

## Procedure

1. **State the hypothesis.** One line: what should this operation produce or prove? If you can't write it, you're not ready to run at scale.
2. **Can a cheap path prove it?** If the goal is verifying *logic/wiring*, use a deterministic or mocked substitute (fake LLM, `--no-llm`, stub, dry-run) — reserve real calls for the one "does the real backend work" smoke test.
3. **Pick a minimal representative sample.** 1–3 items exercising the real path end-to-end; include a known edge case.
4. **Run the pilot, verify.** Check correctness *and* cost/behavior (how many calls did it actually make? any surprise?). Confidence comes from an observed result, not "it should work."
5. **Scale only after the pilot validates.** If it fails, you fixed the approach before paying for N.
6. **Log what you scoped.** "Piloted on X of N; scaling to the rest" — a silent full-run must not masquerade as a validated one.

## Pitfalls

- **Instruction-literalism.** "Verify the update works" → running the *full* rebuild. The instruction asked for a proof, not the whole job at full cost.
- **Sunk-cost repeat.** Letting a wasteful full run finish is sometimes right (avoid half-state); *repeating* it is not. Once is an accident, twice is a choice.
- **Silent full-scope.** Scaling without saying so reads as "validated everything" when only a sample was checked.
- **Over-piloting.** Endlessly sampling a cheap, low-risk operation instead of just running it. The discipline is for *expensive/irreversible* scope, not everything.

## Verification

- [ ] Is this operation's cost large enough that a wrong approach would hurt (tokens/time/irreversible)?
- [ ] Did I state the hypothesis this run confirms?
- [ ] Could a deterministic/mock path prove it without the real cost — and did I use it if so?
- [ ] Did an observed pilot result (not an assumption) justify scaling?
- [ ] Did I log what was piloted vs. scaled?

---
*Origin: vector-graph-ontology session (2026-07-06) — agents repeatedly ran a full 20-item LLM re-extraction to test a partial-update path, burning ~20 calls to prove what a 1–2 item pilot (or a no-LLM path) would have shown, while contradicting the "no full rebuild" property under test.*
