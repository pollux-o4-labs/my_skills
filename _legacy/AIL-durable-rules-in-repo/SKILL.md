---
name: AIL-durable-rules-in-repo
description: "Routes shareable reusable rules and lessons to a git-synced canonical home (project CLAUDE.md, ADR, skills repo) instead of machine-local agent memory — and private or secret items away from shared repos. Use when saving a lesson, rule, or workflow that should outlive the current machine and session, or when about to store it only in personal memory."
version: 1.0.0
metadata:
  provenance: AIL
---

# Durable Rules Live in the Repo

Personal agent memory (`~/.claude` and equivalents) is machine-local scratch. Two axes decide a fact's home — **durability** (must it outlive this machine?) and **audience** (who may see it?).

## When to Use

- About to save a reusable rule, lesson, or workflow into personal/agent memory.
- A correction from the user should govern future sessions on any machine.
- Reviewing memory and finding entries that are actually team- or project-level rules.

**Do NOT use for** session-scoped context that expires with the task — don't persist it at all.

## Procedure

1. **Route by scope and audience**:
   - Team/project rule → that repo (its existing rules convention: a rules dir if present, else CLAUDE.md/ADR).
   - Cross-project behavior → a git-synced personal location (skills/dotfiles repo) if one exists; if none, say so — memory is then best-available, with that caveat.
   - Machine-local fact (path, hardware quirk) → memory or local config; never the shared repo.
   - Person-private fact (health, identity, non-public preference) → personal memory or a private personal repo — never a shared repo, even though it usefully travels.
   - Secret/credential → OS keychain or credential helper; never plaintext anywhere, repo or memory — memory holds at most a pointer to where it lives.

   Example: "always run the delta sync, not full rebuild" → skills repo; "this box mounts scratch at D:" → memory; API token → keychain, memory keeps only "token is in keychain X".
2. **For repo-routed rules, memory keeps a pointer, not the payload** — an accelerator naming the canonical location.
3. **On "remember this"**: if it should hold on another machine or for another agent, write it to the repo first — but only if every reader of that repo may see it — then optionally a memory pointer.

## Pitfalls

- **"It's in memory, so it's handled"** — memory recall is account-bound and probabilistic; other machines, agents, and people never see it.
- **Durability over privacy** — pushing a portable-but-private fact (or a secret) into a shared repo because "git-synced = durable"; a mixed batch of facts routes per fact, not wholesale.

## Verification

- [ ] Would this rule survive a machine switch or a fresh clone? ("No, but it's private" still means memory — privacy outranks durability.)
- [ ] After a machine wipe, could every shareable rule be recovered from git alone?
- [ ] Nothing private or machine-local pushed to a shared repo — and no secret in plaintext anywhere?

---
*Origin: a reusable documentation rule was saved only to laptop-local agent memory during docs consolidation; it would have been silently absent on the desktop — caught before the loss (pre-jeongcheoki, 2026-07).*
