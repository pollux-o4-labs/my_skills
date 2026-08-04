#!/usr/bin/env bash
# sync-gemini.sh — Dedicated script to sync skills into Gemini / agy CLI paths.
#
# Gemini (agy) requires physical copies (not symlinks/junctions).
# Source of truth for active skills: ~/.claude/skills (curated hub) + repo skills as fallback.
#
# Dests (only synced if parent dir exists):
#   ~/.gemini/skills
#   ~/.gemini/antigravity-cli/skills
#   ~/.gemini/config/skills
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
HOME_DIR="${HOME}"
SRC_ROOT="${HOME_DIR}/.claude/skills"

DRY=0
PRUNE_MIRROR=0
VERBOSE=0
ONLY=()

while [ $# -gt 0 ]; do
  case "$1" in
    --only) IFS=',' read -ra parts <<< "$2"; for p in "${parts[@]}"; do p="$(echo "$p" | xargs)"; [ -n "$p" ] && ONLY+=("$p"); done; shift 2 ;;
    --prune-mirror) PRUNE_MIRROR=1; shift ;;
    --verbose|-v) VERBOSE=1; shift ;;
    --dry-run) DRY=1; shift ;;
    -h|--help) echo "Usage: sync-gemini.sh [--only <name>] [--prune-mirror] [--verbose] [--dry-run]"; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

NOT_SKILLS=(.git .github .claude .playwright-mcp .system review sync-skills docs node_modules md-ebook show-me)
COPY_ONLY_IF_MISSING=(md2ebook)

is_not_skill()   { local n="$1"; for x in "${NOT_SKILLS[@]}"; do [ "$n" = "$x" ] && return 0; done; return 1; }
copy_if_missing(){ local n="$1"; for x in "${COPY_ONLY_IF_MISSING[@]}"; do [ "$n" = "$x" ] && return 0; done; return 1; }
run() { if [ "$DRY" = 1 ]; then echo "    [dry] $*"; else eval "$@"; fi; }

# Collect all valid skill names from ~/.claude/skills and REPO_ROOT
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
  local dest="$1"
  [ -d "$dest" ] || run "mkdir -p '$dest'"

  local copy_count=0

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
