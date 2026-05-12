> These subsections coexist with any block produced by `setup-matt-pocock-skills` (Issue tracker / Triage labels / Domain docs). Merge under the same `## Agent skills` heading — do not create a second one. `Domain docs` from matt-pocock covers `CONTEXT.md` / `docs/adr/` consumer rules; the entry below adds the ADR write-side convention.

## Agent skills

### Sub-agent discipline

When spawning a sub-agent via the Agent tool, include in the prompt: "Load the `efficient-subagent` skill before starting." That skill enforces context-absorption order, scope discipline, and a tight reporting format so results stay usable.

Reusable efficiency block for sub-agent prompts: `docs/meta/efficiency-feedback.md`.

### ADR status lifecycle

ADRs in `docs/adr/` carry a `status:` field — `proposed` while options are still being weighed, `accepted` once finalised, `superseded by 000M` when reversed. In-flight decisions live alongside finalised ones; no separate plans layer.

### Key file index

`docs/meta/spec-locations.md` — check here before searching the codebase.

### Docs rules

`docs/meta/writing-guide.md` — single source of truth, no one-off reports.
