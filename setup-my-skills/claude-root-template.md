# {PROJECT_NAME} — Claude 작업 가이드

> 이 파일은 **워크스페이스 공통 규칙**만 담는다. 영역별 상세는 하위 `CLAUDE.md`로 분리.
> - {AREA} 작업 → [{area}/CLAUDE.md](./{area}/CLAUDE.md)

---

## 작업 시작 규칙

- **모든 작업 시작 전**: [TODO.md](./TODO.md) 확인. 진행할 항목을 `## In Progress`로 이동 후 착수.
- **작업 완료 시**: TODO.md 항목을 `## Done`으로 이동, 관련 CLAUDE.md 갱신.
- **하위 폴더 작업 시**: 해당 폴더의 CLAUDE.md(있다면)가 우선 규칙.
- **파일 위치 탐색 시**: [docs/meta/spec-locations.md](./docs/meta/spec-locations.md) 먼저 확인.
- **서브 에이전트 프롬프트 작성 시**: [docs/meta/efficiency-feedback.md](./docs/meta/efficiency-feedback.md) 블록 앞에 붙이기.

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

1. **TODO.md·CLAUDE.md 갱신**: 작업 완료 시 TODO 이동, 패턴 변경 시 관련 CLAUDE.md 갱신.
2. **설계 결정**: forward-looking → `docs/adr/`, 결함 트리거 → `docs/capa/`.
3. **dead code 남기지 않기**: 주석 처리 금지, 삭제.
4. **Conventional Commits 강제**: `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:`, `style:`, `perf:`, `build:`, `ci:`, `revert:`.
   **커밋 전 체크**: 이번 작업으로 오래된 CLAUDE.md·TODO.md·docs/ 없는지 확인 후 커밋.
5. **문서 작성 규칙**: [docs/meta/writing-guide.md](./docs/meta/writing-guide.md) 확인. 일회성 보고서 금지.
6. **병렬 서브 에이전트 위임**: 독립 작업이고 완료 기준 명확할 때만. 위임 전 사용자 승인. model="sonnet" 기본.
7. **서브 에이전트 보고 누적 감시 + 영속화**:
   - 매 회 서브 에이전트 보고의 **Out-of-scope spotted** 와 **Late-discovered docs** 항목을 main 컨텍스트에 누적.
   - 3건 이상 또는 같은 영역 2건 이상이면 사용자에게 "정리/보강 제안" 형태로 surface.
   - 사용자 승인 시 `TODO.md` Backlog P2 에 적재 (세션 종료 시 휘발 방지):
     - Out-of-scope → `T-XX cleanup: <영역>` (코드 정리 작업)
     - Late-discovered → `T-XX docs: <인덱스/엔트리 보강 영역>` (가이드 보강 작업)
   - 같은 Late-discovered 가 반복되면 그 자체가 `docs/meta/spec-locations.md` / ADR 제목 컨벤션 / CLAUDE.md entry point 결함의 신호 — 단순 추가가 아닌 *구조 개선* 으로 처리.

---

## Agent skills

> `setup-matt-pocock-skills` 가 추가하는 섹션들(Issue tracker / Triage labels / Domain docs)과 같은 `## Agent skills` 헤딩 아래 공존. 헤딩 두 개 만들지 말 것.

### Sub-agent discipline
서브 에이전트 투입 전 `efficient-subagent` 스킬 로드. 브리핑 블록: [docs/meta/efficiency-feedback.md](./docs/meta/efficiency-feedback.md).

### ADR status lifecycle
`docs/adr/` 안 ADR은 `status:` 필드를 가짐 — 진행 중은 `proposed`, 굳어지면 `accepted`, 뒤집히면 `superseded by 000M`. 한 디렉토리에서 통합 관리, 별도 plans 레이어 없음.

### Key file index
[docs/meta/spec-locations.md](./docs/meta/spec-locations.md) — 코드 탐색 전 먼저 확인.

### Docs rules
[docs/meta/writing-guide.md](./docs/meta/writing-guide.md) — 단일 진실 원천, 일회성 보고서 금지.