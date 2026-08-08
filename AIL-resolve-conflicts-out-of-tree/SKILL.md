---
name: AIL-resolve-conflicts-out-of-tree
description: "Resolves a merge conflict without touching a shared or checkout-restricted working tree — clone the branch pair into an isolated scratch directory, rebase and fix the conflict there, verify the build, then force-with-lease push back. Use when a PR's merge conflicts and another actor (a parallel worker, a locked CI checkout) currently owns the shared tree's HEAD, or when several sequential PRs touch adjacent regions of the same file and merge order surfaces a conflict the individual diffs didn't show."
version: 1.0.0
metadata:
  provenance: AIL
---

# Resolve Conflicts Out Of Tree

Two PRs each delete a different, non-overlapping block from the same file. Neither diff overlaps the other's lines. Merged in sequence anyway, the second merge reports a conflict — because the two deleted blocks sat physically adjacent, and the merge algorithm's context window treated the boundary as contested. Semantic independence does not guarantee textual independence.

## When to Use

- A PR's merge state turns conflicting/dirty against the target branch, and the shared working tree cannot be checked out right now — a parallel worker owns its HEAD, or checkout is policy-forbidden there.
- Several sequential PRs edit adjacent (not overlapping) regions of one file — a boundary conflict is likely the moment they merge out of the order they were branched from.
- Before assuming a conflict means real semantic overlap: run `git merge-tree <merge-base> <branch-a> <branch-b>` first — it previews the merge without touching any working tree and shows whether the conflict is a boundary artifact (both sides delete adjacent content) or a genuine competing edit.

Related: [[AIL-worktree-parallel-guard]] covers *preventing* conflicts across parallel worktrees via file-ownership partitioning. This skill is the *resolution* step for when a conflict still surfaces despite non-overlapping edits, and the shared tree isn't free to use for the fix.

**Do NOT use** when the working tree is free to check out — a plain `git rebase`/`git merge` in place is simpler and this isolation step is unneeded overhead.

## Procedure

1. **Diagnose without touching anything**: `git fetch` both refs, then `git merge-tree "$(git merge-base A B)" A B`. Read the conflict hunk — if both sides are deleting adjacent content, the fix is usually "keep neither" (accept both deletions), not a real editorial choice.
2. **Clone into an isolated scratch directory** — not `git worktree`. A worktree shares the primary checkout's object store and refs, so it can still interact with in-flight operations there; a separate `git clone` does not:
   ```bash
   git clone --branch <pr-branch> --single-branch <repo-url-or-path> /tmp/scratch/<name>
   cd /tmp/scratch/<name> && git fetch <remote> <target-branch>:refs/remotes/<remote>/<target-branch>
   ```
3. **Rebase and resolve** in the clone: `git rebase <remote>/<target-branch>`, edit the conflicted file to the intended combined state, `git add`, `git rebase --continue`.
4. **Verify before pushing** — run the project's build/test inside the clone; it is a real, independent checkout, so results are trustworthy.
5. **Push back with a lease, not a bare force**: `git push origin <pr-branch> --force-with-lease` — fails safely if someone else pushed to the branch meanwhile, where a bare `--force` would silently clobber that.
6. **Discard the scratch clone** once the PR merges — it was never registered as a worktree, so no `git worktree remove` bookkeeping is owed.

## Pitfalls

- **Reaching for `git worktree add` instead of a clone**: lighter-weight, but shares the primary repo's refs and object store — safe for read-only inspection, riskier when another actor is mid-operation in that same repo.
- **Force-pushing without `--lease`**: overwrites work that landed on the branch in the meantime without you knowing.
- **Resolving by guessing intent instead of reading `git merge-tree` first**: the diagnostic step often reveals the resolution is mechanical (both deletions stand), not a judgment call.

## Verification

- [ ] Was the primary/shared working tree's HEAD left untouched throughout?
- [ ] Did the resolved file build and pass tests inside the isolated clone before pushing?
- [ ] Was the push `--force-with-lease`, not a bare `--force`?

---
*Origin: a session merging seven sequential single-file-adjacent-region PRs, where the second PR's merge conflicted against the first after it merged, resolved via an isolated `/tmp` clone while a parallel worker held the shared tree's HEAD on an unrelated branch.*
