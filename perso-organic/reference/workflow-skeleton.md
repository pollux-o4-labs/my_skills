# perso-organic — 실행 골격 (SKILL.md §3단계 참조)

> 실행 *모델*은 substrate 중립이다. 구현은 호스트에 따라 둘 중 하나(A=오케스트레이터 있음 / B=강등). 둘 다 1급 경로.

## 핵심 — 불변부 상수 1개 + 가변부 config 배열 + 루프 1개

즉석 N회 호출(불변부 ~90% 복붙) 대신 **config 루프 1회**. 불변부 = 격리·라벨 규약·역할 정체성, 가변부 = 단계 목표·게이트·입력파일·편성 직무·모델 티어.

## 구현 A — 호스트가 Workflow 류 오케스트레이터를 제공할 때

API 계약(이 호스트에서 실측 동작):
- `pipeline(items, stage1, stage2, …)` — 각 item 을 모든 stage 에 통과시킨다. **스테이지 간 barrier 없음**(item A 가 stage3 일 때 item B 는 stage1 가능). 각 stage 콜백 인자 = `(이전결과, 원본item, index)`.
- `parallel(thunks)` — barrier 동시 실행, 실패 thunk 는 `null`(→ `.filter(Boolean)`).
- `agent(prompt, {schema, label, model, phase})` — `model` 은 `'opus'|'sonnet'|'haiku'` = high|middle|low. schema 주면 구조화 출력 강제·검증.

```js
// (이 파일 전체 = scriptPath 의 스크립트 = resume 단위)
const SHARED = `격리: <작업폴더> 내부만 + 인용 웹검증. 라벨:[사실](독립2출처)/[추정]. 개조식·간결.`;
// 리더 협상 schema — 리더가 총책임에 반환(파일 저장과 별개). 총책임 보완 후 execute args 로 흐름. (SKILL.md §2 리더 협상 루프)
const STAFFING = {/* {scopeItems:[], smeConfig:[{id,role,domains}], qaConfig:[{id,lens}], riskFlags:[] } */};
const PROPOSAL = {/* 실무 schema: {summary, claims[], outFile} */};
const FINAL    = {/* 통합 schema: {verdict, findings:[{severity:'blocker|advisory', type:'content|direction', issue, suggestion}], reportFile} */};
//   ↑ 총책임 라우팅(QA 자체엔 분기 없음 — 총책임이 판단): content→SME 재가동(워크플로 내) / direction→실무 워크플로 재트리거(총책임만)

// 가변부 — 단계 수만큼. staff 는 도메인마다 새로(박제 금지, args.smeConfig 에서 옴).
// create = 창작/품질천장 실무(카피·디자인 방향 등) — SKILL.md §2 '예외 상향' 조건. true 면 실무도 opus 로 올린다.
const STAGES = [/* {id, goal, gate, inputs, outPath, staff, create} */];

await pipeline(STAGES,
  // 실무(제작): 도메인 SME. 모델 = create(창작/품질천장)면 high, 아니면 middle
  S => agent(`${roleSME(S.staff)}\n${SHARED}\n목표:${S.goal}\n입력:${S.inputs}\n산출:${S.outPath}`,
        { schema: PROPOSAL, label:`${S.id}:실무`, model: S.create ? 'opus' : 'sonnet' }),
  // 적대QA(병렬 최대 2렌즈) → high-severity 블로커 루프 max2 → 해당 QA만 재검. 판정 계층이라 high
  (made, S) => reviewLoop(S, made, SHARED),
  // 통합(편집장): 종합 + 환원 리포트. [MUST] SME 2명↑일 때만 — 1명이면 생략(판정=리더, 환원=총책임). SKILL.md §2
  (verd, S) => S.staff.length > 1
        ? agent(`편집장 통합+환원 리포트 → ${S.outPath}`, { schema: FINAL, label:`${S.id}:통합`, model:'opus' })
        : verd,   // SME 1명: 통합자 생략, 리뷰 결과를 그대로 총책임에 올림
);

// reviewLoop 내부 골자 (검증자 3종 — ①②는 고정, "최대 2" 상한은 ③에만):
//   ① 팩트체커(ctx✗, model 기본 'sonnet' — 규제·안전 등 틀리면 큰일 나는 항목만 'opus'): 수치·출처·내부논리만. SERVICE_CONTEXT 주지 마라. high → 원 SME 재가동(ctx✓, raw+통합본 둘 다 수정) → 팩트체커가 *고친 부분만* 다시 검증(편집장이 글자만 훑고 통과시키면 안 됨 — 고치다 새 오류 끼임).
//   ② 논리 QA(ctx✗): 내부논리 baseline, 고정. ③ 예산 밖.
//   ③ 도메인 적대 렌즈(협상): const qa = await parallel(pickLenses(S).slice(0,2).map(lens =>
//        () => agent(adversarialQA(lens), {schema:{findings:[{severity:'',type:''}]}, label:`${S.id}:QA:${lens}`, model:'opus'})));  // 동시 최대 2, 초과분 다음 라운드
//   high-severity 있으면 수정 라운드 → 같은 QA만 재검(max 2). 그래도 남으면 유저 보고 후 멈춤.

// 수정·중단 후 처음부터 재발사 금지:
//   Workflow({ scriptPath: <이 파일>, resumeFromRunId })
//   → 프롬프트 문자열이 *동일한* agent 호출만 저널 캐시 반환, 바뀐 지점부터 재실행(같은 세션 한정).
//   캐시 키 = 프롬프트 문자열 동일성. 템플릿 보간 미세차로도 캐시 미스 가능 — resume 효과 과신 금지.
```

