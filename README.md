# my_skills

Claude Code, Codex, agy에서 사용하는 도메인 원칙 기반 스킬 모음이다.

## 규격

스킬은 `SKILL.md` 하나를 진입점으로 사용한다.

```md
---
name: skill-name
description: Apply {domain} principles. Use when work involves {triggers — include task scope only when it disambiguates}. Select and combine suitable approaches, then review {review targets} against those principles.
---

# Apply {domain} principles

{Canonical principles for this domain.}

# Scope

- {Concrete task, artifact, or decision area.}
```

기본 템플릿은 [`templates/domain-principles-template/SKILL.md`](templates/domain-principles-template/SKILL.md)다.

## 정본 스킬

전체 구조와 범위는 [`skill-map.md`](./skill-map.md)에서 확인한다.

기존 스킬과 병합된 세부 스킬은 [`_legacy/`](./_legacy/)에 보존한다. 변경 이력은 Git으로 확인한다.

`research-principles`는 실제 연구에 적용하는 공통 원칙과 대표적인 학문별 관점을 함께 둔다. 이 안의 도메인 범주는 앞으로 어떤 전용 스킬을 만들지 판단할 때 우리끼리 참고하는 기준이며, 별도의 도메인 지도나 자동 분기 규칙으로 관리하지 않는다.

## 동기화

```bash
bash sync-skills/sync-skills.sh --dry-run
bash sync-skills/sync-skills.sh --all-skills
```

현재 정본 스킬은 `sync-skills/custom-skills.txt`에서 제외해 비등록 상태로 둔다. 개인 허브 `~/.agents/custom-skills`가 선택된 스킬을 Claude, Codex, agy에 배포한다. `templates/`와 `_legacy/`는 동기화 대상이 아니다.

agy의 공식 전역 스킬 경로는 `~/.gemini/config/skills`다. `~/.gemini/antigravity-cli`는 런타임 상태 경로이므로 동기화하지 않는다.
