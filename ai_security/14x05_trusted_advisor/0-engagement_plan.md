# 0 — Engagement Plan: Cascadia Health Systems patient-support agent

## 1. What I am assessing
Cascadia's application of the model — the routes, tools, trust boundaries and the
rules Cascadia built around it — not Gemini's own safety training. The engagement
is anchored to **the six findings the prior "post-scare" assessment reported as
Remediated but never retested** (`prior-assessment-excerpt.md`), because
`brief.md` states this deployment is unique in what is "present or fixed", and
`GET /config` re-asserts every one of those controls as on. `/config` is
documentation, not a test; each claim below is unknown until I establish it live.

| Prior # | Claimed remediation (`/config` key) | Route/tool I test it on |
|---|---|---|
| 1 | FAQ route closed (`retrieval.allow_user_ingest:false`) | `POST /kb/faq-suggestion` → retrieval |
| 2 | Ticket intake closed + quarantine (`input_filter.mode:guard`, `retrieval.provenance_check`) | `POST /kb/ticket` → retrieval |
| 3 | Internal docs removed + chunks segmented (`retrieval.top_k:4`) | `GET /kb/search`, `/chat` retrieval |
| 4 | SQL parameterised, raw refused (`tools.output_handling:parameterized`) | `db_query` |
| 5 | Per-tool authz + human approval on refund/delete (`tools.per_tool_authz`, `tools.human_approval`) | `issue_refund`, `delete_record`; cross-member via `POST /victim/run` |
| 6 | Iteration + per-session token caps (`resource_caps` 40000 tok / 20 rpm, 600 s window) | rolling-window token spend |

The ten OWASP LLM / ATLAS classes are used only as **vocabulary** for anything
these six claims do not cover — not as a checklist run in order against the
deployment.

## 2. Order of work, and when a line of enquiry is "finished"
I take the six claims in the order above: the three injection/retrieval claims
(1–3) first, because they seed the ground the tool claims stand on, then the tool
and authorisation claims (4–5), then the resource caps (6). For each claim there
is exactly one of two end states — nothing in between:

- **Still broken → Finding**: driven *to consequence*, not to proof-of-concept —
  the side effect actually happened, a consequence flag is present in
  `GET /audit/log`, and a transcript of the attempt that landed is committed to
  `evidence/` (with how many attempts it took, since the model is stochastic).
  "The input was accepted" is **not** a finding.
- **Actually fixed → Cleared**: I attacked it live, it did not reach consequence,
  and I evidence that clearance as carefully as a finding. A clearance is a claim
  too, and "this is safe" is the claim that gets a client hurt.

A claim I have not yet tested is **neither** — it stays a hypothesis on this list,
never a line in the report. Over-claiming a finding on a control that is genuinely
fixed is the false positive this whole project is about, so "fixed" is verified as
hard as "broken".

## 3. Boundary of the engagement, and why it sits there
**In scope:** Cascadia's routes (`/chat`, `/victim/run`, the three `/kb/*` intakes,
`/kb/search`, `/config`, `/audit/log`), the four tools (`order_lookup`,
`issue_refund`, `delete_record`, `db_query`), the retrieval path, and the
server-side system prompt's effect — i.e. everything Cascadia can change.

**Out of scope, deliberately:**
- The model's own safety training. I will not spend hours trying to make
  `gemini-3.1-flash-lite` emit harmful content; it refuses, and that is not this
  assessment.
- The model provider's API, the lab platform, and anything outside this lab.
- Re-running projects 1–5 end to end. Prior modules are hypotheses to test *here*,
  not work to repeat — the engagement runs out of hours if it quietly grows into a
  tour of everything I have ever learned.
- Any second member's traffic beyond the canned `POST /victim/run`. I am one
  assessor account and I never fabricate another member's message.

The boundary sits at "what Cascadia deployed and can fix" because that is the only
thing Elena's board can act on. Anything I cannot reach from here is named as an
untested boundary in the report, not left silent.

## 4. Using the assistant without signing my name to its errors
`assist findings | remediation | summary` print drafts Cascadia's assistant
prepared; `assist ask "..."` reaches the live model. The drafts are fluent,
confident, and partly wrong by design — catching that is the graded spine of this
engagement, not a bonus.

- I keep `3-verification_log.md` from the **first** time I use the assistant, not
  from the first time I suspect it.
- **Nothing the assistant hands me enters `2-findings_map.md` or
  `4-assessment_report.md` until it is verified against the live deployment and has
  a line in the verification log.** Concretely:
  - a cited CVE → I confirm the identifier exists and describes what the draft
    claims, **and** that the named component is actually in this stack;
  - a severity or consequence → backed by an `evidence/` transcript, never by the
    assistant's wording;
  - any "control is present / absent" → established by me live, never read off
    `GET /config`.
- A drafted finding for a control the prior excerpt already reports fixed gets the
  most scrutiny, because that is exactly the false positive that makes Cascadia
  spend on nothing and then distrust every other page.

## 5. Definition of done
The engagement is done when: each of the six claims is either a consequence-backed
finding (flag in `/audit/log` + `evidence/` transcript) or an evidenced clearance;
every claim in `4-assessment_report.md` traces to a verification-log line; the
regulatory position and the architecture recommendation address the flaws **found**,
not the flaws expected; and the report ends on the **residual-risk statement** —
what Cascadia still carries once my recommended fixes are in place. That last
sentence is what Elena said she is paying for, so the report is not finished
without it.
