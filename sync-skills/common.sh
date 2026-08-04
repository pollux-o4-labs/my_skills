#!/usr/bin/env bash
# common.sh — Shared constants, helpers, and argument parsing for sync scripts.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
HOME_DIR="${HOME}"
SRC_ROOT="${HOME_DIR}/.claude/skills"

NOT_SKILLS=(.git .github .claude .playwright-mcp .system review sync-skills docs node_modules md-ebook show-me)
COPY_ONLY_IF_MISSING=(md2ebook)

HOST=all
DRY=0
PRUNE_MIRROR=0
ALL_SKILLS=0
VERBOSE=0
ONLY=()

is_not_skill()   { local n="$1"; for x in "${NOT_SKILLS[@]}"; do [ "$n" = "$x" ] && return 0; done; return 1; }
copy_if_missing(){ local n="$1"; for x in "${COPY_ONLY_IF_MISSING[@]}"; do [ "$n" = "$x" ] && return 0; done; return 1; }
run()            { if [ "$DRY" = 1 ]; then echo "    [dry] $*"; else eval "$@"; fi; }

parse_args() {
  while [ $# -gt 0 ]; do
    case "$1" in
      --host) HOST="$2"; shift 2 ;;
      --only) IFS=',' read -ra parts <<< "$2"; for p in "${parts[@]}"; do p="$(echo "$p" | xargs)"; [ -n "$p" ] && ONLY+=("$p"); done; shift 2 ;;
      --all-skills) ALL_SKILLS=1; shift ;;
      --prune-mirror) PRUNE_MIRROR=1; shift ;;
      --verbose|-v) VERBOSE=1; shift ;;
      --dry-run) DRY=1; shift ;;
      -h|--help) echo "Usage: $0 [--host <name>] [--only <name>] [--all-skills] [--prune-mirror] [--verbose] [--dry-run]"; exit 0 ;;
      *) echo "unknown arg: $1" >&2; exit 2 ;;
    esac
  done
}
