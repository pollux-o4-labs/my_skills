## Agent skills

### Sub-agent discipline

When spawning a sub-agent via the Agent tool, include in the prompt: "Load the `efficient-subagent` skill before starting." That skill enforces context-absorption order, scope discipline, and a tight reporting format so results stay usable.

Reusable efficiency block for sub-agent prompts: `docs/meta/efficiency-feedback.md`.

### Plan lifecycle

In-flight decisions live in `docs/plans/*.md` using the canonical structure (decision table, done criteria, progress log). All edits to decision status, progress entries, and archival go through the `update-plan` skill — do not hand-edit ad-hoc.

### Domain & decisions

- **Domain glossary**: `CONTEXT.md` (single-context) or `CONTEXT-MAP.md` (multi-context). Sub-agents use these terms verbatim.
- **Finalised architectural decisions**: `docs/adr/`.
- **In-flight decisions**: `docs/plans/`. Graduate to ADRs on resolution.
- **Key file index**: `docs/meta/spec-locations.md` — check here before searching the codebase.
- **Docs rules**: `docs/meta/writing-guide.md` — single source of truth, no one-off reports.
