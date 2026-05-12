# Plans

In-flight design and decision documents. Each plan is a *living* document with a decision table, done criteria, and a progress log — so handoffs (across sessions, across people, to sub-agents) survive without re-explaining context.

## Structure

Every plan follows the canonical layout enforced by the `update-plan` skill:

1. **Entry guide** — orients a new contributor on what to read first.
2. **Decision table** — rows of `ID / Title / Status / Owner / Blocking / Last-updated / Suggested skill`. IDs are `D1, D2, …`.
3. **Plan-level done criteria** — checkbox list; when all checked, the plan archives and a follow-up ADR is published.
4. **Per-decision sections** — each with status meta, **Done criteria**, options, rationale.
5. **Progress log** — `| date | who | summary |` table.

The reference template is `PLAN-TEMPLATE.md` bundled with the `update-plan` skill. Copy it when starting a new plan.

## Lifecycle

- New plans live as `docs/plans/<topic>.md`.
- Resolved decisions get their final answer in the per-decision section; the plan-level done criteria gate archival.
- When all plan-level criteria are met, the `update-plan` skill moves the plan to `docs/plans/archive/` and publishes an ADR under `docs/adr/`.
