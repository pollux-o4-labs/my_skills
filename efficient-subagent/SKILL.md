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
4. **Late-discovered docs** — guides/ADRs/specs you found mid-task or that the supervisor pointed you to, that *should have been visible* from the standard context-absorption order. Include the path and one phrase on what was missed. If nothing was missed, say `none`. This signals gaps in `docs/meta/spec-locations.md`, ADR titling, or the entry point — supervisor uses it to strengthen the guides.
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

→ 격리 전략은 모델 선택과 독립 — 격리 기준은 아래 섹션을 본다.

## Worktree isolation 기준 (supervisor 전용)

middle-merge **직속** layer (integration/*, mixed/*, 단독 fix/*) 는 **root 공유** 기본.
**sub-branch** (feat/<topic>, fix/<sub> 등 그 아래) 는 `isolation: "worktree"` 기본.

| 상황 | isolation | 이유 |
|---|---|---|
| middle-merge 직속 branch (integration/*, mixed/*, fix/*) | **X** | supervisor cwd switch 로 즉시 검증 가능 |
| sub-branch (feat/<topic>, fix/<sub> — 시행착오 구간) | **O** | 물리 파일 충돌 방지, 병렬 작업 허용 |
| 동시 multi-branch 작업 (진짜 파일 충돌 위험) | O | 파일 충돌 방지 |
| 대량 삭제·rename 포함 — rollback 필요 | O | 파일 상태 격리 |

**기본 패턴**: 직속 layer 는 `git switch -c <branch>` 후 공유 working directory 에서 작업.

branch switch 시 supervisor 에게 한 줄 알림:
```
branch switch → <이름>. 실행 중 프로세스 있으면 재기동 필요. uncommitted 변경 있으면 stash 먼저.
```

## 검증 책임 분배 (supervisor 전용)

| 상황 | 검증 주체 |
|---|---|
| pytest / mock 으로 충분히 잡히는 영역 (순수 로직, 내부 helper, type fix, import, mock-able 통합) | **AI end-to-end** — sub-agent 자체 test + supervisor 회귀 확인만. supervisor 통보 |
| 운영 UI / 외부 시스템 의존 / hardware / UX 시나리오 | **supervisor 직접 검증** — cwd 이동 + PR 실측 |

"middle-merge 안 떠나는 게 default" 는 idle 상태 (다른 작업·휴면) 의미.
supervisor 검증 영역 PR 발생 시 cwd 잠깐 이동 = 자연 — 두 줄은 다른 상황을 다룬다.

## Middle-merge 통합 검증 패턴 (supervisor 전용)

단순 fix 포함 **모든 작업**에 사용한다. main 직접 PR 은 hotfix (긴급, 단발) 만 허용.

**판단 기준**: "이 작업이 시행착오·다회 PR 이 예상되는가?" → Yes면 `integration/<type>`, No면 `fix/<topic>`. 둘 다 middle-merge 직속 — main 직접 X.

### Branch 수명

| Branch | 수명 |
|---|---|
| `main` | 영구 (squash commit 만 누적) |
| `middle-merge` | **영구 sub-main** — main squash 후에도 삭제·reset X. merge chain history 원천 |
| `integration/*` | short-lived — middle-merge merge 완료 후 즉시 삭제 |
| sub-branch (`<type>/<topic>`, `fix/<sub>`) | short-lived — integration merge 완료 후 즉시 삭제 |

### Branch 구조

```
main
 └─ middle-merge (영구)
     ├─ integration/<type>  ← root 공유. commit 타입별 bucket. <type> = feat / refactor / docs / chore / test / perf 등 Conventional Commits prefix
     │   └─ <type>/<topic>  ← worktree isolation. 시행착오 sub-branch
     │       └─ fix/<sub>   ← worktree isolation
     ├─ mixed/<topic>       ← root 공유. cross-cutting 직속
     └─ fix/<topic>         ← root 공유. 단순 1 PR 직속 (integration 우회)
```

### 사장(supervisor) 검증 단위

- sub-branch 마다 supervisor 검증 X. sub-agent 자체 test 로 minimal 통과만 확인.
- **integration/* 통합 결과를 supervisor 가 한 번에 검증** (회귀 + 신규 기능). middle-merge 머지 게이트.
- hallucinate 발견 시 integration 단위 추적 + revert/fix → 재검증. main 절대 안 손댐.

### 머지 방식

| 방향 | 방식 | 이유 |
|---|---|---|
| sub-branch (`<type>/<topic>`, `fix/<sub>`) → integration | merge commit | 시행착오 맥락 보존 |
| integration → middle-merge | merge commit | 통합 단위 명시 |
| `fix/<topic>` (단독) → middle-merge | merge commit | sub-branch 와 동일. main squash 시 어차피 압축 |
| middle-merge → main | squash 1 commit | main history 를 작업 단위 1 줄로 유지 |

### Cross-cutting 판단 기준

한 PR 이 commit type 2개 이상 손대면 cross-cutting:

- docs + code 동시 변경
- refactor + feat 동시
- docs + refactor 동시

처리: sub-agent 가 supervisor 에게 알림 → 동의 후 `mixed/<topic>` 직속 middle-merge (integration 우회).
단일 commit type 안에 머무르면 일반 `integration/<type>` 사용.

### 병렬 작업 머지 순서

여러 integration 이 동시에 ready 상태일 때:

1. 기본 기준: 파일 충돌 적은 순 (보통 docs → refactor → feat)
2. dependency 있으면 dependency 순서 우선
3. 최종 결정 = supervisor

### sub-agent 위임 시 브리핑 예시

```
target branch: integration/<type>
base branch:   middle-merge
PR target = integration/<type>  (main X)
merge 방식 = merge commit (squash X)
```

### 언제 안 쓰나

- hotfix (긴급, 단발) → main 직접 (유일 예외)
- 그 외 모든 작업은 middle-merge 경유. 1 PR 도 `fix/<topic>` (middle-merge 직속, L123 참고)

## Anti-patterns (do not do)

- Out-of-scope cleanup or refactoring
- Defensive code for impossible cases
- Future-proofing shims, dead feature flags
- *What*-explaining comments on well-named code
- Self-recap or success-framing in the final message
- Silently overriding the supervisor's request when conventions conflict — surface it instead
- Omitting the **Late-discovered docs** field. If nothing was missed, write `none` explicitly — silence reads as forgotten, not perfect
