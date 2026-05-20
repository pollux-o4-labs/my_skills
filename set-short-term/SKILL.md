---
name: set-short-term
description: 사용자 응답 톤을 short-term mode (카톡 대화 톤, 짧은 응답) 로 영속 설정. ~/.claude/CLAUDE.md 에 marker + rule.md import 한 줄을 idempotent 하게 삽입. 모든 repo 자동 적용. 다음 세션부터 효과. 사용자가 `/set-short-term` 으로 명시 invoke 시에만 동작.
disable-model-invocation: true
---

# set-short-term

사용자 요청 시 응답 톤을 short-term mode (카톡 대화 톤, 짧은 응답) 로 영속화한다.

## 동작

1. **Read** `~/.claude/CLAUDE.md` (없으면 빈 문자열로 처리).
2. **Find** 다음 marker 쌍 (대소문자·공백 정확히):
   - 시작: `<!-- BEGIN: short-term-tone -->`
   - 끝: `<!-- END: short-term-tone -->`
3. **분기**:
   - **둘 다 발견** — 그 사이 (marker 포함 전체) 영역을 아래 "삽입 블록" 으로 교체. 이미 동일 내용이면 skip + 사용자에게 "이미 설정됨" 1줄 보고.
   - **둘 다 미발견** — 파일 끝에 빈 줄 + "삽입 블록" append.
   - **한쪽만 발견 (마커 파손)** — 사용자에게 경고 + 수동 확인 요청. 자동 수정 X.
4. **Write back** — UTF-8 (no BOM), LF 줄끝. marker 영역 외 어떤 바이트도 변경 X.
5. 사용자에게 "룰 적재됨. 다음 세션부터 자동 적용. 첫 세션 시 Claude Code 가 외부 import approval 한 번 물어볼 수 있음." 1줄 보고.

## 삽입 블록 (이 텍스트 정확히)

```
<!-- BEGIN: short-term-tone -->
@~/.agents/my_skills/set-short-term/rule.md
<!-- END: short-term-tone -->
```

## 주의

- **CLAUDE.md 의 marker 영역 외는 절대 건드리지 않는다.** 다른 글로벌 룰·메모리·import 가 있어도 보존.
- **CLAUDE.md 가 없으면 신규 생성 OK.** UTF-8 no BOM, LF.
- **반복 invoke 안전 (idempotent)** — 이미 적재된 상태면 no-op + 사용자에게 알림.
- **해제는 `/cancel-short-term`** (별도 스킬). 이 스킬은 ON 전용.
- **rule.md 본문 수정 금지** — 이 스킬은 import 한 줄만 책임. 룰 본문 수정은 `~/.agents/my_skills/set-short-term/rule.md` 직접 편집 + git commit.
