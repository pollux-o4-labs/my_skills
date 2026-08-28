---
name: perso-organic
disable-model-invocation: true
description: "Builds a dynamic persona organization for unfamiliar domain work by selecting task-specific leaders, SMEs, reviewers, and validation loops instead of using fixed role lists. Use when the user explicitly invokes perso-organic or asks to delegate an unfamiliar, multi-domain task through a temporary expert organization."
---

# perso-organic — 동적 페르소나 조직

모르는 도메인 작업을 그 작업에 맞는 실제 조직으로 쪼개 병렬 위임한다. main agent는 페르소나를 연기하지 않고 총책임으로서 편성, 검증, 사용자 소통만 맡는다.

## Core Rule

편성 골격은 고정 기능이고, 실무자는 매 작업의 도메인에서 새로 유도된다. "리서처/리뷰어/에디터" 같은 제네릭 명단 재탕은 실무 SME가 없는 실패다.

## Entry Gate

1. 목적을 확인한다: 결과물, 소비자, 성공 기준.
2. 리더를 부르기 전 `SERVICE_CONTEXT`를 모은다: 대상, 핵심 컨셉/제약, 작업 목적, 근거 파일 경로.
3. plan gate에서는 확정 SME 명단이 아니라 리더 워크플로 dispatch를 승인받는다.
4. 리더가 `SERVICE_CONTEXT`만 받고 백지에서 `staffingProposal`을 반환한다.
5. 총책임이 제안과 경험칙을 대조한 뒤 조직도를 확정하고, 사용자 재승인을 받은 후 실행한다.

## Four-Step Loop

| # | 단계 | Exit |
|---|---|---|
| 1 | 부서 선정 | 현실의 오너 부서/직능 1~N개 확정 |
| 2 | 인력 배치 | 총책임-리더-실무-리뷰 계층과 티어 확정 |
| 3 | 실행 | 조직형 파이프라인 실행, high-severity 0 또는 max 2라운드 |
| 4 | 메인 검증 | 엄밀성 + 전략 렌즈 환원 리포트 완료 |

Phase가 바뀌면 오너 부서와 실무 SME를 다시 고른다. 프로젝트 전체에 조직 하나를 박제하지 않는다.

## Staffing Rules

- 총책임: main agent. 편성, 검증, 사용자 소통. 페르소나 연기 금지.
- 리더: 오너 부서 리드. 총책임 초안을 먼저 받지 않고 staffingProposal을 만든다.
- 실무: 도메인 SME. 매 작업 새로 고용되는 핵심 계층이며 비우지 않는다.
- 리뷰: 적대QA와 통합/판정 기능을 분리한다.
- 통합자는 SME 2명 이상일 때만 둔다. SME 1명이면 리더/총책임이 판정과 환원을 흡수한다.

## Execution Rules

- 분담은 리더가 자동 확정한다. SME별 영역 쪼개기에 사용자 승인 게이트를 끼우지 않는다.
- 소비자 경험 오너는 QA가 아니라 실무 제작 계층에 둔다.
- 모델 티어는 실수 전파 비용으로 고른다: low=추출, middle=기본 실무, high=판단/최종물 직행.
- `SERVICE_CONTEXT`와 중간 산출물은 파일로 저장하고 에이전트에는 경로만 준다.
- 주입 대상은 리더/실무/통합/갭분석이고, 팩트체커와 논리QA에는 주지 않는다.
- execute는 리더 협상 결과를 `args.smeConfig` 같은 config로 받아야 하며 scope/SME/QA를 하드코딩하지 않는다.

## Verification

- 고정 검증자: 팩트체커(ctx 없음, 수치/출처), 논리QA(ctx 없음, baseline).
- 도메인 적대 렌즈는 리더 협상으로 고르고 동시 최대 2개까지만 둔다.
- 모든 산출에는 왜 이렇게 했는지, 근거, 불확실 지점을 담은 환원 리포트를 붙인다.
- 전략 렌즈 질문: 핵심 베팅이 가장 약한 추정 위에 있는가, 결론을 반대하거나 책임질 직무가 빠졌는가.

## Anti-Patterns

페르소나 직접연기, 명단 박제, 실무 SME 공석, Phase 변경 후 리더 재사용, 통과형 QA, 모델 티어 고정, 분담표 없는 병렬 발사, execute 하드코딩, 리더 앵커링, 리더 없이 총책임이 SME 명단 확정, 환원 리포트 생략.

## References

- `reference/playbook.md`: 단계별 실행 디테일, 리더 협상, 티어, 검증 흐름.
- `reference/workflow-skeleton.md`: 실행 골격, resume, schema, 강등 substrate.
- `reference/lessons.md`: 누적 실측 교훈과 디버깅 참고.
