---
name: setup-my-skills
description: Bootstrap a repo for the `efficient-subagent` skill — scaffold a slim `CLAUDE.md` structure (한국어), a `TODO.md` backlog with T-XX IDs, `docs/meta/` workflow guides, and an `## Agent skills` block carrying Sub-agent discipline rules + the ADR `status: proposed/accepted` convention. Designed to coexist with `setup-matt-pocock-skills`, which handles `CONTEXT.md` / `docs/adr/` consumer rules; the bodies of those files are created lazily by `grill-with-docs`, not pre-seeded here. Use when adding the skill to a new project.
---

# Setup My Skills

Scaffold the per-repo artifacts that `efficient-subagent` assumes:

- **Agent-skills index** — a `## Agent skills` block in `CLAUDE.md` or `AGENTS.md` carrying Sub-agent discipline rules and the ADR `status: proposed/accepted` convention. Merges into the same heading produced by `setup-matt-pocock-skills` — never create two `## Agent skills` headings.
- **Claude workflow scaffold** — slim `CLAUDE.md` structure (한국어), `TODO.md` backlog with T-XX IDs, and `docs/meta/` guides (writing rules, sub-agent efficiency block, key file index).

`CONTEXT.md` and `docs/adr/` bodies are **not** seeded here. `setup-matt-pocock-skills` defines their consumer rules in `docs/agents/domain.md`, and `grill-with-docs` creates the files lazily when first terms/decisions get resolved. Pre-seeding empty stubs would conflict with that lazy-creation philosophy.

Prompt-driven skill, not a script. Explore → present → confirm → write. Never overwrite existing user content.

## Process

### 1. Explore

Look at the repo's starting state. Read what exists; don't assume:

- `CLAUDE.md` and `AGENTS.md` at the repo root — does either exist? Is there already an `## Agent skills` block in either (possibly from `setup-matt-pocock-skills`)? Does it have 작업 시작 규칙 / 작업 규칙 sections?
- `TODO.md` — does it exist? Does it use the T-XX ID format?
- `docs/meta/` — does it exist? Which of `writing-guide.md`, `efficiency-feedback.md`, `spec-locations.md` are present?
- `docs/agents/` — sign that `setup-matt-pocock-skills` has already run. Note its presence so the `## Agent skills` block merges instead of duplicating.

### 2. Present findings and ask

Summarise what's present and what's missing in a short table. Then walk the user through two decisions **one at a time** — present a section, get the user's answer, then move to the next.

Assume the user does not know what every term means. Each section starts with a short explainer. Then show the choices and the default.

**Section A — `## Agent skills` block in `CLAUDE.md` / `AGENTS.md`.**

> Explainer: A section in `CLAUDE.md` / `AGENTS.md` that tells future sessions and sub-agents how to discipline sub-agents and which ADR `status` convention to follow. If `setup-matt-pocock-skills` already added its own subsections (Issue tracker / Triage labels / Domain docs), this skill's subsections (Sub-agent discipline / ADR status lifecycle / Key file index / Docs rules) merge into the **same** `## Agent skills` heading — do not create a second one.

Use [agent-skills-block.md](./agent-skills-block.md) as the seed. Adapt language (English / the user's working language) before writing.

**Section B — Claude workflow scaffold.**

> Explainer: A set of lightweight conventions for Claude Code sessions — a slim `CLAUDE.md` structure that separates root rules from sub-area rules, a `TODO.md` backlog format with T-XX task IDs for cross-referencing, and `docs/meta/` guides that sub-agents can reference. These make every Claude Code session start faster and produce consistent handoffs between sessions.

For each item, **detect first, fill only if missing:**

- **`CLAUDE.md` structure** — if missing or lacks 작업 시작 규칙 / 작업 규칙 sections, propose adding them from [claude-root-template.md](./claude-root-template.md). Never overwrite existing content — merge only missing sections.
- **`TODO.md`** — if missing, propose creating from [todo-template.md](./todo-template.md).
- **`docs/meta/`** — if directory is missing or incomplete, propose creating:
  - `docs/meta/writing-guide.md` — single source of truth rules, no one-off reports
  - `docs/meta/efficiency-feedback.md` — reusable sub-agent prompt efficiency block
  - `docs/meta/spec-locations.md` — key file index (user fills in project-specific paths)

### 3. Confirm and edit

Show the user a draft of:

- The `## Agent skills` subsections being added (or the full block if it doesn't exist yet)
- Any new files: `TODO.md` / `docs/meta/*.md`
- Any sections being added to existing `CLAUDE.md`

Let them edit before writing.

### 4. Write

**Pick the file to edit:**

- If `CLAUDE.md` exists, edit it.
- Else if `AGENTS.md` exists, edit it.
- If neither exists, ask the user which one to create — don't pick for them.

Never create `AGENTS.md` when `CLAUDE.md` already exists (or vice versa) — always edit the one that's already there.

If an `## Agent skills` block already exists in the chosen file, **update its contents in-place** rather than appending a duplicate. Don't overwrite user edits to the surrounding sections.

For directories and files: only write if missing. Existing files are user-owned content — leave them.

### 5. Done

Tell the user the setup is complete and which skill will now operate against this layout:

- `efficient-subagent` will brief sub-agents to read `CLAUDE.md` → `CONTEXT.md`/`CONTEXT-MAP.md` → `docs/adr/` → `docs/meta/spec-locations.md`. In-flight decisions surface as `status: proposed` ADRs and require a heads-up before being changed.
- `CONTEXT.md` and `docs/adr/` themselves are created on demand by `grill-with-docs` — this skill doesn't pre-create them. If `setup-matt-pocock-skills` hasn't been run yet, suggest it next so consumer rules (`docs/agents/domain.md`) land too.

Mention they can edit any of these files directly later — re-running this skill is only necessary to refresh the `## Agent skills` block.

## Anti-patterns (do not do)

- Overwriting existing `CLAUDE.md` sections or the `## Agent skills` block without confirming.
- Creating both `CLAUDE.md` and `AGENTS.md`.
- Creating a second `## Agent skills` heading when `setup-matt-pocock-skills` already produced one — merge subsections into the existing heading instead.
- Pre-seeding `CONTEXT.md` or `docs/adr/` files. Those are consumed via `setup-matt-pocock-skills` rules and created lazily by `grill-with-docs`.
- Adding `TODO.md` items — the template is a blank scaffold; the user populates it.