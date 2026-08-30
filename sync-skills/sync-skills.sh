#!/usr/bin/env bash
# sync-skills.sh — Linux/macOS counterpart of sync-skills.ps1.
# Registers/refreshes this repo's skills into each CLI host that exists on the machine.
#
# Hosts (each processed only if its dir exists, except the personal hub):
#   custom : ~/.agents/custom-skills/<name> -> symlink to repo/<name> (curated hub)
#   claude : ~/.claude/skills/<name>  -> symlink to the personal hub
#   codex  : ~/.codex/skills/<name>   -> symlink to the personal hub
#   agy    : ~/.gemini/config/skills/<name> = physical copy
#            (the official global discovery root)
#
# CURATED-HUB POLICY (matches the .ps1): a full run does NOT auto-add every repo
# skill — some are deliberately kept out. EXCEPTION: AIL-* skills (AI-Learned,
# always-on guidance) ARE auto-linked on a full run, so `git pull` + this script
# connects newly pulled AIL skills automatically. Register any non-AIL repo skill
# explicitly with --only <name>. Use --all-skills to link every repo skill.
#
# SAFETY: only ever prune a symlink this sync owns (its target resolves to a direct
# child of the current or legacy source root) and is dangling or left the hub.
# Foreign symlinks and plain dirs (other installers' property) are never touched.
#
# Usage:
#   sync-skills.sh                 # all existing hosts (AIL auto + any --only)
#   sync-skills.sh --host claude   # one host (claude|codex|agy; gemini is an alias)
#   sync-skills.sh --only foo      # also register repo skill 'foo' (comma-list ok)
#   sync-skills.sh --all-skills    # link every repo skill, not just AIL-*
#   sync-skills.sh --prune-mirror  # allow pruning gemini copies absent from source
#   sync-skills.sh --dry-run       # show actions, change nothing
#   ~/.config/my_skills/disabled-skills.txt  # local names excluded from sync
# Idempotent; safe to run repeatedly.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
HOME_DIR="${HOME}"
CUSTOM_DIR="$HOME_DIR/.agents/custom-skills"
CLAUDE_DIR="$HOME_DIR/.claude/skills"
CODEX_DIR="$HOME_DIR/.codex/skills"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME_DIR/.config}/my_skills"
DISABLED_FILE="${MY_SKILLS_DISABLED_FILE:-$CONFIG_DIR/disabled-skills.txt}"
AGY_DIR="$HOME_DIR/.gemini/config/skills"

HOST=all
DRY=0
PRUNE_MIRROR=0
ALL_SKILLS=0
ONLY=()
DISABLED=()

while [ $# -gt 0 ]; do
  case "$1" in
    --host) HOST="$2"; shift 2 ;;
    --only) IFS=',' read -ra parts <<< "$2"; for p in "${parts[@]}"; do p="$(echo "$p" | xargs)"; [ -n "$p" ] && ONLY+=("$p"); done; shift 2 ;;
    --all-skills) ALL_SKILLS=1; shift ;;
    --prune-mirror) PRUNE_MIRROR=1; shift ;;
    --dry-run) DRY=1; shift ;;
    -h|--help) sed -n '2,30p' "${BASH_SOURCE[0]}"; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

if [ "$HOST" = gemini ]; then HOST=agy; fi
case "$HOST" in
  all|claude|codex|agy) ;;
  *) echo "unknown host: $HOST" >&2; exit 2 ;;
esac

# Directories in the repo that are NOT skills (mirrors $NotSkills in the .ps1).
NOT_SKILLS=(.git .github .claude .playwright-mcp .system review sync-skills docs node_modules md-ebook show-me _legacy templates)
# Skills whose gemini copy is refreshed only when absent (submodule-backed WIP).
COPY_ONLY_IF_MISSING=(md2ebook)

# Declarative manifest: non-AIL repo skills to link into the personal hub.
# (AIL-* are auto by provenance and need not be listed.)
MANIFEST_FILE="$SCRIPT_DIR/custom-skills.txt"
MANIFEST=()
if [ -f "$MANIFEST_FILE" ]; then
  while IFS= read -r line || [ -n "$line" ]; do
    line="${line%%#*}"; line="$(echo "$line" | xargs)"
    [ -n "$line" ] && MANIFEST+=("$line")
  done < "$MANIFEST_FILE"
fi

if [ -f "$DISABLED_FILE" ]; then
  while IFS= read -r line || [ -n "$line" ]; do
    line="${line%%#*}"; line="$(echo "$line" | xargs)"
    [ -n "$line" ] && DISABLED+=("$line")
  done < "$DISABLED_FILE"
fi

is_not_skill()   { local n="$1"; for x in "${NOT_SKILLS[@]}"; do [ "$n" = "$x" ] && return 0; done; return 1; }
in_only()        { local n="$1"; for x in "${ONLY[@]:-}"; do [ "$n" = "$x" ] && return 0; done; return 1; }
in_manifest()    { local n="$1"; for x in "${MANIFEST[@]:-}"; do [ "$n" = "$x" ] && return 0; done; return 1; }
is_disabled()    { local n="$1"; for x in "${DISABLED[@]:-}"; do [ "$n" = "$x" ] && return 0; done; return 1; }
copy_if_missing(){ local n="$1"; for x in "${COPY_ONLY_IF_MISSING[@]}"; do [ "$n" = "$x" ] && return 0; done; return 1; }

run() { if [ "$DRY" = 1 ]; then echo "    [dry] $*"; else eval "$@"; fi; }

