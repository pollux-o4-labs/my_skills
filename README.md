# my_skills

Claude Code, Codex, Gemini CLI 에서 쓰는 커스텀 CLI 스킬 모음.

## 경로

- 원본 저장소: `~/.agents/my_skills`
- 공통 user skill 경로: `~/.agents/skills`
- Claude Code 등록 경로: `~/.claude/skills`
- Codex user skill 경로: `~/.agents/skills`
- Gemini CLI user skill 경로: `~/.gemini/skills` 또는 `~/.agents/skills`

클론만으로는 스킬이 활성화되지 않는다.
원본 저장소의 각 스킬 디렉토리를 사용할 CLI 의 user skill 경로에 링크하거나 설치해야 한다.

## 설치

### Linux / macOS / WSL

```bash
mkdir -p ~/.agents ~/.agents/skills
git clone https://github.com/pollux-o4/my_skills.git ~/.agents/my_skills

ln -s ~/.agents/my_skills/efficient-subagent ~/.agents/skills/efficient-subagent
ln -s ~/.agents/my_skills/setup-my-skills   ~/.agents/skills/setup-my-skills
ln -s ~/.agents/my_skills/call-other-cli    ~/.agents/skills/call-other-cli
ln -s ~/.agents/my_skills/set-short-term     ~/.agents/skills/set-short-term
ln -s ~/.agents/my_skills/cancel-short-term  ~/.agents/skills/cancel-short-term
```

### Windows PowerShell

```powershell
New-Item -ItemType Junction `
  -Path "$env:USERPROFILE\.agents\skills\efficient-subagent" `
  -Target "$env:USERPROFILE\.agents\my_skills\efficient-subagent"
# setup-my-skills, call-other-cli, set-short-term, cancel-short-term 도 동일
```

## CLI 별 등록

### Claude Code

Claude Code 에서는 사용할 각 스킬을 `~/.claude/skills/` 에도 링크한다.

```bash
mkdir -p ~/.claude/skills
ln -s ~/.agents/my_skills/set-short-term ~/.claude/skills/set-short-term
```

다른 스킬도 같은 방식으로 링크한다. Windows 에서는 같은 target 으로 junction 또는 symbolic link 를 만든다.

### Codex

Codex 는 user skills 를 `~/.agents/skills/` 에서 발견한다.
위 공통 설치 경로를 쓰면 추가 등록 없이 같은 스킬 원본을 쓴다.

이미 `$CODEX_HOME/skills` 연결을 쓰는 환경은 같은 스킬 디렉토리를 그 경로에도 링크할 수 있다.

### Gemini CLI

Gemini CLI 는 `~/.gemini/skills/` 와 `~/.agents/skills/` alias 를 user skill 경로로 본다.
위 공통 설치 경로를 쓰거나 개별 skill 디렉토리에서 `gemini skills link .` 흐름을 쓴다.

## 검증

```bash
ls -l ~/.agents/skills/                        # Codex / Gemini 공통 user skills 확인
cat ~/.agents/skills/set-short-term/SKILL.md  # 공통 진입점 접근 확인
ls -l ~/.claude/skills/                        # Claude Code 링크 확인
```

각 CLI 새 세션에서 skill discovery 와 명시 호출 흐름을 확인한다.
명시 호출은 CLI 별 문법이 다르다.

- Claude Code: `/set-short-term`, `/cancel-short-term`
- Codex: `$set-short-term`, `$cancel-short-term` 또는 `/skills` 에서 mention
- Gemini CLI: `/skills list` 로 로드 여부를 확인하고 skill 이름을 명시 요청한 뒤 activation consent 를 승인

> **WSL 주의**: WSL의 `~`는 `/home/<user>`이지 `/mnt/c/Users/<user>`가 아니다.
> CLI 가 Windows 네이티브로 실행되면 Windows 쪽 user skill 경로에 링크해야 한다.

## 스킬

| 디렉토리 | 명시 호출 예 | 설명 |
|---|---|---|
| efficient-subagent | sub-agent가 자동 로드 | 컨텍스트 흡수 → 스코프 규율 → 간결 보고 |
| setup-my-skills | Claude `/setup-my-skills` | efficient-subagent가 전제하는 레포 scaffold 생성 |
| call-other-cli | Claude `/call-other-cli` | codex/gemini CLI에 작업 위임 후 요약 병합 |
| set-short-term | Claude `/set-short-term`, Codex `$set-short-term` | 실행한 CLI 하나에 짧은 응답 톤 영속 설정 |
| cancel-short-term | Claude `/cancel-short-term`, Codex `$cancel-short-term` | 현재 세션에서 short-term mode 해제 |
| writing-templates | Claude `/writing-templates` (글쓰기 시 자동 트리거) | 12종 글 골격 라우터 + BLUF·불확실성 라벨 규약. `templates/` 에서 1개만 로드 |
| md-ebook | Claude `/md-ebook` (md→책 변환) | `python build.py <md>` 로 오프라인 단일 HTML 책 리더 생성. `reader.html` 템플릿 + 자체 파서 |

`set-short-term` 과 `cancel-short-term` 은 전역 지침 또는 세션 톤을 바꾸므로 자동 활성화를 막는다.
Claude Code 는 skill frontmatter, Codex 는 `agents/openai.yaml` policy 로 manual-only 를 선언한다.
Gemini CLI 는 activation 때마다 consent 를 요구하므로, 사용자가 skill 이름을 명시하고 승인하는 흐름을 따른다.

## 이 레포와 외부 스킬의 관계

```
~/.agents/
├── my_skills/          ← 이 레포 (커스텀 스킬 원본)
├── skills/             ← 공통 user skill 링크 + 외부 설치 스킬
└── .skill-lock.json    ← 외부 스킬 버전 관리
```

이 레포의 스킬은 원본 디렉토리에서 직접 수정하고 각 CLI user skill 경로는 링크로 연결한다.

## 구조 컨벤션

- 스킬 1개 = 디렉토리 1개, 진입점은 `SKILL.md`
- 디렉토리명 = SKILL.md frontmatter `name` (kebab-case)
- 보조 문서는 같은 디렉토리 안에 배치

## 리뷰

`review/`는 Claude Code 외의 CLI가 이 스킬 저장소를 사용해 본 뒤 남기는 피드백 모음이다.
설치, 등록, 문서 해석, 호출 방식에서 불편했던 점과 수정 제안을 Markdown 문서로 기록한다.
