#!/usr/bin/env python3
"""Measures one skill against the caps in authoring-standards.md.

"Open the standard and measure against it" is an instruction an agent can skip with
nobody the wiser -- the same soft wording the caps exist to replace. This makes the
measurement a command with an exit code, so skipping it is visible.

Usage:  measure_skill.py <skill-dir | SKILL.md>
Exit:   0 within caps (targets may warn), 1 over a cap.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

from caps import STANDARD, Cap, fail_line, load_caps

FRONTMATTER = re.compile(r"\A---\r?\n(?P<yaml>.*?)\r?\n---\r?\n?(?P<body>.*)\Z", re.S)
DESCRIPTION = re.compile(r"^description:\s*(?P<value>.+?)\s*$", re.M)
SECTION = re.compile(r"^##\s+(?P<name>.+?)\s*$", re.M)
TOP_LEVEL_ITEM = re.compile(r"^(?:[-*]|\d+\.)\s+\S", re.M)
ORIGIN_LINE = re.compile(r"^\*+Origin\b", re.I | re.M)
HANGUL = re.compile(r"[가-힣]")


class Skill:
    def __init__(self, path: Path) -> None:
        self.path = path
        raw = path.read_text(encoding="utf-8")
        match = FRONTMATTER.match(raw)
        if not match:
            raise SystemExit(f"{path}: no frontmatter -- cannot tell body from metadata")
        self.yaml, self.body = match["yaml"], match["body"]

    def description_chars(self) -> int:
        found = DESCRIPTION.search(self.yaml)
        if not found:
            raise SystemExit(f"{self.path}: no 'description:' in frontmatter")
        value = found["value"]
        if value[:1] in {'"', "'"} and value[-1:] == value[:1]:
            value = value[1:-1]
        return len(value)

    def body_words(self) -> int:
        return len(self.body.split())

    def verification_items(self) -> int:
        return len(TOP_LEVEL_ITEM.findall(self._section("Verification")))

    def origin_lines(self) -> int:
        lines = self.body.splitlines()
        for i, line in enumerate(lines):
            if ORIGIN_LINE.match(line):
                block = 0
                for rest in lines[i:]:
                    if not rest.strip():
                        break
                    block += 1
                return block
        return 0

    def _section(self, name: str) -> str:
        for found in SECTION.finditer(self.body):
            if found["name"].lower() != name.lower():
                continue
            rest = self.body[found.end():]
            nxt = SECTION.search(rest)
            return rest[: nxt.start()] if nxt else rest
        return ""

    def is_korean(self) -> bool:
        return bool(HANGUL.search(self.body))


# Keyed by the metric names the standard itself writes. An unmapped metric is a hard
# error rather than a skip: silently not measuring a cap is how a gate goes hollow.
MEASURERS = {
    "description": ("chars", Skill.description_chars),
    "body": ("words", Skill.body_words),
    "verification": ("items", Skill.verification_items),
    "origin/provenance": ("lines", Skill.origin_lines),
}


def resolve(arg: str) -> Path:
    path = Path(arg)
    if path.is_dir():
        path = path / "SKILL.md"
    if not path.is_file():
        raise SystemExit(f"{arg}: no SKILL.md here")
    return path


def main(argv: list[str]) -> int:
    if len(argv) != 2:
        raise SystemExit(__doc__)

    path = resolve(argv[1])
    skill = Skill(path)
    caps = load_caps()

    unknown = {c.metric for c in caps if c.metric.lower() not in MEASURERS}
    if unknown:
        raise SystemExit(
            f"{STANDARD.name} caps a metric this script cannot measure: {', '.join(sorted(unknown))}. "
            "Teach measure_skill.py the measurement rather than dropping the cap.",
        )

    print(f"{path}")
    if skill.is_korean():
        print("  note: Hangul in body; the standard calibrates word budgets on English "
              "(Korean ≈ half). Judge the body count by hand.")

    over = False
    for metric in dict.fromkeys(c.metric for c in caps):
        unit, measure = MEASURERS[metric.lower()]
        value = measure(skill)
        hard = fail_line(caps, metric)
        assert hard is not None
        soft = sorted({c.value for c in caps if c.metric == metric and c.value < hard.value})

        if value > hard.value:
            over = True
            verdict = f"OVER by {value - hard.value} -- needs split/compress review"
        elif soft and value > soft[-1]:
            verdict = f"over target {soft[-1]}, within {hard.value}"
        else:
            verdict = "ok"
        print(f"  {metric:<18} {value:>5} {unit:<6} (cap {hard.value}) {verdict}")

    return 1 if over else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
