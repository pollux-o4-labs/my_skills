---
name: refactor-sweep
description: "Runs a parallel multi-agent refactoring audit over an accumulated body of merged work, splitting the codebase by area and forcing each analyst to grade findings and record refusals. Use at an integration point — several feature PRs already merged into a staging branch, before that branch goes to main."
version: 0.1.0
disable-model-invocation: true
---

# Refactor Sweep

Duplication and drift become visible only after several features land — no single PR review can see them. This sweep runs at the integration point, spends analysis on breadth, and returns a graded adopt/reject list. **Refusals are outputs too**: a recorded "do not do this, because…" stops the same proposal from returning next quarter.

## When to Use

- A staging/integration branch has accumulated roughly 3+ merged PRs and is about to go to the trunk.
- A codebase has grown past the point where one reader holds it all, and you want an outside read before it hardens.

## Skip

- Single-PR changes, greenfield code, or anything one reviewer already covers.
- When there is no integration point — sweeping on an arbitrary date produces make-work.

## Procedure

1. **Split by area, not by lens.** Give each analyst a disjoint file set sized so it can read every line (roughly 500–2,000 lines each). Overlapping lenses on the same files return the same finding three times; disjoint areas return coverage.
2. **Inject the project's hard constraints verbatim** — runtime limits, language version, dependency policy — and state that proposals violating them are void. Without this, analysts propose libraries the project cannot take.
3. **Require grading**: HIGH (do now) / MED (worth doing) / LOW (do not — record why). Every finding carries *what* (file:line), *why* (evidence), *how* (concrete change), and *cost/risk*.
4. **Demand "nothing to fix" as a valid answer.** Say it explicitly. Without that permission an analyst manufactures findings to look useful.
5. **Treat existing code comments as design rationale.** Require each analyst to read them and either accept the reasoning or refute it in writing. This is where stale or wrong rationale surfaces.
6. **Require measurement, not impression.** Line counts, branch counts, call-site greps, an actual build — not "this looks complex."
7. **Reject fashionable patterns by default.** A pattern earns its place only when the analyst shows the current code costs more than the indirection would.

## Output Handling

- Adopt only what survives grading; **write the rejections down with their grounds** so the next sweep does not re-litigate them.
- Keep refactor PRs separate from feature PRs — mixed diffs cannot be reviewed.
- Sequence adopted items by blast radius: structural untangling first (isolated), low-risk cleanups batched, large function splits last and alone.

## Signals It Worked

- Analysts converge independently on the same root cause from different areas.
- The reject list is longer than the adopt list.
- At least one finding contradicts a comment the codebase believed about itself.

Grounds: [docs/history/G-refactor-sweep-at-integration.md](../docs/history/G-refactor-sweep-at-integration.md).
