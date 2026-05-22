# Review: PR 검증 루프 패턴 — root 공유 vs worktree isolation

> 작성 배경: 2026-05-22, build/torch-cuda-index 세션에서 발견.
> PR #198~#202 전부 worktree 안에서 만들어져 사장이 매번 `gh pr checkout` 필요 → 손 부담.
> 사장 결론 + 트레이드오프 기반 정리. 본 파일은 SKILL.md 반영 전 review draft.

---

## 문제

`isolation: "worktree"` 를 기본값처럼 박으면:

- sub-agent 가 별도 worktree 에서 branch 를 체크아웃 → 사장 root 에서 같은 branch 못 잡음
- `gh pr checkout <N>` 을 사장이 직접 실행해야 검증 가능
- 봇 띄운 채로 PR 검증하려면 root 에 두 번 branch switch 발생 → 봇 재기동 필요

---

## 권장 기준: `isolation: "worktree"` 사용 vs 미사용

middle-merge **직속** layer (integration/*, mixed/*, 단독 fix/*) 는 root 공유가 기본.
**sub-branch** (feat/<topic>, fix/<sub> 등 그 아래) 는 isolation: "worktree" 기본.

| 상황 | isolation | 이유 |
|---|---|---|
| middle-merge 직속 branch (integration/*, mixed/*, fix/*) | **X** | supervisor cwd switch 로 즉시 검증 가능 |
| sub-branch (feat/<topic>, fix/<sub> — 시행착오 구간) | **O** | 물리 파일 충돌 방지, 병렬 작업 허용 |
| 동시 multi-branch 작업 (진짜 파일 충돌 위험) | O | 파일 충돌 방지 |
| 대량 삭제·rename 포함 작업 | O | rollback 쉬움 |

**기본값: isolation 미사용 (직속 layer).** sub-branch 와 병렬 작업만 명시.

---

## 검증 책임 분배 트리거 룰

| 상황 | 검증 주체 |
|---|---|
| pytest / mock 으로 충분히 잡히는 영역 (순수 로직, 내부 helper, type fix, import, mock-able 통합) | **AI end-to-end** — sub-agent 자체 test + supervisor 회귀 확인. 사장 통보만 |
| 운영 UI / 외부 시스템 의존 / hardware / UX 시나리오 | **supervisor 직접 검증** — cwd 이동 + PR 실측 |

**supervisor 가 직접 검증해야 하는 사례**:
- UI embed/mention/슬래시 흐름 (시각 노출 변경)
- GPU·메모리 등 hardware 연동
- 알람 흐름, 외부 API 연동 시나리오
- 새 모델 통합 등 mock 으로 커버 불가한 외부 의존

**AI end-to-end 로 충분한 사례**:
- 순수 로직 함수, 내부 helper, import 정리
- type fix, lint fix
- mock-able 통합 (DB layer, 내부 API wrapper)

---

## root 공유 패턴 (기본 권장)

```
1. Claude: git switch -c <branch>  (worktree add X)
2. Claude: 코드 변경 + commit + push
3. Claude: gh pr create
4. 사장: root cwd 그대로 — 파일 이미 반영됨, 즉시 검증
5. 사장: mise run butler-run  (봇 재기동 필요하면)
```

사장 손: **gh pr checkout 불필요**.

---

## branch switch 시 사장 체크리스트

Claude 가 `git switch -c` 또는 `git switch` 할 때 사장에게 한 줄 알림:

```
branch switch → <이름>. 봇 떠 있으면 재기동 필요. unsaved 변경 있으면 먼저 stash.
```

체크 항목:
- [ ] 봇 (`mise run butler-run` / `mise run q-bot-run`) 실행 중?
- [ ] root 에 uncommitted 변경 있음?
- [ ] 다른 터미널에서 같은 branch 잡고 있음?

---

## PR body Test plan — root 공유 시나리오 1차 옵션으로 변경

기존 CLAUDE.md 규칙 (작업 규칙 12번) 의 worktree 명령을 대체 옵션으로 내리고, root 공유를 1차로:

```bash
# 옵션 1 (권장): root 공유 — branch 이미 root 에 반영됨
mise run butler-run   # 봇 재기동만 하면 됨

# 옵션 2: 별도 worktree 격리 (진짜 충돌 위험 작업만)
git worktree add ../test-pr-{N} {branch}
cd ../test-pr-{N}
uv sync
cmd /c mklink /J .env.test ..\discord_chatbot\.env.test
mise run butler-run
```

---

## SKILL.md 반영 제안 (사장 검토 후 결정)

SKILL.md 의 `## Model selection` 섹션 아래에 `## Worktree isolation 기준` 섹션 추가:

```markdown
## Worktree isolation 기준 (supervisor 전용)

`isolation: "worktree"` 는 **기본값이 아님**. 아래 조건 중 하나 이상 해당할 때만 명시:

- 동시 multi-branch 작업 (물리 파일 충돌 위험)
- 대량 삭제·rename — rollback 필요
- 사장이 봇 실행 중이 아니고 격리 우선 선택

기본 패턴: `git switch -c <branch>` 후 root 에서 작업.
branch switch 시 사장에게 한 줄 알림 (`봇 떠있으면 재기동 필요`).
```

---

## CLAUDE.md 작업 규칙 12번 반영 제안

Test plan 박는 명령 순서:
- 현재: worktree 명령이 1차 옵션
- 변경: root 공유(`mise run butler-run`) 가 1차, worktree 가 옵션 2

---

_이 파일은 review draft — 사장 검토 후 SKILL.md 및 CLAUDE.md 에 반영 여부 결정._
