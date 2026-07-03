# Business Impact Quantification

**Client:** MediPath Diagnostics
**Engagement reference:** VS-MPD-26-041
**Purpose:** Translate the priority findings and the retained attack chains into euro-denominated impact ranges that the CISO can carry into the audit-committee budget discussion.

## How to read this document

Every range below is a **plausible-scenario band**, not a worst-case ceiling and not a statistical guarantee. Each item separates three things that are often collapsed together: the **statutory maximum** (which is almost never reached in practice), a **defensible central estimate** (the number to defend in a budget meeting), and the **cost drivers and assumptions** that produced it. Figures are anchored to MediPath's own metrics (EUR 31.2M ARR, 400 laboratories, ~62,000 samples/day, EUR 65k–120k/hour outage exposure, EUR 250k insurance deductible, EUR 180k/year IR retainer, 1% churn ≈ EUR 312k ARR, 5% churn ≈ EUR 1.56M ARR) and to comparable CNIL/ANSSI reference points: the CNIL fined **NEXPUBLICA FRANCE EUR 1.7M** (Dec 2025) for a security failure that let portal users access other tenants' case documents — the closest real-world analogue to F-01 and F-03; **CEGEDIM SANTÉ was fined EUR 800k** (Sept 2024) for unauthorized health-data processing, and the same company's 2025 breach of 15.8M health records shows how a smaller regulatory finding can precede a much larger downstream incident; **IQVIA was fined EUR 5M** for a health-data violation (2026); under GDPR Art. 83, MediPath's statutory ceiling is the greater of **EUR 20M or 4% of global annual turnover** (≈ EUR 1.25M on current ARR, so the EUR 20M figure is the theoretical ceiling, not the expected outcome); and ANSSI/EUROSAI reporting puts hospital-sector incident costs at **up to EUR 10M in crisis management and up to EUR 20M in lost operating revenue**, excluding data-theft consequences — useful for sanity-checking upper bounds, not for sizing MediPath directly, since MediPath is a mid-sized SaaS vendor rather than a hospital operator.

## Scope carried into this quantification

Priority findings quantified individually: **F-01, F-02, F-03, F-04, F-05, F-06, F-08, F-09, F-10**.

**F-07** (Support-Manager bulk export) is **not** quantified as a live risk. The context dossier confirms this is a documented, DPO-authorized emergency/regulatory workflow with WebAuthn step-up, dual approval, case-specific encryption, seven-day expiry, and immutable audit logging; the engagement role was pre-approved specifically to exercise the control. Per the engagement's own interpretation rule, authorized functionality with evidenced enforcement is not carried forward as a finding. It is retained only as a small **control-verification** cost item below, to confirm every production path actually enforces the documented approvals — reviving it as a full risk item would double-count a control that has not been shown to be broken.

Three attack chains are quantified because they compound isolated findings into materially larger or qualitatively different consequences: **Chain 1** (cross-tenant health-data correlation: F-10 + F-01, amplified by F-03), **Chain 2** (identity/session governance failure: F-03 + F-09), and **Chain 3** (diagnostic workflow integrity: F-05 + F-04).

---

## Item: F-01 — Cross-laboratory access to diagnostic result records
- Range: EUR 350,000 to EUR 6,500,000 (central estimate EUR 1,800,000)
- Reasoning: This is the closest match to the NEXPUBLICA precedent (EUR 1.7M for cross-tenant document exposure), except the underlying data here is Article 9 health data rather than social-services case data, which pushes environmental severity above the generic base score. Cost drivers: CNIL investigation and potential sanction; mandatory Art. 33/34 breach notification to CNIL and to every affected laboratory; per-laboratory incident coordination (legal, DPO, security); IR retainer utilization (EUR 180k/year capacity); a realistic churn scenario among directly notified laboratories; and knock-on scrutiny during the HDS renewal window, which is only five months out. The low end assumes a single, contained cross-tenant access confirmed only in testing with no evidence of real-world exploitation; the high end assumes the identifier-substitution technique was found to be practical at scale and a subset of laboratories churn.
- Assumptions: Realistic worst case affects data belonging to 5–10% of the 400-laboratory base (20–40 laboratories) rather than all 400; CNIL notification is triggered; central estimate uses the NEXPUBLICA/CEGEDIM fine band rather than the EUR 20M statutory ceiling; churn scenario modeled at roughly 1% of ARR (EUR 312k) as the central case with higher churn only in the high-end scenario; no ransom or extortion component (destructive testing was out of scope and there is no evidence of external exploitation).

