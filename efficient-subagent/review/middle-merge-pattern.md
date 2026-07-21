# Review: Middle-Merge 통합 검증 패턴

> 작성 배경: 2026-05-22, build/torch-cuda-index 세션에서 확정.
> ADR-0011 Rev1~7 (7 amendment PR) + GPU 진단 #199~#202 (4 시행착오 PR) 회고.
> main commit history 오염 + 사용자이 회귀 발견자 되는 패턴 직접 차단 목적.
> 사용자 확정 사항 기반 정리. 본 파일은 SKILL.md 반영 전 review draft.

---

## 문제 (이전 안티패턴)

시행착오 PR 이 main 에 낱개로 머지되면:

- main commit history 에 `fix: rev1`, `fix: rev2`, `fix: rev3` ... 누적 → 맥락 없이 더러워짐
- 하나 고치면 다른 거 망가지는 연쇄 회귀 발생
- 사용자(운영자)이 회귀 발견자가 되는 패턴 반복 (CLAUDE.md 작업 규칙 12번 근본 동기)
- ADR-0011: 7개 amendment PR 이 main 에 낱개 squash → "ClickUp 알람 통합" 한 줄 기록 불가
- GPU 진단: 4개 시행착오 PR 이 main 기록에 그대로 남음

---

## Branch Tree 구조

```
main
 └─ middle-merge          ← 통합 검증 layer + main 게이트
     ├─ integration/docs
     │   └─ docs/<topic>
     ├─ integration/refactor
     │   └─ refactor/<topic>
     ├─ integration/feat
     │   └─ feat/<topic>
     │       └─ fix/<sub>  ← 시행착오 PR 누적
     └─ mixed/<topic>      ← cross-cutting (docs+code 등) middle-merge 직속
```

| Branch | 역할 |
|---|---|
| `main` | 실 운영. squash 1 commit 단위로만 받음 |
| `middle-merge` | **영구** 통합 검증 layer. main 게이트 |
| `integration/*` | 커밋 타입별 통합 bucket. sub-agent PR 수렴점. short-lived |
| `feat/<topic>/fix/<sub>` | 시행착오 sub-branch. integration/feat 아래 누적. short-lived |
| `mixed/<topic>` | cross-cutting 작업. integration 우회 허용 (supervisor 동의 후) |

---

## 직속 layer vs sub-branch — isolation 기준

