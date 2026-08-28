---
name: efficient-subagent
description: Pre-work briefing for CLI sub-agents on context absorption, scope discipline, no-defensive-code rules, and concise final reporting. Use when a supervisor agent (Claude Code, Codex, or similar CLI) spawns a sub-agent via the Agent tool and wants to enforce consistent conventions, prevent scope creep, and keep handoff messages tight. Workflow-agnostic — works under any branch strategy.
disable-model-invocation: true
---

# Efficient Sub-Agent

You were spawned by a supervisor agent (Claude Code, Codex, or similar) and instructed to load this skill before starting work. Follow it as ground rules. These are workflow-agnostic — they hold under any branch strategy and for any task (implementation, review, plain web research).

## Hard rules — no re-delegation, no placeholder returns

You do NOT spawn further sub-agents, and your final message must BE the deliverable, never a "will report / 대기하겠다" status placeholder. Full rationale + the supervisor-side injection template: see **`AIL-subagent-fanout-guard`**.

## Before touching code — absorb context

Read in this order, once:

1. **`CLAUDE.md` / `AGENTS.md`** at repo root — project structure, conventions, scripts.
2. **`CONTEXT.md`** (or per-context `CONTEXT.md` files via `CONTEXT-MAP.md`) — domain glossary. Use these terms verbatim; do not invent synonyms.
3. **`docs/adr/`** — decisions in the area you are touching. Skim titles; read in full any ADR whose subject overlaps your task. If an overlapping ADR has `status: proposed`, treat the area as in-flight — surface to the supervisor before changing decisions there.

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
4. **Late-discovered docs** — guides/ADRs/specs you found mid-task or that the supervisor pointed you to, that *should have been visible* from the standard context-absorption order. Include the path and one phrase on what was missed. If nothing was missed, say `none` explicitly — silence reads as forgotten, not perfect. This signals gaps in the entry-point docs (folder `README.md`s, ADR titling, `CLAUDE.md`) — supervisor uses it to strengthen them.
5. **Blockers** — if you couldn't finish, exactly where and why

No self-introduction, no recap of what you understood, no "successfully implemented" framing. Result-only.

**Length**: under 200 words unless the supervisor specified otherwise. Supervisors read the result to pick the next action — verbosity hides the signal.

## Model selection (supervisor 전용 — sub-agent 호출 시)

Sub-agent를 spawn할 때 작업 난이도에 맞춰 `model` 인자를 **반드시** 명시한다.
명시하지 않으면 parent 모델을 상속 — Opus 메인 세션이면 단순 조사도 Opus로 돌아 낭비된다.

| 작업 유형 | model |
|---|---|
| 파일 위치 조회, glob/grep, 단순 listing | `haiku` |
| 연구, 코드 리뷰, 룰 검증, 일반 구현 | `sonnet` ← 기본 |
| 복잡한 다중 파일 설계, 아키텍처 추론 | `opus` |
| 병렬 호출 (여러 sub-agent 동시) | 각 호출마다 개별 명시. 병렬이라고 자동 downgrade 안 됨 |
| background / worktree isolation 호출 | 동일 룰 적용. 격리 여부와 모델 선택은 독립 |

**판단 기준**: 결과물이 틀렸을 때 재시도 비용 < 처음부터 Opus 쓰는 비용이면 sonnet으로 내린다.

→ 격리 전략은 모델 선택과 독립. repo 워크플로 마커가 `middle-merge` 이면 branch·isolation·검증·머지 규칙은 **`middle-merge`** 스킬을 로드해 따른다 (이 스킬은 워크플로 무관 규율만 담는다).

## 자료조사 작업 시 — 인식론 룰

이 섹션은 **웹·문헌 자료조사 작업에만** 적용된다. 코드 탐색·구현·리뷰에는 적용하지 않는다 — 코드에서 직접 확인한 사실은 1차 관찰이며, `file:line` 참조가 이미 인용 역할을 한다. GitHub issue·공식 문서 조사도 코딩 작업에서 파생된 경우 적용하지 않는다.

- **단정은 인용까지만.** 직접 관찰한 사실은 "출처가 그렇게 말했다"까지다. "~에 따르면", "~로 보고된 바 있다"로 기술한다.
- **핵심 claim마다 등급 라벨**:
  - `[사실]` = **독립** 출처 2개 이상 합치. 독립 = 각자 자체 데이터·조사 보유. 받아쓰기 기사는 원출처 1개로 카운트.
  - `[추정:계층]` = 단일 출처. suffix 필수 — `[추정:논문]` `[추정:기관]` `[추정:언론]` `[추정:블로그]`
  - `[모름]` = 출처 없음 또는 출처 간 상충. 상충은 양쪽 수치·출처를 그대로 노출하고 범위로 뭉개지 않는다.
  - `[의견:출처명]` = 타인의 전망·판단 인용. `[판단]` = 자신의 합성 판단.
- **단일 출처 단정 금지** — 최상위 금지 룰.
- **보고 말미 "검증 실패 항목" 의무** — 교차검증 실패·미확정 claim 목록. 없으면 `없음` 명시.
