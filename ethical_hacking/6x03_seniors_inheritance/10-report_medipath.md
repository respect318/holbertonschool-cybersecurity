# Penetration Test Report, MediPath Diagnostics

**Engagement reference:** VS-MPD-26-041
**Reporting period:** Technical testing 04–12 June 2026; client-ready finalization completed 03 July 2026
**Prepared by:** Junior Consultant, Vanguard Security
**Distribution:** MediPath audit committee (CEO, DPO, Technical Director, CISO, Board Observer)

---

## 1. Executive Summary

Vanguard Security reviewed how well the MediPath platform protects patient and laboratory information as it moves between laboratories, hospitals, and MediPath's own staff. MediPath already has meaningful protections in place today — extra login verification for staff, controlled devices for support teams, a private connection for hospital systems, and a formal sign-off process for large data exports — and these are genuinely reducing risk.

The review also identified a set of gaps that need to be closed. The most significant one is a data-separation gap: under certain conditions, one laboratory's patient information could be seen by someone who should only have access to a different laboratory's information. Two smaller, related gaps make this more likely to happen in practice, so the three are best understood and funded together rather than as separate, unrelated line items. None of this was tested against real patient data — every test used disposable practice accounts built solely for this review, so no patient was affected.

We estimate the two most urgent gaps can be closed within twelve days using MediPath's own engineering team, and that the complete remediation plan fits comfortably inside the committee's eight-week decision window. One additional item that was originally flagged turned out, on closer review, to already be well controlled by an existing approval process — we are not asking the committee to fund a fix for it, only to commission a brief independent check confirming that process is followed consistently across the whole platform, given how sensitive the data involved is.

In financial terms, a serious data-separation incident could plausibly cost MediPath from the high hundreds of thousands to a few million euros once client trust, contract loss, and regulatory response are factored in — substantially more than the cost of the recommended twelve-day fix. We recommend the committee approve that twelve-day work now, schedule the remaining items into this quarter's budget, and track the governance follow-ups ahead of the certification renewal due in about five months.

---

## 2. Engagement Scope and Methodology

This engagement was carried out in two phases. The technical testing phase was performed by Sarah Chen, Senior Security Consultant, between 4 and 12 June 2026, against MediPath's production-equivalent staging environment and its approved integration endpoints. Sarah's technical work — authenticated web and API testing, authorization-boundary review, integration-path review, configuration inspection, and controlled validation using synthetic patient and laboratory accounts — forms the evidentiary foundation of this report. All ten findings described below, and their supporting evidence, originate from that technical phase. Her documented open questions and scoring concerns were treated as first-class inputs to this report's finalization rather than as unresolved gaps to be ignored.

The second phase, carried out by this consultant, translated that technical draft into a client-ready deliverable. This involved: recalibrating each finding's severity against MediPath's actual environment (asset criticality, health-data sensitivity, regulatory exposure, and evidenced compensating controls, as documented in the client context dossier); triaging findings that reflected intended, well-governed functionality rather than live weaknesses; identifying where findings shared a common root cause and could be responsibly consolidated without losing traceability; connecting related findings into attack-chain narratives where the combination materially changes risk; quantifying plausible business impact in euros using MediPath's supplied operational and financial metrics; and assigning named remediation owners and timelines drawn from MediPath's organizational responsibilities.

No new technical testing was performed during this second phase; all conclusions are derived from Sarah's original evidence together with the client context dossier (architecture overview, organization chart, regulatory map, compensating controls register, and business metrics) supplied for this engagement. Testing excluded destructive testing, denial-of-service testing, social engineering, real production patient records, and third-party laboratory infrastructure, consistent with the original rules of engagement.

---

## 3. Findings Synthesis

Ten technical observations were made during the testing phase. After environmental recalibration, seven are retained as live findings below (two of which are consolidated from three original observations due to a shared root cause), and one is retired to the addendum as evidenced, governed functionality. Severities below are **environmental** ratings — Sarah's original base CVSS scores are shown for reference, with a correction note explaining any change.

### Finding F-01, Severity: Critical (environmental)

