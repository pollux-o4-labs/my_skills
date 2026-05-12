---
name: setup-my-skills
description: Bootstrap a repo for `efficient-subagent` and `update-plan` skills — scaffold `CONTEXT.md`, `docs/adr/`, `docs/plans/`, a slim `CLAUDE.md` structure, `TODO.md` backlog format, and `docs/meta/` workflow guides. Add an `## Agent skills` block to `CLAUDE.md`/`AGENTS.md`. Use when adding these skills to a new project, or when a repo is missing the artifacts these skills depend on.
---

# Setup My Skills

Scaffold the per-repo artifacts that `efficient-subagent` and `update-plan` assume:

- **Domain glossary** — `CONTEXT.md` (single-context) or `CONTEXT-MAP.md` + per-context files (multi-context). Sub-agents read this to use the project's terms verbatim.
- **Decision logs** — `docs/adr/` for finalised decisions, `docs/plans/` for in-flight ones. `update-plan` operates on this layout.
- **Agent-skills index** — a `## Agent skills` block in `CLAUDE.md` or `AGENTS.md` so future sessions and sub-agents discover these conventions on first read.
- **Claude workflow scaffold** — slim `CLAUDE.md` structure, `TODO.md` backlog with T-XX IDs, and `docs/meta/` guides (writing rules, sub-agent efficiency block, key file index).

Prompt-driven skill, not a script. Explore → present → confirm → write. Never overwrite existing user content.

## Process

### 1. Explore

Look at the repo's starting state. Read what exists; don't assume:

- `CLAUDE.md` and `AGENTS.md` at the repo root — does either exist? Is there already an `## Agent skills` block in either? Does it have 작업 시작 규칙 / 작업 규칙 sections?
- `CONTEXT.md` and `CONTEXT-MAP.md` at the repo root
- `TODO.md` — does it exist? Does it use the T-XX ID format?
- `docs/adr/` — does it exist? Any ADRs already?
- `docs/plans/` — does it exist? Any plans already? Any `README.md` inside?
- `docs/meta/` — does it exist? Which of `writing-guide.md`, `efficiency-feedback.md`, `spec-locations.md` are present?
- `git remote -v` — orienting info only; this skill does not write anything to remote.

### 2. Present findings and ask

Summarise what's present and what's missing in a short table. Then walk the user through three decisions **one at a time** — present a section, get the user's answer, then move to the next.

Assume the user does not know what every term means. Each section starts with a short explainer. Then show the choices and the default.

**Section A — Domain & decision-log layout.**

> Explainer: `efficient-subagent` directs sub-agents to read `CONTEXT.md` → `docs/adr/` → `docs/plans/` before touching code, so they use the project's domain language and don't re-litigate decided questions. `update-plan` maintains decision tables and progress logs inside `docs/plans/*.md`. These directories need to exist with a minimum skeleton or the skills have nothing to point at.

For each item below, **detect first, fill only if missing.** If the file/dir already exists, do not touch it unless the user explicitly asks.

- **`CONTEXT.md`** — if missing, propose creating a stub from [context-stub.md](./context-stub.md). The user fills in glossary entries later.
- **`docs/adr/`** — if missing, propose creating the directory + a `README.md` from [adr-readme.md](./adr-readme.md).
- **`docs/plans/`** — if missing, propose creating the directory + a `README.md` from [plans-readme.md](./plans-readme.md) (this points at the `update-plan` skill's `PLAN-TEMPLATE.md`).

Also ask: **single-context or multi-context?**

- **Single-context** — one `CONTEXT.md` at the repo root. Most repos.
- **Multi-context** — `CONTEXT-MAP.md` at the root pointing to per-context `CONTEXT.md` files. Usually monorepos with separate frontend/backend.

If multi-context, create `CONTEXT-MAP.md` instead of `CONTEXT.md`; the user fills in the map.

**Section B — `## Agent skills` block in `CLAUDE.md` / `AGENTS.md`.**

> Explainer: A single section in `CLAUDE.md` / `AGENTS.md` that tells future sessions and sub-agents which skills are configured and where each skill looks for its artifacts. Without it, sub-agents brief-loaded with `efficient-subagent` would still know *how* to behave, but not *which* internal artifacts to consult.

Use [agent-skills-block.md](./agent-skills-block.md) as the seed. Adapt language (English / the user's working language) before writing.

**Section C — Claude workflow scaffold.**

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

- The `## Agent skills` block
- Any new files: `CONTEXT.md` / `CONTEXT-MAP.md` / `docs/adr/README.md` / `docs/plans/README.md` / `TODO.md` / `docs/meta/*.md`
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

Tell the user the setup is complete and which skills will now operate against this layout:

- `efficient-subagent` will brief sub-agents to read `CLAUDE.md` → `CONTEXT.md`/`CONTEXT-MAP.md` → `docs/adr/` → `docs/plans/` → `docs/meta/spec-locations.md`.
- `update-plan` will maintain `docs/plans/*.md` per its procedure.

Mention they can edit any of these files directly later — re-running this skill is only necessary to refresh the `## Agent skills` block or migrate single-context ↔ multi-context.

## Anti-patterns (do not do)

- Overwriting existing `CONTEXT.md`, ADRs, plans, `CLAUDE.md` sections, or the `## Agent skills` block without confirming.
- Creating both `CLAUDE.md` and `AGENTS.md`.
- Bundling matt-pocock's `setup-matt-pocock-skills` outputs here — those concern external issue trackers and triage labels, and are a separate skill.
- Writing decision content into the seed `README.md` files. Seeds are scaffolds, not decisions.
- Adding `TODO.md` items — the template is a blank scaffold; the user populates it.