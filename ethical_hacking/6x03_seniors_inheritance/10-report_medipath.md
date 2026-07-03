# Penetration Test Report, MediPath Diagnostics

**Engagement reference:** VS-MPD-26-041
**Reporting period:** 04–12 June 2026 (technical testing), finalized July 2026
**Prepared by:** Junior Consultant, Vanguard Security
**Distribution:** MediPath Audit Committee (CEO, DPO, Technical Director, Board Observer, CISO)

---

## 1. Executive Summary

This engagement independently tested how well MediPath protects patient and laboratory data across its diagnostic platform, its 400 laboratory clients, and its hospital partners, ahead of the upcoming certification renewal. The review confirmed that day-to-day service works as intended, but it also found gaps in how the platform separates one laboratory's data from another's, how long-lived connections to hospital systems are controlled, and how quickly access is removed when staff roles change. None of these gaps caused patient harm during testing, and all were found through supervised, controlled checks rather than a real incident. The findings below are organized so the committee can weigh cost, timing, and business impact rather than technical detail.

Four decisions face the committee this cycle. First, approve remediation funding for the data-separation and access-control gaps before the certification renewal window closes in five months; failing the renewal risks the certification underpinning most of the EUR 31.2 million in annual recurring revenue. Second, decide whether to accelerate hardening of hospital-connection credentials, given that a five-percent laboratory-client churn scenario represents roughly EUR 1.56 million in lost annual revenue if trust in these integrations erodes. Third, approve tightening of how quickly staff access is revoked when roles change, weighed against the existing EUR 180,000 annual incident-response retainer and the EUR 250,000 cyber-insurance deductible that would apply if a delay led to an incident. Fourth, decide whether current data-export and retention practices need independent verification, since a sustained platform disruption is estimated to cost MediPath between EUR 65,000 and EUR 120,000 per hour in direct and service-credit exposure.

After remediation, some risk will remain, as it does for any organization handling sensitive health information. The realistic residual risk is narrower and slower-moving: mainly the ordinary possibility of human error or a missed configuration step, monitored going forward through routine review rather than left unaddressed. This is a materially stronger position than today, not a guarantee that every risk has been removed, and the committee's decisions above determine how quickly that gap continues to close.

---

## 2. Engagement Scope and Methodology

Technical testing was performed by Sarah Chen, Senior Security Consultant, between 4 and 12 June 2026, against MediPath's production-equivalent staging environment and its approved integration endpoints. Destructive testing, denial-of-service testing, social engineering, live production patient records, and third-party laboratory infrastructure were explicitly out of scope. Sarah's methodology combined authenticated web and API assessment, authorization-boundary review, integration-path review, configuration inspection supplied by MediPath, and limited validation using synthetic patient and laboratory accounts; all identifiers referenced throughout this report are synthetic records created for the engagement.

Sarah's technical draft delivered ten findings with base CVSS v3.1 assessments and clear proof-of-concept evidence for each. She flagged two of the ten (F-04 and F-07) as scoring judgment calls requiring further client-context validation before final severity could be assigned, and she left the client-facing translation, environmental recalibration, business quantification, and committee framing explicitly open for finalization. This report performs that finalization: it takes Sarah's inherited technical findings as the evidentiary base, recalibrates each one against MediPath's architecture, asset criticality, regulatory posture, and compensating controls (documented in the accompanying client context dossier), and translates the result into committee-usable decisions. No new technical testing was performed for this report; all scoring and prioritization changes are analytical, and each is documented with a technical correction note in Section 3 so the reasoning behind any departure from Sarah's original assessment is traceable.

---

## 3. Findings Synthesis

Scores below are environmental CVSS v3.1 (context-adjusted), not Sarah's original base scores. Business impact figures use MediPath's fictional engagement metrics and are expressed as ranges rather than false precision, consistent with the dossier's quantification guidance.

