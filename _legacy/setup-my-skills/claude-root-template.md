# {PROJECT_NAME} — Claude 작업 가이드

> 이 파일은 **워크스페이스 공통 규칙**만 담는다. 영역별 상세는 하위 `CLAUDE.md`로 분리.
> - {AREA} 작업 → [{area}/CLAUDE.md](./{area}/CLAUDE.md)

---

## 작업 시작 규칙

- **모든 작업 시작 전**: [docs/handoff/README.md](./docs/handoff/README.md) 확인. 진행 중인 topic 있으면 owner·상태 확인 후 착수.
- **작업 완료 시**: 해당 topic 파일 status 갱신(splice, 인덱스 전체 재작성 금지) — 회수(merge) 완료로 표시, 관련 CLAUDE.md 갱신.
- **하위 폴더 작업 시**: 해당 폴더의 CLAUDE.md(있다면)가 우선 규칙.
- **파일 위치 탐색 시**: 해당 폴더의 `README.md` 먼저 확인.
- **서브 에이전트 프롬프트 작성 시**: [docs/rules/efficiency-feedback.md](./docs/rules/efficiency-feedback.md) 블록 앞에 붙이기.

---

## 프로젝트 개요

{PROJECT_OVERVIEW}

---

## 레포 구조

```
{REPO_ROOT}/
├── {AREA}/
└── docs/
```

---

## 기술 스택

| 영역 | 핵심 |
|------|------|
| {AREA} | {STACK} |

---

## 작업 규칙

1. **docs/handoff·CLAUDE.md 갱신**: 작업 완료 시 해당 topic 파일 status 스플라이스, 패턴 변경 시 관련 CLAUDE.md 갱신.
2. **설계 결정**: forward-looking → `docs/adr/`, 결함 트리거 → `docs/capa/`.
3. **dead code 남기지 않기**: 주석 처리 금지, 삭제.
4. **Conventional Commits 강제**: `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:`, `style:`, `perf:`, `build:`, `ci:`, `revert:`.
   **커밋 전 체크**: 이번 작업으로 오래된 CLAUDE.md·docs/handoff·docs/ 없는지 확인 후 커밋.
5. **문서 작성 규칙**: [docs/rules/writing.md](./docs/rules/writing.md) 확인. 일회성 보고서 금지.
6. **병렬 서브 에이전트 위임**: 독립 작업이고 완료 기준 명확할 때만. 위임 전 사용자 승인. model="sonnet" 기본.
7. **서브 에이전트 보고 누적 감시 + 영속화**:
   - 매 회 서브 에이전트 보고의 **Out-of-scope spotted** 와 **Late-discovered docs** 항목을 main 컨텍스트에 누적.
   - 3건 이상 또는 같은 영역 2건 이상이면 사용자에게 "정리/보강 제안" 형태로 surface.
   - 사용자 승인 시 GitHub Issue로 발행(세션 종료 시 휘발 방지) — 라벨은 `setup-matt-pocock-skills` triage 컨벤션 따름:
     - Out-of-scope → `cleanup: <영역>` 이슈 (코드 정리 작업)
     - Late-discovered → `docs: <인덱스/엔트리 보강 영역>` 이슈 (가이드 보강 작업)
   - 아직 진행 중(어느 branch/agent가 잡고 있는지 추적 필요)이면 `docs/handoff/`에 owner 기재.
   - 같은 Late-discovered 가 반복되면 그 자체가 폴더 `README.md` / ADR 제목 컨벤션 / CLAUDE.md entry point 결함의 신호 — 단순 추가가 아닌 *구조 개선* 으로 처리.

---

## Agent skills

> `setup-matt-pocock-skills` 가 추가하는 섹션들(Issue tracker / Triage labels / Domain docs)과 같은 `## Agent skills` 헤딩 아래 공존. 헤딩 두 개 만들지 말 것.

### Sub-agent discipline
서브 에이전트 투입 전 `efficient-subagent` 스킬 로드. 브리핑 블록: [docs/rules/efficiency-feedback.md](./docs/rules/efficiency-feedback.md).

### ADR status lifecycle
`docs/adr/` 안 ADR은 `status:` 필드를 가짐 — 진행 중은 `proposed`, 굳어지면 `accepted`, 뒤집히면 `superseded by 000M`. 한 디렉토리에서 통합 관리, 별도 plans 레이어 없음.

### Handoff ownership
`docs/handoff/`는 `AIL-handoff-topic-index` 컨벤션 — 리스트 인덱스(`docs/handoff/README.md`) 하나가 topic 파일들을 프론트. 각 인덱스 줄에 owner(어느 branch/sub-agent가 잡고 있는지)와 회수(merge) 여부 표기. 갱신 시 해당 줄만 splice, 전체 재작성 금지. 우선순위(P0-P2)는 여기 안 다룸 — issue tracker 몫.

### 폴더 네비게이션
중앙 인덱스 없음 — 각 주요 폴더(루트, `{area}/`, `docs/` 등)가 자기 내용을 설명하는 `README.md`를 가짐. 코드 탐색 전 해당 폴더의 `README.md` 먼저 확인.

### Docs rules
[docs/rules/writing.md](./docs/rules/writing.md) — 단일 진실 원천, 일회성 보고서 금지. 관심사별로 분리 — 규칙이 늘어도 한 파일에 다 담지 않음.