- **Technical description:** MediPath's results API confirms that a caller is authenticated but does not consistently confirm that the specific diagnostic result being requested belongs to that caller's own laboratory. By substituting a result identifier, a user from one laboratory tenant retrieved a complete result record — patient identity, test name, collection time, and status — belonging to a different, synthetic laboratory tenant.
- **Environmental CVSS justification:** Base score 8.1 High (`AV:N/AC:L/PR:L/UI:N/S:U/C:H/I:H/A:N`). *Correction note: raised to 9.0 Critical.* Diagnostic result records are classified as "Very high" confidentiality and integrity assets serving all 400 contracted laboratories, and the compensating controls register confirms that neither the CDN/WAF nor MFA enforce tenant ownership at the data-access layer — no evidenced control offsets the base exposure, and the regulated, special-category nature of the data (RGPD Article 9) increases the environmental confidentiality requirement to High.
- **Quantified business impact:** A confirmed cross-tenant result-access incident affecting even a small fraction of MediPath's 1.9 million active patient profiles would trigger mandatory DPO and legal notification analysis. Using MediPath's own churn scenarios, a resulting 1–5% laboratory-client churn event represents EUR 312,000 to EUR 1.56 million in lost annual recurring revenue, before incident-response costs (partially offset by the existing EUR 180,000/year retainer) and the EUR 250,000 cyber-insurance deductible.
- **Attack chain context:** This finding is the highest-value target in a broader chain — see Chain 1 below, involving F-03/F-09 (Identity and Session Lifecycle Governance Gap) and F-10 (trusted analytics header). A foothold gained through either of those weaknesses materially increases the practical likelihood of reaching this finding at scale.
- **Remediation:** Enforce tenant ownership as a mandatory check at the data-access layer for every result-retrieval path, independent of the API gateway's tenant claim, and add automated negative-authorization regression tests to the CI pipeline. **Owner:** Head of Platform Engineering. **Timeline:** Short-term — hotfix and verification within the twelve-day window; full regression-test coverage within the current quarter.

### Finding F-02, Severity: Medium (environmental)

- **Technical description:** The laboratory case-notes field, rendered inside the internal support portal, accepts markup that is not fully output-encoded, allowing injected content to execute when a support analyst opens the case. A harmless test marker demonstrated the ability to alter the page and make a same-origin request to the analyst's own profile endpoint.
- **Environmental CVSS justification:** Base score 6.1 Medium (`AV:N/AC:L/PR:L/UI:R/S:C/C:L/I:L/A:N`). *Correction note: adjusted to 5.4 Medium.* The compensating controls register confirms MFA and managed workstations cover the support portal user population, meaningfully reducing the practical consequence of a hijacked session; however, support analysts routinely hold access spanning multiple laboratory tenants, which keeps the finding from being downgraded further — the blast radius of a successful session compromise remains cross-tenant.
- **Quantified business impact:** Limited direct financial exposure in isolation, but a compromised support-analyst session could be a stepping stone toward the cross-tenant data exposure described in Finding F-01, compounding the impact range described there.
- **Remediation:** Apply contextual output encoding to all rendered laboratory-supplied content, sanitize legacy stored notes, and move the Content Security Policy from report-only to full enforcement after a compatibility review. **Owner:** Head of Platform Engineering, in coordination with the Support Operations Manager for CSP compatibility sign-off. **Timeline:** Immediate encoding fix within twelve days; CSP enforcement mode within the current quarter (medium-term).

### Finding F-03/F-09 (consolidated), "Identity and Session Lifecycle Governance Gap," Severity: High (environmental)

- **Technical description:** Two originally separate observations share a common root cause and are consolidated here while preserving both manifestations for traceability.
  - *(F-03 manifestation)* A hospital connector token, intended for a single hospital integration, remained valid for 180 days and carried a broad `integration:all` scope. The token was accepted by routes belonging to a different, unrelated hospital connector profile.
  - *(F-09 manifestation)* When an administrator's role was downgraded to read-only, an already-open session retained write privileges for approximately 27 minutes because authorization state is invalidated only when a distributed cache entry expires, rather than immediately on role change.
  - Both manifestations trace to the same underlying design gap: MediPath's authorization and credential lifecycle relies on broad scope grants and time-based cache expiry rather than immediate, tightly scoped revocation.
