---
name: call-other-cli
description: Delegate research, plan review, code review, or a "second opinion" to an external LLM CLI (codex or gemini) — for a fresh outside perspective or to protect the main session's context budget. Use when the user says "codex 한테 시켜", "gemini 로 검토", "외부 cli", "두번째 의견", "다른 LLM 한테 물어봐", "peer review", "ask codex", "delegate to codex/gemini", or asks for an independent review of a plan / patch / research question. Also use proactively when the main session's context is already heavy and a delegation would isolate the work.
---

# Call Other CLI

Delegate a *self-contained* unit of work (research / plan review / code review / second opinion) to **codex** or **gemini** CLI, then merge only the summary back into the main session. Goal: outside perspective + main-context protection, not raw speedup.

## When to delegate (4-condition gate)

Delegate only if **all four** hold:

- [ ] Work is *independently scoped* — no concurrent edits in main session on the same files
- [ ] Result will be a *summary*, not raw output (we don't pipe whole search dumps into main)
- [ ] Main context is *already heavy*, or we explicitly want an independent voice
- [ ] Completion criteria is one sentence ("does this plan miss X?")

If any condition is shaky → just do it in main. Delegation is not a speedup tool.

## Tool selection

| Task | Use | Why |
|---|---|---|
| Heavy research with citations, deep reasoning | **codex** (gpt-5.5) | High signal, plenty of links, ~80k tokens per call OK |
| Plan review / "spot what's wrong with this design" | **codex** | Reasoning model catches blind spots better |
| Quick summary / light text shaping / TL;DR | **gemini** | Faster, cheaper, terser — but read failure-modes below |
| **Actual coding (write/edit/run/iterate)** | **codex** with `-s workspace-write` | Verified production-grade. See Write delegation section |
| Quick throwaway scaffold (no production code) | gemini `--approval-mode yolo` | Works but tends to over-engineer. Don't use for production |
| When two opinions are explicitly wanted | **both in parallel** | Compare answers — disagreement is the signal |

## Invocation (codex 0.130 / gemini 0.42, verified 2026-05-13)

```powershell
# codex read
"prompt" | codex exec --skip-git-repo-check
# codex write
"prompt" | codex exec --skip-git-repo-check -s workspace-write -C $cwd
# gemini read ($env:GEMINI_CLI_TRUST_WORKSPACE='true' required first)
gemini --approval-mode plan -p "prompt"
```

codex *fails clean* on every restriction. Gemini *fails messy* — always add `--approval-mode plan`. See [INVOCATION-PATTERNS.md](./INVOCATION-PATTERNS.md) for full code blocks, critical flags, and bulletproof paste-inline pattern.

## Write delegation

### Use when ALL of these hold

- [ ] Workdir is *isolated*: temp folder, new sub-module dir, or a folder with no concurrent edits
- [ ] Task is *self-contained*: doesn't cross-cut multiple modules / conventions
- [ ] Prompt includes a *verify step* (run tests, exec the script, check output) — without this, the delegate has no feedback loop
- [ ] You (Claude) will *read back the result* and validate before merging into the main project

### Do NOT write-delegate when

- Active edits on the same files in the main session (you'll lose your changes when the delegate's patch lands)
- Task requires deep knowledge of project conventions / domain language (delegate doesn't read CLAUDE.md / CONTEXT.md unless you embed them in the prompt)
- Result must match a specific style — gemini over-engineers, codex is closer to minimal but still not your style
- You can't verify the result automatically (file diff + test exec) — manual review of arbitrary writes is friction that often exceeds delegation gain

### Claude's role

1. Claude picks the workdir (isolation guarantee)
2. Claude writes the prompt (scope, verify step, output format)
3. Delegate executes — writes files, runs commands, iterates on failures
4. **Claude reads the result back** (file content + delegate's report) and validates
5. Claude decides whether to merge into the main project tree

→ Verified results + full invocation examples: [WRITE-DELEGATION.md](./WRITE-DELEGATION.md)

## Prompt template

Brief the CLI like a smart colleague who just walked in.

```
ROLE: <one-line — "you are reviewing a plan for X", "you are researching Y">
CONTEXT:
  <links, file excerpts, decisions already made — keep tight>
TASK:
  <one sentence: what to produce>
OUTPUT FORMAT:
  <bullet list / table / numbered findings / max N words>
```

Skip role-play padding ("you are a senior engineer..."). Model already knows.

## After delegation — main-session discipline

1. **Do not pipe raw output into the main response.** Read it, then write a 3–8 line *summary in your own voice* + the verbatim verdict line.
2. **Cite the delegate** ("codex 의견: ...") so the user can audit.
3. **Save the raw output** to a temp file if it's worth keeping — never bury it in the conversation.
4. If two CLIs disagree, surface the disagreement explicitly — do not silently pick one.
5. **Kill stalled delegates after ~30s of silence** — almost always gemini in retry loop. Diagnose from the partial output (`Error executing tool ...` is the signal).

## When NOT to use this skill

- Trivial questions answerable in main with one Grep
- Tasks where the user wanted *you* (Claude) specifically — don't outsource the user's actual request
- "Just to be sure" reviews when nothing is uncertain — that's procrastination, not delegation
- Asking gemini to execute shell commands or run code (the tool doesn't exist there — use codex)
- Plan-review or code-review delegations to gemini *without* paste-inline pattern (default approval mode + file paths = retry loop)
- Production code through gemini — yolo works but consistently over-engineers. Project convention drift is near-guaranteed.
- Write delegation without an isolated workdir or without a verify step in the prompt — both are mandatory safety gates

## Related

- [INVOCATION-PATTERNS.md](./INVOCATION-PATTERNS.md) — full code blocks, critical flags, bulletproof paste-inline pattern, write-mode examples
- [FAILURE-MODES.md](./FAILURE-MODES.md) — gemini failure modes table, codex limits
- [WRITE-DELEGATION.md](./WRITE-DELEGATION.md) — verified results, full write invocation examples, sub-agent notes
- Memory: `reference_codex_gemini_cli.md` — current verified invocation patterns
- Skill: `efficient-subagent` — for *internal* sub-agents (Agent tool), different mechanism
- Doc: `multi_agents_guide/03-for-ai.md` — R4 delegation rules
- Doc: `multi_agents_guide/02-synthesis.md` — full reasoning behind the 4-condition gate

**When to open each bundle**:
- CLI call fails or hangs → `FAILURE-MODES.md`
- Need exact syntax / flags → `INVOCATION-PATTERNS.md`
- Setting up write delegation → `WRITE-DELEGATION.md`
