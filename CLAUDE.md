@~/.claude/CLAUDE.md

# my_skills

Claude Code, Codex, Gemini CLI 공용 커스텀 스킬 레포. 각 스킬 동작은 해당 `SKILL.md` 참조.

## 작업 규칙
- **세션 시작 시 [docs/handoff/README.md](./docs/handoff/README.md) 확인** — 진행 중·기계 간·유보 상태의 단일 진실원(WIP 스킬 소재 등). 상태 변화 시 해당 줄만 splice.
- 스킬 수정 전 해당 SKILL.md를 반드시 읽고 시작
- 디렉토리명 = name (kebab-case), 진입점 = SKILL.md
- **provenance 접두사**: AI가 세션 교훈에서 스스로 생성·승격한 스킬은 `AIL-` 접두사(AI-Learned, 예: `AIL-verify-against-reality`). 사용자가 의도적으로 넣은 스킬과 구분 — 나중에 리팩터·정리·신뢰도 판단 시 식별용. 새 교훈 스킬화 시 이 접두사를 붙인다.
- **스킬 규격**: 템플릿은 [templates/domain-principles-template/SKILL.md](./templates/domain-principles-template/SKILL.md)이다. 본문은 도메인 원칙과 `Scope`로 구성한다.
- 보조 문서는 스킬 디렉토리 안에 — 루트 오염 금지
- **경험 기록(companion log)은 [docs/history/README.md](./docs/history/README.md)** — 커밋·ADR 에 담기 어려운 근거·실적의 거처(BLUF 인덱스 + 상세 .md). 규칙·스킬의 grounds 는 여기를 역참조.
- **레포 자체 운영 규칙은 [docs/rules/README.md](./docs/rules/README.md)** — `documentation-principles`를 적용한 my_skills 전용 규칙(문서 저작·인덱스 형식 등), 근거는 docs/history에서 관리한다.
- **미완성 스킬은 origin에 올리지 않는다** — 로컬 untracked/.gitignore로 유지하고 완성·리뷰 후 커밋. untracked 스킬을 "커밋 누락"으로 단정해 대신 커밋하지 말 것(2026-07-12 AIL-prefer-incremental-over-full 오커밋 사건이 근거).
- 기존 스킬은 `_legacy/`에 보존하고, 현재 정본은 도메인별 원칙 스킬로 관리한다.
- CLI 별 등록 경로와 전역 지침 파일 차이를 섞지 말고 대상 host 를 먼저 식별

## 스킬 등록 경로 (host별 — repo → 개인 허브 → 각 CLI)

| Host | 경로 | 방식 | 주의 |
|---|---|---|---|
| 개인 허브 | `~/.agents/custom-skills/<name>` | 이 repo로 **정션** | manifest/AIL 정책의 단일 적용 지점 |
| Claude Code | `~/.claude/skills/<name>` | 개인 허브로 **정션** | 즉시 반영 |
| Codex | `~/.codex/skills/<name>` | 개인 허브로 **정션** | 로컬 sync 로 반영. `~/.agents/my_skills` clone 은 legacy 소스(정리 대상) |
| agy (Antigravity) | `~/.gemini/config/skills/<name>` | 개인 허브에서 **복사본** | 최신 공식 전역 탐색 경로. `~/.gemini/skills`는 레거시로 기본 보존, `~/.gemini/antigravity-cli`는 내부 상태라 건드리지 않음 |

새 스킬 등록 시 세 host 모두 처리하고, repo에서 스킬 삭제 시 각 host의 정션·복사본도 제거(dangling 정션 방지).

세 host 등록·재동기화는 통합 스크립트로 일괄 처리한다. 서브모듈 기반 스킬(md-ebook·show-me)은 이 스크립트가 건드리지 않는다.
- **Windows**: `sync-skills/sync-skills.ps1` (구 `~/.gemini/antigravity-cli/sync-skills.ps1` 대체). `-Host claude|codex|gemini`, `-Only <스킬명>`, `-WhatIf`(드라이런), Gemini prune 은 `-PruneMirror` 명시 시.
- **Linux/macOS**: `sync-skills/sync-skills.sh` (동일 의미). `--host`, `--only a,b`, `--all-skills`, `--dry-run`, `--prune-mirror`. host 는 심볼릭 링크(claude·codex)·복사(gemini)로 등록하며, **해당 host 의 skills 디렉토리가 이미 있을 때만** 갱신한다(미설치 host 는 새로 만들지 않음).

**로컬 비활성화**: `sync-skills/desync-skills.sh --all` 또는 `desync-skills.ps1 -All`은 저장소 소유 개인 허브·Claude·Codex 링크를 제거하고, 머신별 제외 목록(`~/.config/my_skills/disabled-skills.txt` 또는 Windows `%APPDATA%\my_skills\disabled-skills.txt`)에 기록한다. 이후 sync/pull에서도 해당 스킬은 다시 연결하지 않는다. 특정 스킬은 `--only <name>`/`-Only <name>`을 사용하고, 재활성화는 해당 목록에서 줄을 지운 뒤 sync한다. agy 공식 경로의 물리 복사본은 기본 보존하며, 명시적으로 `--remove-gemini`/`-RemoveGemini`를 지정한 경우에만 제거한다. 레거시 `~/.gemini/skills` 복사본은 `--remove-legacy-gemini`/`-RemoveLegacyGemini`를 별도로 지정해야 하며, `~/.gemini/antigravity-cli`는 절대 건드리지 않는다.

**커스텀 정책 — 선언적 매니페스트 + AIL 자동**: 개인 허브가 링크하는 집합 = **루트의 `AIL-*` 스킬** ∪ **`sync-skills/custom-skills.txt` 매니페스트에 적힌 비-AIL 스킬**. `_legacy/`와 `templates/`는 정본 스킬 탐색에서 제외한다. 현재 정본 스킬은 매니페스트에서 제외해 비등록 상태로 둔다. 등록할 스킬은 매니페스트에 한 줄 추가하거나 `--only`/`-Only`로 지정한다.

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
