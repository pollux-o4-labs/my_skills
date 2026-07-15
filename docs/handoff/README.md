# Handoff — my_skills

> 컨벤션: `AIL-handoff-topic-index`. topic 1개당 인덱스 줄 1개 — 목록에 없으면 잊힌 것.
> 한 줄로 충분한 topic 은 줄만 유지, 상세가 쌓이면 `docs/handoff/<slug>.md` 생성 후 링크.
> 형식: `- <slug> — <한줄 설명(BLUF)> — owner/상태 — <갱신일>`
> 우선순위(P0-P2)는 여기서 안 다룸 — issue tracker 몫.

---

## Topics

- retrofit-backlog — 저작 상한 초과 잔여분(supervisor-mode desc 596c·AIL-design-for-extension desc 403c·setup-my-skills 759w·efficient-subagent 851w) — retrofit-on-edit 정책상 해당 스킬 수정 시점에 처리, 별도 착수 불요 — 2026-07-13
- [matt-checklist-adoption](./matt-checklist-adoption.md) — Matt Pocock 4단계 체크리스트 저작 표준 반영(PR #1·#2 머지, 정본 authoring-standards.md) + 4축 전부 skill-review 파이프라인 검사 내장 — 유보 2종 중 trigger evals 는 실발생 1건 적립(2026-07-13 correct-is-silent 미발동), 재발 시 착수 — 2026-07-13
- skill-review-pipeline — 스킬 PR 전자동 심사 워크플로 v3.3(.claude/workflows/skill-review.js + skill-{prober,replayer,adversary,fixer} 에이전트): 프로브(삭제 테스트)→파생가능성 프로브→replay·적대→중재(NOISE 기각)→fix⇄verify 루프→조건 재심→Land(쉬운말 코멘트), 머지만 사람 게이트. 사용법 정본은 authoring-standards — 가동 상태(#10·#11 실적) — 2026-07-13
- git-workflow-gate-python-silent-fail — `git-workflow-select` 훅이 python3-only 환경에서 무음 통과함을 실측 확인(근거: `docs/history/B-worktree-cleanup-gate.md`) — 미수정, 별도 착수 필요 — 2026-07-16
- docs-handoff-index-bluf-retrofit — 이 파일의 기존 인덱스 줄 3건(202~284자)이 `docs/rules/01-index-line-bluf-discipline.md` 위반 — retrofit-on-edit 정책상 각 줄이 다음에 갱신될 때 정리, 별도 착수 불요 — 2026-07-16
