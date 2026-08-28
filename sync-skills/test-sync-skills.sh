#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYNC="$SCRIPT_DIR/sync-skills.sh"
DESYNC="$SCRIPT_DIR/desync-skills.sh"
TEST_HOME="$(mktemp -d)"
trap 'rm -rf -- "$TEST_HOME"' EXIT

export HOME="$TEST_HOME"
export XDG_CONFIG_HOME="$TEST_HOME/config"
export MY_SKILLS_DISABLED_FILE="$TEST_HOME/config/my_skills/disabled-skills.txt"
mkdir -p "$HOME/.codex/skills" "$HOME/.gemini/config/skills"

bash "$SYNC" --host claude >/dev/null
bash "$SYNC" --host codex >/dev/null
bash "$SYNC" --host agy >/dev/null

[ -L "$HOME/.claude/skills/engineering-principles" ]
[ -L "$HOME/.codex/skills/engineering-principles" ]
[ "$(readlink "$HOME/.codex/skills/engineering-principles")" = "$HOME/.claude/skills/engineering-principles" ]
[ -d "$HOME/.gemini/config/skills/engineering-principles" ]
[ -L "$HOME/.claude/skills/research-principles" ]
[ -L "$HOME/.codex/skills/research-principles" ]
[ -d "$HOME/.gemini/config/skills/research-principles" ]
[ -L "$HOME/.claude/skills/format-response" ]
[ -L "$HOME/.claude/skills/restrict-line" ]
[ ! -e "$HOME/.claude/skills/skill-format" ]
[ ! -e "$HOME/.claude/skills/_legacy" ]

bash "$DESYNC" --only engineering-principles >/dev/null
[ ! -e "$HOME/.claude/skills/engineering-principles" ]
[ ! -e "$HOME/.codex/skills/engineering-principles" ]
[ -d "$HOME/.gemini/config/skills/engineering-principles" ]
grep -Fqx engineering-principles "$MY_SKILLS_DISABLED_FILE"

bash "$SYNC" --host claude --all-skills >/dev/null
[ ! -e "$HOME/.claude/skills/engineering-principles" ]

# A same-named foreign link is preserved.
mkdir -p "$HOME/foreign/skill"
ln -s "$HOME/foreign/skill" "$HOME/.claude/skills/engineering-principles"
bash "$DESYNC" --only engineering-principles >/dev/null
[ -L "$HOME/.claude/skills/engineering-principles" ]

# The official agy copy is removed explicitly; the legacy root is handled separately.
rm -f "$HOME/.claude/skills/engineering-principles"
bash "$DESYNC" --only engineering-principles --remove-gemini >/dev/null
[ ! -e "$HOME/.gemini/config/skills/engineering-principles" ]
mkdir -p "$HOME/.gemini/skills/engineering-principles"
bash "$DESYNC" --only engineering-principles >/dev/null
[ -d "$HOME/.gemini/skills/engineering-principles" ]
bash "$DESYNC" --only engineering-principles --remove-legacy-gemini >/dev/null
[ ! -e "$HOME/.gemini/skills/engineering-principles" ]

echo "test-sync-skills: PASS"
