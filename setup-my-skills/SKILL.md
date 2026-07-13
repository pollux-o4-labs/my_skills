---
name: setup-my-skills
disable-model-invocation: true
description: Bootstrap a repo with the layout `efficient-subagent` assumes — an `## Agent skills` block (sub-agent discipline + ADR status convention) in `CLAUDE.md`/`AGENTS.md`, plus `docs/handoff/` (per `AIL-handoff-topic-index`), `docs/rules/`, and per-folder `README.md` navigation. Use when adding these skills to a new project; coexists with `setup-matt-pocock-skills`.
---

# Setup My Skills

Scaffold the per-repo artifacts that `efficient-subagent` assumes. Prompt-driven, not a script: explore → present → confirm → write. Never overwrite existing user content.

- **Agent-skills index** — an `## Agent skills` block in `CLAUDE.md` or `AGENTS.md` carrying Sub-agent discipline rules and the ADR `status: proposed/accepted` convention. Merges into the heading `setup-matt-pocock-skills` produces — never create a second `## Agent skills` heading.
- **Claude workflow scaffold** — slim `CLAUDE.md` structure (한국어), `docs/handoff/` (`AIL-handoff-topic-index` convention: one list index + topic files, tracking which branch/sub-agent owns a topic and when it was reclaimed/merged back), `docs/rules/` (one file per concern), and per-folder `README.md` navigation.

**Deliberately not scaffolded:**

- Backlog priority (P0/P1/P2, `TODO.md`) — owned by `setup-matt-pocock-skills` via GitHub Issues + triage labels; a local `TODO.md` would be a second, driftable copy.
- `CONTEXT.md` / `docs/adr/` bodies — consumer rules live in `docs/agents/domain.md` (`setup-matt-pocock-skills`); the files themselves are created lazily by `grill-with-docs`. Pre-seeded stubs would conflict with that.
- `docs/meta/` or any central "what's where" index — a single index for the whole repo goes stale and bloats; each folder's own `README.md` documents it instead.

## Process

### 1. Explore

Read the starting state; don't assume:

- `CLAUDE.md` / `AGENTS.md` at root — does either exist? already has an `## Agent skills` block (possibly from `setup-matt-pocock-skills`)? has 작업 시작 규칙 / 작업 규칙 sections?
- `docs/handoff/` — exists? index follows `AIL-handoff-topic-index` (list, one line per topic file)? a leftover `TODO.md` that should retire to GitHub Issues?
- `docs/rules/` — which of `writing.md`, `efficiency-feedback.md` exist? a leftover `docs/meta/` to migrate?
- Major folders (root, each `{area}/`, `docs/`) — already carrying a `README.md`?
- `docs/agents/` — signals `setup-matt-pocock-skills` already ran; note it so the block merges instead of duplicating.

### 2. Present findings and ask

Summarise present/missing in a short table, then walk the user through the two sections **one at a time**. Assume the user does not know what every term means — each section opens with a short explainer, then the choices and the default.

**Section A — `## Agent skills` block.**

> Explainer: a section in `CLAUDE.md` / `AGENTS.md` telling future sessions and sub-agents how to discipline sub-agents and which ADR `status` convention to follow. If `setup-matt-pocock-skills` already added its subsections (Issue tracker / Triage labels / Domain docs), this skill's subsections (Sub-agent discipline / ADR status lifecycle / Handoff ownership / Folder navigation / Docs rules) merge into the **same** heading.

Seed from [agent-skills-block.md](./agent-skills-block.md); adapt language (English / the user's working language) before writing.

**Section B — Claude workflow scaffold.**

> Explainer: lightweight session conventions — a slim `CLAUDE.md` separating root rules from sub-area rules, a `docs/handoff/` topic-index (who owns/reclaimed which in-flight topic) for cross-session continuity, and `docs/rules/` guides sub-agents can reference.

Detect first, fill only if missing:

- **`CLAUDE.md` structure** — merge missing 작업 시작 규칙 / 작업 규칙 sections from [claude-root-template.md](./claude-root-template.md); never overwrite existing content.
- **`docs/handoff/`** — create from [handoff-index-template.md](./handoff-index-template.md); the index starts empty, topic files come with actual work.
- **`docs/rules/`** — `writing.md` (single source of truth, no one-off reports) and `efficiency-feedback.md` (reusable sub-agent prompt block); one file per concern as rules accumulate, never one bloated doc.
- **Per-folder `README.md`** — for each major folder missing one, propose a short description of that folder's contents.

### 3. Confirm and edit

Show drafts of the `## Agent skills` subsections, any new files (`docs/handoff/README.md` / `docs/rules/*.md` / new `README.md`s), and any sections added to existing `CLAUDE.md`. Let the user edit before writing.

### 4. Write

Edit `CLAUDE.md` if it exists, else `AGENTS.md`; if neither exists, ask the user which to create — don't pick for them. Never create the second one when the other already exists. If an `## Agent skills` block exists, **update in place** — no duplicate heading, no touching surrounding user content. Directories and files: write only if missing; existing files are user-owned.

### 5. Done

Report completion and what now operates against this layout:

- `efficient-subagent` briefs sub-agents to read `CLAUDE.md` → `CONTEXT.md`/`CONTEXT-MAP.md` → `docs/adr/` → the target folder's own `README.md`. `status: proposed` ADRs mean in-flight areas needing a heads-up before change.
- If `setup-matt-pocock-skills` hasn't run yet, suggest it next so consumer rules land too.

Mention that re-running this skill is only needed to refresh the `## Agent skills` block.

## Anti-patterns (do not do)

- Overwriting existing `CLAUDE.md` sections or the `## Agent skills` block without confirming.
- Creating both `CLAUDE.md` and `AGENTS.md`, or a second `## Agent skills` heading.
- Pre-seeding anything on the "deliberately not scaffolded" list, or `docs/handoff/` topic files — only the empty index is scaffolded.
