---
name: git-workflow-select
description: Git 브랜치 워크플로를 카탈로그에서 선택·기록하고 CLAUDE.md에 마커로 고정하는 게이트. repo 시작 시 워크플로 미지정이면 작업 진입 전 선택을 강제하고, 중간 전환도 처리한다. Use when 새 repo를 git init/clone 직후, 브랜치를 만들려는데 워크플로 기준이 없을 때, "워크플로 정하자/바꾸자", "브랜치 전략", "git flow", "middle-merge" 를 언급할 때. middle-merge·supervisor-mode 가 middle-merge 워크플로를 전제하기 전 이 게이트를 먼저 태운다.
---

# Git Workflow Select

repo 마다 브랜치 워크플로를 **명시 선택**하고 CLAUDE.md 마커로 고정한다. 소프트 지시("알아서 브랜치 파")로 두면 매번 임의 브랜치가 새므로, 선택을 게이트로 강제한다.

## 게이트 규칙 (진입 조건)

브랜치를 만들거나 push 하기 **전에** **repo 루트** CLAUDE.md 에서 워크플로 마커를 읽는다 (서브모듈은 각 루트에 별도 마커):

```
## Git Workflow
현재 워크플로: <id>   (예: github-flow / git-flow / trunk-based / middle-merge)
```

- **마커 있음** → 그 워크플로 규칙대로 브랜치 세팅. 임의 브랜치 금지.
- **마커 없음** → 아래 [카탈로그](#카탈로그)를 사장에게 제시하고 **선택 강제**. 선택 전엔 브랜치 안 판다.
- **기계 판독 대상은 `현재 워크플로: <id>` 라인 하나** — 나머지 필드(선택일·근거 등)는 자유 기재.

## 카탈로그

| id | 구조 | 언제 |
|---|---|---|
| `github-flow` | `main` + 단명 `feature/*` → PR → main squash | 1인·소규모, 지속 배포. 기본 추천 |
| `git-flow` | `main`/`develop` + `feature/*`·`release/*`·`hotfix/*` | 릴리스 버전 관리 필요, 배포 주기 명확 |
| `trunk-based` | `main` 직접 + 짧은 브랜치, feature flag | 빠른 통합, CI 강함, 리뷰 가벼움 |
| `middle-merge` | `main`→`middle-merge`(영구)→`integration/<type>`→sub-branch(worktree) | 시행착오 다회 PR, 서브에이전트 병렬, main history 청결 필요. 상세는 **`middle-merge`** 스킬 (서브에이전트 규율은 `efficient-subagent`) |

사장에게 선택지를 제시할 땐 [CATALOG.md](CATALOG.md)(ASCII 다이어그램 요약본)를 그대로 건넨다. 각 워크플로의 브랜치 세팅·머지 명령 상세는 [REFERENCE.md](REFERENCE.md).

## 선택 절차

1. CLAUDE.md 마커 확인 → 없으면 카탈로그 제시. 이때 기존 브랜치 구조 감지(`git branch -a`) → 짐작되는 id 가 있으면 **사장에게 확인 질문**한다 (단독 `develop` 이 git-flow 를 확증하지 않으니 자동 확정 금지, 확인만).
2. 사장 선택 수령. 미정이면 repo 성격으로 1개 추천(1인 기획/코드 → `github-flow`, 서브에이전트 병렬 대작업 → `middle-merge`).
3. **마커 기록**: CLAUDE.md 에 `## Git Workflow` 섹션 추가.
4. **브랜치 세팅**: 선택한 워크플로의 초기 브랜치 생성(REFERENCE.md).
5. `middle-merge` 선택 시 → 이후 실행은 **`middle-merge`** 스킬(branch·isolation·검증·머지)로 위임. 서브에이전트 운영 규율은 `efficient-subagent`.

## 중간 전환

워크플로는 언제든 변경 가능. 스킬 레포가 상태를 안 들고 CLAUDE.md 마커가 단일 진실원이므로:

1. CLAUDE.md 마커를 새 id 로 갱신.
2. 브랜치 구조만 새 워크플로로 마이그레이션(REFERENCE.md 의 전환 표).
3. 진행 중 브랜치는 현 워크플로로 마무리 후 전환 권장 — 중간 전환 시 열린 PR 의 target 재지정 필요.

## 안티패턴

- 마커 확인 없이 `dev`·`feature/x` 임의 생성 — 이 스킬이 존재하는 이유.
- 카탈로그만 두고 선택 안 시킴 — 소프트 지시 무시 문제 재발. 선택은 **게이트**다.
- middle-merge 규칙을 여기 복붙 — 원본은 `middle-merge` 스킬. 여기선 id 로 라우팅만.

## 하드 게이트 (PreToolUse hook)

스킬 문서만으로는 mid-flight 브랜치 생성(작업 중 무심코 `git switch -c dev`)을 강제 차단할 수 없다. 실제 차단은 [hooks/git-workflow-gate.sh](hooks/git-workflow-gate.sh) 가 담당한다 — 브랜치 생성 3패턴(`switch -c` / `checkout -b` / `branch <신규>`)을 가로채, repo 루트 CLAUDE.md 에 `현재 워크플로:` 마커가 없으면 exit 2 로 차단한다. CLAUDE.md 자체가 없으면 통과(비관리 repo 안전판).

**설치** (`~/.claude/settings.json` `hooks.PreToolUse` — 상세는 `update-config`):
```json
{ "matcher": "Bash",
  "hooks": [{ "type": "command",
    "command": "bash \"<repo>/git-workflow-select/hooks/git-workflow-gate.sh\"",
    "if": "Bash(git *)", "timeout": 10 }] }
```
- settings.json 이 **레포 스크립트를 직접 참조** — 사본 drift 방지. 유지보수는 레포에서.
- 반영 후 `/hooks` 열거나 재시작해야 활성화.
- **python 의존**(git-bash 에 jq 부재로 shlex 파싱). python 없으면 fail-open(통과).