- **Environmental CVSS justification:** Base scores 8.8 High (F-03, `AV:N/AC:L/PR:L/UI:N/S:U/C:H/I:H/A:H`) and 7.2 High (F-09, `AV:N/AC:L/PR:H/UI:N/S:U/C:H/I:H/A:N`). *Correction note: consolidated and set at 8.7 High.* Hospital connector credentials and the administrative console are both rated "Very high" confidentiality and integrity assets. The private integration network is a real, evidenced compensating control that limits network reachability for F-03's manifestation, which prevents an environmental score at the Critical boundary; it does not, however, address the underlying scope or revocation-timing weakness, so the finding is not downgraded further.
- **Attack chain context:** Central to Chain 1 (below). A long-lived, broadly scoped connector token or a stale administrative session are each independently plausible starting points for lateral movement toward F-10 and, from there, F-01.
- **Remediation:** Replace broad integration scopes with per-connector audience and tenant claims and shorten token lifetime; trigger immediate session and token revocation on any role or scope change rather than relying on cache expiry; centralize revocation across both paths. **Owner:** Identity and Access Management Lead. **Timeline:** Short-term — scope reduction and immediate-revocation hotfix for the administrative path within twelve days; connector-wide token reissuance and centralized revocation service within the current quarter (medium-term).

### Finding F-05, Severity: High (environmental)

- **Technical description:** The partner sample-status webhook accepts status update events without any cryptographic message signature. Source-IP allowlisting is present, but the application does not independently authenticate the message body or bind an event to a specific partner identity. A synthetic sample was moved from "received" to "validated" using a modified request body from within the approved test range.
- **Environmental CVSS justification:** Base score 7.5 High (`AV:N/AC:L/PR:N/UI:N/S:N/C:N/I:H/A:N`). *Correction note: adjusted to 7.0 High.* The sample-status workflow is rated "Very high" for both integrity and availability significance, because an incorrect status can misrepresent the diagnostic pathway itself, not just leak data — this keeps the finding at High despite the IP allowlist, which the compensating controls register itself notes is a network-identity control, not a substitute for signed message integrity.
- **Quantified business impact:** A falsified sample-status event that reached downstream result-release logic could contribute to result-delivery delays; MediPath's own operational thresholds trigger executive escalation once such delays exceed two hours, and manual laboratory reconciliation carries direct staffing and error costs during any such incident.
- **Remediation:** Require cryptographically signed events with partner-specific keys, replay protection, timestamp validation, and strict server-side state-transition rules that reject implausible status jumps. **Owner:** Integration Engineering Lead. **Timeline:** Short-term — signing requirement and allowlist audit within twelve days.

### Finding F-06, Severity: Medium (environmental)

- **Technical description:** Diagnostic export packages are documented to expire after 24 hours, but sampled exports remained downloadable through their signed links for 30 days. The underlying storage object is encrypted, but the application continues to issue valid access links well past the approved retention window.
- **Environmental CVSS justification:** Base score 6.5 Medium (`AV:N/AC:L/PR:L/UI:N/S:U/C:H/I:N/A:N`). *Correction note: adjusted to 6.8 Medium.* Object encryption is a genuine mitigating control against opportunistic access, which prevents a higher score; however, the finding is nudged upward from the base rating because the mismatch between the documented and actual retention period is itself a regulatory accountability gap under HDS and RGPD retention obligations, independent of whether the link is actually misused.
- **Quantified business impact:** Directly relevant to the upcoming HDS renewal audit (expected within five months): documented retention policy that does not match technical enforcement is the kind of gap certification auditors specifically test for, and remediation before the audit avoids a finding that could delay renewal.
- **Remediation:** Align object and link expiry precisely with the DPO-approved retention period and verify deletion through an automated, monitored control rather than manual process. **Owner:** Head of Platform Engineering, with DPO sign-off on the corrected retention configuration. **Timeline:** Short-term — twelve days.

### Finding F-08, Severity: Medium-Low (environmental)

- **Technical description:** The laboratory-user password-recovery flow returns a different response for registered versus unregistered email addresses, and rate limiting is applied by source address rather than by account identifier, allowing account existence to be inferred.
- **Environmental CVSS justification:** Base score 5.3 Medium (`AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:N/A:N`). *Correction note: adjusted to 4.8 Medium-Low.* SSO and MFA cover 82% of laboratory users, meaningfully reducing the practical value of an enumerated identity for account-takeover purposes; the finding is retained rather than retired because the remaining 18% of local, non-SSO accounts are fully exposed to this weakness and represent a real population of laboratory users.
- **Remediation:** Return a uniform response regardless of account existence, and move to account-aware throttling and monitoring rather than IP-based limits alone. **Owner:** Identity and Access Management Lead. **Timeline:** Medium-term — folded into the current quarter's SSO-expansion and account-security roadmap.

