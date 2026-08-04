#!/usr/bin/env bash
# sync-skills.sh — Linux/macOS counterpart of sync-skills.ps1.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"
parse_args "$@"

MANIFEST_FILE="$SCRIPT_DIR/claude-skills.txt"
MANIFEST=()
if [ -f "$MANIFEST_FILE" ]; then
  while IFS= read -r line || [ -n "$line" ]; do
    line="${line%%#*}"; line="$(echo "$line" | xargs)"
    [ -n "$line" ] && MANIFEST+=("$line")
  done < "$MANIFEST_FILE"
fi

in_only()     { local n="$1"; for x in "${ONLY[@]:-}"; do [ "$n" = "$x" ] && return 0; done; return 1; }
in_manifest() { local n="$1"; for x in "${MANIFEST[@]:-}"; do [ "$n" = "$x" ] && return 0; done; return 1; }

wanted_names() {
  local n
  for d in "$REPO_ROOT"/*/; do
    n="$(basename "$d")"
    is_not_skill "$n" && continue
    [ -f "$REPO_ROOT/$n/SKILL.md" ] || continue
    if [ "$ALL_SKILLS" = 1 ] || [[ "$n" == AIL-* ]] || in_manifest "$n" || in_only "$n"; then
      echo "$n"
    fi
  done
}

owned_link() {
  local path="$1"
  [ -L "$path" ] || return 1
  local tgt; tgt="$(readlink "$path")"
  case "$tgt" in
    "$REPO_ROOT"/*) return 0 ;;
    *) return 1 ;;
  esac
}

link_host() {
  local dest="$1" src_root="$2"
  run "mkdir -p '$dest'"
  for entry in "$dest"/*; do
    [ -L "$entry" ] || continue
    local name; name="$(basename "$entry")"
    owned_link "$entry" || continue
    if [ ${#ONLY[@]} -gt 0 ] && ! in_only "$name"; then continue; fi
    if [ ! -e "$entry" ]; then
      echo "    prune (dangling): $name"; run "rm -f '$entry'"
    elif ! grep -qx "$name" <<< "$WANTED"; then
      echo "    prune (dropped from manifest): $name"; run "rm -f '$entry'"
    fi
  done
  while IFS= read -r name; do
    [ -n "$name" ] || continue
    local target="$src_root/$name" dst="$dest/$name"
    if [ ! -e "$target" ]; then echo "    skip $name: source missing"; continue; fi
    if [ -L "$dst" ]; then
      [ "$(readlink "$dst")" = "$target" ] && continue
      owned_link "$dst" || { echo "    skip $name: foreign link ($(readlink "$dst"))"; continue; }
    elif [ -e "$dst" ]; then
      echo "    skip $name: dest is a plain dir/file — resolve manually"; continue
    fi
    echo "    + link $name"; run "ln -sfn '$target' '$dst'"
  done <<< "$WANTED"
}

WANTED="$(wanted_names)"
COUNT="$(grep -c . <<< "$WANTED" || true)"

process() {
  local name="$1" dest="$2" src="$3" mode="$4"
  [ "$HOST" = all ] || [ "$HOST" = "$name" ] || return 0
  if [ "$name" != claude ] && [ ! -d "$dest" ]; then return 0; fi
  echo "==> [$name/$mode] $dest  (<= $src, $COUNT skills)"
  link_host "$dest" "$src"
}

process claude "$HOME_DIR/.claude/skills" "$REPO_ROOT"               link
process codex  "$HOME_DIR/.codex/skills"  "$HOME_DIR/.claude/skills" link

if [ "$HOST" = "all" ] || [ "$HOST" = "gemini" ]; then
  GEMINI_ARGS=()
  [ ${#ONLY[@]} -gt 0 ] && GEMINI_ARGS+=(--only "$(IFS=,; echo "${ONLY[*]}")")
  [ "$PRUNE_MIRROR" = 1 ] && GEMINI_ARGS+=(--prune-mirror)
  [ "$VERBOSE" = 1 ] && GEMINI_ARGS+=(--verbose)
  [ "$DRY" = 1 ] && GEMINI_ARGS+=(--dry-run)
  "$SCRIPT_DIR/sync-gemini.sh" "${GEMINI_ARGS[@]}"
fi

echo "sync-skills: done."
