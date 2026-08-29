---
name: AIL-no-proxy-verdict
description: "Blocks recording a cheap stand-in check as the verdict for the criterion it replaced, and stops automated gates from silently passing inputs they cannot decide. Use when marking items on a rubric, checklist, or acceptance criteria, when writing or trusting an automated gate, or before recording any item as passed."
version: 1.0.0
metadata:
  provenance: AIL
---

# No Proxy Verdict

A **pass** must be the result of checking the thing. When the real check is expensive, the tempting move is a cheap stand-in — a pattern search for a linguistic rule, a source scan for a rendered-output rule — filed under the original criterion. The record then reads "verified" where nothing was, and a rubber stamp is *harder* to distrust than no check at all.

## When to Use

- Marking items on a rubric, checklist, review template, or acceptance criteria.
- Writing an automated gate (lint, CI check, validator), or relying on its pass.
- Reviewing a checklist someone else — including a subagent — reported as passed.

**Do NOT use** to reject proxies as such: one that provably covers its criterion is fine, and cheap gates are how breadth becomes affordable. The rule is about *labeling* — a proxy result may never be recorded under a criterion it only approximates. For "my measurement or environment may be lying", use `AIL-verify-against-reality`; for how deep to check an inferred claim, `AIL-calibrate-verification-depth`.

## Procedure

1. **Name the check you actually ran, beside the criterion.** Not "verified" — *how*. A criterion whose evidence line is a different kind of check than the criterion demands is itself the defect.
2. **Probe the proxy for structural blind spots before trusting it.** Ask what the criterion covers that the proxy *cannot express*, construct one instance in that gap, and confirm the proxy misses it. A pattern matching one grammatical form cannot certify a rule about all forms; a scan of source cannot certify a claim about rendered output.
3. **Blind spot found → record the item as unverified**, not passed-with-caveat. Then either run the real check or hand the gap to a layer that can decide it.
4. **Split criteria by who can decide them.** Mechanically decidable ones (values, pairings, structural rules) get automated **and wired into the build**, so a fix cannot silently regress. Ones needing meaning, fact, or context get exercised directly against the source of truth. Run the mechanical layer **first** — it shrinks the surface the expensive layer must cover.
5. **Make gates declare their silence.** A gate counts and reports the inputs it could not decide, and its pass message states its scope. Undecidable inputs go to the judging layer; they are never absorbed into a pass.

> Example: a rubric said "verify in both themes". The reviewer substituted "search the stylesheet for hardcoded colors", found none, and marked the item passed. Actually rendering both themes later measured real contrast failures in those same files. Separately, the contrast gate built to catch exactly that skipped translucent backgrounds it could not composite and printed an unqualified pass — concealing a failure it existed to find.

## Pitfalls

- **"The search returned 0" as proof.** Zero hits proves the pattern matched nothing, not that the property holds.
- **Scanning source to certify output.** Claims about rendered or observed behavior require observation.
- **Checking the list, not the members.** Names and order matching the canonical list says nothing about whether each entry satisfies its own definition.
- **A gate that only ever passes.** Inject a known violation; if it stays green, it is decorative.
- **Silence read as coverage.** Undecided-but-quiet survives review precisely because it looks like a pass.
- **Explicit user override.** If the user knowingly accepts a proxy for cost, comply — and record that item as proxy-verified in one line rather than as passed.

## Verification

- [ ] Does every passed item name the check that produced it?
- [ ] For each proxy, did I construct a blind-spot instance and observe whether it misses?
- [ ] Are blind-spot items recorded as unverified rather than passed?
- [ ] Does each gate report an undecided count and state its scope in its pass message?
- [ ] Did a deliberately injected violation actually fail the gate?

---
*Origin: re-reviewing six artifacts previously signed off as "no changes needed" — all six carried defects, because the sign-offs had swapped rendered-output and linguistic criteria for source searches, and a new automated gate built in the same session silently passed the inputs it could not compute.*