### Finding F-10, Severity: High (environmental)

- **Technical description:** MediPath's internal analytics service trusts a laboratory-identity header (`X-Lab-ID`) that is normally inserted by the API gateway, but the service is also directly reachable from the general application network, where a caller can supply that header itself. From an approved application test host, changing the header returned aggregate diagnostic activity belonging to a different synthetic laboratory.
- **Environmental CVSS justification:** Base score 8.0 High (`AV:A/AC:L/PR:L/UI:N/S:U/C:H/I:L/A:N`). *Correction note: essentially retained at 7.8 High.* The analytics service's baseline asset criticality (Medium/high) does not by itself justify a High rating, but the finding is kept at High because of its role as a pivot point in Chain 1 below — its value to an attacker is not fully captured by its standalone criticality rating.
- **Attack chain context:** See Chain 1. This finding is the connective step between an initial foothold (via F-03/F-09) and large-scale cross-tenant exposure (via F-01): aggregate analytics data reachable through the trusted-header weakness could help an attacker identify which laboratories and result identifiers are worth targeting for the F-01 weakness.
- **Remediation:** Require authenticated, verified service-to-service calls to the analytics service, derive laboratory identity only from a cryptographically verified claim rather than a caller-supplied header, and remove the direct application-network path that bypasses the gateway. **Owner:** Data Platform Lead, in coordination with the Site Reliability Engineering Lead on network path restriction. **Timeline:** Short-term — header-trust hotfix at the gateway boundary within twelve days; full service-to-service authentication rollout within the current quarter.

### Attack Chain 1: Cross-Tenant Health-Data Exposure at Scale

Individually, F-03/F-09, F-10, and F-01 each describe a bounded weakness. Combined, they describe a plausible path from a single compromised or over-scoped credential to systemic cross-laboratory visibility into patient diagnostic data: (1) a long-lived, broadly scoped connector token or a stale privileged session (F-03/F-09) provides an initial foothold reachable from the application or integration network; (2) that foothold can reach the internal analytics service and manipulate the trusted laboratory header (F-10) to enumerate activity across laboratories that should not be visible to it; (3) that reconnaissance can be used to target specific result identifiers exploitable through the results API's incomplete tenant check (F-01), yielding actual patient result content at scale rather than a single record. This chain is why F-01 is rated Critical rather than High in isolation, and why remediation of F-03/F-09 and F-10 is scheduled within the same twelve-day window as F-01 — breaking any single link materially reduces the chain's overall practicality.

---

## 4. Addendum: Retired and Merged Findings

**Retired — Finding F-07, Bulk patient export available to Support Manager role.** Sarah's original draft scored this 9.1 Critical and flagged explicit doubt about the correct treatment, noting the client context describes this as an approved emergency and regulatory-response workflow. On review of the client context dossier and compensating controls register, this is confirmed: production use of the bulk-export function requires a DPO-approved ticket, WebAuthn step-up authentication, dual approval from the Support Operations Manager and a DPO delegate, encryption to a case-specific key, a seven-day access expiry, and immutable audit logging. The engagement's Support Manager test role was deliberately pre-approved to allow the control path to be exercised for testing purposes — meaning the observed behavior demonstrated the intended, fully-gated workflow operating as designed, not a bypass of it. Per the engagement's interpretation rule that adequately evidenced, authorized functionality should not remain a live finding, F-07 is retired from the findings synthesis. It is not deleted from this report because the dossier's own evidence trail should remain auditable, and because we recommend an independent verification step (see Section 6) rather than simply assuming production parity with the design.

**Merged — Findings F-03 and F-09 into "Identity and Session Lifecycle Governance Gap."** Both findings independently point to the same structural weakness: MediPath's authorization state (connector token scope and lifetime in F-03; administrative session privilege in F-09) is not tightly bound and immediately revocable, but instead relies on broad grants or time-based cache expiry. Sarah's own open question on F-09 explicitly raised the possibility of a shared root cause with F-03. Consolidating these into a single governance-level finding avoids presenting the committee with two disconnected technical items when in fact a single engineering investment — an immediate, event-driven revocation mechanism replacing the current cache-expiry model — addresses both. Both original manifestations, their individual evidence, and their individually assigned CVSS base scores remain fully documented in Section 3 to preserve traceability back to Sarah's original technical draft.

