---
name: update-plan
description: Maintain active plan documents under `docs/plans/` — update decision status, add progress log entries, archive when complete, and write follow-up ADRs for frozen outcomes. Use when user resolves a decision in a plan, asks to log plan progress, adds a new open decision, marks a plan as done, or asks "where should I record this decision".
---

# Update Plan

Procedure for maintaining active plans living in `docs/plans/*.md`.

## Assumed plan structure

Every active plan is assumed to have these sections:

1. **Entry guide** — orients a new contributor (human or sub-agent) on what to read first.
2. **Decision table** — rows of `ID / Title / Status / Owner / Blocking / Last-updated / Suggested skill`. IDs are `D1, D2, …`.
3. **Plan-level done criteria** — checkbox list; when all checked, the plan moves to archive.
4. **Per-decision sections** — each with status meta, **Done criteria**, options/rationale.
5. **Progress log** — `| date | who | summary |` table.

If a plan lacks this structure, normalise it on first edit. See [PLAN-TEMPLATE.md](PLAN-TEMPLATE.md) for the canonical layout and how to retrofit. Do not skip — the structure is what makes the plan survive handoff.

## Resolving a decision (most common case)

1. **Table row** — flip `Status` (`open` → `resolved` / `blocked on D{N}` / `dropped`); update `Last-updated` to today's date.
2. **Decision section** — update its status meta; mark each Done criterion as `✅ met — <evidence>` or `⏳ not met — <why>`. When `resolved`, write the final decision in one sentence with the rationale.
3. **Progress log** — append `| YYYY-MM-DD | who | D{N} resolved → <option> |`.

## Adding a new open decision

1. Add a row to the decision table with the next free ID.
2. Add a new per-decision section: status `open`, owner, blocking-on (use `-` if none), **measurable Done criteria**, options.
3. Append a progress log row.

## Done criteria — write them measurable

The contributor closing the decision must be able to *check* whether the criteria are met. Bad: "Decide tag convention." Good: "For each forum, list the agreed tag set; add tag-routing rule to `cag/system.md` or the equivalent prompt asset."

If the criterion reads like a goal ("clarify policy"), it is too vague — rewrite as an observable artifact ("blacklist channel IDs committed to env + handler updated").

## Plan-level done criteria all met → archive

When every plan-level checkbox is ticked:

1. Confirm with the plan owner: "Archive this plan? All done criteria met."
2. On approval, in one atomic change:
   - Create `docs/plans/archive/` if absent.
   - `git mv docs/plans/<name>.md docs/plans/archive/<name>.md`.
   - Publish a follow-up ADR (`docs/adr/000N-<topic>-outcome.md`) freezing the resolved patterns. Use the project's ADR format if present, otherwise Context / Decision / Consequences.
   - Update any reference to the plan (e.g. in `CLAUDE.md` or `AGENTS.md`) to point at the new ADR.
   - Append a final progress log row noting `archived`.

## Edge cases

- **Reopened decision**: status → `reopened`; log the reason in the progress log; if a finalising ADR was already published, mark it `superseded` and reference the new one once written.
- **Blocking-only change**: edit only the table; do not touch the decision section body.
- **Stale plan** (no progress-log entry for 30+ days): add a progress-log row marking it stale and surface to the plan owner — they decide whether to archive or revive.
- **Plan without standard structure**: retrofit first using [PLAN-TEMPLATE.md](PLAN-TEMPLATE.md), then apply the procedure above.
