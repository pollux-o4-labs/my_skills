> These subsections coexist with any block produced by `setup-matt-pocock-skills` (Issue tracker / Triage labels / Domain docs). Merge under the same `## Agent skills` heading — do not create a second one. `Domain docs` from matt-pocock covers `CONTEXT.md` / `docs/adr/` consumer rules; the entry below adds the ADR write-side convention.

## Agent skills

### Sub-agent discipline

When spawning a sub-agent via the Agent tool, include in the prompt: "Load the `efficient-subagent` skill before starting." That skill enforces context-absorption order, scope discipline, and a tight reporting format so results stay usable.

Reusable efficiency block for sub-agent prompts: `docs/rules/efficiency-feedback.md`.

### ADR status lifecycle

ADRs in `docs/adr/` carry a `status:` field — `proposed` while options are still being weighed, `accepted` once finalised, `superseded by 000M` when reversed. In-flight decisions live alongside finalised ones; no separate plans layer.

### Handoff ownership

`docs/handoff/` follows `AIL-handoff-topic-index` — one list index (`docs/handoff/README.md`) fronting per-topic detail files. Each index line carries item · one-line description · status, where status includes which branch/sub-agent currently owns an in-flight topic and when it was reclaimed (merged back). Splice the affected line on update — never rewrite the whole index. Backlog priority (P0/P1/P2) is not tracked here — that's the issue tracker's job.

### Folder navigation

No central index — each major folder (repo root, `{area}/`, `docs/`, etc.) carries its own `README.md` describing its contents. Check the folder's `README.md` before searching blindly.

### Docs rules

`docs/rules/writing.md` — single source of truth, no one-off reports. Split by concern — never fold everything into one growing doc.
