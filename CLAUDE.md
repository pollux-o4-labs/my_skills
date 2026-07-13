@~/.claude/skills/karpathy-guidelines/SKILL.md
@~/.claude/skills/AIL-calibrate-verification-depth/SKILL.md

# my_skills

Claude Code, Codex, Gemini CLI 공용 커스텀 스킬 레포. 각 스킬 동작은 해당 `SKILL.md` 참조.

## 작업 규칙
- 스킬 수정 전 해당 SKILL.md를 반드시 읽고 시작
- 디렉토리명 = name (kebab-case), 진입점 = SKILL.md
- **provenance 접두사**: AI가 세션 교훈에서 스스로 생성·승격한 스킬은 `AIL-` 접두사(AI-Learned, 예: `AIL-verify-against-reality`). 사용자가 의도적으로 넣은 스킬과 구분 — 나중에 리팩터·정리·신뢰도 판단 시 식별용. 새 교훈 스킬화 시 이 접두사를 붙인다.
- **AIL 스킬 frontmatter**: `version`(semver, 수정 시 bump) + `metadata.provenance: AIL` + `metadata.platforms` 기입. description은 짧게(상시 로드 비용).
- **분량·중복 상한(전 스킬 공통)**: description = what+when 2문장, 목표 ≤400자 — 도구·예외 나열은 본문("Skip"/"Do NOT use" 절)으로 내린다. 본문 목표 ≤700단어(1,000 초과 시 분할·압축 검토). Verification은 결과 확인형 ≤6항 — Procedure의 1:1 재진술 금지. Origin/Provenance 서명은 1줄. 상한은 **영문 기준**(언어별 환산 근거는 `skill-refactor/RATIONALE.md` §3). 기존 스킬은 파일럿 우선 소급(1차 파일럿: AIL-calibrate-agent-spend) — 이후 각 스킬을 수정하는 시점에 `skill-refactor` 스킬로 이 상한에 맞춘다. lint 자동화는 위반 재발 시 도입. 근거 원문은 `skill-refactor/RATIONALE.md`.
- **언어**: 스킬 정본은 영어 1개(한국어는 리뷰 렌더링만). 예외 = 한국어 출력 자체를 가르치는 스킬(예: format-response). repo 규칙·문서는 해당 repo의 문서 언어를 따른다(`write-a-rule` 표가 영·한 양식 지원).
- 보조 문서는 스킬 디렉토리 안에 — 루트 오염 금지
- **미완성 스킬은 origin에 올리지 않는다** — 로컬 untracked/.gitignore로 유지하고 완성·리뷰 후 커밋. untracked 스킬을 "커밋 누락"으로 단정해 대신 커밋하지 말 것(2026-07-12 AIL-prefer-incremental-over-full 오커밋 사건이 근거).
- setup-my-skills → efficient-subagent 의존관계 있음
- CLI 별 등록 경로와 전역 지침 파일 차이를 섞지 말고 대상 host 를 먼저 식별

## 스킬 등록 경로 (host별 — 2026-07 실측)

| Host | 경로 | 방식 | 주의 |
|---|---|---|---|
| Claude Code | `~/.claude/skills/<name>` | 이 repo로 **정션** | 즉시 반영 |
| Codex | `~/.codex/skills/<name>` | `~/.agents/my_skills/<name>`로 정션 | `~/.agents/my_skills`는 GitHub **clone** — push 후 그쪽에서 `git pull` 해야 반영 |
| Gemini CLI | `~/.gemini/skills/<name>` | 디렉토리 **복사본** | pull/정션 아님 → 방치 시 drift. 갱신 시 재복사 필요 |

새 스킬 등록 시 세 host 모두 처리하고, repo에서 스킬 삭제 시 각 host의 정션·복사본도 제거(dangling 정션 방지).

