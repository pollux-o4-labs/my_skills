---
name: AIL-machine-knowable-rots
description: "Keeps comments and docs free of facts a tool recomputes — call-site claims, counts, current values, and line numbers go false silently while grep, tests, and version control answer them in a second. Use when writing or reviewing a comment or doc that asserts what code elsewhere currently does, or when a decision cites a comment as its premise."
version: 1.0.0
metadata:
  provenance: AIL
---

# Machine-Knowable Rots

A statement a tool can recompute has an expiry date and no alarm. Whoever invalidates it is editing a different file and never sees it — distance, not diligence, is the mechanism. Meanwhile the false line keeps reading as authoritative, and decisions get built on it.

## When to Use

- About to write a fact another file determines: "nothing calls this yet", "N callers", "default is 8" (defined elsewhere), `path:58`.
- Reviewing a comment or doc that asserts the current state of code outside its own file.
- A decision doc cites a comment as a premise — re-derive it from the tool.
- Writing metadata that duplicates version control (adoption date, "added in v2").

**Do NOT use when** the artifact's purpose IS to snapshot state (generated indexes, lockfiles, changelogs, benchmark records); the fact is a live constraint no tool expresses ("don't reorder — init order dependency"); or the claim is about the file's own content (a summary of its own document doesn't rot).

**Explicit user override**: if the user wants the fact inlined anyway, comply and note once that nothing will flag it when it goes false.

## Procedure

1. **Ask the discriminator**: can grep, a test, a type checker, or `git log` answer this? If yes, don't write it — the tool is canonical and always current.
2. **Keep the why, drop the what.** "Downgraded because a flipped direction is a grounded hallucination" survives any refactor; "this function has no callers yet" dies on the next commit.
3. **Point with coordinates that fail loudly.** Use a symbol name or a commit-pinned path (`git show <SHA>:<path>`) — both fail to resolve when wrong. A line number silently resolves to the wrong place on another branch.
4. **Re-derive premises.** A comment is a claim, not evidence. Before a decision rests on one, run the tool.
5. **Audit an existing artifact** by grepping its rot signatures: counts ("both", "all three"), call-site claims ("not used", "only X calls"), `file:NN`, dates version control holds, and "planned / not built yet" notes. Each hit: delete it, or convert it to a why.
6. **Deleting is silent.** Don't leave "the date lives in git now" behind — nobody asks where a thing that isn't there went. That line is talk for your reviewer, not the next reader.

## Example

```python
# BAD — grep answers this. False 36 minutes later; premise of a decision doc 5 days on.
def materialize_sections(...):
    """... (nothing calls this yet — wiring lands in increment 2b)"""

# GOOD — no tool can show this. Survives until the decision itself changes.
def materialize_sections(...):
    """... Reuses the entities already stored: re-extracting them would defeat
    the point of deferring, and would cost entity recall."""
```

## Pitfalls

- **"I'll keep it updated"** — you will not be present. The invalidator never opens your file.
- **Speculative status** — "gate not built yet" flips false the day it ships, silently, and helps no reader meanwhile.
- **Counts that grow** — "both rules", "all three articles" break when a fourth arrives.
- **Trusting a comment as a premise** — the decision inherits the comment's expiry, and review rarely re-derives it.

## Verification

- [ ] Does every retained statement answer "why", not "what / where / how many"?
- [ ] Would a wrong pointer fail to resolve rather than land somewhere plausible?
- [ ] Was each decision premise re-derived from a tool rather than read off a comment?

---
*Origin: a docstring claiming "nothing calls this yet" went false 36 minutes later when its own author wired the caller; five days on it was the load-bearing premise of a decision doc that passed adversarial review (2026-07).*
