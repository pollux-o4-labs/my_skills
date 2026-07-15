---
name: AIL-bluf-is-a-label
description: "A document's summary line (BLUF, ADR abstract, rule preamble, index entry) states only what topic the document is about — evidence, numbers, and prescriptions belong in the body, never the summary line. Use when writing or reviewing a BLUF/abstract/one-line summary, or when a rollup index (ADR index, rules index, handoff index) is getting long or hard to scan."
version: 1.0.0
metadata:
  provenance: AIL
---

# BLUF Is a Label

A summary line is read at decision time, before the reader commits to opening the body — its only job is to let the reader route ("is this the document I need?"). A rollup index (ADR index, rules index) is built by concatenating these lines, so the index inherits whatever the line costs. A label does that job in one sentence. A line that also carries the evidence, the number, or the prescription is doing the body's job twice — once in the summary, once in the body — and the two copies drift the moment only one gets edited.

## When to Use

- Writing or reviewing a BLUF, ADR abstract, rule preamble, or any one-line summary that rolls up into a parent index.
- A rollup index is getting long or hard to scan, or a diff shows a summary line growing across revisions.
- About to fold a body's evidence, a measured number, or an obligation into its own summary line "for completeness."

**Do NOT use for** the body of the document — that is exactly where evidence, numbers, and prescriptions belong. Also skip for short single-purpose docs with no parent index rolling them up; the label-vs-report distinction only bites where a summary is read separately from, and aggregated apart from, its body.

## Procedure

1. Write the line as a topic label — "this document is about X." If the line already tells the reader what to do, what was measured, or why to believe it, it has stopped being a label.
2. Route everything else to where it belongs: evidence and measurements → a rationale section in the body; obligations → the rule/decision section; history of what changed → the commit message or an ADR, never the live summary (see `AIL-correct-is-silent`).
3. Budget check: one plain sentence. A second clause, an "and," or an embedded number is the tell that body content leaked upward — cut it back to the topic.
4. When several documents describe the same underlying fact (a threshold, a decision), the summary line doesn't quote it — it points to the one document that owns it. That's a duplication concern, not a length concern; `write-a-rule`'s "one rule, one home" already covers it, so don't restate that principle here.
5. If the index itself is unwieldy even with thin lines, that's a corpus-organization problem, not a compression problem — see `AIL-handoff-topic-index` for splitting a growing index by topic.

## Pitfalls

- **Summary-as-mini-report** — packing in the measured numbers "for evidence" turns the index into a second body; the moment the real body changes, the two copies disagree.
- **Length creep across revisions** — each edit adds one more clause "for completeness," and without a one-sentence budget there's no natural place to stop; summaries in a document corpus can drift many times their original length this way.
- **Confusing "thin" with "silent about why"** — the label still names the topic; it just doesn't carry the argument or the numbers behind it. Trim the *what was measured*, not the *what this is about*.

## Verification

- [ ] Is the line one plain sentence, with no embedded number, measurement, or instruction?
- [ ] Does the body — not the summary — carry the evidence and the obligation?
- [ ] If another document states the same fact, does this line point to it instead of restating it?

## Example

Before: "This ADR adopts a 15-message rotation cap because agent sessions were hitting context limits at the old cap and dropping fixes mid-task (incident logged 2026-07-10)."

After (summary): "Rotation cap for long-running agent sessions." The number, the incident, and the decision move to the body's rationale and decision sections, where they can be updated without touching the line the index displays.

---
*Origin: promoted from a project rule requiring summary lines to state topic only, after a decision-record index drifted from short single-clause summaries toward summaries several times longer as authors folded in evidence and prescriptions.*
