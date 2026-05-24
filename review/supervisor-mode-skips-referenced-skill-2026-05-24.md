# Supervisor mode 가 reference 한 efficient-subagent 본체를 안 읽음

- 작성 CLI: Claude Code (main supervisor)
- 작성일: 2026-05-24
- 작업: oneul-nutri 메타레포에 nutri-skills 자동 셋업 (mise.toml + 심링크) — `/supervisor-mode` invoke 후 4건의 sub-agent (Explore 1 + general-purpose 3) 발사. 사용자가 "별도 호출 agent들은 sonnet 모델 맞지?" 지적 → 전부 parent (opus) 상속된 것이 드러남.

## 불편했던 점

1. **`supervisor-mode` SKILL body 가 efficient-subagent 본체 로드를 강제하지 않는다.**

   `supervisor-mode/SKILL.md` 의 "Subagent delegation rules" 절에 "`/efficient-subagent` conventions enforced" 라고만 적혀있음. supervisor 입장에서 이 문구는 "subagent 가 알아서 따른다" 로 읽힘 → 본체를 안 펼침. 그런데 `efficient-subagent/SKILL.md` 안에는 **"supervisor 전용" 라벨이 붙은 섹션이 5개** 있음:
   - Model selection (sub-agent 호출 시 model 인자 강제)
   - Worktree isolation 기준
   - 검증 책임 분배 (4 layer 검증 chain)
   - Middle-merge 통합 검증 패턴 (branch 구조, 머지 옵션, issue → branch 자동 세팅)
   - Issue → Branch 자동 세팅 룰

   이 룰들은 *supervisor* 가 알아야 적용 가능. subagent 가 자기 prompt 에 "skill load" 해도 supervisor 행위는 안 바뀜.

2. **sub-agent 발사 시 `model` 미지정 = parent 상속 = 무비용 안전망 없음.**

   Opus 메인 세션 (claude-opus-4-7) 에서 `model` 안 박으면 Explore·일반 조사·문서 작성까지 전부 opus. 이번 세션 4건 다 opus 상속. CLAUDE.md 루트 규칙 ("model='sonnet' 기본") 도 위반인데 — supervisor 가 그 룰을 모르고 시작했으니 자가 검열 불가.

3. **사용자가 지적해야만 발견됨.**

   `gh pr merge` 옵션 미명시 사례 (`--squash` 누락) 와 동형 — supervisor 가 룰 본문을 안 읽으면 기본값 함정에 빠짐. 사용자 직접 지적 → "skill 에 안 써있었음?" 재질문 → 그제서야 본문 확인. peer review layer 없음.

## 수정 제안

1. **`supervisor-mode/SKILL.md` 활성화 시퀀스에 명시적 load 단계 추가.**

   기존 "Activation sequence" 1번 (EnterPlanMode) 앞에 **0번** 추가:
   ```
   0. Load `efficient-subagent` skill body in full and read every section labeled "supervisor 전용". These rules govern YOUR behavior (delegation, branching, model selection, verification chain) — not the subagent's.
   ```
   "enforced" 같은 추상어 대신 "load + read supervisor 전용 sections" 동사로 강제.

2. **`efficient-subagent/SKILL.md` 최상단에 supervisor 안내 박스 추가.**

   현재 첫 문장이 "You were spawned by a supervisor agent..." — sub-agent 시점 가정. supervisor 시점 독자가 윗부분만 보고 "본체는 subagent 용이구나" 닫고 가는 게 이번 사고 원인. 최상단에 한 박스:
   ```
   > **If you are the SUPERVISOR (not a spawned subagent):**
   > 이 문서 안 "supervisor 전용" 섹션 5개는 너의 행동을 규율한다 — skip 금지. 목록: ① Model selection ② Worktree isolation ③ 검증 책임 분배 ④ Middle-merge 통합 검증 패턴 ⑤ Issue → Branch 자동 세팅
   ```

3. **`supervisor-mode` 안 "Subagent delegation rules" 절에 model 디폴트 한 줄 inline.**

   "Assign model by task complexity (haiku → lookup, sonnet → default, opus → complex design)" 줄이 이미 있음 — 좋음. 그 옆에 **"⚠ 미지정 시 parent 상속. 절대 생략 금지."** 강조 추가. 현재는 단순 가이드라 누락 시 자동 fallback 처럼 보임.

4. **(선택) hook 으로 model 미지정 Agent 호출 차단.**

   Claude Code 의 PreToolUse hook 에서 Agent 호출 시 model 파라미터 검증 → 미지정이면 reject + "supervisor-mode 활성 상태에선 model 필수" 메시지. settings.json 글로벌 hook 으로 한 번만 박으면 모든 supervisor 세션에서 안전망 동작. 룰 변경 없이 기계적 강제.

## 관련

- supervisor-mode/SKILL.md 의 "Activation sequence" — 본 사고 trigger
- efficient-subagent/SKILL.md 의 "Model selection (supervisor 전용)" — 위반된 룰
- oneul-nutri CLAUDE.md "병렬 서브 에이전트 위임" 규칙 — 동일 정신, 같이 위반
