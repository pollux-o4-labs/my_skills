@~/.claude/skills/karpathy-guidelines/SKILL.md

# my_skills

Claude Code, Codex, Gemini CLI 공용 커스텀 스킬 레포. 각 스킬 동작은 해당 `SKILL.md` 참조.

## 작업 규칙
- 스킬 수정 전 해당 SKILL.md를 반드시 읽고 시작
- 디렉토리명 = name (kebab-case), 진입점 = SKILL.md
- 보조 문서는 스킬 디렉토리 안에 — 루트 오염 금지
- setup-my-skills → efficient-subagent 의존관계 있음
- CLI 별 등록 경로와 전역 지침 파일 차이를 섞지 말고 대상 host 를 먼저 식별

## 서브모듈 — md-ebook (= md2ebook), show-me

`md-ebook/` 와 `show-me/` 는 일반 폴더가 아니라 각각 공개 repo `pollux-o4/md2ebook`, `pollux-o4/show-me` 를 가리키는 **git submodule** 이다 (`npx skills add pollux-o4/<repo>` 로 배포). 그래서 수정·clone 규칙이 다르다.

- **스킬 수정 시 2단계 push**: ① 서브모듈 폴더 안에서 commit + push (→ 공개 repo 갱신) → ② my_skills 루트에서 `git add <서브모듈>` + commit + push (서브모듈 포인터 갱신)
- **clone/pull 시**: `git clone --recursive` (또는 clone 후 `git submodule update --init`). 안 하면 서브모듈 폴더가 빈 채로 온다.
- 서브모듈 내부 파일을 my_skills 에서 직접 추적·수정하지 말 것 — 각 공개 repo 가 정본.

## 리뷰
- `review/`는 다른 CLI가 이 스킬 저장소를 사용하며 발견한 불편점과 수정 제안을 모으는 저장소 공용 피드백 폴더
- 리뷰는 `review/*.md`에 남기고, 어떤 CLI와 어떤 작업에서 나온 피드백인지 적기
