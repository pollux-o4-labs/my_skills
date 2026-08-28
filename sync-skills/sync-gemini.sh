#!/usr/bin/env bash
# sync-gemini.sh — Dedicated skill synchronization for Gemini / agy CLI paths.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"
parse_args "$@"

# Collect valid skill names from ~/.claude/skills and REPO_ROOT
gemini_wanted="$(
  {
    if [ -d "$SRC_ROOT" ]; then
      for d in "$SRC_ROOT"/*; do
        [ -e "$d" ] || continue
        n="$(basename "$d")"
        is_not_skill "$n" && continue
        [ -f "$d/SKILL.md" ] && echo "$n"
      done
    fi
    for d in "$REPO_ROOT"/*/; do
      [ -d "$d" ] || continue
      n="$(basename "$d")"
      is_not_skill "$n" && continue
      [ -f "$d/SKILL.md" ] && echo "$n"
    done
  } | sort -u
)"

if [ ${#ONLY[@]} -gt 0 ]; then
  gemini_wanted="$(grep -xFf <(printf '%s\n' "${ONLY[@]}") <<< "$gemini_wanted" || true)"
fi

SKILL_COUNT="$(grep -c . <<< "$gemini_wanted" || true)"

sync_dir() {
  local dest="$1" copy_count=0
  run "mkdir -p '$dest'"

  if [ "$PRUNE_MIRROR" = 1 ]; then
    for entry in "$dest"/*/; do
      [ -d "$entry" ] || continue
      local name; name="$(basename "$entry")"
      if ! grep -qx "$name" <<< "$gemini_wanted"; then
        [ "$VERBOSE" = 1 ] && echo "    prune (not in source): $name"
        run "rm -rf '$entry'"
      fi
    done
  fi

  while IFS= read -r name; do
    [ -n "$name" ] || continue
    local target="$SRC_ROOT/$name" dst="$dest/$name"
    [ -e "$target" ] || target="$REPO_ROOT/$name"
    [ -e "$target" ] || continue

    if copy_if_missing "$name" && [ -e "$dst" ]; then continue; fi

    [ "$VERBOSE" = 1 ] && echo "    + copy $name"
    run "rm -rf '$dst'; cp -RL '$target' '$dst'"
    copy_count=$((copy_count + 1))
  done <<< "$gemini_wanted"

  echo "==> [gemini] $dest ($SKILL_COUNT skills synced, $copy_count updated)"
}

GEMINI_DESTS=(
  "$HOME_DIR/.gemini/skills"
  "$HOME_DIR/.gemini/antigravity-cli/skills"
  "$HOME_DIR/.gemini/config/skills"
)

for dest in "${GEMINI_DESTS[@]}"; do
  if [ "$dest" = "$HOME_DIR/.gemini/skills" ] || [ -d "$dest" ]; then
    sync_dir "$dest"
  fi
done

echo "sync-gemini: done."
