# History — my_skills

> 커밋·ADR 에 담기 어려운 경험 기록(companion log)의 거처 — `write-a-rule` "Grounds live in a companion log" 의 실체이며, `AIL-correct-is-silent` 의 history-purposed doc 예외 대상. 규칙·스킬의 근거(grounds)는 여기를 역참조한다.
> 형식: 기록 1건당 아래 인덱스 줄 1개(BLUF) + 상세 `<slug>.md`. 같은 뿌리 사건은 한 파일에 모아 재발 횟수가 보이게 한다.

## 파일명 접두사 — `B-`/`G-`

폐기·오판 등 **하지 말아야 할 사례가 중심**인 기록은 `B-` 접두사, 채택할 만한 **좋은 설계·관행이 중심**인 기록은 `G-` 접두사를 붙인다. 파일을 열지 않고도 인덱스·파일명만으로 valence 를 알 수 있게 하기 위함(vector-graph-ontology 프로젝트의 docs/history 관행을 차용). 결과가 뒤섞여 있으면(폐기안+최종 확정안) 더 비중 있는 쪽으로 정한다.

`light-review-log.md` 처럼 사건 1건이 아니라 **누적 장부(ledger)** 인 문서는 이 접두사 대상이 아니다 — B/G 는 단발 사건 기록에만 붙인다.

각 기록 문서는 그 내용이 규칙·스킬로 승격됐다면 파일 하단에 `## 승격` 절을 두고 승격 대상·날짜·PR을 적는다(역방향 추적 — 규칙 쪽은 이미 `write-a-rule` 의 grounds 역참조로 이 문서를 가리키므로 왕복 링크가 된다).

- [light-review-log](./light-review-log.md) — 약식 스킬 심사(적대 1기) 실적 장부: 5건 적립 + 사후 결함 0 도달 시 규정화 재상정, 현재 3건 — 2026-07-15
- [B-worktree-cleanup-gate](./B-worktree-cleanup-gate.md) — 워크트리 정리 훅: 로컬 머지 판정은 실측 진짜양성 0%(서버 머지·squash), 서버 조회는 정확하나 과구현 — 명령어 인지 + 한 줄 소환으로 확정. 자매 훅이 `python` 만 찾아 무음 고장 중(별건) — 2026-07-15
