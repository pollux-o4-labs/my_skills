---
name: skillify-session-lessons
description: "Turns reusable lessons from a difficult session into a durable English canonical SKILL.md, with Korean review rendering for user approval. Use when the user asks to make a skill from lessons learned, or at session close when there were repeated failures, user corrections, or a nontrivial workflow discovery that is clearly reusable."
version: 1.2.0
metadata:
  platforms: [claude-code, codex, gemini-cli]
---

# Skillify Session Lessons

Use this skill to turn a concrete session lesson into a reusable skill. It owns the lesson-mining workflow; general skill authoring rules belong to `write-a-skill`.

## When to Use

- The user asks to make a skill from this session, today's lesson, a correction, or a repeated failure.
- At session close, the work revealed a reusable workflow through repeated failures, user corrections, or nontrivial recovery.

Do not use for smooth one-off work, project-specific facts, or a brand-new skill idea unrelated to session experience. Use repo docs/lessons for project-local knowledge and `write-a-skill` for ordinary new skill authoring.

## Procedure

1. **Retrospect** - extract what succeeded, what failed, what the user corrected, and the blameless root cause. Use concrete session evidence.
2. **Filter** - promote only lessons that transfer across projects. Keep project-specific facts in repo `lessons.md`.
3. **Abstract** - remove local file names, tools, and incidental numbers while preserving the real edge case that taught the lesson.
4. **Check duplicates** - search existing skills, memory, and repo lessons. Update an existing skill when it already covers the lesson.
5. **Draft the canonical skill in English — load the authoring rules first, do not draft from memory.** (a) Actually read/invoke `write-a-skill` for base structure, description wording, size limits, and the review checklist. (b) `write-a-skill` is only the minimal template and does **not** carry the AIL conventions — so also read the skills-repo `CLAUDE.md` for AIL frontmatter (`version` semver + `metadata.provenance: AIL` + `metadata.platforms`; keep the description short) and mirror one sibling `AIL-*/SKILL.md` for the expected shape: sections `When to Use → Procedure → Pitfalls → Verification`, at least one concrete example, and a closing `*Origin:*` line. Keep one canonical file, normally `SKILL.md` in English.
6. **Show Korean review rendering** - before registration, show the user a Korean translation or summary of the English draft, especially name, description, triggers, scope, procedure, and pitfalls. Do not save a second Korean skill file unless the user explicitly asks.
7. **Replay the draft** - apply the draft back to the original session problem or a close analogue. Revise if it misses a step or produces ambiguity.
8. **Register provenance** - AI-generated session-lesson skills use the `AIL-` prefix and one source folder such as `Documents/my_skills/<name>`.
9. **Link safely** - on Windows, prefer junctions (`New-Item -ItemType Junction` or `mklink /J`) and verify the link type to avoid copied skill folders drifting from source.
10. **Approval gate** - register only after the user approves the English canonical draft via the Korean review rendering.

## Pitfalls

- **Empty generality**: a skill made without concrete failure becomes advice nobody can apply.
- **Over-skillifying**: every small hiccup does not deserve a globally visible description.
- **Project leakage**: local facts make a global skill brittle.
- **Duplicate skills**: overlapping skills fragment trigger quality and increase noise.
- **Korean second source**: saving both English and Korean files creates two things to maintain. Translate for review, keep one canonical file.
- **No replay**: if the draft cannot guide the original case, it is not ready.
- **Copy instead of link**: duplicated registered folders drift from the source skill.
- **Drafting from memory**: naming `write-a-skill` but not actually loading it — and not loading the AIL conventions (which live in the skills-repo `CLAUDE.md`, not in `write-a-skill`) — yields drafts missing the frontmatter and section shape, forcing the review to catch what the load would have prevented.

## Verification

- [ ] Is the lesson reusable outside this project?
- [ ] Did it come from concrete session evidence?
- [ ] Did I remove project-specific details without losing the edge case?
- [ ] Did I check for an existing skill before creating a new one?
- [ ] Did I actually load `write-a-skill` **and** the AIL conventions (skills-repo `CLAUDE.md` + a sibling `AIL-*` skill) before drafting, rather than drafting from memory?
- [ ] Does the draft carry AIL frontmatter (`version`, `metadata.provenance: AIL`, `metadata.platforms`) and the full `When to Use → Procedure → Pitfalls → Verification` shape with a concrete example?
- [ ] Is the English `SKILL.md` the single canonical file?
- [ ] Did I show a Korean translation or summary for user review?
- [ ] Did the draft work against the original or analogous case?
- [ ] Did the user approve name, scope, description, and trigger before registration?

---
*Self-improvement loop: session evidence -> reusable lesson -> English canonical draft via write-a-skill -> Korean review rendering -> replay -> approved skill.*
