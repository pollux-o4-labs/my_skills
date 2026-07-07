# Middle-Merge Reference

Detailed source rules moved out of SKILL.md to keep the loadable skill under the write-a-skill size guideline. Read this file only after the repo workflow marker is confirmed as `middle-merge`.

# Middle-Merge Workflow

`middle-merge` 워크플로의 branch 구조·isolation·검증·머지 상세 원본. 범용 서브에이전트 규율(context 흡수·scope·보고 포맷·model 선택)은 `efficient-subagent` 에 있다 — 이 스킬은 middle-merge 선택 repo 에서 그 위에 얹는다.

## 적용 전제 (먼저 읽는다)

이하 "Worktree isolation 기준"·"검증 책임 분배"·"Middle-merge 통합 검증 패턴" 은 repo 가 `middle-merge` 워크플로를 **선택했을 때만** 적용된다. repo 워크플로는 repo 루트 CLAUDE.md 의 `## Git Workflow` 마커가 단일 진실원이다.

- 마커가 `middle-merge` → 아래 규칙 그대로 적용. 이 문서가 그 원본이다.
- 마커가 없거나 다른 id(`github-flow` 등) → 아래 middle-merge 규칙을 적용하지 말고, **supervisor 에게 blocker 로 보고한 뒤 브랜치 작업을 중단**한다. sub-agent 는 카탈로그 제시·선택 수령·재위임이 불가하므로 스스로 워크플로를 선택하지 않는다. 워크플로 선택 게이트는 supervisor 가 **`git-workflow-select`** 로 태운다.

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

### 4 layer 검증 chain (PR 흐름)

원 작업자 sub-agent 의 PR 을 main supervisor 가 받으면 **즉시 사장에게 보내지 말 것**. code review sub-agent 위임 후 결과 종합 → 사장 검증 게이트.

| Layer | 주체 | 책임 |
|---|---|---|
| 1 | 원 작업자 sub-agent | 코드 변경 + 자체 test + PR 생성 |
| 2 | code review sub-agent | PR diff 객관 review — 보고와 실 변경 일치, scope, 로직, 부작용 점검 |
| 3 | main supervisor | review 결과 종합 + 사장 보고 |
| 4 | 사장 | 운영 실측 (cwd 이동 + 시나리오 확인) → 머지 |

code review 위임 prompt 예시:
- 입력: PR 번호 또는 branch 이름
- 출력: 변경 file 매핑, scope 검토, 로직 점검, 부작용, OK / 정정 필요 판단

main 이 직접 PR diff 모두 읽는 패턴 (= layer 2 우회) 금지 — 객관 review layer 확보 위해.

## Middle-merge 통합 검증 패턴 (supervisor 전용)

> **전제 재확인**: 마커가 `middle-merge` 일 때만 적용 (상단 "적용 전제" 참조). 아래는 그 상세 규칙이자 원본이다.

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

| 방향 | gh CLI 명령 | 이유 |
|---|---|---|
| sub-branch (`<type>/<topic>`, `fix/<sub>`) → integration | `gh pr merge <N> --merge` | 시행착오 맥락 보존 |
| integration → middle-merge | `gh pr merge <N> --merge` | 통합 단위 명시 |
| `fix/<topic>` (단독) → middle-merge | `gh pr merge <N> --merge` | sub-branch 와 동일. main squash 시 어차피 압축 |
| middle-merge → main | **`gh pr merge <N> --squash`** | main history 를 작업 단위 1 줄로 유지 |

> **⚠️ gh CLI 머지 옵션 명시 의무**
>
> `gh pr merge <N>` 만 박으면 기본 `--merge` (merge commit) 모드가 된다.
> middle-merge → main 머지 시 **반드시 `--squash` 명시**:
>
> ```powershell
> gh pr merge <N> --squash    # ✅ middle-merge → main
> gh pr merge <N> --merge     # ✅ integration → middle-merge, sub-branch → integration
> ```
>
> 옵션 없이 박으면 main 에 merge commit chain 누적 → `git reset --hard` + force push 정정 비용 발생 (실제 사례).
> merge 방식을 대화형으로 선택하려면 `gh pr merge <N>` (옵션 없이) 로 interactive prompt 사용.

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

### Issue → Branch 자동 세팅 룰 (supervisor 전용)

issue 발행 시 main supervisor 가 자동으로 middle-merge 하위 branch 를 만든다 — sub-agent 발사 전 단계.

| 작업 성격 | branch 이름 패턴 | base |
|---|---|---|
| 시행착오 다회 PR 예상 | `integration/<type>/<issue-N>` 예: `integration/feat/123` | middle-merge |
| 단순 1 PR 예상 | `fix/<issue-topic>` 또는 `fix/<issue-N>` 예: `fix/123-emoji-encoding` | middle-merge |

흐름:
1. issue 발행 (사장 또는 AI)
2. main supervisor 가 위 패턴으로 branch 생성 + push (또는 local 만)
3. sub-agent 발사 시 그 branch 를 base 로 박음. sub-branch (`<type>/<topic>`) 는 그 안에서 만듦
4. sub-agent PR target = issue branch (main X, middle-merge X 도 X)
5. issue 완료 → issue branch → middle-merge merge commit

issue 단위 = 1 integration branch 매핑 — 한 issue 의 모든 시행착오 PR 이 한 곳에 모임. middle-merge 로 가기 전 통합 검증 단위.

### sub-agent 위임 시 브리핑 예시

```
target branch: integration/<type>
base branch:   middle-merge
PR target = integration/<type>  (main X)
merge 방식 = merge commit (squash X)
```

### 언제 안 쓰나

- hotfix (긴급, 단발) → main 직접 (유일 예외)
- 그 외 모든 작업은 middle-merge 경유. 1 PR 도 `fix/<topic>` (middle-merge 직속)
