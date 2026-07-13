# matt-checklist-adoption — Matt Pocock 스킬 체크리스트 도입

BLUF: 트리거·구조·유도·가지치기 4단계 체크리스트를 repo 저작 표준에 반영 완료(PR #1·#2, 2026-07-13). 정본은 `skillify-session-lessons/authoring-standards.md`, 근거는 `skill-refactor/RATIONALE.md` §6(논거 요지·채택/유보 매핑·출처 youtu.be/YLq04CDeOTE — 여기까지가 repo 내 정본). Obsidian 정리본([정리] 좋은 에이전트 스킬 작성법)은 사장 개인 vault 보조 자료로 이 머신 외에선 접근 불가.

## 반영 완료

- `skill-refactor` v1.2.1 — 절단 패턴 2종 추가: 무동작 지시문 삭제 테스트("지워도 행동이 안 변하면 무효"), 장문 설명→기학습 강한 용어 치환(reasoning trace 재출현으로 검증).
- `skillify-session-lessons/authoring-standards.md` 신설 — 분량 상한·트리거 유형 결정·AIL frontmatter·언어 정책의 정본. 스킬 폴더 동승으로 전 host(claude 정션·codex 재정션·gemini 복사) 전파. CLAUDE.md 는 포인터 1줄.
- 상한 소급 4건 — setup-my-skills(1,116→759w)·AIL-verify-against-reality v1.3.0(840→622w)·AIL-pilot-before-scale v0.2.0(740→578w)·efficient-subagent(912→851w). opus 적대 리뷰 2인×2회 통과, 유실 조항 0.

## 잔여 (in-flight)

- **stage-splitting** — 에이전트가 특정 단계를 대충 넘기는 증상 실발생 시, 그 단계를 별도 스킬로 쪼개 다음 목표를 가리는 기법 적용.
- **trigger evals** — model 호출 스킬이 제때 발동 안 한다는 불만 실발생 시, 호출 신뢰도 평가 도입.
- 상한 초과 잔여 스킬은 [retrofit-backlog](./README.md) 줄 참조 — 각 스킬 수정 시점에 처리.
