---
name: AIL-worktree-parallel-guard
description: "Guard rails for verifying code inside a secondary checkout (git worktree, extra clone) and for parallelizing implementation agents across them — an editable-installed package silently imports the primary checkout, so a green suite may have tested the wrong code. Use before running tests in a worktree, spawning parallel worktree workers, or attributing a worktree-only test failure."
version: 1.3.0
metadata:
  provenance: AIL
---

# Worktree Parallel Guard

A git worktree gives workers isolated *files*, but not an isolated *import path*: with an editable install (`pip -e`, `uv sync`), `import pkg` resolves to the **primary checkout**, so pytest run inside the worktree silently verifies code the worker never changed. Every downstream judgment (green suite, failure attribution, merge decision) is built on that sand unless you probe first.

## When to Use

- About to run tests inside a git worktree or secondary clone whose package is **installed editable** — the case where `import pkg` resolves to the primary checkout. (A *non-editable* shared venv imports the site-packages copy instead — neither checkout; the probe still applies, the "primary checkout" anchor does not.)
- About to spawn parallel implementation agents, each in its own worktree. (Spawn mechanics — recursion, placeholder-return, fan-out sizing → [[AIL-subagent-fanout-guard]]; this skill owns import-path correctness and shared-file partition.)
- A worktree test run behaves identically no matter what you change — or fails in ways the primary checkout doesn't.

**Do NOT use** for a single checkout with its own dedicated venv, or for worktrees that never execute the package (docs-only edits).

## Procedure

1. **Probe the import target before trusting any run.** Assert the loaded module lives under *this* worktree — the assert substring must be the same `$WT` you set, never a stray literal:
   ```bash
   : "${WT:?}"   # empty $WT makes the assert vacuously true — refuse to probe with it unset
   PYTHONPATH="$WT/src" .venv/bin/python -c "import pkg; assert '$WT' in pkg.__file__, pkg.__file__"
   ```
   (`.venv/bin/python` → `.venv/Scripts/python.exe` on Windows.) Run it once *without* the override too — seeing the primary path there confirms the shadowing is real, not hypothetical. Path-based editables (`.pth`) lose to `PYTHONPATH` while hook-based ones may not — so probe where the module *actually* loads, not the mechanism.
2. **Force the verified path on every execution** — baked into the worker's standing instructions; one unprefixed pytest silently re-tests the primary. Where you control the environment, a per-worktree venv (`pip install -e .` from that worktree into its own venv) removes the shared editable pointer structurally — prefer it, and keep the probe as the gate either way. *Override clause*: if the user declines the probe/prefix, comply and run as-is — the user outranks the rule — but note "unprefixed at your request; a green suite here may reflect the primary checkout, not this worktree's edits."
3. **Partition parallel workers by file ownership.** Shared hot files that every task touches (ledgers, changelogs, status docs) are edit-forbidden for workers — they return splice-ready text, and the integrator splices at commit time. This deletes the guaranteed-conflict class instead of resolving it later.
4. **Serialize what shares a runtime.** A live server/daemon loads one code version; implementation parallelizes, but live verification and commits queue through the integrator, one change-set at a time. The merge gate is a suite run from the primary checkout's own install — a worktree-local green never gates a merge.

## Pitfalls

- **Green-but-wrong suite**: worker reports "all pass" while the interpreter tested the primary checkout — probe-less parallel runs make every result unfalsifiable. Anchor: a supervisor session found `vgo.config.__file__` pointing at the main tree from inside a fresh worktree; one `PYTHONPATH` prefix flipped it.
- **Blaming the diff for the location**: worktrees fail for reasons of *location* (sibling-path assumptions, untracked assets, missing `.env`) — stash the diff and rerun before blaming the change; a gate test once failed in every worktree because a sibling repo existed next to the primary checkout only.
- **Resolving instead of preventing ledger conflicts**: letting N workers edit the shared status file "carefully" still collides; report-then-splice costs one paragraph per worker.
- Surprising results *after* these guards are in place → switch to [[AIL-verify-against-reality]] (stale layer / measurement debugging); this skill is the pre-flight, that one is the post-mortem.

## Verification

- [ ] The path pytest actually imported is proven to be this worktree on *every* run — or the unprefixed run was the user's call and the disclosure went with it?
- [ ] No merge counted as gated until the suite passed from the primary checkout's own install?
- [ ] Zero worker commits touched a shared hot file — the conflict was prevented, not resolved after?
- [ ] Nothing sharing a live runtime had two change-sets in flight at once?

## Cleanup Summons (PostToolUse hook)

Written rules don't summon themselves at cleanup time: "tidy up when done" fires at *worktree add* and never at *worktree remove*, so finished worktrees sit at multiple GB each. [hooks/worktree-cleanup-gate.sh](hooks/worktree-cleanup-gate.sh) pins the summons to the merge moment — it detects a local `gh pr merge` and emits one line asking the supervisor to clean up. It judges nothing (you just merged; you know which one) and deletes nothing — mutation stays with the supervisor.

**Install** (`~/.claude/settings.json` → `hooks.PostToolUse`; see `update-config`):
```json
{ "matcher": "Bash",
  "hooks": [{ "type": "command",
    "command": "bash \"<repo>/AIL-worktree-parallel-guard/hooks/worktree-cleanup-gate.sh\"",
    "timeout": 10 }] }
```
Point settings.json at the repo script (no copies to drift). Reload via `/hooks` or restart. Grounds: [docs/history/worktree-cleanup-gate.md](../docs/history/worktree-cleanup-gate.md).

---
*Origin: a vgo supervision session (2026-07) that measured editable-install shadowing before its first parallel worktree pair, then watched both stewards (the worktree worker agents) hit — and correctly attribute — the same environment-inherent test failure. The cleanup hook came later, from 47GB of merged-but-unremoved worktrees in the same repo.*
