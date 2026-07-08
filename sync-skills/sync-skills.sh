#!/usr/bin/env bash
# sync-skills.sh — Linux/macOS counterpart of sync-skills.ps1.
# Registers/refreshes this repo's skills into each CLI host that exists on the machine.
#
# Hosts (each processed only if its dir exists, except claude which is created):
#   claude : ~/.claude/skills/<name>  -> symlink to repo/<name>        (curated hub)
#   codex  : ~/.codex/skills/<name>   -> symlink to ~/.claude/skills/<name>
#   gemini : ~/.gemini/skills/<name>  =  physical copy (agy skips symlinks)
#
# CURATED-HUB POLICY (matches the .ps1): a full run does NOT auto-add every repo
# skill — some are deliberately kept out. EXCEPTION: AIL-* skills (AI-Learned,
# always-on guidance) ARE auto-linked on a full run, so `git pull` + this script
# connects newly pulled AIL skills automatically. Register any non-AIL repo skill
# explicitly with --only <name>. Use --all-skills to link every repo skill.
#
# SAFETY: only ever prune a symlink this repo OWNS (its target resolves to a direct
# child of the repo root) and is dangling or left the repo. Foreign symlinks and
# plain dirs (other installers' property) are never touched.
#
# Usage:
#   sync-skills.sh                 # all existing hosts (AIL auto + any --only)
#   sync-skills.sh --host claude   # one host (claude|codex|gemini)
#   sync-skills.sh --only foo      # also register repo skill 'foo' (comma-list ok)
#   sync-skills.sh --all-skills    # link every repo skill, not just AIL-*
#   sync-skills.sh --prune-mirror  # allow pruning gemini copies absent from source
#   sync-skills.sh --dry-run       # show actions, change nothing
# Idempotent; safe to run repeatedly.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
HOME_DIR="${HOME}"

HOST=all
DRY=0
PRUNE_MIRROR=0
ALL_SKILLS=0
ONLY=()

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

# Directories in the repo that are NOT skills (mirrors $NotSkills in the .ps1).
NOT_SKILLS=(.git .github .claude .playwright-mcp .system review sync-skills docs node_modules md-ebook show-me)
# Skills whose gemini copy is refreshed only when absent (submodule-backed WIP).
COPY_ONLY_IF_MISSING=(md2ebook)

# Declarative manifest: non-AIL repo skills to link into the curated hub.
# (AIL-* are auto by provenance and need not be listed.)
MANIFEST_FILE="$SCRIPT_DIR/claude-skills.txt"
MANIFEST=()
if [ -f "$MANIFEST_FILE" ]; then
  while IFS= read -r line || [ -n "$line" ]; do
    line="${line%%#*}"; line="$(echo "$line" | xargs)"
    [ -n "$line" ] && MANIFEST+=("$line")
  done < "$MANIFEST_FILE"
fi

is_not_skill()   { local n="$1"; for x in "${NOT_SKILLS[@]}"; do [ "$n" = "$x" ] && return 0; done; return 1; }
in_only()        { local n="$1"; for x in "${ONLY[@]:-}"; do [ "$n" = "$x" ] && return 0; done; return 1; }
in_manifest()    { local n="$1"; for x in "${MANIFEST[@]:-}"; do [ "$n" = "$x" ] && return 0; done; return 1; }
copy_if_missing(){ local n="$1"; for x in "${COPY_ONLY_IF_MISSING[@]}"; do [ "$n" = "$x" ] && return 0; done; return 1; }

run() { if [ "$DRY" = 1 ]; then echo "    [dry] $*"; else eval "$@"; fi; }

# The wanted set for a full run: AIL-* (auto by provenance) + manifest entries +
# any --only names. --all-skills overrides and takes every repo skill with a SKILL.md.
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

# True if $1 is a symlink this repo owns (resolves under REPO_ROOT).
owned_link() {
  local path="$1"
  [ -L "$path" ] || return 1
  local tgt; tgt="$(readlink "$path")"
  case "$tgt" in
    "$REPO_ROOT"/*) return 0 ;;
    *) return 1 ;;
  esac
}

link_host() {   # symlink-based host (claude, codex)
  local dest="$1" src_root="$2"
  [ -d "$dest" ] || run "mkdir -p '$dest'"
  # 1) prune ONLY links this repo owns (target resolves under REPO_ROOT) that are
  #    dangling OR no longer wanted (AIL dir removed, or dropped from the manifest).
  #    Foreign links and plain dirs (other installers') are never touched. With --only,
  #    limit pruning to the named skills so an ad-hoc run can't clear the hub.
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
  # 2) (re)create each wanted link
  while IFS= read -r name; do
    [ -n "$name" ] || continue
    local target="$src_root/$name" dst="$dest/$name"
    if [ ! -e "$target" ]; then echo "    skip $name: source missing"; continue; fi
    if [ -L "$dst" ]; then
      [ "$(readlink "$dst")" = "$target" ] && continue      # already correct
      owned_link "$dst" || { echo "    skip $name: foreign link ($(readlink "$dst"))"; continue; }
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
  local name="$1" dest="$2" src="$3" mode="$4"
  [ "$HOST" = all ] || [ "$HOST" = "$name" ] || return 0
  # gemini/codex: only refresh if the host's own skills dir already exists
  # (don't spin up a host that isn't installed). claude hub is always managed.
  if [ "$name" != claude ] && [ ! -d "$dest" ]; then return 0; fi
  echo "==> [$name/$mode] $dest  (<= $src, $COUNT skills)"
  case "$mode" in
    link) link_host "$dest" "$src" ;;
    copy) copy_host "$dest" "$src" ;;
  esac
}

process claude "$HOME_DIR/.claude/skills"  "$REPO_ROOT"               link
process codex  "$HOME_DIR/.codex/skills"   "$HOME_DIR/.claude/skills" link
process gemini "$HOME_DIR/.gemini/skills"  "$HOME_DIR/.claude/skills" copy

echo "sync-skills: done."
