# worktree-cleanup-gate

`gh pr merge` 직후 워크트리 정리를 감독에게 소환하는 PostToolUse(Bash) 훅. 판정도 삭제도 하지 않고 한 줄만 주입한다 — 어느 워크트리가 끝났는지는 방금 머지한 감독이 안다.

훅은 자동 발화하므로 스킬 문서가 이것을 설명할 필요가 없다(SKILL.md 에 없는 이유).

## 등록

`~/.claude/settings.json` → `hooks.PostToolUse` (상세는 `update-config`):

```json
{ "matcher": "Bash",
  "hooks": [{ "type": "command",
    "command": "bash \"<repo>/AIL-worktree-parallel-guard/hooks/worktree-cleanup-gate.sh\"",
    "timeout": 10 }] }
```

settings.json 이 레포 스크립트를 직접 참조한다 — 사본 drift 방지. 반영은 `/hooks` 또는 재시작.

전역 등록이라 모든 repo 에서 발화한다. 주입 문구는 특정 repo 의 규칙·경로를 인용하지 않는다.

## 근거

[docs/history/B-worktree-cleanup-gate.md](../../docs/history/B-worktree-cleanup-gate.md)
