#!/usr/bin/env bash
# worktree-cleanup-gate.sh — PostToolUse(Bash) 훅 진입점. 판정은 worktree_cleanup_gate.py.
#
# 등록 (~/.claude/settings.json):
#   "PostToolUse": [{ "matcher": "Bash", "hooks": [{ "type": "command",
#     "command": "bash '<이 파일의 절대경로>'" }] }]
#
# 근거: docs/history/worktree-cleanup-gate.md

set -uo pipefail

# 데비안·우분투 계열은 python3 만 깔고 `python` 이름은 python-is-python3 를 따로 설치해야
# 생긴다 — `python` 만 찾으면 훅이 상시 무음 통과한다.
PY="$(command -v python3 || command -v python || true)"
if [ -z "$PY" ]; then
  echo "[worktree-cleanup-gate] python 인터프리터를 찾지 못해 건너뛴다." >&2
  exit 0
fi

exec "$PY" "$(dirname "${BASH_SOURCE[0]}")/worktree_cleanup_gate.py"