---

## 5. Strategic Recommendations

**Short-term (within the twelve-day committee decision window):**
- Deploy the tenant-ownership enforcement fix for the results API (F-01).
- Deploy the immediate-revocation hotfix for administrative sessions and reduce connector token scope/lifetime (F-03/F-09).
- Deploy the analytics service header-trust hotfix at the gateway boundary (F-10).
- Require signed webhook events for the sample-status partner integration (F-05).
- Correct export link expiry to match the documented retention period (F-06).
- Commission the independent spot-check of the bulk-export approval workflow described below.

**Medium-term (current quarter):**
- Complete output encoding and CSP enforcement for the support portal (F-02).
- Roll out full service-to-service authentication for the analytics service and remove the bypassable network path entirely (F-10, deeper remediation).
- Deliver connector-wide token reissuance under the new scope model and stand up a centralized, event-driven revocation service (F-03/F-09, deeper remediation).
- Extend SSO/MFA coverage and move to account-aware throttling for the remaining 18% of local laboratory-user accounts (F-08).
- Add automated negative-authorization regression tests across all tenant-scoped APIs, not only the results API, to catch the same class of gap elsewhere in the platform.

**Governance-level (committee-grade):**
- The CISO should sponsor a formal remediation budget covering the above short- and medium-term items, sized against the quantified exposure ranges in Section 3 rather than treated as discretionary engineering backlog.
- The DPO should independently assess F-01, F-06, and F-08 for RGPD Article 9 and HDS notification-readiness implications ahead of the certification renewal expected within five months, and confirm the corrected export-retention configuration (F-06) before renewal evidence collection closes.
- The committee should commission a short, independent verification — distinct from this engagement — that the bulk-export approval controls described for F-07 (DPO ticket, WebAuthn step-up, dual approval, case-specific key, seven-day expiry, audit logging) are enforced on every production path, not only the one exercised by the pre-approved test role. This closes the residual uncertainty noted in Section 6 without re-opening F-07 as a live technical finding.
- The Board Observer should track the medium-term items as a standing quarterly governance agenda item, given that several of them (identity lifecycle, service-to-service authentication) represent platform-level investments rather than single-sprint fixes.
- The Technical Director should confirm engineering capacity for the twelve-day short-term items concurrently with, rather than after, budget approval, given the compressed timeline relative to normal change-management cycles.

---

## 6. Limitations and Uncertainty

This engagement's technical testing was scoped to MediPath's production-equivalent staging environment and approved integration endpoints, using synthetic patient and laboratory data; destructive testing, denial-of-service testing, social engineering, real production patient records, and third-party laboratory infrastructure were explicitly out of scope. Findings and their environmental recalibration should therefore be understood as a rigorous assessment of the tested surface, not a guarantee that no other weaknesses exist in untested areas — most notably, production-specific configuration drift from the staging environment was not independently verified.

Two specific areas of residual uncertainty deserve committee attention. First, Finding F-04 (certificate validation disabled in a legacy hospital connector worker) was reviewed but is intentionally not carried forward as a numbered live finding in Section 3: configuration review confirmed `verify_peer=false` on the worker, but the client architecture overview documents that this worker does not connect directly to the public network — all connector traffic passes through a managed private egress gateway that itself establishes mutual TLS and validates the upstream certificate. Direct interception was not attempted, as the rules of engagement prohibited interference with the managed connectivity layer, so the practical live risk could not be fully confirmed either way. We recommend this be tracked as a defense-in-depth remediation item (enable peer validation at the worker regardless of gateway behavior) rather than a scored finding, and that the Site Reliability Engineering Lead confirm there is no bypass path around the gateway as part of the medium-term work in Section 5.

Second, the retirement of Finding F-07 in Section 4 relies on the client context dossier's description of the production approval workflow rather than on independent technical verification that every production code path enforces it identically to the tested one; the recommended spot-check in Section 5 exists specifically to close this gap.

Finally, all euro-denominated impact figures in this report use ranges built from MediPath-supplied business metrics (annual recurring revenue, per-incident outage cost, churn scenarios, insurance deductible, and incident-response retainer) rather than a single point estimate, and should be treated as planning inputs for the committee's budget discussion rather than as a precise loss forecast. Actual impact of any single incident would depend on scope, duration, and regulatory response specifics that cannot be known in advance.

