# B-history-index-line-drift — 실측 근거

2026-07-16. `docs/rules/01-index-line-bluf-discipline.md` 의 grounds.

## 문제: 길이 규범 부재로 인덱스 줄이 본문을 흡수

docs/history·docs/handoff 인덱스 줄을 실측하니 117~284자로 벌어져 있었다. 짧은 쪽(`light-review-log`, 117자)은 사건 + 결론만 담았지만, 긴 쪽(`worktree-cleanup-gate`, 187자)은 본문에 이미 있는 실측 수치("로컬 머지 판정은 실측 진짜양성 0%")와 완전히 별건인 발견("자매 훅이 python 만 찾아 무음 고장 중")까지 인덱스에 중복 적재하고 있었다. docs/handoff 쪽은 더 심해서 202~284자(수치·상태·유보 사유까지 인덱스 줄에 나열)였다.

vector-graph-ontology 프로젝트의 규칙 08 제1조가 겪은 것과 같은 패턴이다 — 길이·내용 범위 규범이 없으니 저자(세션)마다 재량으로 점점 더 많은 상세를 인덱스 줄에 채워 넣었다.

## 대신 할 것

인덱스 줄은 "무슨 사건 + 확정된 결론"만 담고, 실측 수치·폐기안 상세·곁가지 발견은 본문(상세 `<slug>.md`)에 남긴다.

## 승격

- `docs/rules/01-index-line-bluf-discipline.md` (2026-07-16) — 이 실측을 grounds로 규칙화. docs/history 쪽 위반은 이 PR에서 정정(`B-worktree-cleanup-gate` 인덱스 줄 축약), docs/handoff 쪽 기존 3건은 retrofit-on-edit 정책상 후속으로 백로그 등재.
