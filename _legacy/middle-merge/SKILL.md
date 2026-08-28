---
name: middle-merge
description: "Defines the middle-merge git workflow for branch isolation, PR review layers, merge direction, and supervisor verification responsibilities. Use when repo root CLAUDE.md has the Git Workflow marker `middle-merge` and a supervisor is orchestrating sub-agent branch work; use `git-workflow-select` first when no workflow marker exists."
disable-model-invocation: true
---

# Middle-Merge Workflow

middle-merge is the selected repo workflow's detailed branch and verification policy. It sits above the general sub-agent discipline in `efficient-subagent` and must only run after the repo root `CLAUDE.md` declares `## Git Workflow: middle-merge`.

## Gate

- If the marker is `middle-merge`, apply this workflow.
- If the marker is missing or different, stop branch work and have the supervisor run `git-workflow-select`.
- Sub-agents do not choose or change the repo workflow.

## Branch Shape

```
main
 └─ middle-merge
     ├─ integration/<type>
     │   └─ <type>/<topic>
     │       └─ fix/<sub>
     ├─ mixed/<topic>
     └─ fix/<topic>
```

- `main`: permanent, receives squash commits only.
- `middle-merge`: permanent sub-main; do not delete or reset after main squash.
- `integration/*`: short-lived buckets for multi-PR work by commit type.
- `mixed/*`: short-lived cross-cutting work touching multiple commit types.
- `fix/*`: short-lived direct middle-merge branch for simple one-PR fixes.

## Isolation

- Direct middle-merge layer branches (`integration/*`, `mixed/*`, direct `fix/*`) default to shared root.
- Sub-branches below an integration branch default to worktree isolation.
- Use worktrees for concurrent file-conflicting work or large delete/rename work.
- Before switching shared-root branches, warn the supervisor that running processes may need restart and uncommitted changes may need stash.

## Review Chain

1. Worker sub-agent changes code, runs its own checks, and opens a PR.
2. Code-review sub-agent reviews the diff objectively.
3. Main supervisor synthesizes review findings and reports.
4. User/supervisor performs operational verification before merge.

Do not skip layer 2 by having the main supervisor directly review all PR diffs.

## Merge Rules

- sub-branch -> integration: `gh pr merge <N> --merge`.
- integration -> middle-merge: `gh pr merge <N> --merge`.
- direct `fix/*` -> middle-merge: `gh pr merge <N> --merge`.
- middle-merge -> main: `gh pr merge <N> --squash`.

Always spell the merge option. Omitting `--squash` on middle-merge -> main pollutes main history with merge commits.

## Supervisor Verification

- Pure logic, helper, type, import, and mockable integration work can be AI end-to-end with worker checks plus supervisor regression confirmation.
- Operational UI, external systems, hardware, and UX scenarios require supervisor/user real verification.
- Verify integration branches as a unit before merging to middle-merge; do not require full supervisor verification for every sub-branch.

## Issue Setup

- Multi-PR issue: create `integration/<type>/<issue-N>` from `middle-merge`.
- Simple issue: create `fix/<issue-topic>` or `fix/<issue-N>` from `middle-merge`.
- Worker PR targets the issue/integration branch, never `main`.

## Reference

Read [REFERENCE.md](REFERENCE.md) for the detailed original policy, cross-cutting rules, branch lifetime tables, issue-to-branch mapping, and briefing examples.
