# Business Impact Quantification

**Client:** MediPath Diagnostics
**Engagement reference:** VS-MPD-26-041
**Purpose:** Translate the priority findings and the retained attack chains into euro-denominated impact ranges that the CISO can carry into the audit-committee budget discussion.

## How to read this document

Every range below is a **plausible-scenario band**, not a worst-case ceiling and not a statistical guarantee. Each item separates the **statutory maximum** (almost never reached in practice) from a **defensible central estimate** (the number to defend in a budget meeting), and then lists, explicitly, the cost components that drive the range and the assumptions that produced it — affected scope, incident duration, notification scenario, and churn scenario, at minimum.

Figures are anchored to MediPath's own metrics: EUR 31.2M ARR, 400 contracted laboratories, ~1.9M active patient profiles, ~62,000 samples/day, ~14M result documents/year, EUR 65k–120k/hour core-platform outage exposure, EUR 250k cyber-insurance deductible, EUR 180k/year external IR retainer, 1% laboratory churn ≈ EUR 312k ARR, 5% laboratory churn ≈ EUR 1.56M ARR, and an HDS renewal audit due within five months.

Regulatory anchors used throughout: the CNIL fined **NEXPUBLICA FRANCE EUR 1.7M** (Dec 2025) for a security failure that let portal users access other tenants' case documents — the closest real-world analogue to F-01/F-03; **CEGEDIM SANTÉ was fined EUR 800k** (Sept 2024) for unauthorized health-data processing, and the same company's later 2025 breach of 15.8M health records shows how an earlier, smaller regulatory finding can precede a much larger downstream incident; **IQVIA was fined EUR 5M** for a health-data violation (2026); under GDPR Art. 83 the statutory ceiling is the greater of **EUR 20M or 4% of global annual turnover** (≈ EUR 1.25M on MediPath's current ARR, so EUR 20M is the theoretical, not expected, ceiling); ANSSI/EUROSAI reporting puts hospital-sector incident costs at up to EUR 10M crisis management and up to EUR 20M lost operating revenue (a sanity-check ceiling for a hospital operator, not a direct MediPath comparable, since MediPath is a mid-sized SaaS vendor, not a hospital).

## Scope carried into this quantification

Priority findings quantified individually: **F-01, F-02, F-03, F-04, F-05, F-06, F-08, F-09, F-10**.

**F-07** (Support-Manager bulk export) is **not** quantified as a live risk. The dossier confirms this is a documented, DPO-authorized emergency/regulatory workflow with WebAuthn step-up, dual approval, case-specific encryption, seven-day expiry, and immutable audit logging; the engagement test role was pre-approved specifically to exercise the control. Per the engagement's interpretation rule, authorized functionality with evidenced enforcement is not carried forward as a live finding. It is retained only as a small **control-verification** cost item, to confirm every production path actually enforces the documented approvals.

Three attack chains are quantified because they compound isolated findings into materially larger or qualitatively different consequences: **Chain 1** (cross-tenant health-data correlation: F-10 + F-01, amplified by F-03), **Chain 2** (identity/session governance failure: F-03 + F-09), and **Chain 3** (diagnostic workflow integrity: F-05 + F-04).

---

## Item: F-01 — Cross-laboratory access to diagnostic result records
- Range: EUR 350,000 to EUR 6,500,000 (central estimate EUR 1,800,000)
- Reasoning:
  - Regulatory exposure: closest real-world analogue is NEXPUBLICA (EUR 1.7M for cross-tenant document exposure); severity here is pushed above that anchor because the exposed data is Article 9 health data, not administrative case data, and MediPath's HDS renewal audit is five months away, so a CNIL inquiry would land during an already-scrutinized period.
  - Operational disruption: minimal — the API itself keeps functioning; the disruption is administrative (freezing the affected identifier ranges, adding negative-authorization tests) rather than an outage.
  - Incident response: mandatory RGPD Art. 33/34 breach notification to the CNIL within 72 hours and to every affected laboratory; DPO- and legal-led per-laboratory coordination; draws on the EUR 180k/year external IR retainer, likely exhausting a meaningful share of it in a multi-laboratory scenario.
  - Reputational impact / customer churn: laboratories are contractually and clinically dependent on result confidentiality; a confirmed cross-tenant leak plausibly drives a churn scenario in the 1%–5% ARR range (EUR 312k–EUR 1.56M) among directly notified laboratories, on top of the regulatory cost.
- Assumptions:
  - Affected scope: realistic worst case touches 5–10% of the 400-laboratory base (20–40 laboratories) rather than the full client base.
  - Duration: exploitation window assumed short (days) once identifier substitution is discovered internally, since the weakness was already found by scoped testing rather than left to be discovered externally.
  - Notification scenario: CNIL notification and laboratory notification are both triggered; low end assumes internal discovery with no evidence of external exploitation, high end assumes the technique is shown to be practical at scale.
  - Churn scenario: central estimate uses roughly 1% ARR churn (EUR 312k) as the base case, with higher churn reserved for the high end.
  - No ransom, extortion, or destructive-testing component is modeled (out of engagement scope, no evidence of exploitation in the wild).

## Item: F-02 — Stored active content in laboratory-to-support notes
- Range: EUR 40,000 to EUR 350,000 (central estimate EUR 120,000)
- Reasoning:
  - Regulatory exposure: low in isolation — no direct evidence of data exfiltration, and MFA plus managed workstations already narrow the practical population of analysts who could be affected.
  - Operational disruption: negligible; the support portal remains available and the fix (contextual output encoding, CSP enforcement) is a scheduled engineering change, not an emergency patch.
  - Incident response: triage of the specific case where the marker executed, plus a review of historical case notes for other latent stored content; CSP rollout requires a compatibility-testing cycle before enforcement, adding a small fixed engineering cost.
  - Reputational impact / customer churn: negligible standalone, since no patient or laboratory was shown to be directly affected; the real cost driver is this finding's role as a stepping stone into a support analyst's cross-tenant view, which is priced under the identity-governance items rather than duplicated here.
- Assumptions:
  - Affected scope: limited to the single synthetic case exercised in testing plus a bounded review of legacy notes, not a platform-wide compromise.
  - Duration: assumed contained to the session in which the marker executed; no credential material is confirmed retained.
  - Notification scenario: no regulator or laboratory notification assumed necessary at this standalone severity.
  - Churn scenario: none modeled standalone.

## Item: F-03 — Long-lived integration token with cross-tenant privileges
- Range: EUR 500,000 to EUR 7,000,000 (central estimate EUR 2,200,000)
- Reasoning:
  - Regulatory exposure: same NEXPUBLICA/CEGEDIM-scale CNIL exposure as F-01, but potentially larger because the token grants write access (`C:H/I:H/A:H`) as well as read access, and spans a trust boundary with external hospital institutions rather than laboratories alone.
  - Operational disruption: token revocation and reissuance across affected connectors, plus a freeze on the affected hospital integration(s) while scope is confirmed — a bounded, hours-to-days operational event rather than a platform outage.
  - Incident response: forensic review of everything the token could reach over its 180-day lifetime; centralized revocation-program build-out; drawn from the IR retainer.
  - Reputational impact / customer churn: B2B trust damage with the affected hospital(s), whose referral relationships indirectly drive laboratory sample volume, so the churn exposure is modeled as touching both the hospital relationship and a subset of the laboratories it feeds.
- Assumptions:
  - Affected scope: a realistic incident compromises 1–3 hospital integration relationships, not all connectors simultaneously.
  - Duration: 180-day token lifetime is used only to size the likelihood of discovery, not as the assumed active-exploitation window, which is modeled as days to a few weeks.
  - Notification scenario: CNIL and affected-hospital notification assumed at the central estimate and above; low end assumes internal discovery with contained scope.
  - Churn scenario: high end includes a scenario where write access is used to alter sample-status or connector configuration, layering in the operational-disruption cost priced in F-05/Chain 3.

## Item: F-04 — Certificate validation disabled in a connector worker
- Range: EUR 15,000 to EUR 250,000 (central estimate EUR 60,000)
- Reasoning:
  - Regulatory exposure: low standalone — the managed private mTLS egress gateway independently validates upstream certificates and restricts destinations, so this is primarily a defense-in-depth and audit-evidence gap rather than a live exploitation path today.
  - Operational disruption: none expected from the finding itself; remediation (enabling peer validation, confirming certificate-chain compatibility) is a scheduled configuration change with a small compatibility-testing risk.
  - Incident response: not applicable at standalone severity — no incident is assumed, only a verification and remediation exercise.
  - Reputational impact / customer churn: the main cost is audit-readiness — explaining a fail-open worker-level configuration to HDS renewal assessors, who expect layered controls rather than reliance on a single upstream gateway; no churn is modeled at this severity.
- Assumptions:
  - Affected scope: limited to the legacy connector worker configuration; the managed gateway's mTLS enforcement is treated as currently effective per the compensating-controls document, but not yet independently verified for bypass resistance or fail-closed behavior.
  - Duration: not applicable — no active-exploitation window assumed given interception was out of engagement scope.
  - Notification scenario: none assumed unless gateway verification later fails, in which case this item should be re-scored upward.
  - Churn scenario: none modeled.

## Item: F-05 — Sample-status webhook accepts unsigned events
- Range: EUR 150,000 to EUR 3,500,000 (central estimate EUR 900,000)
- Reasoning:
  - Regulatory exposure: moderate on its own — no patient data is disclosed (`C:N`), but DPO/legal review is still triggered because sample-status is part of Article 9-adjacent health-data processing accountability.
  - Operational disruption: this is the dominant cost driver — the regulatory map rates sample-status workflow integrity as very high, and the business metrics confirm that result-delivery delays beyond two hours trigger executive escalation, with manual laboratory reconciliation carrying real staffing and error costs.
  - Incident response: forensic reconciliation of forged versus genuine status transitions across the affected sample population, drawing on the IR retainer.
  - Reputational impact / customer churn: primarily hospital-partner trust rather than laboratory churn, since sample-status integrity affects the hospital-facing side of the workflow; the high end includes a scenario where an incorrect result is released before the discrepancy is caught, adding liability review.
- Assumptions:
  - Affected scope: central estimate assumes hundreds to low thousands of the ~62,000 daily samples are affected.
  - Duration: bounded incident, detected and reconciled within the two-hour escalation window at the central estimate; high end assumes the backlog threshold is breached before detection.
  - Notification scenario: DPO/legal review assumed at all levels; CNIL notification only assumed if a released result is later found incorrect (high end).
  - Churn scenario: modeled as hospital-relationship and reconciliation cost rather than direct laboratory ARR churn at the central estimate; laboratory churn appears only at the high end if the incident becomes public.
  - Source-IP allowlisting is treated as reducing likelihood, not eliminating it, since it authenticates network origin rather than message integrity.

## Item: F-06 — Diagnostic export packages retained beyond the documented period
- Range: EUR 60,000 to EUR 900,000 (central estimate EUR 250,000)
- Reasoning:
  - Regulatory exposure: object-storage encryption limits the confidentiality blast radius, but a documented 24-hour retention period actually enforced at 30 days is itself an RGPD storage-limitation and HDS-evidence accountability gap, independent of whether any specific link was misused.
  - Operational disruption: low — remediation is a link/object expiry logic fix, not a workflow change.
  - Incident response: DPO/legal review of the retention-policy mismatch and of which exports remained accessible beyond the documented window; access-log review of object storage.
  - Reputational impact / customer churn: low standalone, but the timing risk is real — HDS renewal evidence collection is already underway, and a retention-policy mismatch surfacing during the audit itself adds review cycles and schedule risk rather than a direct fine.
- Assumptions:
  - Affected scope: based on the one confirmed 29-day-old test export still being downloadable; central estimate assumes a similar population of exports across the retention gap, not the entire export history.
  - Duration: the mismatch (24-hour documented vs. 30-day actual) is assumed to have existed for some meaningful prior period, not just the sampled case.
  - Notification scenario: no confirmed unauthorized access beyond the sampled case is assumed; the high end reflects the scenario where the HDS auditor treats this as a control-design failure requiring formal remediation evidence.
  - Churn scenario: none modeled directly; cost is compliance and schedule risk rather than customer-facing.

## Item: F-08 — Password-recovery flow reveals account existence
- Range: EUR 20,000 to EUR 180,000 (central estimate EUR 60,000)
- Reasoning:
  - Regulatory exposure: low — this concerns account existence, not health data, and SSO/MFA already covers 82% of laboratory users, narrowing the affected population.
  - Operational disruption: none.
  - Incident response: not applicable at standalone severity; cost is remediation engineering (uniform responses, account-aware throttling) plus incremental monitoring.
  - Reputational impact / customer churn: negligible standalone; the main relevance is as a minor enabler of targeted social engineering or credential attacks against the remaining local-account population, priced as a small uplift rather than a separate incident.
- Assumptions:
  - Affected scope: limited to the ~18% of laboratory users on local accounts rather than the full 400-laboratory base.
  - Duration: not applicable — no active-exploitation evidence in production.
  - Notification scenario: none assumed.
  - Churn scenario: none modeled.

## Item: F-09 — Administrative privileges remain active after role downgrade
- Range: EUR 200,000 to EUR 3,000,000 (central estimate EUR 800,000)
- Reasoning:
  - Regulatory exposure: moderate to high — the regulatory map flags audit-log and accountability integrity as a certification-relevant asset, and this finding is precisely an accountability gap: privileged write access surviving an intended downgrade.
  - Operational disruption: potentially significant if the retained window is misused — unauthorized configuration or tenant changes made during the ~27-minute (or longer, in edge cases) window may not be immediately visible.
  - Incident response: the dominant cost driver — forensic reconstruction of what a given privileged session actually did during any ambiguous-authorization window, since detection is not immediate under a time-based cache model.
  - Reputational impact / customer churn: low standalone unless the retained access is shown to have been actively misused, in which case it converges with the F-03 churn/reputational picture (priced jointly under Chain 2).
- Assumptions:
  - Affected scope: central estimate assumes one affected privileged session per incident, not a systemic pattern across many role changes.
  - Duration: exposure window is the gap between role change and authorization-cache expiry (documented at ~27 minutes, with edge cases longer); quarterly access reviews are assumed to catch most routine cases eventually but do not provide immediate revocation.
  - Notification scenario: no assumption that any specific observed downgrade event was malicious — this prices the structural exposure, not a confirmed incident; notification is assumed only in the high-end, actively-misused scenario.
  - Churn scenario: none at the central estimate; high end assumes a genuinely malicious or compromised departing administrator.

## Item: F-10 — Internal analytics service trusts a caller-supplied laboratory header
- Range: EUR 150,000 to EUR 2,500,000 (central estimate EUR 600,000)
- Reasoning:
  - Regulatory exposure: moderate — the regulatory map rates analytics confidentiality as medium-to-high rather than very high, since the exposed data is aggregate laboratory activity, not identified patient records.
  - Operational disruption: none; the analytics service continues functioning normally.
  - Incident response: remediation is service-to-service authentication and deriving tenant identity from verified claims rather than a trusted header; a bounded confidentiality review of which laboratories' aggregate data was accessible.
  - Reputational impact / customer churn: primarily commercial/contractual — laboratory activity volume is commercially sensitive to the labs themselves, so a confirmed cross-tenant leak damages trust independent of any RGPD Article 9 exposure; churn risk is lower than F-01 because no identified patient data is involved standalone.
- Assumptions:
  - Affected scope: no patient-identifiable data is assumed exposed by this finding alone.
  - Duration: assumed discoverable and fixable within days once flagged, since the service is only reachable from the internal application network, not the public internet.
  - Notification scenario: no CNIL notification assumed standalone (no personal health data); commercial disclosure to affected laboratories only in the high-end scenario.
  - Churn scenario: high end reflects a scenario where analytics identifiers are shown to help locate F-01-affected result objects, which is priced jointly under Chain 1 rather than double-counted here.

## Item: F-07 — Support-Manager bulk export (control-verification item, not a live-risk range)
- Range: EUR 5,000 to EUR 25,000 (central estimate EUR 12,000) — verification cost only, not a breach-impact range
- Reasoning:
  - Regulatory exposure: none assumed — the control design (DPO ticket, WebAuthn step-up, dual approval, case-specific encryption, seven-day expiry, immutable audit logging) is evidenced in the dossier, and the engagement's own interpretation rule states that authorized, adequately controlled functionality is not carried forward as a live finding.
  - Operational disruption: none; this is a verification exercise, not a remediation of a broken control.
  - Incident response: not applicable; the cost is the labor of confirming, across every production path, that the ticket requirement, step-up authentication, and dual approval cannot be bypassed or defaulted.
  - Reputational impact / customer churn: none modeled.
- Assumptions:
  - Affected scope: verification effort covers all production paths that can trigger a bulk export, not just the engagement's pre-approved test role.
  - Duration: a short, scheduled verification exercise, not an ongoing exposure window.
  - Notification scenario: none.
  - Churn scenario: none. If verification finds any production path where an approval step can be skipped or defaulted, this item must be re-scored using the same methodology as F-03/F-09, not left at this verification-only range.

---

## Item: Chain 1 — Cross-tenant health-data correlation (F-10 → F-01, amplified by F-03)
- Range: EUR 1,500,000 to EUR 14,000,000 (central estimate EUR 5,000,000)
- Reasoning:
  - Why this is not a mechanical sum: individually, F-10 exposes aggregate, non-identified activity data and F-01 exposes one identified result record at a time by guessing identifiers — both are bounded, effortful weaknesses. Chained, F-10 gives an attacker a map of which laboratories are worth targeting, and F-03's broad connector-token reach can provide a path into the application network where F-10 is directly callable, converting a slow, manual, one-record-at-a-time weakness into a systematic, multi-laboratory harvesting capability. The consequence category changes from "contained incident" to "mass health-data exposure," which is qualitatively different, not just F-01's range plus F-10's range plus F-03's range.
  - Regulatory exposure: mass cross-tenant exposure of Article 9 health data is the fact pattern that produces the largest CNIL sanctions in the comparable set (above the NEXPUBLICA/CEGEDIM band, approaching or exceeding the IQVIA anchor), and it lands squarely inside the five-month HDS renewal window.
  - Operational disruption: multi-laboratory incident coordination at a scale the standard IR retainer is not sized for, likely requiring supplemental external support.
  - Incident response: CNIL notification, broad laboratory notification, and public-disclosure management.
  - Reputational impact / customer churn: modeled across the full 1%–5% ARR churn range (EUR 312k–EUR 1.56M) given the multi-laboratory, public-disclosure nature of the scenario.
- Assumptions:
  - Affected scope: realistic worst case affects 10–15% of the 400-laboratory base and a proportional patient population, not the full client base.
  - Duration: assumed to run from initial reconnaissance (via F-10) to detection and containment over days to a few weeks, given no single control currently correlates these three findings.
  - Notification scenario: mandatory CNIL notification and public disclosure are both assumed.
  - Churn scenario: central estimate anchored between the NEXPUBLICA/CEGEDIM fine band and the larger IQVIA-scale band, explicitly not at the EUR 20M statutory ceiling; HDS renewal is assumed to be delayed or subjected to additional evidence requirements, adding indirect compliance cost beyond the direct fine.

## Item: Chain 2 — Identity and session governance failure (F-03 + F-09)
- Range: EUR 800,000 to EUR 8,000,000 (central estimate EUR 2,500,000)
- Reasoning:
  - Why this is not a mechanical sum: both findings share a root cause — authorization state is invalidated on a time-based cache cycle instead of an explicit revocation event. Chained, a privileged actor who should no longer have access (a downgraded admin, an over-scoped connector, or both at once) can retain **write** access for an unpredictable window. That is qualitatively worse than either finding's read-only or single-session leak: it can silently corrupt sample-status or connector configuration, delay detection, and force a forensic review of every privileged action taken during the exposure window, not just a single point-in-time data pull.
  - Regulatory exposure: audit-log and accountability integrity is explicitly flagged as certification-relevant in the regulatory map; a governance failure of this kind is a harder finding for the Compliance/HDS Manager to explain to renewal assessors than a simple data leak.
  - Operational disruption: potentially significant — undetected write access to connector configuration or sample-status can propagate incorrect state into the diagnostic workflow before anyone notices.
  - Incident response: the dominant cost driver — full forensic reconstruction of privileged-session activity across the affected identity/authorization-cache lifecycle, since there is no event-driven revocation log to shortcut the review.
  - Reputational impact / customer churn: primarily hospital-partner and laboratory operational trust rather than a direct data-breach churn event, since the harm is integrity-based rather than confidentiality-based.
- Assumptions:
  - Affected scope: incident scenario involves at least one privileged actor and touches multiple laboratory or hospital tenants.
  - Duration: forensic reconstruction is assumed to take several weeks given the lack of event-driven revocation logging, well beyond the ~27-minute technical exposure window itself.
  - Notification scenario: CNIL/DPO notification assumed if write actions are confirmed to have altered production data; central estimate assumes actions are eventually detected and reversed.
  - Churn scenario: high end reserved for a scenario causing permanent diagnostic-record corruption rather than a detected-and-reversed event.

## Item: Chain 3 — Diagnostic workflow integrity failure (F-05 + F-04)
- Range: EUR 500,000 to EUR 6,000,000 (central estimate EUR 1,600,000)
- Reasoning:
  - Why this is not a mechanical sum: F-04 alone is a defense-in-depth gap sitting behind an effective managed gateway; F-05 alone is a webhook authenticity gap sitting behind a source-IP allowlist. Neither is a live exploitation path on its own given its respective compensating control. Chained, a degradation, misconfiguration, or bypass of the gateway control that currently mitigates F-04 would let an unsigned, forged sample-status event (F-05) reach production and be trusted by downstream result-release logic without independent verification — moving the exposure from "two dormant, individually-mitigated gaps" to "diagnostic pathway integrity incident."
  - Regulatory exposure: moderate — DPO/legal review triggered by any confirmed integrity failure in Article 9-adjacent processing, though less severe than a confidentiality breach unless a released result is shown to be incorrect.
  - Operational disruption: the dominant cost driver — the dossier explicitly flags workflow-integrity issues as capable of disrupting laboratory operations even with no data stolen at all; manual reconciliation across a subset of the ~62,000 daily samples carries the staffing and error costs described in the business metrics.
  - Incident response: gateway-degradation investigation plus sample-status reconciliation, drawing on the IR retainer.
  - Reputational impact / customer churn: hospital-partner trust and potential clinical-liability exposure dominate over laboratory ARR churn; the high end reflects a scenario where an incorrect result reaches a patient before detection.
- Assumptions:
  - Affected scope: a plausible worst case affects hundreds to low thousands of the ~62,000 daily samples.
  - Duration: the managed gateway is assumed generally effective, so this chain models a bounded degradation window, not a permanent bypass.
  - Notification scenario: DPO/legal review assumed at the central estimate; CNIL notification and clinical-liability review only assumed at the high end, where a released result is later found incorrect.
  - Churn scenario: modeled as hospital-relationship remediation rather than direct laboratory ARR churn, since the finding's primary harm is workflow integrity, not confidentiality.

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

Chain ranges are not additive with their component findings — they replace the standalone ranges for F-01/F-03/F-09/F-05/F-04/F-10 in a compounded-exploitation scenario and are the figures that matter if remediation sequencing is delayed, while the individual finding ranges are what disappears once each item is fixed independently.
