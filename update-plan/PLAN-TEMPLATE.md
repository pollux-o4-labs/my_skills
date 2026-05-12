# Plan Template

Canonical structure for documents in `docs/plans/*.md`. Use this when creating a new active plan or retrofitting an existing one that lacks structure.

The template assumes a plan tracks several **decisions** (`D1, D2, …`) that must each be resolved before the plan can move to `docs/plans/archive/`.

---

## Skeleton

```markdown
# <Plan title>

Created: YYYY-MM-DD
Status: in progress — <one-line context>

---

## 👋 Entry guide (for new contributors / sub-agents)

If you just received this plan:

1. **Read first**: `CLAUDE.md` (or `AGENTS.md`) → `CONTEXT.md` → ADRs that overlap this topic.
2. **This plan's job**: <one-line scope — what decisions it covers>.
3. **Order of work**: pick the lowest-ID `open` decision whose `Blocking` column is empty.
4. **When resolving a decision**: update the decision table, mark Done criteria in the per-decision section, add a progress-log row.
5. **When all plan-level done criteria are checked**: confirm with owner, then archive (see `update-plan` skill).

---

## Decision table

| ID | Title | Status | Owner | Blocking | Last-updated | Suggested skill |
|---|---|---|---|---|---|---|
| D1 | <title> | open | <name> | - | YYYY-MM-DD | grill-with-docs |
| D2 | <title> | ✅ resolved | <name> | - | YYYY-MM-DD | - |
| D3 | <title> | open | <name> | D1 | YYYY-MM-DD | AskUserQuestion |

### Plan-level done criteria

- [ ] All decisions resolved
- [ ] Outcomes reflected in <code/config/prompt asset locations>
- [ ] Follow-up ADR published (`docs/adr/000N-<topic>-outcome.md`)
- [ ] Any operational backfill / deploy completed

---

## Background

<Why this plan exists. Context the reader needs but cannot derive from current code.>

## Decisions

### D1. <Decision title>

- **Status**: open
- **Owner**: <name>
- **Blocking**: -
- **Last-updated**: YYYY-MM-DD
- **Suggested skill**: grill-with-docs

**Done criteria**
- (i) <observable artifact — e.g. "option chosen and recorded">
- (ii) <observable artifact — e.g. "code path updated in `module.py`">

**Options**
- **(a)** <option> — <pro/con>
- **(b)** <option> — <pro/con>

### D2. <Decision title> ✅ resolved

- **Status**: resolved (YYYY-MM-DD)
- **Owner**: <name>
- **Done criteria**: <how each was satisfied>

**Decision**: <one sentence — what was chosen and why>.

---

## Progress log

| Date | Who | Change |
|---|---|---|
| YYYY-MM-DD | <name> | Plan created — D1, D2 identified |
| YYYY-MM-DD | <name> | D2 resolved → option (a) |
```

---

## Retrofitting an existing plan

If you encounter an active plan missing parts of this structure, do the additions in this order before applying the regular `update-plan` procedure:

1. Add the entry guide block at the top.
2. Extract the existing decisions into the decision table (assign IDs by document order).
3. Add per-decision `Status / Owner / Blocking / Last-updated / Suggested skill` meta if missing.
4. Add a **Done criteria** subsection to each decision — even if you have to invent the criteria from context. Mark unresolved decisions' criteria with `⏳`.
5. Add the plan-level done criteria checklist.
6. Add the progress log table with one initial row: `| <today> | <you> | Structure retrofitted |`.

Once the structure is in place, all further edits follow the standard procedure in `SKILL.md`.

## Writing measurable Done criteria

A criterion is measurable if a *different* contributor can read it and decide pass/fail without asking. Heuristics:

- It names a *file* / *commit* / *config key* / *channel* (concrete artifact)
- It uses verbs like "committed", "merged", "documented at X", "deployed", "confirmed by <person>"
- It does **not** use verbs like "decide", "consider", "clarify" without an artifact attached

If the criterion still reads like a wish, split it into smaller artifacts until each piece is checkable.

## Decision IDs

- IDs are sticky — once `D3` is assigned, it stays `D3` even if dropped. Don't renumber.
- Dropped decisions stay in the table with `Status: dropped` so future readers don't wonder why `D2` jumped to `D4`.
