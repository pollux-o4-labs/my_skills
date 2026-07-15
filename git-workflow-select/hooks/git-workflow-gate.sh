#!/usr/bin/env bash
# git-workflow-gate.sh — PreToolUse(Bash) 하드 게이트
#
# 목적: AI 가 작업 중 무심코 새 브랜치를 파기 전에, repo 가 워크플로를
#       선택했는지(CLAUDE.md `## Git Workflow` 마커)를 강제 확인한다.
#       스킬 문서로는 못 막는 mid-flight `git switch -c dev` 를 차단하는
#       유일한 하드 게이트.
#
# 계약:
#   stdin  : PreToolUse hook JSON. .tool_input.command 에 실행할 Bash 명령.
#   exit 0 : 통과 (조용히).
#   exit 2 : 차단. stderr 메시지가 사용자·모델에 전달됨.
#
# 판정:
#   신규 브랜치 생성 명령이 아님          → 통과 (git 여부 불문).
#   CLAUDE.md 자체가 없음                 → 통과 (아래 안전판 참조).
#   CLAUDE.md 있고 마커 있음              → 통과.
#   CLAUDE.md 있고 마커 없음              → 차단(exit 2).
#
# 설계: 명령 파싱은 python(shlex)에 위임한다. 정규식 부분문자열 매칭은
#   `git commit -m '... switch -c ...'` 나 `echo git switch -c` 처럼 인용문·
#   인자에 든 문자열을 실제 git 호출과 구분 못 해 오탐한다. shlex 토큰화로
#   각 세그먼트(&&·;·| 로 분리)의 첫 토큰이 진짜 git 인지 정확히 본다.

set -euo pipefail

input="$(cat)"

# 인터프리터 해소: python3 를 먼저 본다. 리눅스·WSL 표준 설치엔 `python3` 만
# 있고 `python` 은 없다 — `python` 만 찾으면 그 머신에서 게이트가 통째로
# 무력화된다(실측: exit 0 만 반환, 마커 없는 repo 도 통과).
# 둘 다 없으면 판정 불가 → 정상 작업을 막지 않도록 통과(fail-open).
PY=""
for cand in python3 python; do
  if command -v "$cand" >/dev/null 2>&1; then
    PY="$cand"
    break
  fi
done
if [ -z "$PY" ]; then
  exit 0
fi

# repo 루트에서 CLAUDE.md 경로 계산 (없으면 현재 디렉토리).
repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [ -n "$repo_root" ]; then
  claude_md="$repo_root/CLAUDE.md"
else
  claude_md="./CLAUDE.md"
fi

# 판정 코어. stdin JSON 을 받아 브랜치 생성 여부를 정하고,
# 필요 시 CLAUDE.md 마커까지 검사해 exit code 로 결과를 낸다.
#   exit 0 = 통과, exit 2 = 차단(+stderr 메시지)
CLAUDE_MD_PATH="$claude_md" "$PY" - "$input" <<'PYEOF'
import sys, os, shlex, re

# 차단 메시지가 어떤 콘솔 인코딩에서도 UTF-8 바이트로 나가도록 강제.
try:
    sys.stderr.reconfigure(encoding="utf-8")
except Exception:
    pass

raw = sys.argv[1] if len(sys.argv) > 1 else ""

try:
    import json
    cmd = (json.loads(raw).get("tool_input") or {}).get("command") or ""
except Exception:
    cmd = ""

if not cmd:
    sys.exit(0)

# &&, ||, ;, | (파이프), 개행으로 세그먼트 분리. 각 세그먼트의 첫 실질 토큰이
# 진짜 명령어다. 커밋 메시지·echo 인자에 든 문자열은 별도 토큰이라 첫 토큰이
# 될 수 없으므로 자연히 걸러진다.
segments = re.split(r'&&|\|\||[;\n|]', cmd)

