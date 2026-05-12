# Architectural Decision Records

Finalised architectural decisions for this project. Each ADR captures the context, the decision, and its consequences — so future contributors (human or sub-agent) don't re-litigate decided questions.

## Format

One file per decision, numbered: `000N-kebab-case-title.md`. Numbers are monotonic; never reused.

Minimum sections:

- **Context** — what's the problem, what constraints exist
- **Decision** — what was chosen, in one or two sentences
- **Consequences** — what gets easier, what gets harder

Optional but useful: **Alternatives considered**, **Status** (proposed / accepted / superseded by 000M).

## Lifecycle

- New ADRs land as `accepted` once merged.
- If a decision is reversed, do not edit the old ADR — write a new one and mark the old as `superseded by 000M`.
- In-flight decisions live in `docs/plans/`, not here. Plans graduate to ADRs when resolved (see the `update-plan` skill).
