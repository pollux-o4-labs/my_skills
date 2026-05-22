# Review: setup-my-skills — Middle-Merge 협업 컨벤션 반영 안

> 작성 배경: 2026-05-22, efficient-subagent SKILL.md 정정 세션.
> efficient-subagent 의 middle-merge 패턴이 확정된 사장 모델로 굳어짐에 따라,
> 새 프로젝트에 setup-my-skills 를 적용할 때 이 패턴을 안내하는 절차가 필요.
> 본 파일은 setup-my-skills SKILL.md 본체 개정 전 review draft.

---

## 목적

새 프로젝트 온보딩 시 `setup-my-skills` 가 설치하는 협업 컨벤션 맵 (`CLAUDE.md` 아키텍처 섹션 등) 에
middle-merge tree + branch 패턴 + 검증 트리거 룰을 포함시키는 안을 제시한다.

---

## 현행 gap

현재 `setup-my-skills` 가 제공하는 `claude-root-template.md` / `agent-skills-block.md` 에는:

- sub-main (middle-merge) 존재 여부 언급 없음
- branch 네이밍 패턴 (`integration/*`, `fix/<topic>`, `mixed/<topic>`) 없음
- 검증 트리거 (누가, 어느 단계에서 검증하는가) 없음
- hotfix 예외 규칙 없음

결과: 새 프로젝트에서 sub-agent 가 branch 전략 없이 main 에 직접 PR 하는 패턴이 반복됨.

---

## 권장: 협업 컨벤션 맵 템플릿 보완 내용

### 1. Sub-main (middle-merge) 여부 결정 트리거

새 프로젝트 적용 시 아래 질문으로 sub-main 필요 여부를 결정한다:

| 질문 | Yes → | No → |
|---|---|---|
| 여러 AI agent 가 동시에 PR 을 생성하는가? | sub-main 필수 | 단일 agent — 선택 |
| 한 기능에 시행착오 PR 이 2개 이상 예상되는가? | sub-main 권장 | 선택 |
| main history 를 작업 단위 1줄로 유지해야 하는가? | sub-main 권장 | 선택 |
| 프로젝트 규모 < 1인 + PR < 주 3개 이하 | 필요성 낮음 | — |

---

### 2. Branch 패턴 (범용)

```
main
 └─ middle-merge          ← 영구 sub-main. main 게이트
     ├─ integration/<type> ← commit type 별 통합 bucket (short-lived)
     │   └─ <type>/<topic> ← worktree isolation. 시행착오 sub-branch
     │       └─ fix/<sub>  ← worktree isolation. 연쇄 fix
     ├─ mixed/<topic>      ← cross-cutting 직속 (middle-merge 직속)
     └─ fix/<topic>        ← 단순 1 PR 직속 (integration 우회, middle-merge 직속)
```

**핵심 룰**:
- main 직접 PR = hotfix (긴급, 단발) 만. 그 외 모두 middle-merge 경유.
- 단순 1 PR 도 `fix/<topic>` → middle-merge 경유. "1 PR → main 직접" 금지.
- 판단 기준: "시행착오·다회 PR 예상?" → Yes = `integration/<type>`, No = `fix/<topic>`. 둘 다 middle-merge 직속.

---

### 3. 검증 트리거 룰

| 영역 | 검증 주체 |
|---|---|
| 순수 로직 / 내부 helper / mock-able 통합 | AI end-to-end (sub-agent 자체 test + supervisor 회귀 확인) |
| 운영 UI / 외부 시스템 / hardware / UX 시나리오 | supervisor (사장) 직접 검증 |

- sub-branch 단위 supervisor 검증 X. integration/* 통합 결과를 supervisor 가 한 번에 검증.
- hallucinate 발견 → integration 단위 revert/fix → 재검증. main 안 손댐.

---

### 4. PR 검증 chain (4 layer)

원 작업자 → code review sub-agent → main supervisor → supervisor (사람) → middle-merge 머지.
세부는 efficient-subagent SKILL.md 의 `4 layer 검증 chain` 참고.

---

### 5. Issue → Branch 자동 세팅

issue tracker 사용 시 main supervisor 가 issue 발행 → middle-merge 하위 branch 자동 생성 → sub-agent 위임. 세부는 efficient-subagent SKILL.md 의 `Issue → Branch 자동 세팅 룰` 참고.

---

### 6. 환경 구분 (단일 사용자 vs 다인 협업)

| 환경 | 권장 패턴 |
|---|---|
| 단일 supervisor + AI agent | root 공유 기본. sub-branch 만 worktree isolation. |
| 다인 협업 (사람 + AI 혼재) | integration/* 도 worktree isolation 고려. merge conflict 방지. |
| 초소규모 (PR < 주 3개, 시행착오 적음) | middle-merge 선택 사항. hotfix 패턴만 main 직접. |

---

### 7. 병렬 sub-agent 머지 순서 룰

여러 integration/* 가 동시에 ready 상태일 때 supervisor 는 아래 기준으로 순서 결정:

1. **기본**: 파일 충돌 적은 순 (보통 docs → refactor → feat)
2. **dependency 있으면**: dependency 순서 우선
3. **최종 결정**: supervisor

sub-agent 가 스스로 순서를 정하지 않는다 — supervisor 에게 알림 후 대기.

---

### 7-b. fix/<topic> 단독 머지 방식

`fix/<topic>` (단독, integration 우회) → middle-merge 방향은 **merge commit** 을 쓴다.
sub-branch 와 동일 이유: middle-merge → main squash 시 어차피 압축되므로 merge commit 유지가 맥락 추적에 유리.

---

### 8. CLAUDE.md 협업 컨벤션 섹션 추가 템플릿

새 프로젝트의 `CLAUDE.md` 에 아래 블록을 추가하도록 `setup-my-skills` 가 안내한다:

```markdown
## Branch 전략

- main 직접 PR: hotfix (긴급, 단발) 만.
- 모든 작업: `middle-merge` 경유. 1 PR 도 예외 없음.
- 시행착오·다회 PR → `integration/<type>` (middle-merge 직속)
- 단순 1 PR → `fix/<topic>` (middle-merge 직속, integration 우회)
- cross-cutting → `mixed/<topic>` (middle-merge 직속)
- middle-merge → main: squash 1 commit. integration → middle-merge: merge commit.
```

---

## setup-my-skills SKILL.md 반영 제안

1. `agent-skills-block.md` 에 "Branch 전략" 섹션 추가 (위 템플릿 포함).
2. `claude-root-template.md` 의 협업 섹션에 sub-main 여부 결정 트리거 질문 추가.
3. 온보딩 체크리스트에 "middle-merge branch 생성 여부 결정" 항목 추가.
4. 병렬 sub-agent 머지 순서 룰 (§5) + fix/<topic> 머지 방식 (§5-b) 을 템플릿에 포함.

---

_이 파일은 review draft — 사장 검토 후 setup-my-skills SKILL.md 반영 여부 결정._
