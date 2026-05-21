# Codex Skill Setup Review

- 작성 CLI: Codex
- 작성일: 2026-05-21
- 작업: Claude Code에서 쓰던 `my_skills` 저장소를 Codex CLI 사용자 스킬 경로에 연결

## 불편했던 점

1. 저장소 위치가 문서에서 바로 드러나지 않았다.

   사용자 설명은 `~/.claude/my_skills`를 가리켰지만 실제 Git 저장소는 `~/.agents/my_skills`였고,
   Claude 등록 경로는 `~/.claude/skills`의 링크였다. Codex 연결 전에 실제 소스 저장소와 소비 경로를
   따로 확인해야 했다.

2. README가 Claude Code 등록 절차만 설명한다.

   Codex는 사용자 스킬을 `~/.codex/skills/<skill-name>`에서 읽는다. README에는 Codex 등록 예시나
   어떤 경로를 원본으로 링크해야 하는지 설명이 없어, 설치된 Codex 스킬 디렉터리 구조를 먼저 확인했다.

3. 등록 대상 스킬 목록이 README와 실제 저장소 상태에서 어긋나 보였다.

   README 설치 예시는 `efficient-subagent`, `setup-my-skills`, `call-other-cli`만 다룬다.
   실제 저장소와 Claude 링크에는 `set-short-term`, `cancel-short-term`도 있어 Codex에 전부 연결할지
   예시의 세 개만 연결할지 판단이 필요했다.

4. Windows 링크 방식 선택 기준이 부족하다.

   README는 Windows에서 `SymbolicLink` 예시를 제공하지만 권한 조건도 같이 적혀 있다.
   이번 Codex 연결은 같은 로컬 볼륨의 디렉터리 연결이라 junction으로 처리했는데,
   각 CLI 등록 예시에서 symbolic link와 junction 중 무엇을 권장하는지 기준이 있으면 덜 헤맨다.

5. Git 상태가 등록 판단을 흐렸다.

   이번 확인 시점에는 `call-other-cli/`가 Git status에서 untracked로 보였는데 README에는 정식 스킬처럼
   나열되어 있었다. 로컬 작업 중인 상태일 수 있지만, 설치 대상 판단 시 tracked 상태와 문서 상태가
   다르게 보였다.

## 수정 제안

1. README에 경로 역할을 먼저 명시한다.

   - 원본 저장소: `~/.agents/my_skills`
   - Claude Code 등록 경로: `~/.claude/skills`
   - Codex 등록 경로: `~/.codex/skills`

2. CLI별 등록 예시를 나눈다.

   Claude Code와 Codex가 같은 원본 스킬 디렉터리를 링크하도록 예시를 두고,
   Windows에서는 junction을 허용할지 권장할지 명시한다.

3. 등록 대상 스킬 목록을 한 군데에서 관리한다.

   README 스킬 표가 현재 등록 대상 전체 목록인지, 핵심 스킬 예시인지 구분한다.
   선택 등록 스킬이 있다면 표에 표시한다.

4. 검증 명령을 CLI별로 둔다.

   링크 목록과 `SKILL.md` 접근 확인 명령을 Claude Code와 Codex 경로 각각에 맞춰 적으면
   다른 CLI가 연결 작업을 재현하기 쉽다.
