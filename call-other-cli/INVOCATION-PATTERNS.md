# Invocation Patterns (codex 0.130 / gemini 0.42, verified 2026-05-13)

Check memory for version drift before invoking:
→ `~/.claude/projects/<slug>/memory/reference_codex_gemini_cli.md`

## codex — stable, simple

```powershell
# Standard: stdin pipe
"prompt here" | codex exec --skip-git-repo-check

# Write needed (file modification): explicitly elevate sandbox
"prompt" | codex exec --skip-git-repo-check -s workspace-write

# Specific model
"prompt" | codex exec --skip-git-repo-check -m gpt-5.5
```

Default sandbox = read-only. Write attempts fail *gracefully* — model reports it and exits clean (no hang). Codex calls often take 60–120s and emit `Reading prompt from stdin...` first. Use `run_in_background: true` for long calls.

## gemini — fragile, requires guards

```powershell
# REQUIRED: workspace trust (first call per workspace)
$env:GEMINI_CLI_TRUST_WORKSPACE='true'

# CORRECT: --approval-mode plan FIRST, then -p with prompt string
gemini --approval-mode plan -p "prompt here"

# Tool calls completely disabled (safest — paste content inline):
gemini --approval-mode plan -p "Summarize this text: ..."
```

**Critical gemini flags**:
- `--approval-mode plan` — auto-approves read-only tools. **Without this, headless calls hang on tool invocation.** Default mode tries to prompt for approval; stdin can't answer; retry loop ensues.
- `-p <string>` is a *value-taking* option. Place AFTER other flags or it eats the next flag as its value. (`gemini -p --approval-mode X` fails: "Not enough arguments following: p".)
- `--include-directories <path>` if the task needs file paths *outside* cwd. Without it, even plan mode can't read external files.

## Bulletproof gemini pattern (paste inline — sidesteps all failure modes)

```powershell
$body = Get-Content 'path\to\file.md' -Raw -Encoding UTF8
$prompt = "Do not call any tools. Below is the file content; summarize in 3 bullets.`n---`n$body`n---"
$prompt | gemini -p -
```

For any gemini delegation that needs file context, prefer this pattern over passing file paths.

## Write mode invocation

```powershell
# codex — explicit workdir + workspace-write sandbox
$cwd = 'C:\path\to\isolated\workdir'
$prompt = @"
Working in cwd. Do the following in order:
1. <action>
2. <action>
3. Run <verify command> and report exit code and stdout.
4. List files at end.
"@
$prompt | codex exec --skip-git-repo-check -s workspace-write -C $cwd

# gemini — yolo + cwd set in shell. Watch for over-engineering.
$cwd = 'C:\path\to\isolated\workdir'
$env:GEMINI_CLI_TRUST_WORKSPACE='true'
Set-Location $cwd
gemini --approval-mode yolo -p "<same kind of prompt>"
```
