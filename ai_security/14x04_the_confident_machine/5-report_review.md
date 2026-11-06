# 5 — Incident report review: INC-2026-0417

The assistant's draft (P-1…P-8) was checked line by line against the incident
evidence file (`ir/evidence-2026-0417.md`). The draft is fluent and almost
entirely faithful. One line asserts facts the evidence explicitly lists as *not
established*, and would ship false certainty in a regulated report.

## The unsupported line

**P-5, as drafted:**
> "The login originated from a commercial VPN exit node in Bucharest, Romania,
> consistent with the infrastructure of known mailbox-compromise crews."

**What is wrong with it:** every claim in this sentence is contradicted by the
evidence file's "What is NOT established" section, which says of 203.0.113.58:
> "there is no geolocation, no hosting record and no threat-intelligence match
> for it in the case file."

- "Bucharest, Romania" — there is **no geolocation** for the address.
- "commercial VPN exit node" — there is **no hosting record** for the address.
- "consistent with known mailbox-compromise crews" — there is **no
  threat-intelligence match**; this is an attribution the sources do not make.

The evidence states only that 203.0.113.58 appears in the webmail logs and
nowhere else. The draft turns three open unknowns into confident facts. In a
regulated incident report read by the client's lawyers, this is the most
dangerous kind of error: it is specific, professional-sounding, and false.

**The corrected version I would send:**
> "The login originated from 203.0.113.58. This address appears only in the
> webmail audit logs and nowhere else in our telemetry; we have no geolocation,
> hosting record, or threat-intelligence match for it, and we make no attribution."

## Secondary discrepancy (worth correcting before sending)

**P-7** states the forwarding rule was removed at **12:05 UTC**; the evidence
file records the removal at **11:50 UTC**. Use 11:50, the time in the
authoritative record.
