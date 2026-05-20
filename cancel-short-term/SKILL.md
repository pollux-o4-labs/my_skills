---
name: cancel-short-term
description: 현 세션 한정 으로 short-term mode (짧은 응답 룰) 해제. CLAUDE.md 는 건드리지 않음 — 다음 세션 시작 시 자동 복귀. 사용자가 `/cancel-short-term` 으로 명시 invoke 시에만 동작.
disable-model-invocation: true
---

# cancel-short-term

현 세션 한정 으로 short-term mode (카톡 톤, 3 섹션 제한 등 — `~/.agents/my_skills/set-short-term/rule.md` 룰) 를 해제한다.

## 동작

1. **CLAUDE.md 는 건드리지 않는다.** 파일 read/write 없음. I/O 0회.
2. **현 세션 컨텍스트에만 flag.** 다음 응답부터 short-term mode 룰 (3 섹션 제한, 정보 폭탄 금지, "더 보려면" 안내 등) **을 따르지 않는다**. 평소 응답 스타일로 복귀.
3. 사용자에게 "이번 세션 해제됨. 다음 세션엔 다시 자동 적용." 1줄 보고.

## 주의

- **다음 세션은 자동 복귀.** `~/.claude/CLAUDE.md` 의 marker + import 가 그대로 유지되므로 새 세션 시작 시 룰 다시 자동 로드.
- **영구 해제 원할 시** — 사용자가 `~/.claude/CLAUDE.md` 의 `<!-- BEGIN: short-term-tone -->` ~ `<!-- END: short-term-tone -->` 블록 직접 삭제. (이 스킬 범위 밖.)
- **자연어 동등** — 사용자가 "길게 답해" / "verbose" / "전부 보여줘" / "다 풀어" / "full" 등 명시 요청해도 같은 효과 (rule.md 의 "해제 방법" 절에 명시).
