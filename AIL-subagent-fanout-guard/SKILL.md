---
name: AIL-subagent-fanout-guard
description: Guard rails for fanning work out across multiple subagents. Use when about to spawn several parallel or background Agent calls for research, surveys, audits, or any broad multi-part task. Prevents recursive agent explosions (agents spawning agents that return "I'll wait / will report" placeholders) that silently multiply into dozens of processes, burn tokens, and trip rate limits.
version: 1.0.0
metadata:
  platforms: [claude-code, codex]
  provenance: AIL (session lesson — research fan-out that ballooned into dozens of nested agents)
---

# Subagent Fan-out Guard

You (the supervisor) are about to spawn multiple subagents. Before you do, wire these into **every** spawn prompt. The failure this prevents: a broad task ("survey every service / audit all modules") makes each agent recursively fan out into its own children, and the parents return status placeholders instead of results — dozens of processes, wasted tokens, rate limits. A mid-flight `SendMessage` nudge does **not** reliably stop a runaway; agents already looping on "waiting for my children" re-delegate again. **Prevention in the initial prompt is the only reliable control.**

## Procedure

1. **Cap fan-out up front.** Decide the agent count before launching (e.g. one per axis/dimension, ~5) and hold it. Do not let scope ("everything") translate into unbounded spawning.
2. **Inject the two hard constraints into each spawn prompt** (paste verbatim):
   > - 너는 하위 서브에이전트를 spawn하지 않는다. 작업이 넓어도 네가 직접 수행한다. 쪼갤 필요가 있으면 그 사실을 한 문장으로 보고하고 멈춘다.
   > - 최종 메시지는 실제 산출물이어야 한다. "완료되면 보고" / "대기하겠다" 같은 상태 placeholder를 최종 반환값으로 내지 마라 — 지금 가진 것으로 self-contained 결과를 낸다.
3. **Give each agent a self-contained prompt**: goal, scope boundary, files/URLs to read, expected output format. No shared state it must coordinate.
4. **Assign model per task** (haiku → lookup, sonnet → research/review default, opus → complex design). Parallel calls do not auto-downgrade — set each.
5. **Collect and synthesize yourself.** The supervisor compiles; agents only return their piece.

## Pitfalls

- **Nudging a runaway.** Once agents are recursively fanning out, SendMessage rarely halts it — they re-delegate. Fix is prevention (step 2), not correction.
- **Placeholder as final output.** An agent whose last message is "I'll report when done" delivered nothing — that work is lost to you. Step 2's second constraint blocks it.
- **Scope→spawn leakage.** "Be comprehensive" read as "spawn without limit." Step 1 caps it.
- **Reacting to every nested notification.** If a runaway already happened, don't respond substantively to each nested-child ping — collect real digests, ignore placeholders, `TaskList`/`TaskStop` the stragglers, then synthesize.

## Verification

- [ ] Fan-out count decided and bounded before launch?
- [ ] Both hard constraints (no re-delegation, no placeholder return) in every spawn prompt?
- [ ] Each prompt self-contained with explicit output format?
- [ ] Model set per call?
- [ ] Plan to compile results yourself, not await an agent's "final report" promise?
