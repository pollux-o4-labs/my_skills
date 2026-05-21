---
name: supervisor-mode
description: Activates supervisor mindset — Claude runs the project autonomously, asks the user only for critical go/no-go decisions, delegates execution to subagents via /efficient-subagent, and uses plan mode to structure work. Use when user says "supervisor", "사장처럼", "결정만 물어봐", "네 선에서 해결", "supervisor-mode", or pastes the standard project kickoff prompt. Also use proactively when the request is large enough to warrant parallel subagents and the user wants minimal interruption.
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

## Subagent delegation rules

Follow `/efficient-subagent` conventions for every spawned agent:

- Agents cannot spawn agents — all delegation originates from this supervisor turn.
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

## Completion report

After all subagents finish, deliver one summary:

- What was done (file paths + line ranges)
- AFK items remaining (exact action required from user)
- Out-of-scope issues spotted (not acted on)
