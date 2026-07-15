#!/usr/bin/env bash
# worktree-cleanup-gate.sh — PostToolUse(Bash) 훅 진입점.
#
# 이 파일은 인터프리터만 찾아 넘긴다. 판정·조회·출력은 worktree_cleanup_gate.py 에 있다
# (셸에서 porcelain 을 파싱하면 detached 누락·개행 든 경로 절단 같은 결함이 재발한다 —
#  v2 실측에서 실제로 났다).
#
# 등록 (~/.claude/settings.json):
#   "PostToolUse": [{ "matcher": "Bash", "hooks": [{ "type": "command",
#     "command": "bash '<이 파일의 절대경로>'" }] }]
#
# python3 를 먼저 찾는 이유: 데비안·우분투 계열은 python3 만 깔고 `python` 이름은
#   python-is-python3 를 따로 설치해야 생긴다. `python` 만 찾으면 훅이 상시 무음
#   통과한다 — 자매 훅 git-workflow-select/hooks/git-workflow-gate.sh 가 이 함정에
#   빠져 "유일한 하드 게이트"라 자칭하면서 아무것도 막지 못하고 있었다(2026-07-15 실측).

set -uo pipefail

PY="$(command -v python3 || command -v python || true)"
if [ -z "$PY" ]; then
  # 훅을 조용히 죽이지 않는다 — 무음 실패는 "보고할 것이 없음"과 구분되지 않는다.
  echo "[worktree-cleanup-gate] python 인터프리터를 찾지 못해 건너뛴다." >&2
  exit 0
fi

exec "$PY" "$(dirname "${BASH_SOURCE[0]}")/worktree_cleanup_gate.py"
