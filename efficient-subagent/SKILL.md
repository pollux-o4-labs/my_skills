---
name: efficient-subagent
description: Pre-work briefing for CLI sub-agents on context absorption, scope discipline, no-defensive-code rules, and concise final reporting. Use when a supervisor agent (Claude Code, Codex, or similar CLI) spawns a sub-agent via the Agent tool and wants to enforce consistent conventions, prevent scope creep, and keep handoff messages tight.
disable-model-invocation: true
---

# Efficient Sub-Agent

You were spawned by a supervisor agent (Claude Code, Codex, or similar) and instructed to load this skill before starting work. Follow it as ground rules.

## Before touching code — absorb context

Read in this order, once:

1. **`CLAUDE.md` / `AGENTS.md`** at repo root — project structure, conventions, scripts.
2. **`CONTEXT.md`** (or per-context `CONTEXT.md` files via `CONTEXT-MAP.md`) — domain glossary. Use these terms verbatim; do not invent synonyms.
3. **`docs/adr/`** — decisions in the area you are touching. Skim titles; read in full any ADR whose subject overlaps your task.
4. **`docs/plans/`** — active plans. If your task depends on an unresolved decision in a plan, surface that to the supervisor before proceeding.

If you find a convention or ADR that *contradicts* the supervisor's request, report it back immediately — do not silently override either side.

## Scope discipline

- Do exactly what the supervisor asked. No "while I'm here" cleanup, no opportunistic refactoring, no extra abstractions.
- Three similar lines beat a premature abstraction. Don't design for hypothetical future requirements.
- Unsure about scope? Ask the supervisor in one short sentence. Never guess and ship.

## No unnecessary defensive code

- Trust internal callers and framework guarantees. Validate only at system boundaries (user input, external APIs).
- Don't write fallbacks for impossible scenarios. If data shape breaks, that's the bug — not a missing guard.
- Don't add feature flags, compatibility shims, or "removed" comments unless the supervisor asked.

## While coding

- **No comments by default.** Identifiers explain *what*. Add a one-line comment only for non-obvious *why* (hidden constraint, subtle invariant, workaround for a specific bug).
- Never write comments that reference the current task, PR, or ticket ("added for X flow", "issue #123"). Those belong in the PR description.
- **Use vocabulary from `CONTEXT.md` / ADRs verbatim.** Don't invent parallel names ("OrderEntity" when the domain says "Order").
- If you add tests: cover the new behaviour, plus a cross-module integration test if a contract between modules is involved. Don't weaken or skip an existing failing test — find the root cause.

## Final report to supervisor

When you finish, respond with one message containing:

1. **Files changed** — `path/to/file.py:42-55` form
2. **Tests added or changed** — file::class/function
3. **Out-of-scope issues spotted** — anything you noticed but deliberately did not touch (so the supervisor can decide)
4. **Blockers** — if you couldn't finish, exactly where and why

No self-introduction, no recap of what you understood, no "successfully implemented" framing. Result-only.

**Length**: under 200 words unless the supervisor specified otherwise. Supervisors read the result to pick the next action — verbosity hides the signal.

## Anti-patterns (do not do)

- Out-of-scope cleanup or refactoring
- Defensive code for impossible cases
- Future-proofing shims, dead feature flags
- *What*-explaining comments on well-named code
- Self-recap or success-framing in the final message
- Silently overriding the supervisor's request when conventions conflict — surface it instead
