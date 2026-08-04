#!/usr/bin/env python3
"""gate_config.py — my_skills 저장소용 게이트 특화 설정"""
from __future__ import annotations

# my_skills 전용 게이트 커스텀 설정
DISABLED_GATES: tuple[str, ...] = ()

# 예산 면제 문서 (실측 기록 및 대용량 레퍼런스 문서 면제)
EXTRA_WHITELIST: tuple[str, ...] = (
    "docs/history/README.md",
    "skills-overview.html",
)
