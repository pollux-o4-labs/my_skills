---
name: organize-agent-team
description: "Organize a multi-agent team from the installed agent registry instead of ad-hoc generic spawns: enumerate typed definitions (plugin agents, .claude/agents), read their model/tools pins and role doctrine, place each role deliberately, and set the team's runtime ground rules. Invoke when the user asks to organize or assemble an agent team."
version: 0.5.0
disable-model-invocation: true
metadata:
  platforms: [claude-code]
---

# Organize Agent Team

A registered agent type (plugin agent, `.claude/agents` entry) is **configuration someone authored**: its frontmatter pins model and tools; its body is a role doctrine. Spawning `general-purpose` for a role the registry already defines silently discards that policy — most often the model tier, because unset model means *inherit the parent session's model*, tiers above or below what the definition chose. Registry mechanics and the measured tier distribution behind this workflow: `RATIONALE.md`.

**Scope**: sizing width/effort of an already-typed call → `AIL-calibrate-agent-spend`; fan-out mechanics → `AIL-subagent-fanout-guard`; sub-agent briefing → `efficient-subagent`.

## Procedure

1. **Honor user pins first.** An explicit user placement or model instruction supersedes registry pins — state the delta once ("plugin pins opus, you chose sonnet") and comply; skip the steps below for roles the user has already decided.
2. **Enumerate before composing.** List available agent types *and* plugin commands; if a packaged command already covers the requested workflow (e.g. an installed `/team-feature`), propose or use it instead of hand-composing. `general-purpose` is the fallback, not the starting point.
3. **Read the definition only when placement needs its body or model.** The registry enumeration already surfaces each type's name, tools, and role summary — enough to spawn it typed, since a typed spawn carries the pinned model automatically without your knowing its value. Open the file only to *adopt* its doctrine in-session or to *substitute* a generic (porting the model, injecting the body). Don't re-search the filesystem for a definition the listing already covers.
4. **Place each role deliberately** (three-way):
   - **Spawn the typed agent** when its toolset suffices and the role is self-contained: user is away, multiple teams run, or the role's chatter would pollute the main context.
   - **Adopt its doctrine in-session** — at most one role, the one at the user interface (typically the lead); steering need wins any tie with the spawn criteria. Follow its protocol — you are not a relay; translate steering into directives.
   - **Substitute a generic type** for the gapped role only (e.g., the typed agent lacks a needed tool); the rest still spawn typed. Port the pinned model via the `model` parameter and inject the definition's body doctrine into the substitute's prompt; anything unportable (a pinned effort, a tool restriction) is named in the delta.
5. **Announce before spawning**: for substitutions, one line stating which definition, what you kept, what you changed and why; otherwise one line naming the definition used.
6. **No definition matches** → assign tiers per `AIL-subagent-fanout-guard`'s model table (the one home for that rule).

## Team Runtime (messaging-based teammates)

When a role runs as a named teammate with a message mailbox — not an Agent-tool subagent whose final text returns automatically:

- **Final text is NOT delivered.** Only an explicit send reaches the leader. Every teammate prompt must end with: "before exiting, send your full report to the leader via SendMessage — final text alone is lost."
- **Idle-without-report → ping once** for a resend; recurring silence is a failure signal, not completion.
- **Re-verification after a fix needs a precondition**: have the verifier assert the fix marker (a string unique to the fix, e.g. the changed line) exists in the tested artifact — grep the served/deployed copy — before running. Crossed messages otherwise yield stale verdicts against pre-fix state.
- When spawning several teammates, also inject `AIL-subagent-fanout-guard`'s prompt constraints (no re-delegation, no placeholder replies).

## Pitfalls

- **Tool-driven type choice silently dropping model config** — picking generic for one missing tool and letting session-model inheritance apply unexamined.
- **Assuming built-ins run on cheap models** — inheritance is the rule; unset ≠ economical.
- **Spawning a leader agent under active user steering** — every correction then transits a lossy relay hop (user → you → lead → teammates).
- **Adopting doctrine from memory** — naming the protocol without reading the definition file.
- **Re-searching for a definition the enumeration already lists** — a plain typed spawn needs no file read; `find`-ing and opening it just to spawn typed burns round-trips. Read only to adopt or substitute.
- **Relitigating a user pin** — the delta line is for transparency, not for arguing the registry back.

## Verification

- [ ] Registry enumerated, and definitions read *only* for roles being adopted or substituted (not for plain typed spawns the listing already covers)?
- [ ] Placement (spawn / adopt / substitute) chosen for stated reasons — user pins honored, not relitigated?
- [ ] Every substitution ports the model and carries (or names the loss of) the definition's doctrine?
- [ ] Delta stated before invocation — would it survive "did you just ignore the plugin's settings?"
- [ ] Every messaging-teammate prompt ends with the SendMessage-before-exit clause?

## Example

Asked to organize an inspection team with "specialized agents", the orchestrator correctly adopts the plugin lead's doctrine in-session (user steering live) but spawns all four teammates as `general-purpose` because one needs `Write`. The plugin definitions pin `model: opus`; the substitution silently inherits the session model — caught only by two user challenges. The fix this skill encodes: enumerate → read the lead's definition to adopt its doctrine and the `Write`-needing role's to substitute it (`model: "opus"` ported, doctrine injected, swap announced); spawn the remaining teammates typed with no file read.

---
*Origin: session lesson (launch-inspection team, 2026-07-13) reshaped into a user-invoked workflow — provenance and registry measurements in `RATIONALE.md`.*
