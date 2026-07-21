---
name: AIL-bluf-is-a-label
description: "A document's summary line (BLUF, ADR abstract, rule preamble, index entry) states only its topic — evidence, numbers, and prescriptions belong in the body, never the summary line. Use when writing or reviewing a one-line summary, or when a rollup index (ADR/rules/handoff) grows long or hard to scan."
version: 1.1.0
metadata:
  provenance: AIL
---

# BLUF Is a Label

A summary line — BLUF (bottom line up front), ADR abstract, index entry — is read at decision time to route ("is this the document I need?"), then aggregated into a parent index. Keep it a label that names the topic. The moment it also carries the evidence, the number, or the prescription, that content now lives in two places — line and body — and the two copies drift the instant only one is edited.

## When to Use

- Writing or reviewing a BLUF, ADR abstract, rule preamble, or any one-line summary that rolls up into a parent index.
- A rollup index is getting long or hard to scan, or a diff shows a summary line growing across revisions.

**Do NOT use for** the body — that is exactly where evidence, numbers, and prescriptions belong. Skip short single-purpose docs with no parent index rolling them up; the label-vs-report distinction only bites where a summary is read and aggregated apart from its body.

**Explicit user override**: if the user knowingly wants the number or evidence in the summary line, comply and note once that the body remains the durable home — a one-line transparency delta, not a refusal.

## Procedure

1. Write the line as a topic label — "this document is about X." If it tells the reader what to do, what was measured, or why to believe it, it has stopped being a label.
2. Route the rest to its home: evidence and measurements → a rationale section in the body; obligations → the rule/decision section; history of what changed → the commit or ADR, never the live summary (see `AIL-correct-is-silent`).
3. Budget: one short topic label, a phrase not a full report. **Handoff index lines are owned end-to-end by `AIL-handoff-topic-index`** — including progress markers folded into its description field (e.g. "P1–P3 done, Phase 4 next") — this rule does not apply to them. Everywhere else (ADR abstracts, rule preambles), the tell that body content leaked upward is a second *independent clause* or an embedded number/measurement/instruction; a conjoined noun phrase ("cap and retry policy") is fine.
4. **When several documents state the same fact** (a threshold, a decision), don't quote it in the line — point the line at the one document that owns it.
5. **If the index is still unwieldy with thin lines**, that is a corpus-organization problem, not a compression one — split it by topic (see `AIL-handoff-topic-index`).

## Pitfalls

- **Summary-as-mini-report** — packing in the measured numbers "for evidence" turns the index into a second body; when the real body changes, the two copies disagree.
- **Length creep across revisions** — each edit adds one more clause "for completeness," and without the label budget there is no natural place to stop.
- **Confusing "thin" with "silent about why"** — the label still names the topic; it just drops the argument and the numbers behind it. Trim the *what was measured*, not the *what this is about*.

## Verification

- [ ] Label test: if the body were deleted, would this line still route the reader correctly — carrying no number, measurement, or instruction that only ever lived in the line?

## Example

Before: "This ADR adopts a 15-message rotation cap because agent sessions were hitting context limits at the old cap and dropping fixes mid-task (incident logged 2026-07-10)."

After (summary): "Rotation cap for long-running agent sessions." The number, the incident, and the decision move to the body's rationale and decision sections, where they can change without touching the line the index displays.

---
*Origin: a decision-record index drifted from short single-clause summaries toward summaries several times longer as authors folded evidence and prescriptions into the summary lines.*