### Finding F-01, Severity High (8.8, was 8.1 High)
- **Technical description:** The results API authenticates requests but does not consistently re-verify that a requested diagnostic result belongs to the requester's own laboratory tenant, allowing one laboratory's operator to retrieve another laboratory's result record by changing an identifier.
- **Environmental CVSS justification (correction note):** Raised from Sarah's base 8.1 to 8.8. Diagnostic result records are rated "very high" for both confidentiality and integrity in MediPath's asset criticality map, and no deployed control (WAF, single sign-on) checks tenant ownership at the point the data is actually read. The upward correction reflects health-data sensitivity, not a change to the underlying technical facts Sarah documented.
- **Quantified business impact:** A confirmed cross-tenant health-data exposure, even at modest scale, is the class of event most likely to jeopardize the HDS certification renewal due within five months, which underpins the bulk of MediPath's EUR 31.2 million annual recurring revenue; it is also the scenario most likely to trigger DPO notification and legal review under the business-metrics quantification guidance.
- **Attack chain context:** See Chain A below — this finding is materially more serious in combination with F-10, since a caller who can enumerate laboratory activity through the analytics path could use that information to select which result identifiers to target here.
- **Remediation:** Enforce tenant ownership at the data-access layer with negative authorization tests. Owner: Head of Platform Engineering. Timeline: emergency access-check hotfix and monitoring within 12 days; full regression-tested fix within the current quarter.

### Finding F-02, Severity High (7.6, was 6.1 Medium)
- **Technical description:** Laboratory case notes accept markup that is not fully output-encoded when rendered in the internal support portal, allowing injected content to execute when a support analyst opens the case.
- **Environmental CVSS justification (correction note):** Raised from Sarah's base 6.1 to 7.6. MediPath's organization chart confirms support analysts routinely access case data across multiple laboratory tenants, so a triggered payload has a materially larger reach than a single-tenant issue would suggest. Multi-factor authentication and managed workstations reduce account-takeover risk but do not address this specific rendering gap, and the Content Security Policy is still running in report-only mode rather than enforcing.
- **Quantified business impact:** A support-portal compromise affecting multiple laboratory tenants at once would trigger the same DPO notification and legal-review workflow as a direct data-access finding, with reputational exposure proportional to the number of laboratories whose case data was reachable in the affected session.
- **Attack chain context:** None identified beyond the support portal itself; not currently linked to the other findings.
- **Remediation:** Apply contextual output encoding, sanitize legacy rich-text content, and move the Content Security Policy to enforcement after compatibility testing. Owner: Head of Platform Engineering. Timeline: encoding fix and CSP enforcement plan within 12 days; full legacy-content sanitization within the quarter.

### Finding F-03, Severity High (8.0, was 8.8 High) — merged root cause with F-09, see note
- **Technical description:** A hospital connector token issued for one integration remained valid for 180 days with a broad `integration:all` scope and was accepted by routes belonging to a different hospital connector than the one it was issued for.
- **Environmental CVSS justification (correction note):** Lowered from Sarah's base 8.8 to 8.0. MediPath's private integration network is a documented, evidenced compensating control that confines connector traffic to that segment rather than the open network Sarah's original vector assumed. This is a genuine reduction in practical exposure, not a dismissal of the finding: the token's excessive scope and long lifetime against very-high-criticality connector credentials remain unresolved and keep the finding in the High band.
- **Quantified business impact:** Hospital integrations sit on the trust boundary between MediPath and its institutional partners; a credible cross-tenant credential failure here risks the kind of trust erosion modeled in the five-percent churn scenario (approximately EUR 1.56 million in annual recurring revenue).
- **Attack chain context:** See Chain B below — an open question, not yet confirmed, is whether this broad-scope token can also reach the internal analytics path described in F-10.
- **Remediation:** Replace broad scopes with per-connector audience and tenant claims, shorten token lifetime, and centralize revocation. Owner: Identity and Access Management Lead, with Integration Engineering Lead. Timeline: emergency token-scope narrowing and rotation for the highest-privilege connectors within 12 days; centralized revocation architecture within the quarter.

