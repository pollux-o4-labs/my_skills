#!/usr/bin/env python3
"""worktree_cleanup_gate.py — PostToolUse(Bash) 훅.

`gh pr merge` 를 친 순간, 워크트리 정리를 감독에게 소환한다. 어느 워크트리가 끝났는지
판정하지 않고(방금 머지한 감독이 안다), 삭제하지 않는다(뮤테이션은 감독 전담).

계약: stdin 은 hook JSON(.tool_input.command), stdout 은 hookSpecificOutput,
      exit 은 항상 0 — exit 2 는 stderr 를 에러로 전달하고 stdout JSON 을 무시시킨다.

근거: docs/history/worktree-cleanup-gate.md
"""

import json
import os
import re
import shlex
import sys

NOTE = ("[worktree-cleanup-gate] `gh pr merge` 직후다 — 머지한 브랜치와 관련 워크트리 정리 요망. "
        "워크트리는 개당 수 GB 를 문다. 정리는 감독 전담이다(규칙 06 제2조): "
        "`git worktree list` 로 확인하고 끝난 것만 `git worktree remove <경로>`. "
        "지금 그 워크트리 안에 서 있으면 주 체크아웃으로 cd 한 뒤 지워라 — clean 하면 "
        "remove 가 거부 없이 성공해 이 세션의 이후 명령이 전부 깨진다. "
        "정리하지 않을 거라면 그 이유를 한 줄로 말하라 — 침묵으로 넘기지 말 것.")

# heredoc 본문은 명령이 아니라 데이터다.
_HEREDOC = re.compile(r"<<-?\s*(['\"]?)([A-Za-z_][A-Za-z0-9_]*)\1.*?^\s*\2\s*$", re.S | re.M)
# 값을 별도 토큰으로 받는 gh 전역 플래그. 값까지 건너뛰지 않으면 값이 위치인자로 샌다.
# 임의 플래그의 arity 를 추측하면 새 오탐이 생기므로 화이트리스트로만 다룬다.
_VALUE_FLAGS = {"-R", "--repo"}
_WRAPPERS = ("command", "builtin", "exec", "nohup", "time", "sudo", "xargs", "env")
_SEPARATORS = (";", "&&", "||", "|", "&", "\n")


def is_gh_pr_merge(cmd):
    prev = None
    while prev != cmd:  # 다중 heredoc → 고정점까지
        prev = cmd
        cmd = _HEREDOC.sub(" ", cmd, count=1)

    # 구분자 분리를 렉서에 맡긴다. 정규식으로 먼저 쪼개면 인용문 안의 `;`·개행이 분리를
    # 만들어 `git commit -m "fix; gh pr merge"` 가 오탐한다.
    lex = shlex.shlex(cmd, posix=True, punctuation_chars=";|&\n")
    lex.whitespace_split = True
    lex.whitespace = " \t\r"  # 개행은 whitespace 가 아니라 구분자 토큰으로 남긴다
    try:
        toks = list(lex)
    except ValueError:
        return False  # 따옴표 불균형 등 → 판정 포기(오탐보다 미탐)

    segs, cur = [], []
    for t in toks:
        if t in _SEPARATORS or set(t) <= {"\n", ";", "&", "|"}:
            if cur:
                segs.append(cur)
                cur = []
        else:
            cur.append(t)
    if cur:
        segs.append(cur)

    for toks in segs:
        i = 0
        while i < len(toks) and re.match(r"^[A-Za-z_][A-Za-z0-9_]*=", toks[i]):
            i += 1
        while i < len(toks) and toks[i] in _WRAPPERS:
            i += 1
        if i >= len(toks) or os.path.basename(toks[i]) != "gh":
            continue
        i += 1
        rest = []
        while i < len(toks):
            t = toks[i]
            if t in _VALUE_FLAGS:
                i += 2
                continue
            if not t.startswith("-"):
                rest.append(t)
            i += 1
        if rest[:2] == ["pr", "merge"]:
            return True
    return False


def main():
    # 어떤 입력에도 조용히 통과한다 — 훅이 뱉은 Traceback 은 세션에 남는 노이즈이고,
    # 이 훅은 알림이라 판정 실패의 대가가 침묵이면 충분하다.
    try:
        cmd = (json.load(sys.stdin).get("tool_input") or {}).get("command")
    except Exception:
        sys.exit(0)
    if not isinstance(cmd, str) or not cmd:
        sys.exit(0)
    try:
        hit = is_gh_pr_merge(cmd)
    except Exception:
        sys.exit(0)
    if not hit:
        sys.exit(0)
    json.dump({"hookSpecificOutput": {
        "hookEventName": "PostToolUse",
        "additionalContext": NOTE,
    }}, sys.stdout)


if __name__ == "__main__":
    main()
