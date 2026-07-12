# Rationale — where these authoring standards come from

Provenance: user-provided research synthesis (2026-07-12) mapping encyclopedia governance standards, statutory drafting practice, and cognitive-load research onto rule and knowledge authoring. This file grounds `skill-refactor`, `write-a-rule`, and the quantitative caps in the skills-repo `CLAUDE.md`. It records **why** those rules exist and **what was deliberately rejected**, so future edits argue against the source, not against a bare number.

## 1. Instruction creep (Wikipedia governance)

Rule systems accrete micro-clauses added to control rare edge cases. The accumulation shifts participants from the actual goal to mechanical rule-compliance and rule-lawyering, and raises the entry barrier. The countermeasures: state the principle, trust discretion for edge cases (KISS); add a micro-clause only after a real incident; control total volume — past ~8,000–10,000 words, split summary-style into a parent (principle + index) and child detail docs.

→ Adopted as: write-a-rule's creep-control section; the skill caps (700-word target / 1,000-word review threshold — the same total-volume idea scaled to skill size); skill-refactor itself.

## 2. Namespace tone duality (article space vs. policy space)

Encyclopedic content is written declaratively ("WHO does not recommend aspirin"), never imperatively; governance/policy documents are the opposite — direct, binding must/should wording. Mixing the two weakens both.

→ Adopted as: write-a-rule's policy-vs-knowledge split. Carve-out: agent-facing instruction docs (skills, prompts) are imperative by design — the split governs repo documents.

## 3. Cognitive load and quantitative readability

Working memory is narrow; extraneous load (bad formatting, run-on structure) steals capacity from understanding the rule itself. The research's quantitative standards: 50–75 characters per line (Latin) / ≤40 (CJK); sentences of 10–20 words; active voice ≥90%; a lead section of 1–4 paragraphs that stands alone, with no bullets; paragraph 4–6 lines.

→ Adopted as: BLUF-first leads; short-sentence, active-voice preference; the description budget (≤400 chars, what+when only — the description is an always-loaded lead).
→ Rejected: CPL, line-height, letter-spacing — rendering-layer properties, unenforceable in markdown source and of no benefit there.

## 4. Statutory article hierarchy (Korean legislative drafting)

Statutes control thousands of clauses with a strict hierarchy (편-장-절-관-조, then 조-항-호-목): 항 must be a complete sentence; 호/목 must be noun-phrase enumerations, never full sentences; exceptions are provisos opening with 다만; conditional follow-ups are sequels opening with 이 경우; even terminal punctuation is semantically regulated. The point is mechanical: any clause can be cited unambiguously, and its binding force is readable from its form.

→ Adopted as: write-a-rule's light 2-level hierarchy (numbered article → noun-phrase items), the modality table (must / must not / may), and the connector forms (다만 / 이 경우). Full 5-level hierarchy rejected as over-engineering for repo-scale rule sets.

## 5. Deontic properties map to machine-readable structure

Obligation / prohibition / permission / exception / sequence map one-to-one onto knowledge-engineering constructs (required constraint, negative constraint, optional relation, override, state transition) — which is what makes consistently-worded rules mechanically checkable and, eventually, extractable into a graph.

→ Adopted as: the modality-per-clause discipline (one clause, one modality). The graph-extraction half (deontic relation types) was deliberately deferred in the vgo project until a consumer exists — recorded in `docs/review/2026-07-12-doc-validate-quant-checks.md` there.

## 6. Deliberately not adopted

- Prose meta-rules about how to write rules, placed inside a project repo — that reproduces the creep it fights. Standards live here (a propagating skill) and in code-level backstops (validators, caps), not as more repo prose.
- Retrofitting all existing skills at once — pilot-first, then retrofit-on-edit (see skills-repo `CLAUDE.md`).
