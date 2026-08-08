---
name: AIL-supervisor-owns-publish-actions
description: "Keeps the final visible, hard-to-reverse action in a workflow — merging a PR, deploying, sending a message, publishing — with the supervising agent or human, never fully delegated to a subagent even after that subagent's work is verified. Use when instructing a subagent that has completed and passed verification, or when drafting a subagent prompt that would tell it to proceed to publish/merge/deploy/send on its own once checks are green."
version: 1.0.0
metadata:
  provenance: AIL
---

# Supervisor Owns Publish Actions

A subagent finishes implementing, its own build and tests pass, and the natural next instruction is "go ahead and merge it once it's green." That instruction was rejected outright by a permission classifier before it ever reached the subagent — not because the subagent lacked the technical means, but because the *action* (merging into a branch other people read) is the kind of step that should not be handed off on autopilot, independent of how well-verified the work behind it is.

## When to Use

- About to tell a subagent — or write into its standing instructions — to perform the final publish-class action (merge, deploy, send, post, delete) autonomously once its own checks pass.
- A pipeline has N independent units of work (e.g., N pull requests) and the natural instinct is to let each unit's implementer close its own loop end-to-end to avoid idling between units.

**Do NOT use** to justify requiring approval before every reversible, low-visibility step — that reintroduces the friction delegation was supposed to remove. The line is the *publish* action itself, not the implementation work leading up to it.

**Explicit user override**: if the user explicitly authorizes a subagent to perform the publish action itself, comply — but state once, plainly, which action now executes without a supervisor checkpoint, so the tradeoff is visible rather than silently accepted.

## Procedure

1. **Split the loop**: a subagent implements, verifies locally, and *stops* at "ready to publish" — it reports that state rather than acting on it.
2. **The supervisor performs the publish action directly** (or a human does, if the supervisor itself lacks authorization) — one command, immediately after reading the verification result. This is usually a single `merge`/`deploy`/`send` call the supervisor already has full context to run correctly, not extra ceremony.
3. **This does not have to serialize the pipeline.** The next unit of work can start immediately after its own PR opens — only the *publish* step itself waits on the supervisor, not the implementation work behind the next unit.
4. **If a permission system blocks an instruction that hands off a publish action**, treat that as the signal working as intended — don't rephrase the same delegation to route around it. Perform the action yourself instead.

## Pitfalls

- **Rephrasing to route around a classifier block**: if "merge once green" is blocked, "merge once green, but double-check first" is the same delegation with more words — the fix is to stop delegating the action, not to qualify it.
- **Treating this as a blanket approval gate**: requiring sign-off on *every* step, not just publish-class ones, defeats the reason to delegate at all — scope the rule to actions visible to others or hard to reverse.
- **Assuming verification quality substitutes for who presses the button**: a subagent's tests passing is orthogonal to whether it should be the one to merge — this lesson keeps those two questions separate.

## Verification

- [ ] Did every publish-class action (merge/deploy/send/delete) in this session execute from the supervisor's own tool call, not a subagent's?
- [ ] Where a subagent reached "ready to publish," did it stop and report rather than act?

---
*Origin: a session pipelining seven independent PRs, where instructing the implementing subagent to self-merge on green was blocked by a permission classifier; every subsequent merge was executed directly by the supervising agent instead, without slowing the pipeline.*
