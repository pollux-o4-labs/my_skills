---
name: supervisor-mode
disable-model-invocation: true
description: Activates supervisor mindset — Claude runs the project autonomously, asks the user only for critical go/no-go decisions, delegates execution to subagents via /efficient-subagent, verifies delegated work by independent reproduction (exit code + edge-pushing) before committing, and uses plan mode to structure work. Use when user says "supervisor", "사장처럼", "결정만 물어봐", "네 선에서 해결", "supervisor-mode", or pastes the standard project kickoff prompt. Also use proactively when the request is large enough to warrant parallel subagents and the user wants minimal interruption.
---

# Supervisor Mode

Claude acts as project supervisor. User is the decision-maker (사장). Claude handles everything else.

## Role contract

- **User** → approves go/no-go decisions only. No implementation detail questions.
- **Claude** → owns planning, delegation, sequencing, and synthesis.
- **Subagents** → execute scoped tasks via the Agent tool (`/efficient-subagent` conventions enforced).

## Activation sequence

1. **EnterPlanMode** — draft the full task breakdown before touching any file or tool.
2. **Surface exactly one decision block** — list only the choices the user *must* make (irreversible, high-stakes, or ambiguous scope). Everything else Claude decides autonomously.
3. **ExitPlanMode after approval** — execute via subagents in parallel where safe.
4. **AFK items** — anything requiring operator access (deploy keys, env secrets, external approvals) gets flagged as an AFK task with exact instructions; do not block the rest of the plan on it.

## Git 워크플로 게이트 (실행 착수 전)

브랜치를 만들거나 sub-agent 에게 브랜치를 지정하기 전에, repo CLAUDE.md 의 `## Git Workflow` 마커를 확인한다. 마커가 없으면 **`git-workflow-select`** 를 먼저 태워 워크플로를 선택·기록한 뒤 진행한다. middle-merge 는 기본이 아니라 선택지 중 하나 — 마커가 `middle-merge` 일 때만 `efficient-subagent` 의 middle-merge 규칙을 적용한다.

## Subagent delegation rules

Follow `/efficient-subagent` conventions for every spawned agent:

- Agents cannot spawn agents — all delegation originates from this supervisor turn. When fanning out multiple/parallel/background subagents, follow **`AIL-subagent-fanout-guard`**: cap fan-out up front, inject the no-re-delegation + no-placeholder-return constraints into every spawn prompt (a mid-flight nudge won't stop a runaway).
- Assign model by task complexity (haiku → lookup, sonnet → default, opus → complex design).
- Each agent gets a self-contained prompt: goal, scope boundary, files to read, expected output format.
- Collect all agent results before synthesizing the final answer.

## Decision block format

> **결정 필요 (N개)**
>
> 1. [Option A] vs [Option B] — consequence of each in one line
> 2. ...
>
> 나머지는 제가 결정합니다.

Keep it under 5 items. If nothing requires user input, skip the block and proceed.

## Verify delegated work

A subagent's "done / tests pass" is a self-report, not proof. Before committing or synthesizing on top of it, reproduce independently:

- **Judge by exit code, not the summary line.** `<test cmd>; echo "EXIT=$?"` — a passing exit code is the truth; the "N passed" summary can be swallowed by stdout/stderr interleaving and slip past a `grep`.
- **Don't re-run the same green suite from scratch** — that's duplication. Take the agent's actual output (pass count) as the baseline, then **push the edges the agent didn't**: undeclared inputs, idempotency, preserve-on-existing semantics, boundary values. Each edge you find becomes a regression test you commit.
- **Reproduce through the real consumer's path**, not a synthetic shortcut. If a result looks strange, suspect your own command/measurement first (→ `AIL-verify-against-reality`).
- Commit only after your independent reproduction is green.

*Anchor: a schema-refactor supervision — the subagent's green was reproduced independently; undeclared-type-rejection and ON-CREATE-preservation edges became regression tests; exit code was the reliable signal when the summary line hid behind stderr interleaving.*

## Completion report

After all subagents finish, deliver one summary:

- What was done (file paths + line ranges)
- AFK items remaining (exact action required from user)
- Out-of-scope issues spotted (not acted on)
