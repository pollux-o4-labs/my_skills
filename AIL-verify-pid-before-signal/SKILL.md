---
name: AIL-verify-pid-before-signal
description: "Verify process identity (cmdline marker match, fail-closed) before signaling or classifying liveness of any pid read from a recorded source — pidfile, activity ledger, saved state — because the OS recycles pids and a stale record can point at an innocent process. Use when implementing or reviewing stop/cleanup/reap/monitor paths that act on a stored pid."
version: 1.2.0
metadata:
  provenance: AIL
  platforms: [claude-code, codex, gemini-cli]
---

# Verify PID Before Signal

A pid you *recorded* is a name, not a handle. If the recording process crashed before cleaning up, the OS may hand that number to an unrelated process — then `kill <pid>` murders a bystander and `os.kill(pid, 0)` "alive" checks classify a ghost as running. Both failures report **success**. Never act on a stored pid without confirming the process is still yours.

**User override:** not absolute — if the user, owning the context, explicitly waives the check, comply, but state in one line that a recycled pid could then signal a bystander; the guarantee is theirs to waive.

## When to Use

- Writing or reviewing a stop/shutdown path that reads a pidfile and sends a signal.
- A cleanup/reap routine or monitor that decides "dead or alive" from recorded pids (activity ledgers, job tables).

**Do NOT use** for a pid you just obtained from a live handle you own (`subprocess.Popen.pid` still in scope) — ownership is inherent there.

## Procedure

1. **Identity-check before any action.** Read the process's command line (`/proc/<pid>/cmdline` on Linux; platform equivalent elsewhere) and require a marker proving it's your program. Four verdicts, each with its own handling:
   - **match** → safe to signal / count as live.
   - **alien** (alive but not yours) → stale-confirmed: clean the record, do NOT signal.
   - **gone** (no such process) → stale-confirmed: clean the record.
   - **unknown** (unreadable, e.g. EACCES) → **fail-closed**: don't signal, don't delete the record, exit nonzero with manual guidance.
   ```python
   try:
       raw = open(f"/proc/{pid}/cmdline", "rb").read()
   except FileNotFoundError:
       verdict = "gone"          # standard /proc only — under hidepid=2 a hidden LIVE process also raises this: treat as unknown there
   except OSError:
       verdict = "unknown"       # fail-closed: no signal, keep record, exit nonzero
   else:
       args = raw.split(b"\0")
       verdict = "match" if b"myapp.cli" in args else "alien"  # exact argv element, not a substring
   ```
   Check→signal still races with process exit — keep `ProcessLookupError` handling at the kill site as the final backstop. Scope: a pid is checkable only where it was recorded (same host and pid namespace); cross-host records need a host/boot-id pairing or a lease/heartbeat instead.
2. **Back-stop the unverifiable with an age cap.** Monitors that must classify (not signal) treat unknown as still-live, but bound it: entries older than N× the operation's own timeout are stale regardless — otherwise one unreadable pid stays "running" forever.
3. **Exempt the reader's own pid** — it cannot be a recycled instance of itself.

## Pitfalls

- **"kill then handle the error" feels safe** — it isn't: SIGTERM to a recycled pid *succeeds*, so no error ever fires. Anchor: an adversarial review wrote a `sleep` process's pid into a stale pidfile; the stop command SIGTERMed it and printed "graceful shutdown in progress", rc=0.
- **Liveness ≠ identity in monitors**: `kill(pid, 0)` success classified 2-day-old ghost entries as in-flight work; identity + age cap split 61 ghosts from the 1 genuinely live call.
- **Duplicate kill logic drifts**: two hand-rolled pidfile-kill sites got the guard in one and not the other — unify to a single implementation first, then guard it.

## Verification

- [ ] Every signal on a stored pid preceded by an identity verdict, with alien/gone/unknown handled distinctly (unknown fail-closed)?
- [ ] Unverifiable liveness bounded by an age cap where classification is required?
- [ ] A test proves refusal to kill an innocent pid (not just the happy path)?

---
*Origin: a vgo supervision session (2026-07) where an adversarial reviewer reproduced a stale-pidfile stop command killing an innocent `sleep` with rc=0, and the same identity helper then split 61 ledger ghosts from 1 live LLM call.*