세 host 등록·재동기화는 통합 스크립트로 일괄 처리한다. 서브모듈 기반 스킬(md-ebook·show-me)은 이 스크립트가 건드리지 않는다.
- **Windows**: `sync-skills/sync-skills.ps1` (구 `~/.gemini/antigravity-cli/sync-skills.ps1` 대체). `-Host claude|codex|gemini`, `-Only <스킬명>`, `-WhatIf`(드라이런), Gemini prune 은 `-PruneMirror` 명시 시.
- **Linux/macOS**: `sync-skills/sync-skills.sh` (동일 의미). `--host`, `--only a,b`, `--all-skills`, `--dry-run`, `--prune-mirror`. host 는 심볼릭 링크(claude·codex)·복사(gemini)로 등록하며, **해당 host 의 skills 디렉토리가 이미 있을 때만** 갱신한다(미설치 host 는 새로 만들지 않음).

**커스텀 정책 — 선언적 매니페스트 + AIL 자동**: 전체 실행이 링크하는 집합 = **`AIL-*`(provenance 로 자동)** ∪ **`sync-skills/claude-skills.txt` 매니페스트에 적힌 비-AIL 스킬**. 개인 스킬(자동 인식 안 되는 전용 스킬)은 이 매니페스트에 **한 줄 추가**하면 모든 머신에서 다음 `git pull` 때 링크된다. `--only`/`-Only` 는 매니페스트에 없는 스킬을 일회성으로 등록. prune 은 이 repo 가 소유한(타깃이 repo 하위) 링크에 대해서만, **dangling 이거나 매니페스트에서 빠졌을 때** 수행 — foreign 링크·일반 디렉토리(다른 설치물)는 절대 안 건드린다. 매니페스트에서 한 줄 지우면 다음 sync 때 그 링크가 정리된다.

**pull 시 자동 연결 (git hook)**: `sync-skills/git-hooks/post-merge` 가 `git pull`/merge 직후 `sync-skills.sh` 를 돌려 새로 받은 AIL 스킬을 자동 링크한다. (GitHub Actions 는 로컬 `~/.claude` 에 접근 불가 — 자동 연결은 반드시 로컬 hook 으로 한다. Actions 는 repo 쪽 검증 용도로만.)

**머신마다 1회 부트스트랩**: git 은 clone 에 hook 활성화를 딸려 주지 않는다(보안 — clone 이 코드 자동 실행 불가). 그래서 `core.hooksPath` 는 **clone 마다 한 번** 걸어야 한다. 새 환경에서 clone 직후 OS 에 맞게 1회:
```bash
bash sync-skills/install.sh          # Linux/macOS
pwsh -File sync-skills\install.ps1   # Windows
```
이후 그 머신에선 `git pull` 이 자동으로 새 AIL 스킬을 링크한다. post-merge hook 은 OS 를 감지해 Windows 는 `sync-skills.ps1`(정션), Unix 는 `sync-skills.sh`(심볼릭 링크)로 분기한다(Windows 에선 Git Bash 가 hook 을 실행). 수동 활성화: `git config --local core.hooksPath sync-skills/git-hooks`.

## 서브모듈 — md-ebook (= md2ebook), show-me

`md-ebook/` 와 `show-me/` 는 일반 폴더가 아니라 각각 공개 repo `pollux-o4/md2ebook`, `pollux-o4/show-me` 를 가리키는 **git submodule** 이다 (`npx skills add pollux-o4/<repo>` 로 배포). 그래서 수정·clone 규칙이 다르다.

- **스킬 수정 시 2단계 push**: ① 서브모듈 폴더 안에서 commit + push (→ 공개 repo 갱신) → ② my_skills 루트에서 `git add <서브모듈>` + commit + push (서브모듈 포인터 갱신)
- **clone/pull 시**: `git clone --recursive` (또는 clone 후 `git submodule update --init`). 안 하면 서브모듈 폴더가 빈 채로 온다.
- 서브모듈 내부 파일을 my_skills 에서 직접 추적·수정하지 말 것 — 각 공개 repo 가 정본.

## 리뷰
- `review/`는 다른 CLI가 이 스킬 저장소를 사용하며 발견한 불편점과 수정 제안을 모으는 저장소 공용 피드백 폴더
- 리뷰는 `review/*.md`에 남기고, 어떤 CLI와 어떤 작업에서 나온 피드백인지 적기

## Git Workflow
현재 워크플로: github-flow
선택일: 2026-07-13, 근거: 1인 개인 스킬 레포, 지속적 소규모 커밋
