---
name: AIL-correct-is-silent
description: "Keeps living documents free of inline history — a correctly placed or corrected artifact states only its current state, while the story of what moved where and why belongs in commit messages and ADRs. Use when about to annotate a fix or relocation with its history ('this used to be...'), or when transition banners are spreading across documents."
version: 1.0.0
metadata:
  platforms: [claude-code]
  provenance: AIL
---

# Correct Is Silent

A reader of a living document needs the current correct state, not the journey. Inline narratives ("[2026-07 rewritten] previously X…", "moved here from Y") age into noise: they outlive their usefulness, spread by imitation, and bury the actual content. Version control already records what changed, when, and why.

## When to Use

- About to leave a "this was here, now it's there" / "previously X" annotation next to something you just fixed or relocated.
- A transition/migration banner is appearing in more than one document.
- Writing config or gitignore comments that narrate history instead of stating purpose.

**Do NOT use when** the document's purpose IS history, or a consumer must act on the transition: changelogs and release notes; deprecation notices (including `@deprecated` source annotations) and migration guides for consumers who must act on the change (operators, deployers, API users); comments stating a live constraint ("don't reorder — X depends on init order") — that is rationale, not narrative.

## Procedure

1. **Route the story to its canonical home**: the what/why of the change → commit message; a decision with lasting value → ADR (or the repo's decision log). The artifact itself keeps only the current state.
2. **Comments state purpose, not provenance** — "excludes build artifacts", not "moved here from the Makefile cleanup in June".
3. **A recurring banner is an absorption signal.** If the same transition note appears in a second document, delete both; if the transition embodies a durable decision, write the one ADR they would have linked to — otherwise the commit message is the record. If readers may still arrive at the old location, a one-line redirect stub THERE replaces banners at the new one. (Consumer-facing surfaces — changelog, deprecation notice, migration guide — legitimately repeat the same transition; that repetition is not a banner.)
4. **When editing near old narrative**, don't extend it; if your change makes it stale, remove it in the same commit — its content goes into that commit's message.

## Pitfalls

- **Reviewer-directed comments** — "why my change is correct" notes are PR-talk; the moment the PR merges they are noise (they belong in the PR description).
- **Deleting live rationale along with dead narrative** — a constraint the code can't express must stay; only the history goes.

## Verification

- [ ] Does the artifact read correctly to someone with no knowledge of its past?
- [ ] Is the change's what/why captured in the commit (and an ADR if durable)?
- [ ] No transition banner duplicated across documents?

---
*Origin: consolidating project docs, an agent kept inlining "moved from X to Y" relocation narratives into the base document, burying current-state content under migration noise (pre-jeongcheoki, 2026-07).*
