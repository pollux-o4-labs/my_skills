# Skill Authoring Standards

Canonical conventions for creating or editing any SKILL.md in this repo. This file lives inside a skill folder so it travels to every host with the junction/copy — the repo `CLAUDE.md` does not. Other docs point here; don't restate these rules elsewhere. Why each rule exists: `skill-refactor/RATIONALE.md`.

## Budgets (English-calibrated; Korean ≈ half the words — RATIONALE §3)

- **description**: what + when, 2 sentences, ≤400 chars. No tool/exception enumerations — move those to a body "Skip" / "Do NOT use" section.
- **body**: ≤700 words target; past 1,000 → split/compress review.
- **Verification**: outcome checks only, ≤6 items — no 1:1 restatement of Procedure.
- **Origin/Provenance**: one line.
- Existing skills: retrofit on edit via `skill-refactor` (pilot-first, no mass retrofit). Lint automation only if violations recur.

## Trigger type (decide per skill)

Discriminator: does the user know *when* to invoke (→ user-invoked) or must the situation be detected (→ model-invoked)?

- **User-workflow skills**: `disable-model-invocation: true` — zero resident description cost; recall is on the user.
- **Auto behavior-correction skills** (AIL etc.): model-invoked — the description is a per-session resident cost and fires probabilistically. Write it accordingly. (Rationale: `skill-refactor/RATIONALE.md` §6.)

## AIL skills (session-lesson provenance)

- Name prefix `AIL-`; frontmatter `version` (semver, bump on every edit), `metadata.provenance: AIL`, `metadata.platforms`.
- Section shape: `When to Use → Procedure → Pitfalls → Verification`, at least one concrete example, closing one-line `*Origin:*`.
- Replay before registration: original case, ≥1 analogue from another domain, and ≥1 boundary case where the skill's advice must NOT apply — boundary replays catch misleads, not just misses (2026-07-13, AIL-prefer-incremental-over-full 검증에서 MISLEADS 결함 적발 근거).

## Language

- Canonical skill = one English file; Korean is a review rendering only. Exception: skills that teach Korean output itself (e.g. `format-response`).
- Repo rules/docs follow that repo's document language (`write-a-rule` carries both English and Korean forms). This standards file itself stays English for the same host-portability reason it lives in a skill folder.

## Dedup

One home per rule; everywhere else a pointer. Over budget → apply `skill-refactor` (creep patterns, deletion test, leading words).