## Item: F-02 — Stored active content in laboratory-to-support notes
- Range: EUR 40,000 to EUR 350,000 (central estimate EUR 120,000)
- Reasoning: Standalone, this is a same-origin content-execution issue against a support analyst's session, mitigated in part by MFA and managed workstations, so its direct financial footprint is modest: incident triage, remediation engineering (output encoding, CSP enforcement), and legacy content sanitization. The meaningful risk is not the standalone weakness but its role as a stepping stone into a support analyst's cross-tenant view — that escalation path is priced separately as part of the broader identity-governance picture rather than double-counted here.
- Assumptions: No credential material is confirmed retained by the marker used in testing; support-portal cross-tenant reach is treated as a likelihood multiplier rather than a separate line item; remediation is assumed to require both code changes and a CSP rollout (report-only to enforcing), which carries a compatibility-testing cost.

## Item: F-03 — Long-lived integration token with cross-tenant privileges
- Range: EUR 500,000 to EUR 7,000,000 (central estimate EUR 2,200,000)
- Reasoning: Unlike F-01, this finding grants both read and write reach (`C:H/I:H/A:H`) across a trust boundary that spans hospital institutions, not just laboratories, and hospital integrations are a channel MediPath does not fully control end to end. Cost drivers: token compromise/rotation and centralized revocation program; forensic review of everything the token could reach; potential sample-status or result manipulation if combined with write access; and B2B reputational exposure with hospital partners, whose referral relationships indirectly drive laboratory volume, so damage here can propagate into laboratory churn even though hospitals aren't the direct paying customer.
- Assumptions: A realistic incident compromises 1–3 hospital integration relationships rather than all connectors; 180-day token lifetime is treated as the exposure window for likelihood purposes; high end includes a scenario where write access is used to alter sample-status or connector configuration, triggering the same operational-disruption costs priced in F-05/Chain 3; no assumption of confirmed real-world exploitation, only demonstrated technical reach.

## Item: F-04 — Certificate validation disabled in a connector worker
- Range: EUR 15,000 to EUR 250,000 (central estimate EUR 60,000)
- Reasoning: Sarah's own doubt is well founded: the managed private mTLS egress gateway is the actual traffic path, and it independently validates upstream certificates and restricts destinations, so this is primarily a defense-in-depth and audit-evidence gap rather than a live exploitation path today. The dominant cost is verification and remediation engineering (enabling peer validation, confirming certificate-chain compatibility) plus the audit-readiness cost of explaining a fail-open worker-level configuration to HDS renewal assessors, who will expect layered controls rather than reliance on a single upstream gateway.
- Assumptions: The managed gateway's mTLS enforcement is treated as currently effective (per the compensating-controls document) but not yet independently verified for bypass resistance or fail-closed behavior; if that verification fails, this item's severity should be revisited upward rather than assumed away; no standalone breach scenario is modeled because interception was out of scope and the network path is not directly reachable from outside the private integration network.

## Item: F-05 — Sample-status webhook accepts unsigned events
- Range: EUR 150,000 to EUR 3,500,000 (central estimate EUR 900,000)
- Reasoning: The regulatory map rates sample-status workflow integrity as very high, independent of confidentiality, and the business metrics confirm that delivery delays beyond two hours trigger executive escalation and that manual reconciliation carries real staffing and error costs. A forged status transition does not need to leak data to be expensive: it can misrepresent the diagnostic pathway, force manual reconciliation across a live production volume of ~62,000 samples/day, and — in a plausible worst case — allow an incorrect result to be released before the discrepancy is caught, which shifts the exposure from an IT incident to a care-quality and liability question.
- Assumptions: Central estimate assumes a bounded incident affecting hundreds to low thousands of samples, detected and reconciled within the escalation window, with no confirmed patient-safety outcome; the high end reflects a scenario where the forged event volume is large enough to breach the 2-hour backlog threshold or where a released result is later found to be incorrect, adding liability review and hospital-trust remediation costs; source-IP allowlisting is treated as reducing likelihood, not eliminating it, since it authenticates network origin rather than message integrity.