## 구현 B — 오케스트레이터 미제공 호스트 (강등)

노출 여부 먼저 확인 — 없으면 ToolSearch/툴목록에 안 보인다. 없으면:

- `Task` 서브에이전트를 STAGES 순서대로 호출(`for…of`)
- 의존은 `TaskUpdate` 의 `blockedBy` 그래프로 표현
- 중간 산출은 작업폴더 파일, 반환은 요약만
- 모델 티어는 `Task` 에 modelId 류 파라미터가 있으면 거기, 없으면 프롬프트 첫 줄 `// 사용 모델: <구체명>` 인라인 힌트
- **포기:** 저널 캐시·resume·병렬. (게이트형 직렬 루프와 동형 — 그래도 1급.)

## 모델 티어 (실수 전파 비용 기준 — 3티어 이산)

| 티어 | Claude | 대상 |
|---|---|---|
| **high** | opus | 리뷰(적대QA·편집장)·총책임 — 실수가 최종물 직행 / 창작·UX카피 실무(리뷰가 천장 못 메움) |
| **middle** | sonnet | 실무 기본 — 실수는 리뷰가 잡는 전제 |
| **low** | haiku | 단순 추출·정리·형식 변환 |

라벨만 보고 자동배정 금지 — 페르소나가 *자기 실수 전파 비용*으로 고른다. 타 호스트는 동급 모델로 자율 매핑.

## 각 페르소나 프롬프트 필수 4요소 + 컨텍스트 주입 매트릭스

역할 정체성 · 담당 영역(만질 수 있는 범위) · 산출물 형식 · 참조 입력 파일 경로.

**SERVICE_CONTEXT 선택 주입** (전 계층 동일 주입은 안티패턴):

| 계층 | SERVICE_CONTEXT | 이유 |
|---|---|---|
| 리더·실무(SME)·통합·갭분석※ | ✓ | "왜 하는지" 알아야 분해·제작·해석 가능 (※갭분석=리더 태스크, 별도 계층 아님) |
| 팩트체커·논리 QA | ✗ | 수치·출처·내부논리만 — 맥락 주면 편향 |
