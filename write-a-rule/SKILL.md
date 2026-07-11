---
name: write-a-rule
description: "Authoring standard for repository operational rules and agent policy documents — deontic wording, article-style structure, exception marking, and instruction-creep control. Use when writing or revising repo rules (docs/rules, CLAUDE.md norm sections, agent guidelines), or when rule docs show mixed obligation levels, ad-hoc exceptions, or unchecked growth."
version: 1.0.0
metadata:
  platforms: [claude-code, codex, gemini-cli]
---

# Write a Rule

Rules are read by agents under load: every ambiguity about *who must do what, when, unless what* becomes a misfire. This skill encodes two proven systems — statute drafting (deontic precision) and wiki guideline design (creep control) — into a repo-rule authoring standard.

## Namespace: pick the tone before writing

- **Policy documents** (rules, gates, mandates): imperative, deontic wording from the table below.
- **Knowledge/guide documents** (explanations, how-tos, records): declarative statements; no bare imperatives.
- Never mix in one document. A guide that needs a mandate links to the rule; a rule that needs background links to the guide.
- Agent-facing instruction docs (skills, prompts, procedures) are imperative by design — this split governs repo documents, not the instruction genre itself.

## Deontic vocabulary — one clause, one modality

| Modality | English | Korean legal form |
|---|---|---|
| Obligation | must | ~해야 한다 |
| Prohibition | must not | ~해서는 아니 된다 / 금지 |
| Permission | may | ~할 수 있다 |

Connectors — not modalities; each carries its own modality inside:

| Connector | English | Korean legal form |
|---|---|---|
| Exception (proviso) | provided that / unless | 다만, ~ |
| Sequel (follow-up step) | in that case | 이 경우, ~ |

- Do not bury a prohibition inside a permission sentence, or an obligation inside background prose.
- Every exception is a proviso ("다만, ~") attached to the clause it overrides — not a parenthesis, footnote, or trailing dash.
- A conditional follow-up action is a sequel ("이 경우, ~"), a distinct sentence after its trigger clause.

## Structure — light article hierarchy

- One rule = one numbered article with a title, written in complete sentences.
- Conditions and enumerable cases go in numbered noun-phrase lists — the governing sentence above the list carries the modality; items end in a noun or "~할 것", never a full sentence.
- Nesting depth ≤2 (article → items). Needing a third level means the rule does too much; split it.
- Metadata per rule file: status, date, and a grounds backreference (the incident, ADR, or decision that created it). Register every rule file as one line in the rules index.

## Creep control

- **Principle first, discretion second.** State the principle and trust judgment for edge cases. Add a micro-clause only after a real incident, and cite that incident as grounds.
- **Structural backstop beats prose.** If a validator, test, or hook can enforce the rule, build the check and shrink the prose to one line pointing at it.
- **Split at ~800 words** (summary style): parent file keeps the principle plus a one-line index of children; details move to child files.
- **One rule, one home.** Never restate a rule's body in a second document; link to it. Every duplicate is a future sync failure.

## Procedure

1. Classify the document: policy or knowledge. Set the tone accordingly.
2. Draft each clause at exactly one modality from the table; mark exceptions as provisos and follow-ups as sequels.
3. Run the creep check: is each micro-clause incident-backed? Can code enforce it instead? Is the file under budget?
4. Fill metadata (status/date/grounds) and add the index line.
5. Reread as the constrained agent: for each clause, can you answer "must, may, or must not — and unless what?" without guessing.

## Pitfalls

- **Modality soup** — 필수/권장/가능 mixed in one paragraph, so the reader cannot rank clauses.
- **Parenthetical exceptions** — "(self는 면제)" style asides that hide an override where scanners skip.
- **Prophylactic clauses** — rules against imagined failures; wait for the incident (quick fail, quick win).
- **Restating instead of linking** — copying a rule into CLAUDE.md "for visibility" creates a drifting second source.

## Verification

- [ ] Every normative clause carries exactly one modality, with provisos/sequels used as connectors, not as levels?
- [ ] Every exception is a proviso attached to its clause, every follow-up a sequel?
- [ ] Each micro-clause cites its incident, or was replaced by a code check?
- [ ] File within word budget, metadata and index line present, no body duplicated elsewhere?

## Example

Before (modality soup + hidden exception):

> 백업은 중요하므로 가급적 작업 전에 만들고, 파괴적 작업(단, self 제외)은 주의한다.

After (one level per clause, proviso and sequel explicit):

> 파괴적 작업 전에는 백업을 만들어야 한다. 다만, self 대상 작업은 예외로 한다. 이 경우, 실행 로그를 남겨야 한다.
