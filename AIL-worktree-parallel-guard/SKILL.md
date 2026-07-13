---
name: AIL-worktree-parallel-guard
description: "Guard rails for verifying code inside a secondary checkout (git worktree, extra clone) and for parallelizing implementation agents across them — an editable-installed package silently imports the primary checkout, so a green suite may have tested the wrong code. Use before running tests in a worktree, spawning parallel worktree workers, or attributing a worktree-only test failure."
version: 1.0.0
metadata:
  provenance: AIL
  platforms: [claude-code, codex, gemini-cli]
---

# Worktree Parallel Guard

A git worktree gives workers isolated *files*, but not an isolated *import path*: with an editable install (`pip -e`, `uv sync`), `import pkg` resolves to the **primary checkout**, so pytest run inside the worktree silently verifies code the worker never changed. Every downstream judgment (green suite, failure attribution, merge decision) is built on that sand unless you probe first.

## When to Use

- About to run tests or any verification inside a git worktree or secondary clone of a repo whose package is installed editable (or via any shared venv).
- About to spawn parallel implementation agents, each in its own worktree.
- A worktree test run behaves identically no matter what you change — or fails in ways the primary checkout doesn't.

**Do NOT use** for a single checkout with its own dedicated venv, or for worktrees that never execute the package (docs-only edits).

## Procedure

1. **Probe the import target before trusting any run.** Plant a sentinel (or just check the path) and assert where the module really loads from:
   ```bash
   PYTHONPATH="$WT/src" .venv/bin/python -c "import pkg; assert '/my-worktree/' in pkg.__file__, pkg.__file__"
   ```
   Run it once *without* the override too — seeing the primary path there confirms the shadowing is real, not hypothetical. Path-based editables (`.pth`) lose to `PYTHONPATH`; hook-based ones may not — the probe, not the mechanism, is the truth.
2. **Prefix every execution, not just the first.** Bake `PYTHONPATH=<wt>/src` (or the probe-verified equivalent) into the worker's standing instructions; a single unprefixed pytest silently re-tests the primary.
3. **Attribute worktree-only failures against clean base.** Worktrees fail for reasons of *location* (sibling-path assumptions, untracked assets, missing `.env`). Protocol: stash the diff, rerun the failing test in the same worktree — same failure ⇒ environment-inherent, not the change. Re-verify on the primary checkout after applying the change there; only that run counts as the gate.
4. **Partition parallel workers by file ownership.** Shared hot files that every task touches (ledgers, changelogs, status docs) are edit-forbidden for workers — they return splice-ready text, and the integrator splices at commit time. This deletes the guaranteed-conflict class instead of resolving it later.
5. **Serialize what shares a runtime.** A live server/daemon loads one code version; implementation parallelizes, but live verification and commits queue through the integrator, one change-set at a time.

## Pitfalls

- **Green-but-wrong suite**: worker reports "all pass" while the interpreter tested the primary checkout — probe-less parallel runs make every result unfalsifiable. Anchor: a supervisor session found `vgo.config.__file__` pointing at the main tree from inside a fresh worktree; one `PYTHONPATH` prefix flipped it.
- **Blaming the diff for the location**: a gate test failed in every worktree because a sibling repo existed next to the primary checkout only — stash-rerun proved it, and the same test passed on the primary after merge.
- **Resolving instead of preventing ledger conflicts**: letting N workers edit the shared status file "carefully" still collides; report-then-splice costs one paragraph per worker.
- Surprising results *after* these guards are in place → switch to [[AIL-verify-against-reality]] (stale layer / measurement debugging); this skill is the pre-flight, that one is the post-mortem.

## Verification

- [ ] Probe output shows the worktree path (and showed the primary path without the override)?
- [ ] Every worker command line carries the verified prefix, not just the first run?
- [ ] Worktree-only failures attributed via clean-base rerun, and the gate re-run on the primary checkout?
- [ ] Shared hot files untouched by workers — splice text reported instead?
- [ ] Live verification and commits serialized through one integrator?

---
*Origin: a vgo supervision session (2026-07) that measured editable-install shadowing before its first parallel worktree pair, then watched both stewards hit — and correctly attribute — the same environment-inherent test failure.*