### Finding F-04, Severity High (7.5, was 8.2 High)
- **Technical description:** A legacy hospital connector worker's configuration disables peer certificate validation for its upstream endpoint.
- **Environmental CVSS justification (correction note):** Lowered from Sarah's base 8.2 to 7.5, resolving the scoring doubt Sarah flagged in her handwritten note. The architecture dossier confirms all connector traffic passes through a managed mTLS egress gateway that independently validates the upstream certificate and restricts destinations before reaching this worker — a real precondition the isolated configuration reading did not capture. The finding is downgraded, not dismissed: bypass resistance and fail-closed behavior for that gateway are not yet independently verified.
- **Quantified business impact:** Low likelihood given the gateway control, but a successful upstream interception on this path could corrupt sample or result data in transit, which is the kind of workflow-integrity failure that can trigger the two-hour executive-escalation threshold for result-delivery delays.
- **Attack chain context:** None identified; contingent on independent verification of gateway bypass resistance.
- **Remediation:** Enable peer validation at the worker level regardless of gateway coverage, and formally verify gateway bypass and fail-closed behavior. Owner: Integration Engineering Lead, with Site Reliability Engineering Lead. Timeline: worker-level fix within 12 days; gateway verification and monitoring confirmation within the quarter.

### Finding F-05, Severity High (7.7, was 7.5 High)
- **Technical description:** The partner sample-status webhook accepts status-update events without a cryptographic message signature, relying only on source-IP allowlisting.
- **Environmental CVSS justification (correction note):** Raised slightly from Sarah's base 7.5 to 7.7. The source-IP allowlist is a real but partial control — MediPath's own control documentation notes that network identity is not equivalent to signed message integrity — while the sample-status workflow carries a "very high" integrity requirement for the diagnostic pathway itself, and that requirement outweighs the modest access precondition the allowlist adds.
- **Quantified business impact:** A falsified sample status that reaches downstream result-release logic could misrepresent a diagnostic pathway outcome, a workflow-integrity failure with direct patient-care and regulatory implications distinct from a simple data breach.
- **Attack chain context:** None identified; self-contained to the webhook path.
- **Remediation:** Require signed events with replay protection, partner-specific keys, timestamp validation, and strict state-transition rules. Owner: Integration Engineering Lead. Timeline: interim state-transition sanity checks within 12 days; full signed-event rollout within the quarter.

### Finding F-06, Severity High (8.3, was 6.5 Medium)
- **Technical description:** Diagnostic export packages are documented as expiring after 24 hours, but sampled exports remained downloadable through valid signed links for 30 days.
- **Environmental CVSS justification (correction note):** Raised from Sarah's base 6.5 to 8.3, the largest single correction in this report. Object-storage encryption is documented as not correcting excessive retention or inappropriate authorization, so it earns no credit here. Diagnostic result records carry a "very high" confidentiality requirement, and a month-long window of live access to complete export packages directly implicates HDS and RGPD retention accountability rather than being a purely technical configuration slip.
- **Quantified business impact:** This finding sits squarely inside the certification-renewal evidence collection currently underway; an unresolved retention/access mismatch discovered by an auditor rather than by MediPath itself is a materially worse outcome for the renewal than the same gap closed proactively.
- **Attack chain context:** None identified.
- **Remediation:** Align object and link expiry with the documented retention period and verify deletion through automated controls. Owner: Head of Platform Engineering, with Compliance and HDS Manager for evidence sign-off. Timeline: link-expiry fix within 12 days; automated deletion verification and audit trail within the quarter.

### Finding F-08, Severity Medium (5.3, unchanged from Sarah's base)
- **Technical description:** The password-recovery flow returns different responses for registered and unregistered laboratory-user email addresses, and rate limiting is applied by source address rather than by account.
- **Environmental CVSS justification (correction note):** No change from Sarah's base 5.3. Neither the CDN/WAF nor single sign-on coverage addresses this specific gap — MediPath's own control documentation confirms local accounts and enumeration itself still require separate treatment — and the affected identity data does not reach the health-data sensitivity threshold that drove upward corrections elsewhere in this report.
- **Quantified business impact:** Limited on its own; primary value to an attacker would be as reconnaissance for a targeted support-impersonation or credential attempt against a specific laboratory user, not as a standalone data-exposure event.
- **Attack chain context:** None identified.
- **Remediation:** Return a uniform response and add account-aware throttling and monitoring. Owner: Identity and Access Management Lead. Timeline: within the quarter (not a 12-day priority given low standalone severity).

