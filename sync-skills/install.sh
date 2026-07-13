#!/usr/bin/env bash
# install.sh — one-time per-clone bootstrap (run once on each new machine).
#
# Git does NOT ship hook activation with a clone (security: a clone can't auto-run
# code). So core.hooksPath must be set once per clone. This does that, then runs an
# initial sync so skills are linked immediately.
#
#   bash sync-skills/install.sh
#
# After this, every `git pull` auto-links newly pulled AIL skills via the post-merge hook.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$REPO_ROOT"

git config --local core.hooksPath sync-skills/git-hooks
echo "[install] core.hooksPath -> sync-skills/git-hooks"

if [ -x "$SCRIPT_DIR/sync-skills.sh" ]; then
  echo "[install] initial sync:"
  "$SCRIPT_DIR/sync-skills.sh"
fi

# register skill-owned Stop hook (idempotent; runs after sync so the skill is linked)
GATE_REGISTRAR="$REPO_ROOT/skillify-session-lessons/hooks/register-hook.mjs"
if command -v node >/dev/null 2>&1 && [ -f "$GATE_REGISTRAR" ]; then
  echo "[install] registering skillify Stop hook:"
  node "$GATE_REGISTRAR" || echo "[install] WARN: hook registration failed (skills still linked)"
elif [ -f "$GATE_REGISTRAR" ]; then
  echo "[install] WARN: node not found — skipping skillify Stop hook registration"
fi

echo "[install] done — future 'git pull' will auto-link skills."
