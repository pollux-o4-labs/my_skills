---
name: AIL-calibrate-verification-depth
description: "Calibrates verification depth before asserting a nontrivial inferred conclusion — confidence must be earned by argument (deduction, induction, contradiction) and checking depth matched to how firm that argument is. Use before asserting conclusions that rest on assumptions, partial evidence, or memory rather than direct observation."
version: 1.3.0
metadata:
  provenance: AIL
---

# Calibrate Verification Depth

Before you assert, propose, or decide on something reached by **inference**, treat confidence as earned by a stateable argument, not assumed — and match how deep you verify to how firm that argument is. (Domain siblings apply this per area: `AIL-ground-before-structuring` = structure, `AIL-verify-against-reality` = runtime.)

**Tradeoff:** biases toward checking over speed. For low-stakes, reversible claims, use judgment. If the user explicitly opts out of verification, comply and label the answer as unverified/from-memory in one line — don't refuse and don't verify anyway.

**Skip for**: directly observed facts and routine implementation steps; structure and runtime checks belong to the siblings above.

## Procedure

- **State the argument.** Deduction (follows from a rule/spec) or induction (several agreeing cases, no counterexample) → a summary/index suffices; don't open the raw original. Can't confirm directly → assume the negation and look for the break ("if it were stale/wrong, what trace would show?"). No stateable argument = a vibe — don't assert it.
- **Must resolve and still open** → open the **nearest material first** (related folder, catalog, index), then the **raw source**. Summaries go stale, so **get the user's ok before the raw dive**.
- **Repeated pushback** ("isn't it X?" / "did you actually look?"), especially twice, means you fixed it by inference — stop arguing, open the source, nearest first.
- **Relaying to a subordinate raises the stakes.** An unverified claim about another party's state ("someone else already started/owns this") handed down as settled fact is the same failure at one remove: the subordinate can't check what you told them and acts on your unearned confidence. Verify against something checkable (a log, a direct look) before it gates someone else's scope.

*Origin:* session lessons on asserting inferred conclusions without earned confidence; the subordinate-relay step was added after an unverified "someone else already owns this" claim was passed down as fact and gated another agent's scope.