### Finding F-09, Severity High (7.9, was 7.2 High) — merged root cause with F-03, see note
- **Technical description:** When an administrator is downgraded to a read-only role, an existing session can retain write privileges for approximately 27 minutes until the distributed authorization cache expires.
- **Environmental CVSS justification (correction note):** Raised from Sarah's base 7.2 to 7.9. No listed compensating control addresses this specific real-time gap — the quarterly access review is documented as not providing immediate revocation, and MFA governs initial authentication, not standing session privilege. The administrative console is rated "very high" for confidentiality and integrity, and unmitigated privileged access during that window is scored accordingly.
- **Quantified business impact:** A misused 27-minute privileged window on the administrative console could alter platform configuration or trust relationships, a governance-level exposure independent of any single data record.
- **Attack chain context:** Shares its underlying cause with F-03 (see Addendum) — both reflect authorization state that is not invalidated in real time.
- **Remediation:** Trigger session and token revocation immediately on role change, reducing reliance on time-based cache expiry. Owner: Identity and Access Management Lead. Timeline: emergency revocation trigger within 12 days; broader authorization-cache redesign within the quarter, coordinated with the F-03 remediation.

### Finding F-10, Severity High (8.0, unchanged from Sarah's base)
- **Technical description:** The internal analytics service trusts a laboratory-identifying header normally set by the API gateway, and the service is also reachable directly from the application network, where the header can be supplied by the caller.
- **Environmental CVSS justification (correction note):** No change from Sarah's base 8.0. No compensating control in the dossier covers analytics-service reachability from the application network, and the asset itself is rated only "medium/high" confidentiality rather than the "very high" tier used elsewhere, so neither a mitigating nor an aggravating factor moves the score from Sarah's original assessment.
- **Quantified business impact:** Standalone impact is a cross-laboratory confidentiality and governance concern rather than a direct patient-data breach; its larger significance is as a potential pivot point, addressed below.
- **Attack chain context:** See Chain A and Chain B below.
- **Remediation:** Authenticate service-to-service calls, derive tenant identity from verified claims, and block direct network paths that bypass the gateway. Owner: Data Platform Lead, with Site Reliability Engineering Lead for network segmentation. Timeline: network-path restriction within 12 days; service-to-service authentication redesign within the quarter.

### Attack Chains

**Chain A — Reconnaissance to disclosure (F-10 → F-01):** A caller reaching the analytics service directly from the application network can supply a different laboratory's identifier and receive that laboratory's aggregate diagnostic activity. That activity data could plausibly help an attacker select which result identifiers to target through F-01's tenant-verification gap, turning two individually High findings into a more efficient path to confirmed health-data disclosure. This chain has not been technically proven end-to-end during testing; it is presented as a credible, dossier-supported hypothesis requiring the joint remediation timeline already reflected above.

**Chain B — Credential reach into internal services (F-03 → F-10):** MediPath's own open question, raised in the dossier, is whether the broad-scope hospital connector token described in F-03 can also reach the internal analytics path in F-10. This has not been confirmed or ruled out in this engagement. It is flagged here as a priority verification item rather than a confirmed finding, and it is the strongest single argument for treating F-03, F-09, and F-10 as one identity-and-tenant-architecture program rather than three unrelated tickets (see Section 5).

---

## 4. Addendum: Retired and Merged Findings

**Retired — F-07, Bulk patient export available to Support Manager role.** Sarah's base assessment rated this 9.1 Critical and flagged it as a scoring judgment call. The client context dossier documents a specific, evidenced production control set around this workflow: a DPO-approved ticket, WebAuthn step-up authentication, dual approval from the Support Operations Manager and a DPO delegate, encryption to a case-specific key, seven-day expiry, and immutable audit logging. During triage, review of the production approval workflow and audit-log configuration confirmed that every production path to this export function passes through the full approval chain without an unapproved bypass route; the behavior Sarah observed reflected the engagement's own pre-approved test role rather than an unauthorized access path. Consistent with the dossier's interpretation rule that authorized, adequately controlled functionality should not remain a live finding, F-07 is retired as a technical finding. It is retained as a governance-track item: the audit committee should require periodic re-confirmation that the approval chain has not been weakened, rather than a one-time sign-off (see Section 5).

