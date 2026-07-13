---
name: AIL-honor-agent-definitions
description: "Treats registered agent definitions (system prompt, model, effort, tools) as authored policy when delegating: spawn the typed agent, adopt its doctrine in the main session, or substitute a generic type while porting the definition's settings — a deliberate choice, never a silent default. Use before spawning subagents for a role a registered/plugin agent type may cover, or when taking that role yourself."
version: 0.2.0
metadata:
  platforms: [claude-code]
  provenance: AIL
---

# Honor Agent Definitions

A registered agent type (plugin agent, `.claude/agents` entry) is **configuration someone authored**: its frontmatter fixes model, effort, and tools; its body is a role doctrine. Spawning a generic agent for a role the registry already defines silently discards that policy — most often the model tier, because unset model means *inherit the parent session's model*, which may sit tiers above (or below) what the definition chose.

## When to Use

- About to spawn a subagent and choosing its type, when a registry of typed agents may cover the role (reviewer, debugger, implementer, lead, …).
- The user asks you to take on a role that exists as a typed agent (e.g., "you be the leader").
- A spawn call leaves `model`/`effort` unset without having checked what the matching definition specifies.

**Skip for**: roles with no registry match after actually enumerating; a type/model the user pinned explicitly. Sizing width/effort of an already-typed call → `AIL-calibrate-agent-spend`; fan-out mechanics → `AIL-subagent-fanout-guard`.

## Procedure

1. **Enumerate the registry before defaulting to generic.** List available agent types and match the role; "general-purpose" is the fallback, not the starting point.
2. **Read the matched definition** — frontmatter (model, effort, tools) *and* body doctrine. The boundary between "just an agent" and "pre-set system prompt + settings" is invisible unless you open the file.
3. **Choose placement deliberately** (three-way):
   - **Spawn the typed agent** when its toolset suffices and the role is self-contained: user is away, multiple teams run, or the role's chatter would pollute the main context.
   - **Adopt its doctrine in-session** when the role needs direct user steering, permission prompts, or context you already hold (an orchestrator/lead while the user actively interjects). Read the definition's system prompt and follow its protocol — you are not a relay; you translate steering into directives.
   - **Substitute a generic type** only for a concrete gap (e.g., the typed agent lacks a needed tool) — then **port the definition's model/effort explicitly** via override parameters.
4. **State the delta in one line before spawning**: which definition, what you kept, what you changed and why.
5. **No definition exists** → set tier by task nature: mechanical execution low, judgment/audit mid, final synthesis the session model.

## Team Runtime (messaging-based teammates)

When the role runs as a named teammate with a message mailbox — not an Agent-tool subagent whose final text returns automatically:

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
*Origin: AIL — launch-inspection team (prompt-gen, 2026-07-13): four general-purpose teammates spawned for tool access, dropping the plugin definitions' model tier (two user corrections); four idle-without-report incidents fixed by a SendMessage-before-exit prompt clause; two crossed-message stale verdicts fixed by fix-marker preconditions.*
