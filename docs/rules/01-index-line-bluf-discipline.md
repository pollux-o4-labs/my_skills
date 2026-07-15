# 규칙 01 — 인덱스 줄(BLUF) 작성 규범

> **BLUF:** docs/history·docs/handoff 등 목록형 인덱스 줄의 길이·내용 범위에 관한 사항.

## 규칙

### 제1조 (사건 + 결론만)

목록형 인덱스 줄(BLUF)은 그 항목이 **무슨 사건이고 결론이 무엇인지**만 담아야 한다. 실측 수치·폐기안 상세·근본 원인 분석·별건 발견 등 상세는 상세 문서(`<slug>.md`) 본문에 두어야 하며 인덱스 줄에 실어서는 아니 된다.

### 제2조 (링크 준용)

여러 문서가 같은 항목을 요약해야 할 때는 원문을 재서술하지 말고 상세 문서를 링크로 준용해야 한다.

## 강제 수단 (정직 표기)

기계 게이트 없음 — 현재는 문서 작성 시점의 리뷰어 판정에 의존한다.

## 메타

- 상태: Accepted · 2026-07-16
- 근거: [docs/history/B-history-index-line-drift.md](../history/B-history-index-line-drift.md)

## 관련

- `write-a-rule` — 이 규칙 자체의 저작 표준(조문·메타·grounds 형식).
- [docs/history/README.md](../history/README.md) — 이 규칙을 적용받는 인덱스 컨벤션의 정본 문서.
- docs/handoff/README.md 기존 3줄은 이 규칙 위반 상태 — retrofit-on-edit 정책상 개별 수정 시점에 정리(핸드오프 백로그에 등재).
