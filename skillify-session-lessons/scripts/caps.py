"""Reads the authoring caps out of authoring-standards.md.

Lives next to the standard because a cap copied into a script is the same rot the
duplication gate exists to catch: the standard would move and the copy would keep
judging by the old number, silently. Both gates import this; neither knows a number.
"""

from __future__ import annotations

import re
import sys
from dataclasses import dataclass
from pathlib import Path

STANDARD = Path(__file__).resolve().parent.parent / "authoring-standards.md"

# The standard spells small counts as English words ("one line"). Those are read for
# measuring but cannot be grepped as numbers, so each cap records which form it wore.
_WORD_NUMERALS = {
    "one": 1, "two": 2, "three": 3, "four": 4, "five": 5,
    "six": 6, "seven": 7, "eight": 8, "nine": 9, "ten": 10,
}

_BUDGETS_HEADING = re.compile(r"^##\s+Budgets\b", re.M)
_NEXT_HEADING = re.compile(r"^##\s+", re.M)
_BULLET = re.compile(r"^-\s+\*\*(?P<metric>[^*]+)\*\*:\s*(?P<text>.*)$", re.M)

# A cap is written as a bound ("≤N unit") or an escalation ("past N → review"). Bare
# numbers in the same bullet are prose (dates, probe counts) and must not be read as
# caps -- the bound marker is what makes the intent machine-visible.
_DIGIT_CAP = re.compile(r"(?:≤|<=|past)\s*(?P<value>\d[\d,]*)\s*(?P<unit>[A-Za-z]+)?")
_WORD_CAP = re.compile(
    r"(?:≤|<=|past)?\s*\b(?P<value>" + "|".join(_WORD_NUMERALS) + r")\s+(?P<unit>[A-Za-z]+)",
    re.I,
)


@dataclass(frozen=True)
class Cap:
    metric: str
    value: int
    unit: str | None
    spelled: bool  # written as an English word, so it is unsearchable as a number


def _budgets_block(text: str) -> str:
    start = _BUDGETS_HEADING.search(text)
    if not start:
        raise SystemExit(f"{STANDARD}: no '## Budgets' section -- caps unreadable, refusing to guess")
    rest = text[start.end():]
    end = _NEXT_HEADING.search(rest)
    return rest[: end.start()] if end else rest


def load_caps(standard: Path = STANDARD) -> list[Cap]:
    caps: list[Cap] = []
    for bullet in _BULLET.finditer(_budgets_block(standard.read_text(encoding="utf-8"))):
        metric, text = bullet["metric"], bullet["text"]
        found = [
            Cap(metric, int(m["value"].replace(",", "")), (m["unit"] or "").lower() or None, False)
            for m in _DIGIT_CAP.finditer(text)
        ]
        if not found:
            found = [
                Cap(metric, _WORD_NUMERALS[m["value"].lower()], m["unit"].lower(), True)
                for m in _WORD_CAP.finditer(text)
            ]
        caps.extend(found)
    if not caps:
        raise SystemExit(f"{STANDARD}: '## Budgets' parsed to zero caps -- refusing to pass vacuously")
    return caps


def fail_line(caps: list[Cap], metric: str) -> Cap | None:
    """The largest cap on a metric is the one that fails.

    The standard can state a soft target and a higher escalation for the same metric.
    Reading the lower one as the failure would convict drafts the standard only asks
    to aim below -- the exact mistake skill-refactor lists as a Pitfall.
    """
    owned = [c for c in caps if c.metric == metric]
    return max(owned, key=lambda c: c.value) if owned else None


if __name__ == "__main__":
    for cap in load_caps():
        unit = cap.unit or "?"
        print(f"{cap.metric}: {cap.value} {unit}{' (spelled)' if cap.spelled else ''}", file=sys.stdout)
