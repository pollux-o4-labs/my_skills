#!/usr/bin/env python3
"""PR close 시 light-review-log 의 `결과:` 필드를 자동 갱신한다.

사람 결정(머지/닫음)을 받아적기만 하며, 장부에 없는 PR 은 건드리지 않는다.
입력은 전부 GitHub event context 의 신뢰 가능한 값(정수 PR 번호, 커밋 SHA)이며
PR 제목 등 사용자 통제 문자열은 쓰지 않는다(주입 표면 없음).
"""
import os
import re
import sys

try:  # 로케일 무관하게 로그가 스크립트를 죽이지 않도록
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

LEDGER = os.environ.get("LEDGER", "docs/history/light-review-log.md")
PR = os.environ["PR"].strip()
MERGED = os.environ.get("MERGED", "false").strip().lower() == "true"
SHA = os.environ.get("SHA", "").strip()
DATE = os.environ["DATE"].strip()

MARKER = " / 결과: "


def emit(changed, note):
    # 기계용 출력을 먼저 확정하고, 로깅은 실패해도 무해하도록 뒤에 둔다.
    out = os.environ.get("GITHUB_OUTPUT")
    if out:
        with open(out, "a", encoding="utf-8") as fh:
            fh.write("changed=%s\n" % ("true" if changed else "false"))
    try:
        print(note)
    except Exception:
        pass


def main():
    if not re.fullmatch(r"\d+", PR):
        emit(False, "invalid PR number: %r" % PR)
        return 0
    if MERGED:
        sha7 = SHA[:7] if re.fullmatch(r"[0-9a-fA-F]{7,40}", SHA) else "?"
        status = "머지됨(%s, %s)" % (sha7, DATE)
    else:
        status = "닫힘·불채택(%s)" % DATE

    with open(LEDGER, encoding="utf-8") as fh:
        lines = fh.readlines()

    line_re = re.compile(r"^-\s+#%s\s" % PR)
    hit = next((i for i, ln in enumerate(lines) if line_re.match(ln)), None)
    if hit is None:
        emit(False, "PR #%s not in ledger — skip (not a lightweight-review PR)" % PR)
        return 0

    raw = lines[hit].rstrip("\n")
    head = raw.rsplit(MARKER, 1)[0] if MARKER in raw else raw
    new = head + MARKER + status
    if new == raw:
        emit(False, "PR #%s already recorded as %s — no change" % (PR, status))
        return 0

    lines[hit] = new + "\n"
    with open(LEDGER, "w", encoding="utf-8") as fh:
        fh.writelines(lines)
    emit(True, "PR #%s -> %s" % (PR, status))
    return 0


if __name__ == "__main__":
    sys.exit(main())
