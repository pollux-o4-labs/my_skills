#!/usr/bin/env python3
"""Fails when a cap from authoring-standards.md is written in too many .md files.

A cap that lives in many documents does not stay one cap: the standard moves and the
copies keep judging by the old number, with nobody reading the copies to notice. The
reviewer agents drifted this way -- a human sees only their verdict, never their source.

Two homes are allowed, not one: skill-refactor/RATIONALE.md opens by saying its purpose
is to make future edits argue against a source instead of a bare number. A rationale that
cannot state the value cannot catch the standard contradicting its own grounds.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

from caps import STANDARD, load_caps

REPO = STANDARD.parent.parent
MAX_HOMES = 2  # the standard + the rationale that must quote it to argue with it

# History records what was true on a date; a cap frozen there is evidence, not a copy to
# keep in sync. Rendered/vendored trees are not authored here.
SKIP_DIRS = {".git", "node_modules", "docs/history"}


def _number_pattern(value: int) -> str:
    """Thousands separators are a writing choice, so a copy is a copy either spelling."""
    grouped = f"{value:,}".replace(",", ",?")
    return f"(?:{grouped})" if grouped != str(value) else str(value)


# What separates a cap from an unrelated number is the claim of a bound, not the unit:
# real copies wrote "(≤400)" and "Verification ≤6" with the unit nowhere near the digits,
# and keying on the unit walked straight past them. Either signal counts.
_BOUND = r"(?:≤|<=|max\.?\s*|at most\s*|no more than\s*|past\s*|under\s*)"


def _search_pattern(unit: str | None, value: int) -> re.Pattern[str]:
    number = _number_pattern(value)
    alternatives = [rf"{_BOUND}{number}\b"]
    if unit is None:
        # The standard gives no unit, so the bare number has to carry the meaning alone.
        alternatives.append(rf"\b{number}\b")
    else:
        # Stem-matching lets a copy say chars/characters and still be counted.
        alternatives.append(rf"\b{number}\b[\s-]*{re.escape(unit.rstrip('s'))}")
    return re.compile("|".join(alternatives), re.I)


def _markdown_files() -> list[Path]:
    out = []
    for path in sorted(REPO.rglob("*.md")):
        rel = path.relative_to(REPO).as_posix()
        if any(rel == d or rel.startswith(f"{d}/") for d in SKIP_DIRS):
            continue
        out.append(path)
    return out


def main() -> int:
    caps = load_caps()
    files = _markdown_files()
    failed = False

    for cap in caps:
        if cap.spelled:
            # Written as an English word, so there is no number to have copied.
            continue
        pattern = _search_pattern(cap.unit, cap.value)
        homes = [f for f in files if pattern.search(f.read_text(encoding="utf-8"))]
        label = f"{cap.metric} = {cap.value} {cap.unit or ''}".strip()

        if len(homes) > MAX_HOMES:
            failed = True
            print(f"FAIL  {label}: in {len(homes)} .md files (max {MAX_HOMES})")
            for home in homes:
                rel = home.relative_to(REPO).as_posix()
                role = "standard" if home == STANDARD else "copy"
                print(f"        {rel}  [{role}]")
        else:
            print(f"ok    {label}: {len(homes)} .md file(s)")

    if failed:
        print(
            "\nEach copy re-states a number the standard owns. Point at "
            f"{STANDARD.relative_to(REPO).as_posix()} instead, or measure with "
            "scripts/measure_skill.py.",
        )
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
