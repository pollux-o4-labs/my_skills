# Failure Modes

## Known gemini failure modes (verified by direct testing)

| Mode | Symptom | Cause | Workaround |
|---|---|---|---|
| **Silent retry loop** | stdout shows a few `Error executing tool ...` lines then stalls forever | Default approval mode + tool calls in headless context — CLI waits on a prompt that can never be answered | `--approval-mode plan` *always*. Kill the process if no output after ~30s |
| **Path outside workspace** | `Path not in workspace: Attempted path "X" resolves outside the allowed workspace directories` | gemini restricts file tools to cwd + `~/.gemini/tmp/<project>/` | `--include-directories <path>` OR paste content inline in the prompt |
| **Missing `run_shell_command`** | `Tool "run_shell_command" not found. Did you mean: invoke_agent` | gemini 0.42 has no shell-execution tool at all | Don't ask gemini to run commands. For "test this code" tasks, use codex |
| **`MODEL_CAPACITY_EXHAUSTED` (429)** | Long error JSON, retries with backoff, may eventually fail | Google Cloud server-side rate limit on `gemini-3.1-pro-preview` | Retry later, or switch to codex for the call |
| **invoke_agent denied in plan mode** | `Tool execution denied by policy. You are in Plan Mode ... scripts blocked` | Plan mode treats agent scripts as side-effectful | If sub-agent delegation is required, use a non-plan approval mode — but then re-evaluate whether the call needs file tools at all |

## Codex limits (verified)

- **read-only sandbox by default** — `patch` / write tools fail with `writing is blocked by read-only sandbox`. Model reports clearly and exits (no hang).
- **OS-subprocess recursion blocked** — `codex exec` invoked *inside* another `codex exec` via shell is rejected by the inner sandbox. Use codex's native `SpawnAgent` primitive instead (model handles it automatically when needed).
- **ChatGPT-account model gating** — older codex versions (0.55) reject `gpt-5` for ChatGPT-account users. 0.130+ accepts `gpt-5.5`. If 400 errors mention "model is not supported when using Codex with a ChatGPT account", upgrade.
- **External paths**: codex can typically read outside cwd in read-only mode (no workspace-trust analogue to gemini's), but writes still require `-s workspace-write`.
- **Cloud-synced cwd**: when cwd is on Google Drive / OneDrive / a folder with non-ASCII Unicode (e.g. `I:\내 드라이브\...`), codex's Windows sandbox may fail `CreateProcessWithLogonW: 267` on the first shell-exec. Codex usually self-recovers by retrying with a different cwd, but prefer launching from a plain local NTFS path (`C:\Users\...\Desktop\...`) when possible.
