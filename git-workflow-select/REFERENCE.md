# REFERENCE — 워크플로별 세팅·머지·전환

SKILL.md 의 카탈로그 id 별 상세. 브랜치 초기 세팅, 머지 명령, 전환 절차.

## github-flow

**구조**: `main` 하나 + 작업마다 단명 `feature/<topic>` → PR → `main` 에 squash 머지.

```bash
# 세팅: main 만 있으면 끝. 작업 시작 시
git switch -c feature/<topic> main
# 완료
gh pr create --base main
gh pr merge <N> --squash --delete-branch
```

- 릴리스 = `main` 에 태그(`git tag v1.0`). 별도 release 브랜치 없음.
- 1인·소규모 기본값.

## git-flow

**구조**: 영구 `main`(릴리스) + 영구 `develop`(통합), 단명 `feature/*`·`release/*`·`hotfix/*`.

```bash
git switch -c develop main            # 최초 1회
git switch -c feature/<topic> develop # 기능
# 기능 완료 → develop
gh pr merge <N> --merge --delete-branch
# 릴리스 준비
git switch -c release/1.0 develop
# 릴리스 확정 → main + develop 양쪽 머지, main 에 태그
git switch main && git merge release/1.0 && git tag v1.0
git switch develop && git merge release/1.0
# 긴급
git switch -c hotfix/<topic> main
```

- 배포 버전 관리가 명확할 때. 오버헤드 있으니 1인이면 과할 수 있음.

## trunk-based

**구조**: `main`(trunk) 직접 통합 + 수시간~1일 단명 브랜치. 미완성 기능은 feature flag 뒤로.

```bash
git switch -c work/<topic> main   # 짧게
gh pr merge <N> --squash --delete-branch   # 하루 내 통합
```

- CI 강하고 리뷰 가벼울 때. 브랜치 오래 안 끈다.
- 릴리스 = `main` 태그 또는 release 브랜치 컷.

## middle-merge

**구조·머지·isolation·issue 세팅 일체 `efficient-subagent` 스킬 참조.** 여기서 중복하지 않는다 — 요약도 두지 않는다. 요약은 원본과 반드시 drift 하므로.

---

## 전환 표 (from → to)

현 워크플로에서 새 워크플로로 옮길 때 브랜치 조치. **CLAUDE.md 마커 갱신이 먼저**, 브랜치는 그 다음.

| from → to | 조치 |
|---|---|
| github-flow → middle-merge | `git switch -c middle-merge main`. 이후 `integration/<type>` 부터 시작 |
| github-flow → git-flow | `git switch -c develop main`. 이후 feature 는 develop 기점 |
| middle-merge → github-flow | 열린 `integration/*`·sub-branch 정리(머지 or 삭제). `middle-merge` 브랜치 보존 여부는 사장 판단. 이후 `feature/*` 는 main 기점 |
| git-flow → github-flow | `develop` 을 main 에 머지 후 develop 보존/삭제 결정. 이후 feature 는 main 기점 |
| trunk-based → 기타 | trunk 는 그냥 main 이므로 위 main 기점 규칙 그대로 적용 |

**공통 원칙**:
- 표에 없는 조합은 **main 기점 공통 원칙** 적용 — 신 워크플로의 초기 브랜치를 main 기점으로 새로 세팅.
- 열린 PR 있으면 전환 전 머지·클로즈. 안 그러면 target 브랜치 재지정 필요.
- 영구 브랜치(develop, middle-merge) 삭제는 되돌리기 비싸니 사장 명시 확인 후.
- 전환 후 첫 브랜치 생성 시 새 워크플로 규칙 준수 확인.

## CLAUDE.md 마커 템플릿

```md
## Git Workflow

현재 워크플로: middle-merge

- 선택일: 2026-07-05
- 근거: 서브에이전트 병렬 대작업, main history 청결 필요
- 상세 규칙: `efficient-subagent` 스킬 (middle-merge 선택 시)
```