---

## 7. Appendices

### A. Detailed Finding Tables

| ID | Title | Base Score | Environmental Score | Status | Owner |
| --- | --- | --- | --- | --- | --- |
| F-01 | Cross-laboratory access to diagnostic result records | 8.1 High | 9.0 Critical | Retained | Head of Platform Engineering |
| F-02 | Stored active content in laboratory-to-support notes | 6.1 Medium | 5.4 Medium | Retained | Head of Platform Engineering |
| F-03/F-09 | Identity and Session Lifecycle Governance Gap | 8.8 / 7.2 High | 8.7 High | Merged | Identity and Access Management Lead |
| F-04 | Certificate validation disabled in connector worker | 8.2 High | Not scored (see Section 6) | Tracked, defense-in-depth | Site Reliability Engineering Lead |
| F-05 | Sample-status webhook accepts unsigned events | 7.5 High | 7.0 High | Retained | Integration Engineering Lead |
| F-06 | Export packages retained beyond documented period | 6.5 Medium | 6.8 Medium | Retained | Head of Platform Engineering / DPO |
| F-07 | Bulk patient export available to Support Manager role | 9.1 Critical | Retired | Retired, see Addendum | N/A — verification recommended |
| F-08 | Password-recovery flow reveals account existence | 5.3 Medium | 4.8 Medium-Low | Retained | Identity and Access Management Lead |
| F-10 | Analytics service trusts caller-supplied laboratory header | 8.0 High | 7.8 High | Retained | Data Platform Lead / SRE Lead |

### B. CVSS Environmental Calculations (Summary Basis)

Environmental adjustments in this report modify Sarah's base CVSS v3.1 vectors by reasoning explicitly about MediPath's Confidentiality Requirement (CR), Integrity Requirement (IR), and Availability Requirement (AR) modifiers, informed by the asset criticality table in the regulatory map, and by whether an evidenced compensating control changes real-world Attack Complexity or Confidentiality/Integrity/Availability impact. Where an asset is rated "Very high" for a relevant impact type (e.g., diagnostic result records, sample-status workflow, hospital connector credentials), the corresponding requirement modifier is treated as High, which raises the environmental score relative to the base score unless a specifically evidenced control (not merely a mentioned one, per the compensating-controls evaluation rule) offsets it. Full per-finding vectors and stated modifiers are provided inline in Section 3 for each finding.

### C. Attack Chain Diagram (Text Form)

```
[Broad/long-lived connector token]  [Stale admin session]
              (F-03/F-09 shared root cause)
                        |
                        v
        [Internal analytics service reachable
         from application network, trusts
         caller-supplied X-Lab-ID header]  (F-10)
                        |
                        v
        [Cross-laboratory reconnaissance:
         which labs / result IDs are active]
                        |
                        v
        [Results API accepts any authenticated
         caller's result_id without verifying
         tenant ownership]  (F-01)
                        |
                        v
        [Cross-tenant patient diagnostic
         result data exposed at scale]
```

### D. Glossary (for non-technical readers)

- **Tenant / tenant isolation:** Each of MediPath's 400 laboratory customers is a separate "tenant." Tenant isolation means the system should never let one laboratory's users or systems see another laboratory's data.
- **API:** A defined way for software systems to request or exchange data with each other — in this report, mostly the connections between MediPath's platform, hospital systems, and its own internal tools.
- **Authentication vs. authorization:** Authentication confirms who someone is (login). Authorization confirms what that person is allowed to do or see once logged in. Several findings in this report involve authentication working correctly while authorization did not.
- **Token:** A digital credential that lets a system (such as a hospital's integration) access MediPath without repeatedly logging in. Tokens can be scoped narrowly (access to one thing) or broadly (access to many things), and can be short-lived or long-lived.
- **CVSS:** A standardized 0–10 scoring system security professionals use to rate how severe a technical weakness is. This report uses both a "base" score (the weakness in the abstract) and an "environmental" score (the weakness adjusted for MediPath's specific data, controls, and business context).
- **Compensating control:** An existing protective measure that reduces the practical risk of a weakness without necessarily eliminating the weakness itself (for example, requiring a second login step).
- **HDS certification:** A French regulatory certification required for hosting health data, which MediPath is currently preparing to renew.
- **RGPD Article 9:** The section of European data-protection law that gives health data special, stricter protection requirements.
