---
name: organize-agent-team
description: "Organize a multi-agent team from the installed agent registry instead of ad-hoc generic spawns: enumerate typed definitions (plugin agents, .claude/agents), read each one's model/tools pins and role doctrine, and place every role deliberately — spawn typed, adopt in-session, or substitute with settings ported. Invoke when the user asks to organize or assemble an agent team."
version: 0.3.0
disable-model-invocation: true
metadata:
  platforms: [claude-code]
---

# Organize Agent Team

You were invoked because the user wants a team of agents organized. A registered agent type (plugin agent, `.claude/agents` entry) is **configuration someone authored**: its frontmatter pins model and tools; its body is a role doctrine. Spawning `general-purpose` for a role the registry already defines silently discards that policy — most often the model tier, because unset model means *inherit the parent session's model*, which may sit tiers above (or below) what the definition chose. Registry mechanics and the measured tier distribution behind this rule: `RATIONALE.md`.

**Scope**: sizing width/effort of an already-typed call → `AIL-calibrate-agent-spend`; fan-out mechanics → `AIL-subagent-fanout-guard`.

## Procedure

1. **Enumerate before composing.** List available agent types *and* plugin commands — the requested workflow may already be packaged as a command (e.g. an installed `/team-feature`). `general-purpose` is the fallback, not the starting point.
2. **Read each matched definition** — frontmatter (model, tools) *and* body doctrine. The boundary between "just an agent name" and "pre-set system prompt + pinned settings" is invisible until you open the file.
3. **Place each role deliberately** (three-way):
   - **Spawn the typed agent** when its toolset suffices and the role is self-contained: user is away, multiple teams run, or the role's chatter would pollute the main context.
   - **Adopt its doctrine in-session** when the role needs direct user steering, permission prompts, or context you already hold (an orchestrator/lead while the user actively interjects). Read the definition's system prompt and follow its protocol — you are not a relay; you translate steering into directives.
   - **Substitute a generic type** only for a concrete gap (e.g., the typed agent lacks a needed tool) — then **port the definition's model/effort explicitly** via override parameters.
4. **State the delta in one line before spawning**: which definition, what you kept, what you changed and why.
5. **No definition matches** → set tier by task nature: mechanical execution low, judgment/audit mid, final synthesis the session model.

## Team Runtime (messaging-based teammates)

When a role runs as a named teammate with a message mailbox — not an Agent-tool subagent whose final text returns automatically:

- **Final text is NOT delivered.** Only an explicit send reaches the leader. Every teammate prompt must end with: "before exiting, send your full report to the leader via SendMessage — final text alone is lost."
- **Idle-without-report → ping once** for a resend; recurring silence is a failure signal, not completion.
- **Re-verification after a fix needs a precondition**: instruct the verifier to assert the fix marker exists in the tested artifact (grep the served/deployed copy) before running. Crossed messages otherwise yield stale FAIL/PASS verdicts against pre-fix state.

## Pitfalls

- **Tool-driven type choice silently dropping model config** — picking generic for one missing tool and letting session-model inheritance apply unexamined.
- **Assuming built-ins run on cheap models** — inheritance is the rule; unset ≠ economical.
- **Spawning a leader agent under active user steering** — every correction then transits a lossy relay hop (user → you → lead → teammates).
- **Adopting doctrine from memory** — naming the protocol without reading the definition file.
- **Retroactive acknowledgment** — admitting the substitution's side effects only when the user challenges.

## Verification

- [ ] Registry enumerated and the matched definition's frontmatter + body actually read before the spawn?
- [ ] Placement (spawn / adopt / substitute) chosen for stated reasons, not by default?
- [ ] Every substitution ports model/effort explicitly on the call?
- [ ] Delta stated before invocation — would it survive "did you just ignore the plugin's settings?"

## Example

Asked to organize an inspection team with "specialized agents", the orchestrator reads the plugin lead's system prompt (correct: adopt-in-session, user is steering live) but spawns all four teammates as `general-purpose` because one needs `Write`. The plugin's reviewer/implementer definitions all pin `model: opus`; the substitution silently inherits the top-tier session model instead. Caught only by two user challenges. The fix this skill encodes: enumerate → read frontmatter → spawn typed where tools suffice, and where substituting, pass `model: "opus"` and say so up front.

---
*Origin: session lesson (launch-inspection team, 2026-07-13) reshaped into a user-invoked workflow — provenance and registry measurements in `RATIONALE.md`.*