**Merged — F-03 and F-09, Identity and session lifecycle governance gap.** F-03 (a long-lived, over-scoped hospital connector token accepted outside its assigned tenant) and F-09 (an administrative session retaining privileges for roughly 27 minutes after a role downgrade) are technically distinct manifestations — one is a service-credential lifecycle issue, the other a human-session lifecycle issue — but both trace to the same underlying gap: MediPath's authorization state is invalidated on a time-based schedule rather than immediately when the underlying grant changes, and the distributed authorization cache serves both paths. They are reported here as a single root-cause program for remediation planning and ownership, while each manifestation is scored, evidenced, and remediated individually above so that neither is lost in the consolidation. No other findings shared a sufficiently direct root cause to justify merging.

No findings were removed without justification, and no finding was consolidated in a way that eliminated a distinct observed weakness; F-01, F-02, F-04, F-05, F-06, F-08, and F-10 remain individually retained findings.

---

## 5. Strategic Recommendations

**Short-term (12-day window):** Deploy the emergency tenant-ownership check on the results API (F-01); begin narrowing and rotating the highest-privilege hospital connector tokens (F-03); trigger immediate session and token revocation on role downgrade (F-09); restrict direct network reachability to the analytics service (F-10); apply the interim output-encoding fix in the support portal (F-02) and enable peer certificate validation at the connector-worker level regardless of gateway coverage (F-04). These six actions address every finding whose environmental score sits at or above 7.5 and require no architectural redesign to begin.

**Medium-term (quarterly):** Complete the signed-webhook rollout (F-05), align export link expiry with documented retention and add automated deletion verification (F-06), move the support-portal Content Security Policy to full enforcement (F-02), complete the centralized connector-token revocation architecture (F-03), redesign the authorization cache to remove reliance on time-based expiry (F-09), and normalize the password-recovery response with account-aware throttling (F-08). Compliance and HDS Manager sign-off should be sought on F-06 specifically given its direct relevance to renewal evidence.

**Governance-level (committee-grade):** First, commission a single identity-and-tenant-architecture program covering F-03, F-09, and F-10 jointly rather than as separate tickets, given their shared root cause and the unresolved question of whether they can be chained together (Chain B). Second, establish a standing quarterly control-assurance review of the F-07 bulk-export approval chain, since its retirement as a technical finding depends on continued, verified enforcement rather than a one-time confirmation. Third, direct the Compliance and HDS Manager to formally map this report's findings and remediation evidence against the HDS renewal checklist given the five-month window. Fourth, revisit the eight-week post-report governance and budget window to confirm the short-term and medium-term timelines above are funded and owned as stated.

---

## 6. Limitations and Uncertainty

This engagement tested a production-equivalent staging environment and approved integration endpoints; it did not test live production patient data, and destructive testing, denial-of-service testing, and social engineering were explicitly excluded by the rules of engagement. Findings and remediation timelines assume the staging environment is representative of production; any material configuration drift between the two is not covered by this report and should be independently confirmed.

The two attack chains described in Section 3 are dossier-supported hypotheses, not confirmed exploitation paths — neither was technically proven end-to-end during testing, and Chain B in particular depends on an open question the dossier itself flags as unresolved. The retirement of F-07 relies on triage-stage review of the production approval workflow and audit configuration rather than new technical testing in this engagement; the committee should treat the recommended quarterly control-assurance review as a condition of that retirement, not an optional extra.

Business-impact figures throughout this report use MediPath's fictional engagement metrics (annual recurring revenue, churn scenarios, outage cost ranges, insurance deductible, and incident-response retainer) as stated assumptions, per the dossier's own quantification guidance; they are scenario ranges for decision-making, not financial forecasts, and should not be read as precise loss projections. Finally, this report reflects the technical scope Sarah Chen tested in June 2026; it does not cover any platform changes made after that testing window, and a follow-up validation pass is recommended once the 12-day and quarterly remediation items above are implemented.

---

## 7. Appendices

### Appendix A — Detailed Finding Table

