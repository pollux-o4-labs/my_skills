# my_skills

Claude Code 커스텀 스킬 모음.

## 설치

클론만으로는 스킬이 활성화되지 않는다.
`~/.claude/skills/`에 각 스킬 디렉토리를 심링크해야 Claude Code가 인식한다.

### Linux / macOS / WSL

```bash
mkdir -p ~/.agents ~/.claude/skills
git clone https://github.com/pollux-o4/my_skills.git ~/.agents/my_skills

ln -s ~/.agents/my_skills/efficient-subagent ~/.claude/skills/efficient-subagent
ln -s ~/.agents/my_skills/setup-my-skills   ~/.claude/skills/setup-my-skills
ln -s ~/.agents/my_skills/call-other-cli    ~/.claude/skills/call-other-cli
```

### Windows (PowerShell, 개발자 모드 또는 관리자)

```powershell
New-Item -ItemType SymbolicLink `
  -Path "$env:USERPROFILE\.claude\skills\efficient-subagent" `
  -Target "$env:USERPROFILE\.agents\my_skills\efficient-subagent"
# setup-my-skills, call-other-cli도 동일
```

### 검증

```bash
ls -l ~/.claude/skills/          # 심링크 목록 확인
cat ~/.claude/skills/efficient-subagent/SKILL.md  # 진입점 접근 확인
```

Claude Code 새 세션을 열어 `/setup-my-skills` 등이 인식되는지 확인.

> **WSL 주의**: WSL의 `~`는 `/home/<user>`이지 `/mnt/c/Users/<user>`가 아니다.
> Claude Code가 Windows 네이티브로 실행되면 Windows 쪽 `~/.claude/skills/`에 심링크해야 한다.

## 스킬

| 디렉토리 | 호출 | 설명 |
|---|---|---|
| efficient-subagent | sub-agent가 자동 로드 | 컨텍스트 흡수 → 스코프 규율 → 간결 보고 |
| setup-my-skills | `/setup-my-skills` | efficient-subagent가 전제하는 레포 scaffold 생성 |
| call-other-cli | `/call-other-cli` | codex/gemini CLI에 작업 위임 후 요약 병합 |

## 이 레포와 외부 스킬의 관계

```
~/.agents/
├── my_skills/          ← 이 레포 (커스텀, 심링크로 수동 등록)
├── skills/             ← 외부 설치 스킬 (mattpocock 등)
└── .skill-lock.json    ← 외부 스킬 버전 관리 (자동)
```

외부 스킬은 `.skill-lock.json`이 관리하며 Claude Code가 자동 처리한다.
이 레포의 스킬은 심링크를 직접 만들어야 한다.

## 구조 컨벤션

- 스킬 1개 = 디렉토리 1개, 진입점은 `SKILL.md`
- 디렉토리명 = SKILL.md frontmatter `name` (kebab-case)
- 보조 문서는 같은 디렉토리 안에 배치

## 리뷰

`review/`는 Claude Code 외의 CLI가 이 스킬 저장소를 사용해 본 뒤 남기는 피드백 모음이다.
설치, 등록, 문서 해석, 호출 방식에서 불편했던 점과 수정 제안을 Markdown 문서로 기록한다.
