---
name: AIL-design-for-extension
description: When a rule or case is about to recur (roughly the third instance), make it declarative/data-driven so new cases are added by declaration or config — not by editing code or duplicating prose. Use when hardcoded if-branches or "handle X, and also Y, and also Z" lists are piling up, or when a one-off is being baked into a system core. Avoids both re-doing the same work and speculative over-abstraction.
version: 0.1.0
metadata:
  provenance: AI-generated from session lessons (vector-graph-ontology, 2026-07-05)
---

# Design for Extension

Turn recurring rules into **declarations**, so "new case = add a declaration" instead of "new case = edit code / copy-paste prose." The goal is not abstraction for its own sake — it is **not doing the same work repeatedly**.

This skill lives in tension with "don't over-engineer" (YAGNI). The resolution is timing, not zeal: abstract **only at variation points that actually recur**, never speculatively.

## When to Use

- The same *kind* of rule/case is about to appear a **third** time.
- Hardcoded `if`/`switch` branches are accumulating for what is really "one rule, many instances."
- A one-off ("Screen must reference PRD/IA/design") is being written directly into a system's core, privileging one instance.
- A "handle X, and also Y, and also Z…" list keeps growing and each addition touches code.

**Do NOT use when:**
- It is the first (or only) occurrence — hardcode it. Premature generalization is over-engineering.
- The variation point will not realistically recur.
- The abstraction would cost more to build/read than the duplication it removes.

Rule of thumb: **once = hardcode. twice = take note. three times = make it declarative.**

## Procedure

1. **Name the invariant.** Find what all the instances share. Rewrite the specific rule ("X must have Y") as a general one ("a node of some type must satisfy its *declared* required relations"). The specific case becomes one *instance* of the general rule.
2. **Externalize the rule as data.** Move the varying part into a declaration — frontmatter, config, a schema, a registry, a policy file. Code reads the declaration and enforces it; code does not enumerate cases.
3. **Default + opt-in promotion.** Let everything be inert/queryable by default; a thing becomes *enforced* only when a declaration references it. New constraints attach by declaration, not by reworking the engine. (Analogy: everything is data; a validation rule referencing a row is what makes it a constraint.)
4. **Keep enforcement cheap first.** Validate structure with rule-based code (free, deterministic) before reaching for an LLM/human judge. Declarative rules are exactly what cheap code can check.
5. **Verify the seam.** Add a new case using only a declaration. If it requires editing engine code, the abstraction is in the wrong place — fix the seam or revert to hardcoding.

## Pitfalls

- **Speculative abstraction (YAGNI):** generalizing a variation point that never recurs. Costs reading/building effort for zero payoff. This is the failure mode that "don't over-engineer" warns about — respect it.
- **Premature generalization:** abstracting on the *first* occurrence because it "feels" like it will grow. Wait for the signal (recurrence), then act.
- **The opposite failure — copy-paste past three:** duplicating the same branch a fourth, fifth time because "it's just one more." That is re-doing work; promote it.
- **Config that still needs code:** an abstraction where adding a case *also* requires touching the engine. Half-declarative is the worst of both — the seam is wrong.
- **Analysis paralysis:** think in plain terms (schema constraint, policy-as-code, plugin registry, feature flag). The pattern is standard backend validation, not exotic theory.

## Verification

- [ ] Is this the third-ish recurrence (not speculative)?
- [ ] Does adding a new case now require **only** a declaration/config change, no engine edit?
- [ ] Is the general rule stated as an invariant, with the original case as one instance?
- [ ] Is structural enforcement done by cheap rule-code before any LLM/human step?
- [ ] Would a reader reach for a familiar term (schema/FK constraint, policy-as-code, registry) to describe it?

---
*Provenance: distilled from a session where a specific enforcement rule ("Screen must reference PRD/IA/design") was repeatedly generalized under user correction into a declarative entry-gate (`required_relations`), reconciling extensibility with YAGNI via the once/twice/three-times rule.*