middle-merge **직속** 하위 (integration/* + mixed/* + 단독 fix/*) 는 **root 공유**.
그 아래 sub-branch (시행착오 fix, 개별 feat 등) 는 **isolation: "worktree"**.

```
middle-merge (영구, supervisor root 공유)
 ├─ integration/feat      ← root 공유 (supervisor cwd switch 로 검증)
 │   └─ feat/<topic>      ← 별 worktree (isolation: "worktree")
 │       └─ fix/<sub>     ← 별 worktree
 ├─ integration/refactor  ← root 공유
 │   └─ refactor/<topic>  ← 별 worktree
 ├─ integration/docs      ← root 공유
 │   └─ docs/<topic>      ← 별 worktree
 ├─ mixed/<topic>         ← root 공유 (cross-cutting 직속)
 └─ fix/<topic>           ← root 공유 (단순 1 PR, integration 우회)
```

**이유**: integration/* 는 supervisor 가 cwd switch 로 즉시 검증 가능해야 함. sub-branch 는 시행착오 누적 구간 → 물리 파일 충돌 위험이 있어 worktree 격리.

---

## 사용자(supervisor) 검증 단위

- sub-branch 마다 supervisor 검증 X. sub-agent 자체 test (pytest 등) 로 minimal 통과만 확인.
- **integration/* 의 통합 결과를 supervisor 가 한 번에 검증** (회귀 + 신규 기능). middle-merge 머지 게이트.
- hallucinate 발견 시 integration 단위에서 sub-branch 추적 + revert/fix → 재검증. main 절대 안 손댐.

---

## 머지 방식

### A. integration → middle-merge: **merge commit 유지**

- 개별 PR history 보존 → 디버깅 시 `git log --merges` 추적 가능
- squash 하면 시행착오 맥락 소실 → merge commit 필수
- 명령: `gh pr merge <N> --merge`

### B. middle-merge → main: **squash 1 commit**

- main 은 작업 단위 1 줄만 ("feat: ADR-0011 ClickUp 알람 통합")
- 시행착오 sub-PR 흔적 main 에 노출 X
- 명령: `gh pr merge <N> --squash --subject "feat: <작업단위 한 줄>"`

---

## main 머지 게이트 (체크리스트)

middle-merge → main squash 전 사용자이 직접 확인:

- [ ] 실 운영 Discord 서버에서 신규 기능 정상 작동
- [ ] 기존 기능 회귀 없음 (봇 재기동 후 기본 흐름 확인)
- [ ] `mise run prompt-eval` PASS (Claude prompt 영향 PR 한정)
- [ ] 위 3개 통과 시 사용자이 명시 "머지 OK" — 에이전트 단독 판단 X

---

## cross-cutting 처리

강제 금지 X. 단, sub-agent 가 cross-cutting 가능성 감지 시 아래 알림 템플릿 사용 후 동의 받기.

**부작용 알림 템플릿 (sub-agent → 사용자)**:

```
이 작업은 docs + code 양쪽에 걸쳐 있어 cross-cutting 가능성 있음.

옵션 A: integration/docs + integration/feat 분리 (각각 PR)
  → 타입 명확, review 쉬움
  → 작업 2번 필요

옵션 B: mixed/<topic> 직속 (integration 우회)
  → 한 번에 처리
  → PR history 에서 타입 구분 어려움

어느 쪽으로 할까요?
```

동의 시 `mixed/<topic>` 직속 PR — target branch = `middle-merge`.

---

## sub-agent 위임 흐름

1. **commit type 선언**: 작업 시작 시 `feat` / `fix` / `docs` / `refactor` 확인
2. **integration branch 확인**: `integration/<type>` 존재 여부 체크
   - 없으면: `git switch -c integration/<type>` from `middle-merge`
3. **sub-branch 생성**: `git switch -c <type>/<topic>` from `integration/<type>`
   - 시행착오 fix 는 `git switch -c fix/<sub>` from `feat/<topic>`
4. **PR target**: `integration/<type>` (main X, middle-merge X)
5. **integration PR 완료 후**: `integration/<type>` → `middle-merge` merge commit

**위임 브리핑 예시 (feat)**:

```
target branch: integration/feat
base branch:   middle-merge
작업 완료 후 PR target = integration/feat
merge 방식 = merge commit (squash X)
```

---

## Long-lived sub-main 정책

middle-merge 는 **영구 sub-main** — main 으로 squash 머지된 후에도 삭제·reset 금지.

| Branch | 수명 |
|---|---|
| `main` | 영구 (squash commit 만 누적, 깔끔) |
| `middle-merge` | **영구** (merge chain 보존, 상세 history) |
| `integration/*` | short-lived — middle-merge merge 완료 후 즉시 삭제 |
| sub-branch (`feat/<topic>`, `fix/<sub>`) | short-lived — integration merge 완료 후 즉시 삭제 |

main squash 완료 = 기록 이전 완료. middle-merge 의 merge chain history 가 상세 내역 원천이므로 삭제하지 않는다.

---

## 언제 안 쓰나

main 직접 PR 은 **hotfix (긴급, 단발) 만** 예외.

| 상황 | 패턴 |
|---|---|
| 시행착오·다회 PR 예상 | `integration/<type>` (middle-merge 직속) |
| 단순 1 PR fix (시행착오 없음) | `fix/<topic>` (middle-merge 직속, integration 우회) |
| cross-cutting (docs+code 등) | `mixed/<topic>` (middle-merge 직속) |
| hotfix (긴급, 단발) | main 직접 (유일 예외) |

판단 기준: **"시행착오·다회 PR 이 예상되는가?"** → Yes면 `integration/<type>`, No면 `fix/<topic>`. 어느 쪽이든 middle-merge 직속 — main 직접 X.

---

## 소급 적용 불가 사항 (2026-05-22 기준)

- GPU 작업 #199, #200 은 이미 main 머지됨 → 소급 불가
- **다음 큰 작업부터 적용** — 현재 진행 중인 build/torch-cuda-index 완료 후

---

_이 파일은 review draft — 사용자 검토 후 SKILL.md 반영 여부 결정._
