# Sub-agent 출력 축약 룰 회고

- 작성 CLI: Claude Code (main supervisor)
- 작성일: 2026-05-22
- 작업: project_oneul/discord_chatbot — prompt eval test 인프라 (PR #170) 적용 후 baseline 실행에서 verbose pytest 출력이 main transcript 누적 → 사용자가 직접 "다른 프로젝트에선 필요한 결과만 보는 룰 있는데 여기도 필요?" 지적.

## 불편했던 점

1. `efficient-subagent` skill 본체에 **출력 축약 룰이 없다**.

   sub-agent 가 종료 시 "Files changed / Tests / Out-of-scope / Late-discovered docs" 4 section 보고 룰은 있지만, **실행 중 명령 출력 (pytest, git log, grep 등) 의 길이 제어** 룰이 없음. 매 sub-agent 가 자체 판단으로 verbose 출력을 보고에 포함하면 main context bloat → 다음 turn 추론 품질·token cost 영향.

2. main supervisor 가 sub-agent 발사 시마다 같은 룰 명시해야 한다.

   skill 본체에 룰 없으니 main 이 매 sub-agent prompt 안에 "결과 50줄 이하" / "`| tail -N`" / "`--quiet`" 등 패턴 명시. 중복 누적.

3. 6 case prompt eval `-v` 출력이 한 번에 200줄+ 차지.

   `pytest -v` 의 verbose traceback + warnings summary + plugin info 가 매번 PASS/FAIL 결과보다 더 많은 줄 차지. main 이 받으면 다음 turn context window 압박.

## 수정 제안

1. **`efficient-subagent/SKILL.md` 에 출력 축약 절 추가**.

   기존 "Scope discipline" / "Final report" 다음에 "Command output truncation" 절. 패턴:
   - `pytest -q --tb=no` 또는 summary-only mise task (`mise run prompt-eval-summary` 같은)
   - `git log --oneline -N` (라인 제한)
   - `... | tail -N` 또는 `| head -N`
   - 대용량 grep → `head_limit` 지정, `output_mode: files_with_matches`
   - 사유: main context bloat 회피, 다음 turn 추론 품질·token cost 영향

2. **프로젝트별 mise task 또는 npm script 로 summary-only variant 제공**.

   verbose task (`prompt-eval`) 와 summary task (`prompt-eval-summary`) 를 분리. sub-agent / CI = summary, 디버깅 = verbose.

3. **anti-pattern 절에 "verbose output dump" 추가**.

   기존 anti-pattern 5건 (out-of-scope cleanup, defensive code 등) 끝에 "verbose command output dumped to supervisor without truncation" 한 줄. self-rule 강제.

4. **각 프로젝트 `CLAUDE.md` 작업 규칙에 mirror**.

   project_oneul/discord_chatbot 은 PR #172 (2026-05-22) 에서 CLAUDE.md 룰 #13 추가 — 같은 정신을 user-level skill 본체에 박아두면 신규 프로젝트에서도 자동 적용.

## 관련 PR / 룰

- project_oneul/discord_chatbot CLAUDE.md 룰 #13 (PR #172 머지, 2026-05-22)
- project_oneul/discord_chatbot mise.toml `prompt-eval-summary` task (PR #172)
- project_oneul/discord_chatbot docs/meta/efficiency-feedback.md 스코프 규율 보강 (PR #172)
