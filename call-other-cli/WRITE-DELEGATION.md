# Write Delegation

Codex with `-s workspace-write` can do **real coding work** — write, edit, run, diagnose, fix — production-grade. Tested 2026-05-13 with codex 0.130 / gpt-5.5:

- **New files + run script + assert**: 4,359 tokens, clean, no over-engineering
- **In-place edit of file with UTF-8 BOM**: first patch failed (line-match miss), codex *self-diagnosed* ("line endings or whitespace differ"), inspected raw bytes, retried, succeeded
- **Deliberate syntax error → run → diagnose → fix → re-run**: 5,551 tokens, full iteration loop autonomous

See [INVOCATION-PATTERNS.md](./INVOCATION-PATTERNS.md) for full write-mode invocation examples (`$cwd` + heredoc prompt for codex, `yolo` for gemini).

## Sub-agent capability notes (verified)

- **codex 0.130**: native `SpawnAgent` primitive works. OS-subprocess recursion blocked by sandbox (correct behavior).
- **gemini 0.42**: native `invoke_agent` (`generalist` / `codebase_investigator` / `cli_help`) exists — confirmed by gemini's own fuzzy-match suggestion when other tools fail. **Blocked in plan mode** by policy. Treat as plausible but not externally verified for actual quality.
- **Claude Code (this CLI)**: Agent tool. Use it for *internal* sub-agents instead of this skill.