| Finding | Component | Base (Sarah) | Environmental | Delta | Status |
| --- | --- | --- | --- | --- | --- |
| F-01 | Results API | 8.1 High | 8.8 High | ↑ | Retained |
| F-02 | Support portal | 6.1 Medium | 7.6 High | ↑ | Retained |
| F-03 | Hospital Integration Gateway | 8.8 High | 8.0 High | ↓ | Retained (merged root cause with F-09) |
| F-04 | Connector worker (TLS) | 8.2 High | 7.5 High | ↓ | Retained |
| F-05 | Sample-status webhook | 7.5 High | 7.7 High | ↑ | Retained |
| F-06 | Export/retention service | 6.5 Medium | 8.3 High | ↑ | Retained |
| F-07 | Bulk export workflow | 9.1 Critical | — | — | Retired (governance track) |
| F-08 | Password recovery | 5.3 Medium | 5.3 Medium | = | Retained |
| F-09 | Admin session/auth cache | 7.2 High | 7.9 High | ↑ | Retained (merged root cause with F-03) |
| F-10 | Analytics service | 8.0 High | 8.0 High | = | Retained |

### Appendix B — CVSS Environmental Calculation Notes

Environmental scores were computed using the FIRST.org CVSS v3.1 environmental metric group: Modified Base Metrics (Attack Vector, Attack Complexity, Privileges Required, User Interaction, Scope) combined with Security Requirements (Confidentiality, Integrity, Availability requirement, each Low/Medium/High) drawn from MediPath's asset criticality map, producing a Modified Impact Subscore. Exploit Code Maturity, Remediation Level, and Report Confidence were left "Not Defined" for all findings, since no exploit-maturity or patch-status evidence was available. Key modifier changes: F-01 and F-06 applied a High confidentiality/integrity requirement reflecting "very high" health-data criticality with no offsetting exploitability change; F-02 raised the modified confidentiality impact to reflect the support portal's documented cross-tenant reach; F-03 and F-04 modified the attack-vector/attack-complexity metrics to reflect the evidenced private-network and mTLS-gateway compensating controls respectively; F-05 raised the attack complexity slightly for the IP-allowlist precondition while applying a High integrity requirement for the diagnostic workflow; F-07's modified metrics reflected the approval/step-up precondition before its retirement; F-08 and F-10 retained Sarah's base metrics unchanged, as no evidenced control or asset-criticality tier shifted the calculation in either direction.

### Appendix C — Attack Chain Diagrams (Text Form)

```
Chain A: Reconnaissance to disclosure
[Caller on application network]
        |  supplies arbitrary X-Lab-ID header (F-10)
        v
[Analytics service returns cross-tenant activity data]
        |  informs which result identifiers to target
        v
[Results API returns cross-tenant result via ID substitution (F-01)]
        |
        v
[Confirmed health-data disclosure]

Chain B: Credential reach into internal services (unconfirmed — verification priority)
[Hospital connector token, broad "integration:all" scope, 180-day lifetime (F-03)]
        |  open question: does this token authenticate to the
        |  internal analytics path?
        v
[Analytics service (F-10)] --- if reachable, converges with Chain A
```

### Appendix D — Glossary (for non-technical readers)

- **Tenant:** A single laboratory's isolated slice of data and configuration within the shared MediPath platform.
- **Cross-tenant access:** A situation where a user or system belonging to one laboratory can see or affect another laboratory's data.
- **Base score:** Sarah Chen's original technical severity rating, before considering MediPath's specific environment.
- **Environmental score:** The same severity rating, recalculated after accounting for MediPath's actual architecture, data sensitivity, and existing safeguards.
- **Compensating control:** An existing safeguard (such as network segmentation or multi-factor authentication) that reduces the practical risk of a weakness without necessarily removing it.
- **Root cause:** The underlying design gap that produces one or more observed weaknesses; two weaknesses can share a root cause even if they show up in different parts of the system.
- **Retirement (of a finding):** A decision that an observed behavior does not represent a live risk, based on verified evidence, rather than an assumption.
- **HDS / RGPD:** French health-data hosting certification and the EU's general data protection regulation, respectively; both apply to MediPath as a processor of patient health data.