# The wanted set for a full run: AIL-* (auto by provenance) + manifest entries +
# any --only names. --all-skills overrides and takes every repo skill with a SKILL.md.
wanted_names() {
  local n
  for d in "$REPO_ROOT"/*/; do
    n="$(basename "$d")"
    is_not_skill "$n" && continue
    is_disabled "$n" && continue
    [ -f "$REPO_ROOT/$n/SKILL.md" ] || continue
    if [ "$ALL_SKILLS" = 1 ] || [[ "$n" == AIL-* ]] || in_manifest "$n" || in_only "$n"; then
      echo "$n"
    fi
  done
}

# True if $1 is a symlink whose target is a direct child of one of the supplied roots.
owned_link() {
  local path="$1"; shift
  [ -L "$path" ] || return 1
  local tgt; tgt="$(readlink "$path")"
  local root
  for root in "$@"; do
    case "$tgt" in
      "$root"/*) [ "$(dirname "$tgt")" = "$root" ] && return 0 ;;
    esac
  done
  return 1
}

owned_legacy_codex_link() {
  local path="$1"
  [ -L "$path" ] || return 1
  local target; target="$(readlink "$path")"
  case "$target" in
    "$CLAUDE_DIR"/*) [ "$(dirname "$target")" = "$CLAUDE_DIR" ] || return 1 ;;
    *) return 1 ;;
  esac
  owned_link "$target" "$REPO_ROOT" "$HOME_DIR/.agents/my_skills"
}

owned_host_link() {
  local path="$1" dest="$2"; shift 2
  owned_link "$path" "$@" && return 0
  [ "$dest" = "$CODEX_DIR" ] && owned_legacy_codex_link "$path"
}

link_host() {   # symlink-based host (claude, codex)
  local dest="$1" src_root="$2"; shift 2
  local owned_roots=("$@")
  [ -d "$dest" ] || run "mkdir -p '$dest'"
  # 1) prune ONLY links this repo owns (target resolves under REPO_ROOT) that are
  #    dangling OR no longer wanted (AIL dir removed, or dropped from the manifest).
  #    Foreign links and plain dirs (other installers') are never touched. With --only,
  #    limit pruning to the named skills so an ad-hoc run can't clear the hub.
  for entry in "$dest"/*; do
    [ -L "$entry" ] || continue
    local name; name="$(basename "$entry")"
    owned_host_link "$entry" "$dest" "${owned_roots[@]}" || continue
    if [ ${#ONLY[@]} -gt 0 ] && ! in_only "$name"; then continue; fi
    if [ ! -e "$entry" ]; then
      echo "    prune (dangling): $name"; run "rm -f '$entry'"
    elif ! grep -qx "$name" <<< "$WANTED"; then
      echo "    prune (dropped from manifest): $name"; run "rm -f '$entry'"
    fi
  done
  # 2) (re)create each wanted link
  while IFS= read -r name; do
    [ -n "$name" ] || continue
    local target="$src_root/$name" dst="$dest/$name"
    if [ ! -e "$target" ]; then echo "    skip $name: source missing"; continue; fi
    if [ -L "$dst" ]; then
      [ "$(readlink "$dst")" = "$target" ] && continue      # already correct
      owned_host_link "$dst" "$dest" "${owned_roots[@]}" || { echo "    skip $name: foreign link ($(readlink "$dst"))"; continue; }
    elif [ -e "$dst" ]; then
      echo "    skip $name: dest is a plain dir/file — resolve manually"; continue
    fi
    echo "    + link $name"; run "ln -sfn '$target' '$dst'"
  done <<< "$WANTED"
}

copy_host() {   # gemini: physical copies
  local dest="$1" src_root="$2"
  [ -d "$dest" ] || run "mkdir -p '$dest'"
  if [ "$PRUNE_MIRROR" = 1 ]; then
    for entry in "$dest"/*/; do
      [ -d "$entry" ] || continue
      local name; name="$(basename "$entry")"
      grep -qx "$name" <<< "$WANTED" || { echo "    prune (not in source): $name"; run "rm -rf '$entry'"; }
    done
  fi
  while IFS= read -r name; do
    [ -n "$name" ] || continue
    local target="$src_root/$name" dst="$dest/$name"
    [ -e "$target" ] || { echo "    skip $name: source missing"; continue; }
    if copy_if_missing "$name" && [ -e "$dst" ]; then continue; fi
    echo "    + copy $name"; run "rm -rf '$dst'; cp -RL '$target' '$dst'"
  done <<< "$WANTED"
}

WANTED="$(wanted_names)"
COUNT="$(grep -c . <<< "$WANTED" || true)"

process() {
  local name="$1" dest="$2" src="$3" mode="$4"; shift 4
  [ "$HOST" = all ] || [ "$HOST" = "$name" ] || [ "$name" = custom ] || return 0
  # Host directories are only refreshed when their CLI is installed. The personal
  # hub is always managed because every host derives its links from it.
  if [ "$name" != custom ] && [ ! -d "$dest" ]; then return 0; fi
  echo "==> [$name/$mode] $dest  (<= $src, $COUNT skills)"
  case "$mode" in
    link) link_host "$dest" "$src" "$@" ;;
    copy) copy_host "$dest" "$src" ;;
  esac
}

process custom "$CUSTOM_DIR"               "$REPO_ROOT"              link "$REPO_ROOT"
process claude "$CLAUDE_DIR"                "$CUSTOM_DIR"              link "$CUSTOM_DIR" "$REPO_ROOT" "$HOME_DIR/.agents/my_skills"
process codex  "$CODEX_DIR"                 "$CUSTOM_DIR"              link "$CUSTOM_DIR" "$REPO_ROOT" "$HOME_DIR/.agents/my_skills"
process agy    "$AGY_DIR"                  "$CUSTOM_DIR"              copy

echo "sync-skills: done."
