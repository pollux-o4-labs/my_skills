#!/usr/bin/env bash
# desync-skills.sh — disable this repo's skills on the local machine.
#
# Claude/Codex entries are removed only when their link ownership can be proved.
# agy's official global root is a physical-copy location. Legacy Gemini copies
# are preserved unless --remove-legacy-gemini is explicitly requested.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
HOME_DIR="${HOME}"
CLAUDE_DIR="$HOME_DIR/.claude/skills"
CODEX_DIR="$HOME_DIR/.codex/skills"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME_DIR/.config}/my_skills"
DISABLED_FILE="${MY_SKILLS_DISABLED_FILE:-$CONFIG_DIR/disabled-skills.txt}"
AGY_DIR="$HOME_DIR/.gemini/config/skills"
LEGACY_GEMINI_DIR="$HOME_DIR/.gemini/skills"

DRY=0
REMOVE_GEMINI=0
REMOVE_LEGACY_GEMINI=0
ALL=0
ONLY=()

usage() {
  sed -n '2,14p' "${BASH_SOURCE[0]}"
  cat <<'EOF'

Usage:
  desync-skills.sh --all [--remove-gemini] [--remove-legacy-gemini] [--dry-run]
  desync-skills.sh --only name[,name...] [--remove-gemini] [--remove-legacy-gemini] [--dry-run]

Both copy-removal options are intentionally explicit: physical copies have no
ownership marker, so a same-named skill from another installer may be removed.
The antigravity-cli directory is internal state and is never touched.
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --all) ALL=1; shift ;;
    --only)
      [ $# -ge 2 ] || { echo "--only requires a value" >&2; exit 2; }
      IFS=',' read -ra parts <<< "$2"
      for p in "${parts[@]}"; do
        p="$(echo "$p" | xargs)"
        [ -n "$p" ] || continue
        [[ "$p" =~ ^[A-Za-z0-9._-]+$ ]] || { echo "invalid skill name: $p" >&2; exit 2; }
        ONLY+=("$p")
      done
      shift 2 ;;
    --remove-gemini) REMOVE_GEMINI=1; shift ;;
    --remove-legacy-gemini) REMOVE_LEGACY_GEMINI=1; shift ;;
    --dry-run) DRY=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown arg: $1" >&2; usage >&2; exit 2 ;;
  esac
done

[ "$ALL" = 1 ] || [ ${#ONLY[@]} -gt 0 ] || { echo "choose --all or --only" >&2; exit 2; }

is_repo_skill_name() {
  local n="$1"
  [ -f "$REPO_ROOT/$n/SKILL.md" ]
}

owned_claude_link() {
  local path="$1"
  [ -L "$path" ] || return 1
  local target; target="$(readlink "$path")"
  case "$target" in
    "$REPO_ROOT"/*) [ "$(dirname "$target")" = "$REPO_ROOT" ] ;;
    *) return 1 ;;
  esac
}

owned_codex_link() {
  local path="$1"
  [ -L "$path" ] || return 1
  local target; target="$(readlink "$path")"
  case "$target" in
    "$CLAUDE_DIR"/*) [ "$(dirname "$target")" = "$CLAUDE_DIR" ] || return 1 ;;
    *) return 1 ;;
  esac
  owned_claude_link "$target"
}

candidate_names() {
  local d name
  for d in "$REPO_ROOT"/*/; do
    [ -f "$d/SKILL.md" ] || continue
    name="$(basename "$d")"
    is_repo_skill_name "$name" && printf '%s\n' "$name"
  done
  for d in "$CLAUDE_DIR"/*; do
    [ -e "$d" ] || [ -L "$d" ] || continue
    owned_claude_link "$d" && printf '%s\n' "$(basename "$d")"
  done
  for d in "$CODEX_DIR"/*; do
    [ -e "$d" ] || [ -L "$d" ] || continue
    owned_codex_link "$d" && printf '%s\n' "$(basename "$d")"
  done
}

disable_name() {
  local name="$1"
  if [ -f "$DISABLED_FILE" ] && grep -Fqx "$name" "$DISABLED_FILE"; then return 0; fi
  echo "    disable: $name"
  if [ "$DRY" = 0 ]; then
    mkdir -p "$CONFIG_DIR"
    printf '%s\n' "$name" >> "$DISABLED_FILE"
  fi
}

remove_link() {
  local path="$1" label="$2"
  echo "    remove $label: $(basename "$path")"
  [ "$DRY" = 1 ] || rm -f -- "$path"
}

NAMES="$(candidate_names | sort -u)"
if [ ${#ONLY[@]} -gt 0 ]; then
  FILTERED=""
  for name in "${ONLY[@]}"; do
    grep -Fqx "$name" <<< "$NAMES" && FILTERED="${FILTERED}${name}\n"
  done
  NAMES="$(printf '%b' "$FILTERED" | sed '/^$/d' | sort -u)"
fi

[ -n "$NAMES" ] || { echo "no matching repo-owned skills" >&2; exit 1; }

echo "==> desync $([ "$DRY" = 1 ] && echo '(dry-run)' || true)"
while IFS= read -r name; do
  [ -n "$name" ] || continue
  disable_name "$name"

  codex_link="$CODEX_DIR/$name"
  if owned_codex_link "$codex_link"; then
    remove_link "$codex_link" codex
  fi

  claude_link="$CLAUDE_DIR/$name"
  if owned_claude_link "$claude_link"; then
    remove_link "$claude_link" claude
  fi

  agy_copy="$AGY_DIR/$name"
  if [ -d "$agy_copy" ] && [ ! -L "$agy_copy" ]; then
    if [ "$REMOVE_GEMINI" = 1 ]; then
      echo "    remove agy copy: $agy_copy"
      [ "$DRY" = 1 ] || rm -rf -- "$agy_copy"
    else
      echo "    keep agy copy (use --remove-gemini): $agy_copy"
    fi
  fi

  legacy_copy="$LEGACY_GEMINI_DIR/$name"
  if [ -d "$legacy_copy" ] && [ ! -L "$legacy_copy" ]; then
    if [ "$REMOVE_LEGACY_GEMINI" = 1 ]; then
      echo "    remove legacy Gemini copy: $legacy_copy"
      [ "$DRY" = 1 ] || rm -rf -- "$legacy_copy"
    else
      echo "    keep legacy Gemini copy (use --remove-legacy-gemini): $legacy_copy"
    fi
  fi
done <<< "$NAMES"

echo "desync-skills: done. disabled list: $DISABLED_FILE"