## Item: F-06 — Diagnostic export packages retained beyond the documented period
- Range: EUR 60,000 to EUR 900,000 (central estimate EUR 250,000)
- Reasoning: Object-storage encryption limits the confidentiality blast radius, but a documented 24-hour retention period that is actually enforced at 30 days is an accountability and RGPD/HDS-evidence problem in its own right, independent of whether any specific link is misused. Costs are dominated by DPO/legal review of the retention-policy mismatch, remediation of link/object expiry logic, and — because HDS renewal evidence collection is already underway — the risk that an auditor treats this as a control-design failure rather than a one-off bug, which adds review cycles during an already time-boxed renewal window.
- Assumptions: No confirmed unauthorized access to an out-of-window export beyond the one 29-day test case; the higher end reflects a scenario where the mismatch is flagged during the HDS renewal itself, adding remediation-evidence cost and schedule risk rather than a direct fine; access logging on object storage is assumed adequate for a scoped forensic review.

## Item: F-08 — Password-recovery flow reveals account existence
- Range: EUR 20,000 to EUR 180,000 (central estimate EUR 60,000)
- Reasoning: With SSO/MFA already covering 82% of laboratory users, the practical blast radius is the remaining local-account population and any targeted social-engineering or credential-stuffing use of confirmed valid addresses against support workflows. This is a low-cost, low-drama fix (uniform responses, account-aware throttling) whose main financial relevance is as a minor contributor to targeted attacks against other findings rather than a standalone incident driver.
- Assumptions: No evidence of automated enumeration having occurred in production; cost is mostly engineering remediation plus incremental monitoring; not treated as a meaningful independent churn or regulatory driver at MediPath's current control maturity.

## Item: F-09 — Administrative privileges remain active after role downgrade
- Range: EUR 200,000 to EUR 3,000,000 (central estimate EUR 800,000)
- Reasoning: The ~27-minute (and potentially longer, in edge cases) write-access survival window matters less for its duration than for what it reveals: authorization state is governed by a time-based cache rather than an event-driven revocation trigger, which is the same structural gap implicated in F-03. Standalone, the cost driver is governance and forensics — reconstructing what any given privileged session actually did during ambiguous-authorization windows — plus the accountability concern flagged in the regulatory map, since audit-log integrity is itself a certification-relevant asset. The high end reflects a scenario involving a genuinely malicious or compromised departing administrator rather than routine role changes.
- Assumptions: Quarterly access reviews are assumed to catch most routine cases eventually but do not provide immediate revocation, so exposure is priced on the gap between change and cache expiry, not on the review cycle; central estimate assumes one affected privileged session per incident rather than a systemic pattern; no assumption that any specific downgrade event was malicious — this prices the structural exposure.

## Item: F-10 — Internal analytics service trusts a caller-supplied laboratory header
- Range: EUR 150,000 to EUR 2,500,000 (central estimate EUR 600,000)
- Reasoning: Standalone, this exposes aggregate cross-laboratory activity rather than identified patient records, which the regulatory map rates as medium-to-high rather than very high — real, but less severe than F-01 in isolation. The main financial exposure is competitive/contractual: laboratory volume and activity patterns are commercially sensitive to the labs themselves, and a confirmed cross-tenant leak of that data could damage trust independent of any RGPD Art. 9 exposure. Its larger significance is as a component of Chain 1, priced separately below.
- Assumptions: No patient-identifiable data is assumed exposed by this finding alone; cost driver is primarily remediation (service-to-service authentication, verified-claim tenant derivation) plus a bounded confidentiality/contractual-trust incident; higher end reflects a scenario where analytics identifiers are shown to help locate F-01-affected result objects even before the two are formally chained in production.

## Item: F-07 — Support-Manager bulk export (control-verification item, not a live-risk range)
- Range: EUR 5,000 to EUR 25,000 (central estimate EUR 12,000) — verification cost only, not a breach-impact range
- Reasoning: This item is priced as the cost of confirming, across every production path, that the ticket requirement, WebAuthn step-up, dual approval, case-specific encryption, and seven-day expiry are all mandatory and cannot be bypassed — not as the cost of an incident, because the evidenced control design does not currently support treating this as a live weakness.
- Assumptions: If verification finds any production path where an approval step can be skipped or defaulted, this item should be re-scored using the same methodology as F-03/F-07-equivalent write-access findings, not left at this verification-only range.

---