def is_new_branch_create(seg):
    seg = seg.strip()
    if not seg:
        return False
    try:
        toks = shlex.split(seg)
    except ValueError:
        # 따옴표 불균형 등 파싱 실패. 안전하게 비생성으로 본다(정상 작업 우선).
        return False
    if not toks:
        return False

    # 선행 env 대입(FOO=bar git ...) 스킵
    i = 0
    while i < len(toks) and re.match(r'^[A-Za-z_][A-Za-z0-9_]*=', toks[i]):
        i += 1
    if i >= len(toks) or os.path.basename(toks[i]) != "git":
        return False
    i += 1

    # git 전역 옵션 스킵: -C <path>, -c <k=v>, --git-dir=..., --work-tree=... 등.
    # 값을 분리해 받는 -C/-c 는 다음 토큰(값)까지 함께 스킵.
    while i < len(toks):
        t = toks[i]
        if t in ("-C", "-c"):
            i += 2
            continue
        if t.startswith("-"):
            i += 1
            continue
        break
    if i >= len(toks):
        return False

    sub = toks[i]
    rest = toks[i+1:]

    if sub == "switch":
        return any(a in ("-c", "-C") or a.startswith("-c=") or a.startswith("-C=") for a in rest)
    if sub == "checkout":
        return any(a in ("-b", "-B") or a.startswith("-b=") or a.startswith("-B=") for a in rest)
    if sub == "branch":
        # 삭제/rename/copy/upstream/조회 플래그가 있으면 생성 아님.
        noncreate = {"-d","-D","--delete","-m","-M","--move","-c","-C","--copy",
                     "-u","--set-upstream-to","-a","--all","-r","--remotes",
                     "-l","--list","--show-current","--edit-description","--unset-upstream",
                     "-v","-vv","--verbose","--merged","--no-merged","--contains","--points-at"}
        for a in rest:
            if a.split("=")[0] in noncreate:
                return False
        # 비옵션 인자(브랜치명)가 하나라도 있으면 생성.
        return any(not a.startswith("-") for a in rest)
    return False

creates = any(is_new_branch_create(s) for s in segments)
if not creates:
    sys.exit(0)

# 신규 브랜치 생성 명령. CLAUDE.md 마커 검사.
claude_md = os.environ.get("CLAUDE_MD_PATH", "./CLAUDE.md")

# 안전판: CLAUDE.md 자체가 없으면 통과.
#   이유 — 이 hook 은 전역(모든 프로젝트) 설정이다. 스킬로 관리하지 않는
#   서드파티 repo·비-repo 디렉토리·스크래치 폴더에서 마커를 요구하면 정상
#   브랜치 작업이 전부 막힌다. CLAUDE.md 존재 = "이 repo 는 관리 대상" 신호로
#   보고, 없으면 게이트를 걸지 않는다.
if not os.path.isfile(claude_md):
    sys.exit(0)

# 마커 라인(`현재 워크플로:`) 존재 여부. SKILL.md 의 "기계 판독 대상은
# `현재 워크플로: <id>` 라인 하나" 규율과 일치.
#
# `@경로` import 를 한 단계 따라간다 — Claude Code 는 CLAUDE.md 가 `@AGENTS.md`
# 한 줄로 본문을 위임하는 형태를 지원하고, 그때 마커는 피대상 파일에 있다.
# 안 따라가면 정상 설정된 repo 를 차단한다(실측: vector-graph-ontology 는
# CLAUDE.md 가 `@AGENTS.md` 뿐이고 마커는 AGENTS.md 에 있어 오탐 차단됨).
def _read(path):
    try:
        with open(path, "r", encoding="utf-8", errors="replace") as f:
            return f.read()
    except OSError:
        return None

text = _read(claude_md)
if text is None:
    sys.exit(0)  # 읽기 실패 시 정상 작업 우선

if "현재 워크플로:" not in text:
    base = os.path.dirname(os.path.abspath(claude_md))
    for line in text.splitlines():
        line = line.strip()
        if not line.startswith("@") or len(line) < 2:
            continue
        target = os.path.expanduser(line[1:].strip())
        if not os.path.isabs(target):
            target = os.path.join(base, target)
        imported = _read(target)
        if imported and "현재 워크플로:" in imported:
            sys.exit(0)

if "현재 워크플로:" in text:
    sys.exit(0)

sys.stderr.write(
    "[git-workflow-gate] 차단: 이 repo 에 `## Git Workflow` 마커가 없다.\n"
    "브랜치 생성 전 `git-workflow-select` 스킬로 워크플로를 선택·기록하라.\n"
    "(CLAUDE.md 에 `현재 워크플로: <id>` 라인이 있어야 통과)\n"
)
sys.exit(2)
PYEOF
