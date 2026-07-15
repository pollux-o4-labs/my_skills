---
name: skill-refactor
description: "Compresses an existing skill to its load-bearing core — cutting instruction creep (description enumerations, restated rules, narrative padding) while preserving every behavioral directive. Use when a skill exceeds the authoring budgets, when touching a skill under the retrofit-on-edit policy, or when a review flags bloat."
version: 1.3.0
---

# Skill Refactor

Every skill description is loaded into every session's prompt, and every body word is read on every trigger — bloat is a recurring tax, not a one-time cost. A refactor cuts the tax without touching behavior: same triggers, same directives, fewer words. Why these standards exist: [RATIONALE.md](RATIONALE.md).

## When to Use

- A skill exceeds the budgets in `skillify-session-lessons/authoring-standards.md`.
- You are editing a skill for another reason — the retrofit-on-edit policy says bring it into caps in the same pass.
- A reviewer or the user flags a skill as bloated.

**Skip for**: skills already within caps (don't churn); changes that alter triggers or behavior — that is a redesign, not a refactor, and needs its own review.

## Procedure

1. **Measure first**: run `python3 skillify-session-lessons/scripts/measure_skill.py <skill-dir>`. It reads the caps from the standard and reports every budgeted quantity; non-zero exit means over a cap. Record before/after — your own count is not a measurement.
2. **Inventory load-bearing content before cutting — mechanically**: every imperative sentence, bullet, and checkbox in the original is an inventory item, plus trigger keywords, boundary cross-references ("not for X, see Y"), and the concrete example that taught the lesson. This list is the contract the refactor must not break.
3. **Cut by creep pattern**:
   - description enumerations (tool lists, exception lists) → body "Skip"/"Do NOT use" section; description keeps what+when in 2 sentences
   - narrative intros and multi-line Origin stories → one line each
   - Verification items restating Procedure steps → outcome checks only
   - the same rule stated in several places → one home + pointer
   - edge-case branch prose → compact enumeration
   - maintenance-facing narrative (what changed, why it changed, review history) → git history / RATIONALE; the body keeps at most a one-line Origin
   - no-op directives — sentences whose deletion cannot change behavior because the model already acts that way untrained (the **deletion test**) → delete
   - long behavioral explanation → one strong term of art the model already knows ("vertical slice", BLUF), repeated at the decision points; it worked if the term echoes in reasoning traces
4. **Behavior-preservation check**: for each inventoried item, point to where it survives in the draft. An item with no home means the cut changed behavior — restore it, or stop and route the change as a redesign with its own review. Exception: deletion-test cuts are declared in the diff summary instead of restored — each with its no-op rationale (why the model already does this untrained), so the exception can't smuggle a real behavior loss.
5. **Finish**: bump the minor version, re-run the measurer until it exits 0 (or the overshoot is justified in the diff summary), and show the diff with before/after numbers — reviewed against the original file, not just the inventory — before registering.

## Pitfalls

- **Cutting the edge case that taught the lesson** — the skill becomes advice nobody can apply.
- **Over-trimming the description** until it loses discriminability from sibling skills.
- **Treating the soft target as a hard cap** — mangling a load-bearing example to hit the word target when the standard sets a higher review threshold.
- **Silent behavior change** smuggled in as compression.

## Verification

- [ ] Before/after measurements recorded, and the result within caps (or the overshoot justified)?
- [ ] Every inventoried directive, trigger, and example has a surviving home (deletion-test cuts declared with rationale, not restored)?
- [ ] Any behavior change declared explicitly, not smuggled in?
- [ ] Version bumped and the numbered diff shown for review?

## Example

Pilot: `AIL-calibrate-agent-spend`, 1,516→717 words, description 520→349 chars. Cut: tool/exception enumeration in the description (moved to the body "Skip for" line), two intro paragraphs already restated in Pitfalls, a five-line Origin narrative, and Verification items mirroring Procedure. Kept: the conflict-naming lesson ("don't silently pick the convenient policy doc") — verified surviving in Procedure step 3, one Pitfall, and the Example. An adversarial reviewer confirmed no load-bearing loss. (Numbers are session-measured, body words with frontmatter excluded; the pre-refactor version was never committed to git.)
