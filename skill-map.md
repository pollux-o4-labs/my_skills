# Skill map

This is a human-facing catalog of the canonical skills. It describes grouping and coverage; it is not an automatic router or an additional source of principles.

## Cross-cutting skills

| Skill | Coverage |
|---|---|
| [`agent-orchestration-principles`](./agent-orchestration-principles/SKILL.md) | Agent teams, delegation, supervision, and parallel work |
| [`documentation-principles`](./documentation-principles/SKILL.md) | Documentation, handoffs, rules, decisions, and responses |
| [`engineering-principles`](./engineering-principles/SKILL.md) | General software design, implementation, and refactoring |
| [`git-workflow-principles`](./git-workflow-principles/SKILL.md) | Branches, worktrees, review, merging, and integration |
| [`research-principles`](./research-principles/SKILL.md) | Balanced research principles and disciplinary lenses |
| [`resource-principles`](./resource-principles/SKILL.md) | AI cost, context, scale, and parallel work |
| [`skill-authoring-principles`](./skill-authoring-principles/SKILL.md) | Skill creation, refactoring, and reuse |
| [`verification-principles`](./verification-principles/SKILL.md) | Testing, verification, reproducibility, and runtime checks |

## Product and software domains

| Group skill | Included perspectives |
|---|---|
| [`computer-science--product--product-experience`](./computer-science--product--product-experience/SKILL.md) | Product Discovery, Product Design, UX Design, Design Systems, Content Design, Product Management |
| [`computer-science--application--application-engineering`](./computer-science--application--application-engineering/SKILL.md) | Frontend, Backend, API Design, Software Architecture |
| [`computer-science--foundations--computing-data-and-intelligence`](./computer-science--foundations--computing-data-and-intelligence/SKILL.md) | Computing Fundamentals, Data Structures and Algorithms, Database Engineering, Product Analytics, AI and ML Engineering |
| [`computer-science--platform--systems-and-delivery`](./computer-science--platform--systems-and-delivery/SKILL.md) | System Design, Mobile Development, Network Engineering, DevOps and SRE |
| [`computer-science--quality--quality-and-security`](./computer-science--quality--quality-and-security/SKILL.md) | Quality Engineering and Application Security |
| [`computer-science--communication--technical-ecosystem`](./computer-science--communication--technical-ecosystem/SKILL.md) | Technical Writing and Developer Relations |

## Business domains

| Group skill | Included perspectives |
|---|---|
| [`business--growth--growth-and-revenue`](./business--growth--growth-and-revenue/SKILL.md) | Growth Marketing, Sales and Monetization, Customer Success |
| [`business--operations--business-operations-and-governance`](./business--operations--business-operations-and-governance/SKILL.md) | Privacy and Legal, Finance and Operations |

## Naming convention

```text
{domain}--{subdomain}--{focus}/SKILL.md
```

- A single hyphen separates words within a term.
- A double hyphen separates taxonomy segments.
- The segments are ordered from broad domain to specific focus.
- This map records the current grouping; it does not require every roadmap node to become a skill.

## Maintenance rules

- Keep principles and behavior instructions in the linked `SKILL.md`, not here.
- Add a new group only when its evaluation criteria and activation scope are materially different.
- Absorb narrow skills into an existing group when they share the same work surface and judgment criteria.
- Keep technology-specific roadmaps such as languages, frameworks, and vendors as examples or adapters rather than automatic skill domains.

Legacy and absorbed skills are preserved under [`_legacy/`](./_legacy/).