## Item: Chain 1 — Cross-tenant health-data correlation (F-10 → F-01, amplified by F-03)
- Range: EUR 1,500,000 to EUR 14,000,000 (central estimate EUR 5,000,000)
- Reasoning: Individually, F-10 exposes aggregate activity and F-01 exposes one result record at a time by guessing identifiers. Chained, F-10 gives an attacker a map of which laboratories are worth targeting and F-03's broad connector-token reach can provide a path into the application network where F-10 is directly callable, turning a slow, manual, one-record-at-a-time weakness into a systematic, multi-laboratory harvesting capability. That shift moves the scenario from "contained incident" to "mass health-data exposure," which is the fact pattern that produces the largest CNIL sanctions and the broadest notification obligations, and it is squarely the scenario the HDS renewal board will ask about.
- Assumptions: Realistic worst case affects 10–15% of the 400-laboratory base and a proportional patient population; mandatory CNIL notification and public disclosure are assumed; churn scenario spans 1% (EUR 312k) at the low end to 5% (EUR 1.56M) at the high end of ARR; central estimate is anchored between the NEXPUBLICA/CEGEDIM band and the higher IQVIA-scale band, not at the EUR 20M statutory ceiling; HDS renewal (due within five months) is assumed to be delayed or subjected to additional evidence requirements, adding indirect compliance cost beyond the direct fine.

## Item: Chain 2 — Identity and session governance failure (F-03 + F-09)
- Range: EUR 800,000 to EUR 8,000,000 (central estimate EUR 2,500,000)
- Reasoning: Both findings share a root cause — authorization state is invalidated on a time-based cache cycle instead of an explicit revocation event. Chained, a privileged actor who should no longer have access (a downgraded admin, an over-scoped connector, or both at once) can retain **write** access for an unpredictable window, which is qualitatively worse than a read-only leak: it can silently corrupt sample-status or connector configuration, delay detection, and force a forensic review of every privileged action taken during the exposure window rather than a single point-in-time data pull. This is why the chain is priced above either finding's standalone range rather than as their sum.
- Assumptions: Incident scenario involves at least one privileged actor and touches multiple laboratory or hospital tenants; forensic reconstruction is assumed to take several weeks given the lack of event-driven revocation logging; central estimate assumes the write actions are eventually detected and reversed rather than causing permanent diagnostic-record corruption, which is the driver of the high end.

## Item: Chain 3 — Diagnostic workflow integrity failure (F-05 + F-04)
- Range: EUR 500,000 to EUR 6,000,000 (central estimate EUR 1,600,000)
- Reasoning: F-04 alone is a defense-in-depth gap behind an effective gateway; F-05 alone is a webhook authenticity gap behind a source-IP allowlist. Chained, a degradation, misconfiguration, or bypass of the gateway control that currently mitigates F-04 would let an unsigned, forged sample-status event (F-05) reach production and be trusted by downstream result-release logic without independent verification — moving the exposure from "IT confidentiality incident" to "diagnostic pathway integrity incident," which is the category the client dossier explicitly flags as capable of disrupting operations without any data being stolen at all.
- Assumptions: The managed gateway is assumed generally effective, so this chain models a bounded degradation window rather than a permanent bypass; a plausible worst case affects hundreds to low thousands of the ~62,000 daily samples; the central estimate assumes reconciliation catches the discrepancy before a result reaches a patient, with the high end reserved for the scenario where an incorrect result is released before detection, which shifts cost from operational reconciliation to liability and hospital-trust remediation.

---

## Summary table (for quick CFO/CISO reference)

| Item | Low (EUR) | Central (EUR) | High (EUR) |
| --- | --- | --- | --- |
| F-01 | 350,000 | 1,800,000 | 6,500,000 |
| F-02 | 40,000 | 120,000 | 350,000 |
| F-03 | 500,000 | 2,200,000 | 7,000,000 |
| F-04 | 15,000 | 60,000 | 250,000 |
| F-05 | 150,000 | 900,000 | 3,500,000 |
| F-06 | 60,000 | 250,000 | 900,000 |
| F-08 | 20,000 | 60,000 | 180,000 |
| F-09 | 200,000 | 800,000 | 3,000,000 |
| F-10 | 150,000 | 600,000 | 2,500,000 |
| F-07 (verification only) | 5,000 | 12,000 | 25,000 |
| Chain 1 | 1,500,000 | 5,000,000 | 14,000,000 |
| Chain 2 | 800,000 | 2,500,000 | 8,000,000 |
| Chain 3 | 500,000 | 1,600,000 | 6,000,000 |

Chain totals are not additive with their component findings — they replace the standalone ranges for F-01/F-03/F-09/F-05/F-04/F-10 in a compounded-exploitation scenario, and should be read by the audit committee as the figure that matters if remediation sequencing is delayed, while the individual finding ranges are what disappears once each item is fixed independently.
