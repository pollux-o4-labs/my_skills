---
name: setup-my-skills
description: Bootstrap a repo for the `efficient-subagent` and `update-plan` skills — scaffold `CONTEXT.md`, `docs/adr/`, `docs/plans/`, and add an `## Agent skills` block to `CLAUDE.md`/`AGENTS.md`. Use when adding these skills to a new project, or when a repo is missing the artifacts these skills depend on.
---

# Setup My Skills

Scaffold the per-repo artifacts that `efficient-subagent` and `update-plan` assume:

- **Domain glossary** — `CONTEXT.md` (single-context) or `CONTEXT-MAP.md` + per-context files (multi-context). Sub-agents read this to use the project's terms verbatim.
- **Decision logs** — `docs/adr/` for finalised decisions, `docs/plans/` for in-flight ones. `update-plan` operates on this layout.
- **Agent-skills index** — a `## Agent skills` block in `CLAUDE.md` or `AGENTS.md` so future sessions and sub-agents discover these conventions on first read.

Prompt-driven skill, not a script. Explore → present → confirm → write. Never overwrite existing user content.

## Process

### 1. Explore

Look at the repo's starting state. Read what exists; don't assume:

- `CLAUDE.md` and `AGENTS.md` at the repo root — does either exist? Is there already an `## Agent skills` block in either?
- `CONTEXT.md` and `CONTEXT-MAP.md` at the repo root
- `docs/adr/` — does it exist? Any ADRs already?
- `docs/plans/` — does it exist? Any plans already? Any `README.md` inside?
- `git remote -v` — orienting info only; this skill does not write anything to remote.

### 2. Present findings and ask

Summarise what's present and what's missing in a short table. Then walk the user through two decisions **one at a time** — present a section, get the user's answer, then move to the next. Don't dump both at once.

Assume the user does not know what every term means. Each section starts with a short explainer (what it is, why these skills need it, what changes with a different pick). Then show the choices and the default.

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

> Explainer: A single section at the top of `CLAUDE.md` / `AGENTS.md` that tells future sessions and sub-agents how these skills fit. Without it, sub-agents brief-loaded with `efficient-subagent` would still know *how* to behave, but not *which* internal artifacts to consult. This block is the index.

Use [agent-skills-block.md](./agent-skills-block.md) as the seed. Adapt language (English / the user's working language) before writing.

### 3. Confirm and edit

Show the user a draft of:

- The `## Agent skills` block to add to whichever of `CLAUDE.md` / `AGENTS.md` is being edited (see step 4 for selection rules)
- Any new files being created in `CONTEXT.md` / `CONTEXT-MAP.md` / `docs/adr/README.md` / `docs/plans/README.md`

Let them edit before writing.

### 4. Write

**Pick the file to edit:**

- If `CLAUDE.md` exists, edit it.
- Else if `AGENTS.md` exists, edit it.
- If neither exists, ask the user which one to create — don't pick for them.

Never create `AGENTS.md` when `CLAUDE.md` already exists (or vice versa) — always edit the one that's already there.

If an `## Agent skills` block already exists in the chosen file, **update its contents in-place** rather than appending a duplicate. Don't overwrite user edits to the surrounding sections.

For directories and files in `CONTEXT.md` / `docs/adr/` / `docs/plans/`: only write if missing. Existing files are user-owned content — leave them.

### 5. Done

Tell the user the setup is complete and which skills will now operate against this layout:

- `efficient-subagent` will brief sub-agents to read `CLAUDE.md` → `CONTEXT.md`/`CONTEXT-MAP.md` → `docs/adr/` → `docs/plans/`.
- `update-plan` will maintain `docs/plans/*.md` per its procedure.

Mention they can edit `CONTEXT.md` / `docs/adr/*` / `docs/plans/*` directly later — re-running this skill is only necessary to refresh the `## Agent skills` block or migrate single-context ↔ multi-context.

## Anti-patterns (do not do)

- Overwriting existing `CONTEXT.md`, ADRs, plans, or the `## Agent skills` block without confirming.
- Creating both `CLAUDE.md` and `AGENTS.md`.
- Bundling matt-pocock's `setup-matt-pocock-skills` outputs here — those concern external issue trackers and triage labels, and are a separate skill.
- Writing decision content into the seed `README.md` files. Seeds are scaffolds, not decisions.
