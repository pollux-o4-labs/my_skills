# 자동 트리거 — 제안 A 적용됨 (2026-07-02)

> 상태: **적용**. `~/.claude/settings.json` Stop 훅에 `scripts/skillify-gate.mjs` 등록 완료(기존 사운드 훅과 병존, timeout 15s).
>
> 적용 파라미터(보수적 임계값):
> - `MIN_USER_TURNS` 8 / `MIN_CORRECTIONS` 2 / `MIN_FAILURE_RECOVER` 1 / `SCORE_TO_FIRE` 2 (3개 신호군 중 2개 충족 시 발화)
> - 세션당 1회 발화 — 상태파일 `~/.claude/skillify-gate-state/<session_id>.done`
> - 출력은 비차단 `hookSpecificOutput.additionalContext`(Stop 이벤트 공식 지원) — `decision:block`과 달리 응답을 강제 연장하지 않음
> - `stop_hook_active` 시 침묵, 모든 오류 시 silent exit 0 (훅이 세션을 깨지 않음)
> - 오탐률 보고 임계치 튜닝 예정 — execute-then-revise

## 문제

Hermes 류 자기개선 에이전트는 "복잡 작업 성공 / 실패 후 복구 / 사용자 정정 / 비trivial 워크플로" 시 **자동으로** 스킬 생성이 발동한다. 반면 Claude Code 스킬은 대화 내용이 description과 매칭될 때만 로드된다 — "세션이 끝나간다"는 사건 자체는 매칭 대상이 아니므로, `skillify-session-lessons`의 회고 루프는 현재 사실상 **수동**(사용자가 "스킬화해줘"라고 말해야 발동)이다.

## 훅 후보 비교

| 훅 | 발동 시점 | 적합성 |
|---|---|---|
| `Stop` | Claude가 응답을 마칠 때마다 | 출력(JSON `decision:block`/`additionalContext`)을 Claude에게 되먹일 수 있음 — **유일하게 실행 가능한 지점**. 단 매 턴 발동이라 노이즈 제어 필수 |
| `SessionEnd` | 세션 종료 시 | 시점은 이상적이나 **출력이 Claude에게 전달되지 않음**(세션이 이미 끝남) → 그 자리에서 회고 불가 |
| `SessionStart` | 다음 세션 시작 시 | 직전 세션 transcript를 후처리해 "지난 세션에 스킬화 후보 있음" 컨텍스트 주입 가능 — 차선책 |

## 제안 A — Stop 훅 + 휴리스틱 게이트 (권장)

`Stop` 훅에서 경량 스크립트가 transcript(JSONL)를 훑어 스킬화 신호를 셈:

- 사용자 정정 패턴("아니", "그게 아니라", "다시" 등) N회 이상
- 실패→복구 흔적(오류 후 성공) 존재
- 세션 길이(턴 수) 임계치 초과

임계 충족 && 세션당 1회 미발화 시에만 `additionalContext`로 주입:
"이 세션은 스킬화 후보 조건 충족 — 사용자에게 skillify-session-lessons 실행을 제안하라."

```json
// ~/.claude/settings.json (초안 — 적용 금지, 스크립트는 별도 작성 필요)
{
  "hooks": {
    "Stop": [{
      "hooks": [{
        "type": "command",
        "command": "node C:/Users/orix4/Documents/my_skills/skillify-session-lessons/scripts/skillify-gate.mjs"
      }]
    }]
  }
}
```

- 스크립트는 stdin으로 hook 입력(transcript_path 포함)을 받아, 조건 미달이면 exit 0(무출력), 충족 시 JSON 출력.
- `stop_hook_active` 플래그 확인해 무한 루프 방지.
- 상태 파일(세션 ID별 1회 발화)로 노이즈 억제.

## 제안 B — SessionStart 이월 리마인더 (보완)

`SessionStart` 훅이 직전 세션 transcript를 스캔해 후보가 있으면 "지난 세션 교훈 스킬화 미처리" 컨텍스트를 주입. 세션 경계를 넘겨 루프를 닫는다. A와 병행 가능.

## 제안 C — 무설정 대안 (현행)

훅 없이: 각 세션 Claude가 마무리 국면에서 스스로 트리거 충족을 점검해 제안(SKILL.md "한계(자동성)" 절). 자동성은 없지만 설정 변경 zero.

## 적용 절차 (사용자 승인 후)

1. `scripts/skillify-gate.mjs` 작성(휴리스틱 + 상태 파일)
2. `update-config` 스킬 또는 수동으로 settings.json에 Stop 훅 등록
3. 며칠 사용하며 오탐률 보고 임계치 튜닝 — execute-then-revise는 훅에도 적용된다

## 크로스-CLI 주의

이 훅 설계는 Claude Code 전용. Codex/Gemini CLI는 훅 체계가 상이 — 각 CLI 별도 설계 필요(현재 미조사).
