# Rationale — organize-agent-team

Provenance: session lesson (launch-inspection team, prompt-gen, 2026-07-13) — four `general-purpose` teammates spawned for tool access, dropping the plugin definitions' pinned model tier (two user corrections); four idle-without-report incidents fixed by a SendMessage-before-exit prompt clause; two crossed-message stale verdicts fixed by fix-marker preconditions. Reshaped from an AIL auto-gate into a user-invoked workflow (2026-07-13 review): the user triggers organization explicitly ("organize a team"), so recall is on the user — `disable-model-invocation: true`, no `AIL-` prefix, registered via the `sync-skills/claude-skills.txt` manifest.

## The registry this skill targets (measured 2026-07-13)

Originating machine: WSL, marketplace `claude-code-workflows` (github: wshobson/agents), 14 plugins installed. Inventory record: `/home/pollux/work/pollux-o4-labs/installed-plugins.txt`.

- **Layout**: `~/.claude/plugins/cache/<marketplace>/<plugin>/<version>/` containing `agents/*.md` (typed agent definitions), `commands/*.md` (slash commands), and for some plugins `skills/` (e.g. `agent-teams` ships team-composition-patterns, team-communication-protocols, task-coordination-strategies, …).
- **Agent definition shape**: frontmatter (`name`, `description`, `tools`, `model`, `color`) + body doctrine — a full role system prompt. Example: `team-lead` pins `model: opus`, declares team tools (`Agent`, `TeamCreate`, `TaskCreate`, `SendMessage`, …), and carries decomposition/file-ownership doctrine.
- **Installed inventory**: 35 agents across 14 plugins. Model pins: **opus 16 / sonnet 7 / haiku 1 / inherit 11**. Only 5 agents declare `tools:`; the rest inherit all tools.
- **Commands package whole workflows**: e.g. `/team-feature` = pre-flight checks → analysis → decomposition with exclusive file ownership → spawn typed teammates → integration verification. The sanctioned path to "organize a team" often already exists as a command, not just as agents.
- `~/.claude/agents/` is empty on that machine — every typed agent loads from plugin cache, so the registry is invisible unless deliberately enumerated.

## Why the failure recurs

- Unset `model` on a spawn call means *inherit the session model*. With 16/35 installed agents pinned to opus by their authors, generic substitution silently rewrites the cost/capability profile the plugin author chose — in either direction, depending on the session model.
- Tool need is the usual trigger: one teammate missing one tool → the whole team spawned generic → every pin dropped (the original incident's exact shape).
- Most of a definition's value sits in the body doctrine, which never surfaces in agent listings — only the description does. Without opening the file, a typed agent looks interchangeable with a generic one.

## Team Runtime section

The messaging-teammate rules (SendMessage-before-exit, idle-ping, fix-marker precondition) come from the same incident's runtime failures. They live in this skill because they only bite when a team is actually organized — the moment this skill governs.
