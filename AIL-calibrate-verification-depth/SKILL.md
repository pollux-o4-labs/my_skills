---
name: AIL-calibrate-verification-depth
description: Before asserting, proposing, or deciding on a conclusion reached by inference, earn confidence by argument (deduction/induction/contradiction/contrapositive) and match verification depth to it — summaries and related folders first, raw source last and human-gated. Use when about to state a fact, propose a structure, diagnose a cause, or answer from memory instead of checking.
version: 1.0.0
metadata:
  provenance: AIL
  platforms: [claude-code, codex, gemini-cli]
---

# Calibrate Verification Depth

Before you assert, propose, or decide on something reached by **inference**, treat confidence as earned by argument, not assumed — and match how deep you verify to how firm that argument is. (Domain siblings apply this per area: `AIL-ground-before-structuring` = structure, `AIL-verify-against-reality` = runtime; the same holds for debugging.)

**Tradeoff:** biases toward checking over speed. For low-stakes, reversible claims, use judgment.

## 1. Earn confidence by argument
- **Deduction** — follows from an established rule/spec? A summary/index suffices.
- **Induction** — several cases/samples agree, no counterexample? Stop there.
- **Contradiction / contrapositive** — can't confirm directly? Assume the negation and look for the break, or ask "if it were stale/wrong, what trace would show?".
- If you can't state the argument, it's a vibe — don't assert it.

## 2. Match depth to confidence
- Settled by deduction/induction → don't open the raw original.
- Not settled → open the **nearest material first** (related folder, catalog, index).
- Must-resolve and still open → go to **raw source**, but summaries go stale, so **get the user's ok before the raw dive**.

## 3. Repeated pushback = you inferred it
Asked "isn't it X?" / "did you actually look?" — especially twice — you fixed it by inference. Stop arguing; open the source, nearest first.
