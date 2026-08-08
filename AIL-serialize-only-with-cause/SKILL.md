---
name: AIL-serialize-only-with-cause
description: "Treats stopping (asking the user, working serially instead of in parallel, doing delegatable work yourself before dispatching it, waiting idle) as a claim that needs a live justification each time, not a default. Use before asking a question that has an obvious reversible default, before processing independent multi-item work one at a time, or before doing your own investigation/analysis ahead of dispatching parallel subagents for other independent parts of the same task."
version: 1.0.0
metadata:
  provenance: AIL
---

# Serialize Only With Cause

A worktree-recovery incident earlier in a session justified avoiding worktrees for *that* task. Two hours later, unrelated backlog items got the same "no worktrees, one at a time" treatment — not because the reason still applied, but because it had become the running default. Separately, the same session kept presenting two-or-three-option menus for decisions with an obvious, reversible recommendation, and did its own investigation before dispatching subagents for independent parts of the same task instead of firing every dispatchable task first. Three different-looking bottlenecks, one root cause: a caution or ordering habit carried forward without re-checking whether its justification still held.

## When to Use

- About to ask the user to choose between options where one is clearly recommended and the decision is reversible (git-revertable, PR-gated, low blast radius).
- About to process a batch of independent items one at a time (sequential branches, sequential merges, sequential agent calls) when nothing structurally forces that order.
- About to do investigation, analysis, or any delegatable step yourself before dispatching subagents for the other independent parts of the same task.
- About to re-apply a caution learned from a specific past incident (a tool blocked you, a recovery cost real time, a conflict happened) to a new situation without checking whether that incident's actual cause is present here too.

**Do NOT use** to justify skipping a real gate — genuinely irreversible/high-visibility actions (merging, deploying, sending, deleting), a true data dependency between steps, or a decision that needs information only the user has. Those still warrant stopping; this skill is about not stopping *reflexively*.

## Procedure

1. **Name the thing that's making you stop.** Is it a real dependency (step B needs step A's output), a real irreversibility (someone else will see this and it's costly to undo), or a habit / an inherited caution from an earlier, possibly different situation?
2. **If it's an inherited caution, check its scope.** The incident that produced it happened under specific conditions (shared tree, one seat, a particular tool). Ask whether those conditions still hold for the current case, not whether the incident happened at all.
3. **If it's a decision point with an obvious, reversible default, take it and say what you took** — don't present a menu. Reserve real questions for cases with no safe default or with information only the user holds.
4. **Sort work into three buckets before executing anything**: delegatable (fire immediately, in parallel, to subagents), supervisor-only (only you can do this — synthesis, merges, judgment calls), user-gated (needs the user's unique authority or knowledge). Dispatch every delegatable item first; do supervisor-only work last, once delegated work is in flight, not interleaved before it.
5. **When several independent items share a resource that only supports one user at a time** (a single working tree, for instance), that is the actual constraint — solve it structurally (isolated clones/worktrees, or a genuinely required order), rather than defaulting to "everything waits its turn" for items that don't need to.

## Pitfalls

- **Asking to be safe costs the same as being wrong when the action is reversible** — a bad reversible default corrected later is cheaper than a blocked pipeline. Weigh delay against the actual cost of a wrong-but-reversible call.
- **A rule learned under one constraint outlives the constraint.** "No worktrees today" (because of a specific recovery incident) is not "no worktrees ever" — re-derive, don't inherit.
- **Explicit user override**: if the user says stop and ask more, or asks for a specific sequential order, comply — this skill lowers the bar for acting, it does not override a standing instruction to check in.
- **Not every batch is independent.** If items genuinely share files or state, that is real justification for a run order or an isolation mechanism (`[[AIL-resolve-conflicts-out-of-tree]]`, `[[AIL-worktree-parallel-guard]]`) — the fix is structural isolation, not returning to strict serial-and-ask.

## Verification

- [ ] For every question asked, was there no reversible default and no way to just act and report?
- [ ] For every batch processed serially, was there a real dependency between items, not just habit?
- [ ] Were all delegatable parts of the task dispatched before any supervisor-only work began?

---
*Origin: a session that processed seven then two more independent pull requests through one shared working tree by habit, kept presenting reversible decisions as option menus, and did its own investigation ahead of dispatching subagents for unrelated parts of the same task — all three corrected only after the user pointed out the same root cause each time.*
