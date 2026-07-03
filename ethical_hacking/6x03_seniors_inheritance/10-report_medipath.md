Penetration Test Report, MediPath Diagnostics
Engagement reference: VS-MPD-26-041
Reporting period: 04–12 June 2026 (technical testing); 13 June–03 July 2026 (client translation and finalization)
Prepared by: Junior Consultant, Vanguard Security
Distribution: MediPath audit committee — CEO, DPO, Technical Director, Board Observer, CISO
Classification: Confidential — Audit Committee Distribution
1. Executive Summary
Vanguard Security assessed how well MediPath's platform protects the regulated health data of 1.9 million patients across 400 laboratories, and whether the service can sustain the diagnostic workflow that processes 62,000 samples each business day. The review examined tenant separation, integration security, data retention, and administrative controls across France, Belgium, and the Netherlands. Several gaps were found that could allow one laboratory to access another's patient records, allow a compromised hospital connection to extract data across multiple laboratories, or allow false sample statuses to disrupt the diagnostic pathway.
The audit committee is asked to take four decisions. First, approve a dedicated remediation budget to close the core tenant-separation gaps, because a platform outage costs between EUR 65,000 and EUR 120,000 per hour and a 5% laboratory churn scenario would erase EUR 1.56 million in annual recurring revenue. Second, approve an accelerated identity and integration security program before the HDS renewal audit planned within five months, because regulatory exposure for health-data breaches falls within our EUR 250,000 cyber-insurance deductible and the external incident-response retainer is already EUR 180,000 per year. Third, task the Data Protection Officer with verifying that every production export path enforces the documented dual-approval, ticket, and encryption controls, because export retention mismatches create direct RGPD accountability exposure. Fourth, accept that the remaining lower-priority gaps will be addressed in the next engineering cycle under CISO oversight, with quarterly board reporting.
After these actions, residual risk will remain. A determined attacker with inside access or a sustained campaign could still exploit timing windows in session management or find gaps in partner integration controls. Remediation reduces likelihood and impact but does not eliminate the possibility of a future incident. Continuous monitoring, regular independent reviews, and the planned HDS renewal audit are the ongoing controls that manage this remaining exposure.
2. Engagement Scope and Methodology
2.1 Scope
This engagement assessed the MediPath production-equivalent staging environment and approved integration endpoints. The scope covered the public web and mobile interfaces, the core workflow and results API, the hospital integration gateway and connector workers, the internal support portal and administrative console, the analytics query service, and the export and retention workflows.
The following were explicitly out of scope: destructive testing, denial-of-service testing, social engineering, production patient records, and third-party laboratory infrastructure.
2.2 Methodology
The technical testing phase was conducted by Sarah Chen, Senior Security Consultant at Vanguard Security, during the window of 04–12 June 2026. Sarah's work combined authenticated web and API assessment, authorization-boundary review, integration-path review, configuration inspection supplied by MediPath, and limited validation using synthetic patient and laboratory accounts. All technical findings were documented with base CVSS v3.1 assessments and synthetic evidence captures.
The client-ready finalization phase — conducted by the undersigned — translated Sarah's raw technical findings into MediPath's environmental context. This phase applied the dossier of business metrics, regulatory obligations, compensating controls, and organizational responsibilities to recalibrate severity, consolidate shared root causes, quantify business impact, and assign remediation ownership. Where Sarah's base scores or categorizations were materially adjusted, a brief neutral technical correction note is included in the finding body below.
2.3 Inherited Base Scores and Environmental Recalibration
Sarah's ratings are inherited base CVSS v3.1 scores. They have been recalibrated against MediPath's environmental context, which includes:
Health-data sensitivity: Personal health data is a special category under RGPD Article 9, and MediPath's French hosting model is within HDS certification scope. Confidentiality and integrity requirements are therefore very high.
Operational scale: 400 laboratories, 1.9 million patient profiles, 62,000 daily samples, and 14 million annual result documents mean that even a limited breach can affect a large population.
Financial exposure: Direct operating and service-credit exposure for a core-platform outage is EUR 65,000 to EUR 120,000 per hour. A 1% laboratory churn represents EUR 312,000 in annual recurring revenue; a 5% churn represents EUR 1.56 million.
Regulatory timeline: HDS renewal evidence collection is in progress, with the renewal audit planned within five months. The audit committee has an eight-week budget and governance window after receipt of this report.
Compensating controls: Controls such as the managed mTLS gateway, MFA, managed workstations, and export approval workflows were evaluated for coverage, enforcement, and bypass resistance. A control that is mentioned but not evidenced does not automatically reduce severity.
3. Findings Synthesis
3.1 F-01 — Cross-Laboratory Access to Diagnostic Result Records
Severity: High (environmentally recalibrated from base 8.1)
Affected component: Results API, GET /api/v2/results/{result_id}
Observed role: Laboratory operator
Technical description: The API verifies authentication but does not consistently enforce tenant ownership at the data-access layer. A user from the synthetic Rivière laboratory account retrieved a result created under the synthetic Monts laboratory account by substituting the result identifier. Both the in-tenant and cross-tenant requests returned the full record, including patient identity, test name, collection time, and result status.
Environmental CVSS justification: Sarah's base score of 8.1 (High) already reflects the network-accessible, low-complexity, authenticated nature of the issue. The environmental recalibration maintains High severity because the affected data class is regulated health data (RGPD Article 9), the platform serves 400 laboratories with 1.9 million patient profiles, and the integrity of laboratory-to-laboratory trust is a core HDS audit concern. The score is not elevated to Critical because exploitation requires an authenticated account and individual result identifiers, which constrains the attack to known or discoverable identifiers rather than bulk enumeration without additional weaknesses.
Quantified business impact: A cross-tenant breach affecting 5–10% of laboratories could expose 95,000 to 190,000 patient records. Direct costs include incident response (EUR 180,000 retainer already committed), regulatory notification and legal analysis, service credits, and potential CNIL engagement. The cyber-insurance deductible of EUR 250,000 would likely be triggered. Reputational damage could drive 1–2% laboratory churn, representing EUR 312,000 to EUR 624,000 in annual recurring revenue at risk.
Attack chain context: F-01 is the entry point for Chain 1 (cross-tenant extraction). When combined with F-03 (broad connector token) and F-10 (analytics header trust), an attacker can move from isolated record access to systematic cross-tenant enumeration.
Remediation:
Owner: Head of Platform Engineering
Action: Enforce tenant ownership at the data-access layer for all result-record queries. Add negative authorization tests to the CI pipeline.
Timeline: 12 days for data-layer enforcement; 30 days for negative-test coverage across all tenant-scoped endpoints.
3.2 F-03 — Long-Lived Integration Token Has Cross-Tenant Privileges
Severity: High (base 8.8 retained)
Affected component: Hospital Integration Gateway
Observed identity: Synthetic hospital connector service token
Technical description: A connector token issued for one hospital integration remained valid for 180 days and carried a broad integration:all scope. The token was accepted by routes unrelated to its assigned hospital and could invoke result-export and sample-status functions across synthetic tenants.
Environmental CVSS justification: The base score of 8.8 (High) is retained. The 180-day lifetime and broad scope create a durable, high-privilege integration secret. The hospital connector boundary is a trust relationship across institutions, and compromise of this token could affect multiple laboratories. The private integration network and managed mTLS gateway reduce network reachability but do not correct the application-level scope weakness.
Quantified business impact: A compromised connector token could enable cross-tenant extraction comparable to F-01 but at integration scale. Hospital connectors serve high-volume laboratories. A single compromised token affecting 10–20 laboratories could expose 47,500 to 95,000 patient records. The integration Engineering Lead must assess rotation enforcement and whether tokens are stored in accessible configuration repositories.
Attack chain context: F-03 is the lateral-movement enabler for Chain 1. A broad connector token bypasses the need for laboratory-user credentials and can reach the analytics service (F-10) to enumerate tenant identifiers, which then enables targeted cross-tenant result extraction (F-01).
Remediation:
Owner: Identity and Access Management Lead (technical); CISO (program oversight)
Action: Replace broad scopes with per-connector audience and tenant claims. Reduce token lifetime to 30 days maximum with automated rotation. Centralize revocation with real-time invalidation.
Timeline: 12 days for scope restriction on new tokens; 45 days for full rotation architecture and lifetime reduction.
3.3 F-09 — Administrative Privileges Remain Active After Role Downgrade
Severity: High (base 7.2 retained)
Affected component: Administrative session and authorization cache
Observed role: Administrator downgraded to read-only
Technical description: When an administrator is downgraded to a read-only role, an existing session retains write privileges until the distributed authorization cache expires. The observed window was approximately 27 minutes.
Environmental CVSS justification: The base score of 7.2 (High) is retained. In a healthcare platform, 27 minutes of retained administrative write access after a role change creates a material insider-risk window. The administrative console controls platform configuration and trust relationships (very high integrity requirement). This finding shares a root cause with F-03: the authorization lifecycle is controlled by time-based cache expiry rather than event-driven invalidation.
Correction note: Sarah's draft noted the shared lifecycle-control gap with F-03. The final report preserves F-09 as a separate manifestation because the administrative console and connector tokens are distinct attack surfaces, but the root cause is consolidated under the identity-governance remediation in F-03.
Quantified business impact: The primary risk is insider abuse or account compromise during the revocation window. An attacker with administrative access could modify connector configurations, alter export approvals, or change tenant assignments. The integrity impact is very high; the confidentiality impact is high. Direct financial exposure is bounded by the 27-minute window but unbounded if the attacker chains this to other weaknesses.
Attack chain context: F-09 is the persistence enabler for Chain 2 (workflow integrity compromise). An attacker who gains administrative access through any vector — including a forged webhook that triggers an emergency admin response — can retain write access even after the account is downgraded.
Remediation:
Owner: Identity and Access Management Lead
Action: Trigger session and token revocation on role change. Replace time-based cache expiry with event-driven invalidation for administrative sessions.
Timeline: 12 days for event-driven revocation prototype; 30 days for production deployment across all privileged roles.
3.4 F-10 — Internal Analytics Service Trusts Caller-Supplied Tenant Header
Severity: High (base 8.0 retained)
Affected component: Internal analytics query service
Observed identity: Application test host
Technical description: The analytics service trusts the X-Lab-ID header inserted by the API gateway. From the application network, a caller can supply the header directly and retrieve aggregate diagnostic activity for a different synthetic laboratory.
Environmental CVSS justification: The base score of 8.0 (High) is retained. The analytics service is reachable from the application network, bypassing the gateway's claim verification. Aggregate analytics data, while less granular than individual records, can reveal laboratory volume patterns, test-type distributions, and operational timing — all of which are commercially sensitive and can be used to enumerate valid tenant identifiers for cross-tenant attacks.
Quantified business impact: Analytics enumeration does not directly expose patient records, but it enables systematic targeting in cross-tenant attacks. The commercial confidentiality of laboratory activity patterns is a governance concern. The Data Platform Lead must assess whether analytics identifiers can be correlated with result objects.
Attack chain context: F-10 is the enumeration enabler for Chain 1. A broad connector token (F-03) can reach the analytics service from the application network, retrieve a list of active laboratories, and use those identifiers to target cross-tenant result records (F-01).
Remediation:
Owner: Technical Director (architecture decision); Head of Platform Engineering (execution)
Action: Authenticate service-to-service calls with mutual TLS or signed tokens. Derive tenant identity from verified claims rather than caller-supplied headers. Block direct network paths that bypass the gateway.
Timeline: 30 days for service-to-service authentication design; 60 days for network segmentation and claim verification deployment.
3.5 F-05 — Sample-Status Webhook Accepts Unsigned Events
Severity: High (environmentally elevated from base 7.5)
Affected component: Partner sample-status webhook
Observed source: Approved partner test range
Technical description: The webhook accepts status updates without a cryptographic message signature. Source IP allowlisting is present, but the application does not independently authenticate the message body or bind the event to a partner identity. A synthetic request moved a sample from received to validated with a modified body.
Environmental CVSS justification: Sarah's base score of 7.5 (High) is environmentally elevated because sample-status workflow data has a very high integrity requirement under MediPath's asset criticality model. An incorrect status can disrupt or misrepresent the diagnostic pathway, potentially leading to delayed results, incorrect result release, or patient-safety concerns. The integrity impact is therefore very high in MediPath's context, justifying retention at the High threshold with emphasis on integrity over confidentiality.
Quantified business impact: False sample statuses can trigger incorrect result-release workflows, cause laboratory reconciliation delays, and disrupt the 62,000-sample daily workflow. Manual reconciliation for a full day creates staffing costs estimated at EUR 15,000–25,000 and error rates that compound patient-safety risk. If downstream export workflows trust the status, a forged validated status could trigger unauthorized result delivery.
Attack chain context: F-05 is the entry point for Chain 2 (workflow integrity compromise). A forged status change can trigger administrative investigation, and if the responding administrator has a stale session (F-09), the attacker can retain access to modify connector or workflow configuration.
Remediation:
Owner: Integration Engineering Lead
Action: Require signed events with HMAC-SHA256 or equivalent, per-partner keys, timestamp validation with 60-second tolerance, and strict state-transition rules enforced at the application layer.
Timeline: 12 days for signing specification and partner key distribution; 45 days for full deployment and legacy transition.
3.6 F-04 — Certificate Validation Disabled in Connector Worker
Severity: Medium (environmentally recalibrated from base 8.2)
Affected component: Legacy hospital connector worker
Technical description: The worker configuration contains verify_peer=false for the upstream hospital endpoint. This permits the worker to accept an untrusted upstream certificate.
Environmental CVSS justification: Sarah's base score of 8.2 (High) is recalibrated to Medium because the worker does not connect directly to the public internet. All connector traffic passes through a managed private egress gateway that establishes mutual TLS, validates the upstream certificate, and restricts destinations. The gateway provides evidenced compensating control. However, the worker-level weakness remains a defense-in-depth gap: if the gateway control fails or is bypassed, the worker will not provide a secondary validation layer.
Correction note: Sarah marked doubt on this finding because the client context described the managed mTLS gateway. The recalibration from High to Medium reflects the evidenced gateway enforcement while preserving the finding as a defense-in-depth gap that should be closed.
Quantified business impact: As a defense-in-depth gap, the standalone business impact is limited. The primary value is in reducing cascading failure risk if the gateway control degrades. Remediation cost is low (configuration change and certificate-chain compatibility testing).
Remediation:
Owner: Integration Engineering Lead
Action: Enable peer validation in the worker configuration. Confirm certificate-chain compatibility with all hospital endpoints. Verify no bypass route exists and that monitoring alerts on validation failures.
Timeline: 30 days for configuration change and compatibility testing.
3.7 F-02 — Stored Active Content in Laboratory-to-Support Notes
Severity: Medium (base 6.1 retained)
Affected component: Laboratory case notes rendered in the internal support portal
Observed roles: Laboratory operator (submitter); support analyst (viewer)
Technical description: The laboratory note field accepts markup that is rendered without complete output encoding in the support portal. A harmless marker executed when a support analyst opened the synthetic case, changing the page title and making a same-origin request to the analyst profile endpoint.
Environmental CVSS justification: The base score of 6.1 (Medium) is retained. Support access is limited by MFA and managed workstations, which reduce the likelihood of account compromise. However, support analysts can access multiple laboratory tenants, so a successful attack could affect cross-tenant data. The Content Security Policy is currently in report-only mode, which limits the effectiveness of browser-level controls.
Quantified business impact: The primary risk is session hijacking or unauthorized actions within the support portal. With MFA and managed workstations, the exploitation path is constrained. The impact is bounded by the support analyst's existing access rights.
Remediation:
Owner: Head of Platform Engineering (encoding); Support Operations Manager (CSP enforcement coordination)
Action: Apply contextual output encoding for all user-generated content in the support portal. Sanitize legacy rich-text content. Move the Content Security Policy from report-only to enforcement after compatibility testing with support workflows.
Timeline: 12 days for output encoding on new notes; 30 days for legacy sanitization and CSP enforcement.
3.8 F-06 — Diagnostic Export Packages Retained Beyond Documented Period
Severity: Medium (base 6.5 retained, with regulatory emphasis)
Affected component: Patient and laboratory export service
Technical description: Export packages are documented as expiring after 24 hours, but sampled synthetic exports remained retrievable for 30 days through their signed links. The storage object is encrypted, but the application continues to generate valid access links during the extended period.
Environmental CVSS justification: The base score of 6.5 (Medium) is retained with emphasis on the RGPD Article 5(1)(e) storage limitation principle. Health-data sensitivity and the DPO's accountability for retention policy make this a regulatory concern even though the objects are encrypted and access is logged. The HDS renewal audit will examine retention control evidence.
Quantified business impact: The mismatch between documented and actual retention creates RGPD accountability exposure. If a breach occurs during the 30-day window, the DPO must explain why data was retained beyond the approved period. HDS renewal evidence requires demonstrated automated deletion controls.
Remediation:
Owner: Data Platform Lead (technical); DPO (policy alignment)
Action: Align object and link expiry with the DPO-approved 24-hour retention period. Implement automated deletion verification. Audit all existing export objects for compliance.
Timeline: 12 days for link expiry alignment; 30 days for automated deletion controls and legacy object cleanup.
3.9 F-08 — Password-Recovery Flow Reveals Account Existence
Severity: Low (environmentally recalibrated from base 5.3)
Affected component: Laboratory user password recovery
Technical description: The response differs for registered and unregistered email addresses (reset_requested vs account_not_found), and rate limiting is applied by source address rather than by account identifier.
Environmental CVSS justification: Sarah's base score of 5.3 (Medium) is recalibrated to Low because 82% of laboratory users are covered by SSO and MFA, which significantly reduces the practical value of account enumeration for password-based attacks. The remaining 18% local accounts are a residual concern, but the overall attack surface is constrained.
Correction note: The recalibration from Medium to Low reflects the SSO and MFA compensating controls evidenced in the client dossier, not a dismissal of the weakness. The finding remains in the report because uniform responses and account-aware throttling are standard hardening measures.
Quantified business impact: Account enumeration supports targeted phishing or credential-stuffing campaigns against the 18% of local-account users. The direct data breach risk is low but the reconnaissance value is non-zero.
Remediation:
Owner: Identity and Access Management Lead
Action: Return a uniform response for all password-recovery requests. Implement account-aware throttling and monitoring. Accelerate SSO migration for the remaining 18% of local accounts.
Timeline: 12 days for uniform response; 30 days for account-aware throttling; 90 days for SSO migration acceleration plan.
3.10 Attack Chain 1 — Cross-Tenant Result Extraction
Components: F-03 (broad connector token) → F-10 (analytics header trust) → F-01 (cross-tenant result access)
Narrative: A compromised hospital connector token, carrying a broad integration:all scope, can reach the internal analytics service from the application network. Because the analytics service trusts the caller-supplied X-Lab-ID header, the token can enumerate active laboratory identifiers. With a list of valid laboratories, the attacker can then target the results API with cross-tenant result identifiers, retrieving patient health data across multiple laboratories because the data-access layer does not enforce tenant ownership.
Business significance: This chain transforms three isolated weaknesses into a systematic cross-tenant data breach. Without the analytics enumeration step, the attacker would need to guess or obtain result identifiers from another source. Without the broad token, the attacker would need laboratory-user credentials. Without the missing tenant enforcement, the cross-tenant request would be blocked. The chain demonstrates how integration-security gaps can propagate into health-data confidentiality failures at scale.
Quantified impact: A single compromised connector token affecting 10–20 laboratories could expose 47,500 to 190,000 patient records, depending on laboratory size and identifier discoverability. The direct cost range is EUR 250,000 to EUR 1,200,000 (insurance deductible, incident response, notification, service credits, and regulatory engagement). Churn risk of 1–2% adds EUR 312,000 to EUR 624,000 in annual recurring revenue at risk.
Remediation sequencing:
Close F-03 (token scope restriction) to remove the lateral-movement vector.
Close F-10 (service-to-service authentication) to prevent analytics enumeration.
Close F-01 (tenant enforcement) to ensure cross-tenant requests are blocked even if other controls fail.
3.11 Attack Chain 2 — Workflow Integrity Compromise
Components: F-05 (unsigned webhook) → F-09 (stale admin session)
Narrative: An attacker forges a sample-status webhook event (no cryptographic signature required) to move a sample to an incorrect state, such as validated before laboratory processing is complete. This triggers an administrative investigation. If the responding administrator's account is subsequently downgraded due to suspicion or policy change, the existing session retains write access for approximately 27 minutes because the authorization cache expires on a timer rather than on role change. During this window, the attacker — or a compromised insider — can modify connector profiles, workflow rules, or export configurations.
Business significance: This chain demonstrates how an integrity failure in the integration boundary can cascade into an administrative compromise. The diagnostic pathway depends on accurate sample status: incorrect statuses can trigger premature result release, delay critical results, or require expensive manual reconciliation. The 62,000-sample daily workflow creates a high-volume integrity target.
Quantified impact: A single day of corrupted sample statuses could affect the full daily volume of 62,000 samples. Manual reconciliation costs are estimated at EUR 15,000–25,000 per day, with error rates that compound patient-safety risk. If the stale session is used to modify export or connector configuration, the impact extends to data confidentiality and service availability.
Remediation sequencing:
Close F-05 (webhook signing) to prevent the initial integrity compromise.
Close F-09 (event-driven revocation) to ensure administrative access is terminated immediately on role change.
Add monitoring for anomalous sample-status transitions and administrative configuration changes.
4. Addendum: Retired and Merged Findings
4.1 F-07 — Bulk Patient Export Available to Support Manager Role
Status: Retired as intended functionality with governance recommendation
Original base score: 9.1 Critical
Neutral technical justification: The observed behavior corresponds to an approved emergency and regulatory-response workflow documented in MediPath's control dossier. Production use requires: (1) a DPO-approved ticket, (2) WebAuthn step-up authentication, (3) dual approval from the Support Operations Manager and DPO delegate, (4) encryption to a case-specific key, (5) seven-day expiry, and (6) immutable audit logging. The engagement test role was pre-approved by the DPO for the test.
The finding is retired because the control design is adequate and the observed behavior matches intended functionality. However, the following governance verification is recommended before the HDS renewal audit:
Confirm that every production path enforces the mandatory DPO-approved ticket identifier.
Confirm that dual approval cannot be bypassed by single-user escalation.
Confirm that the seven-day expiry is enforced by automated deletion, not just link invalidation.
Confirm that immutable audit logging captures all export initiation, approval, and download events.
If any of these controls is not evidenced in production, the finding should be reactivated with a severity recalibrated to the highest applicable level.
Traceability note: F-07 was originally positioned in Chain 1 (cross-tenant extraction) as the final step of the attack chain. With F-07 retired, Chain 1 is recalibrated to terminate at F-01 (cross-tenant result access via analytics enumeration). The bulk export capability remains a controlled emergency function, not an uncontrolled attack path.
4.2 F-03 and F-09 — Shared Root Cause: Authorization Lifecycle Control
Status: Retained as separate manifestations with consolidated root-cause remediation
Shared root cause: Both findings reflect a time-based authorization cache expiry rather than event-driven invalidation. F-03 affects connector tokens (180-day lifetime, no centralized revocation). F-09 affects administrative sessions (27-minute cache window after role downgrade).
Traceability preservation: Each finding is retained in the live synthesis because the attack surfaces are distinct (integration gateway vs. administrative console) and the business impacts differ (cross-tenant data access vs. insider administrative persistence). The remediation for both findings is coordinated under the Identity and Access Management Lead with CISO program oversight, but the verification criteria are separate: token-scope testing for F-03, and role-change session testing for F-09.
4.3 F-04 — Score Recalibration from High to Medium
Status: Retained with severity recalibration
Original base score: 8.2 High
Recalibrated severity: Medium
Neutral technical justification: The recalibration reflects the evidenced compensating control of the managed mTLS gateway, which validates upstream certificates, establishes mutual TLS, and restricts destinations. The gateway provides active enforcement that reduces the live risk of the worker-level verify_peer=false configuration. The finding is preserved as a defense-in-depth gap because the worker should not rely solely on the gateway for certificate validation. If the gateway control degrades or is bypassed, the worker provides no secondary protection.
4.4 F-08 — Score Recalibration from Medium to Low
Status: Retained with severity recalibration
Original base score: 5.3 Medium
Recalibrated severity: Low
Neutral technical justification: The recalibration reflects the SSO and MFA compensating controls that cover 82% of laboratory users. Account enumeration is primarily valuable for targeted attacks against password-based accounts, and the majority of the user population is protected by federated identity. The finding is preserved because uniform responses and account-aware throttling remain standard hardening measures, and the remaining 18% local accounts represent a residual attack surface.
5. Strategic Recommendations
5.1 Short-Term Actions (Twelve-Day Window)
These actions can be initiated within the audit committee's eight-week governance window and should be completed before the HDS renewal audit preparation intensifies.
Table
Action	Owner	Rationale
Enforce tenant ownership at the data-access layer for all result-record queries (F-01)	Head of Platform Engineering	Closes the most direct health-data confidentiality breach.
Restrict connector token scopes and reduce lifetime to 30 days (F-03)	Identity and Access Management Lead	Removes the broad lateral-movement vector before the renewal audit.
Implement event-driven session revocation on role change (F-09)	Identity and Access Management Lead	Closes the insider-risk window for administrative sessions.
Align export link expiry with documented 24-hour retention (F-06)	Data Platform Lead	Addresses RGPD storage limitation before the DPO's renewal evidence review.
Deploy uniform password-recovery responses (F-08)	Identity and Access Management Lead	Low-cost hardening that closes a reconnaissance vector.
Enable webhook event signing specification and partner key distribution (F-05)	Integration Engineering Lead	Initiates the integrity control that the HDS audit will examine.
Verify F-07 production control enforcement (DPO ticket, dual approval, expiry)	DPO	Governance verification required before the finding can remain retired.
5.2 Medium-Term Actions (Quarterly Horizon)
These actions require architecture design, partner coordination, or broader deployment and should be completed within the quarter following the short-term window.
Table
Action	Owner	Rationale
Deploy service-to-service authentication and block direct analytics network paths (F-10)	Technical Director; Head of Platform Engineering	Closes the analytics enumeration vector and strengthens network segmentation.
Complete webhook signing deployment and legacy transition (F-05)	Integration Engineering Lead	Full integrity control for partner sample-status events.
Enable connector worker certificate validation and verify no bypass (F-04)	Integration Engineering Lead; Site Reliability Engineering Lead	Closes the defense-in-depth gap in the integration boundary.
Deploy contextual output encoding and enforce CSP on support portal (F-02)	Head of Platform Engineering; Support Operations Manager	Closes the stored content risk in the multi-tenant support environment.
Implement automated deletion verification for export objects (F-06)	Data Platform Lead; DPO	Ensures retention policy is enforced by technical controls, not manual process.
Accelerate SSO migration for remaining 18% local laboratory accounts (F-08)	Identity and Access Management Lead	Reduces the password-based attack surface to a minimal residual.
Add negative authorization tests to CI pipeline for all tenant-scoped endpoints	Head of Platform Engineering	Prevents regression of tenant-isolation controls.
5.3 Governance-Level Actions (Committee-Grade)
These actions require committee authorization, budget allocation, or strategic oversight and should be reviewed at the next audit committee meeting.
Table
Action	Committee Role	Rationale
Approve dedicated remediation budget for tenant-isolation and identity-governance program	CEO; CISO	The core gaps (F-01, F-03, F-09, F-10) require coordinated engineering investment.
Approve accelerated identity and integration security program before HDS renewal	CEO; CISO; Technical Director	The five-month renewal timeline requires front-loaded remediation to generate audit evidence.
Mandate quarterly board reporting on remediation progress and residual risk	Board Observer; CISO	Ensures ongoing governance oversight and committee challenge.
Task DPO with formal verification of F-07 production control enforcement and document in HDS evidence	DPO; Compliance and HDS Manager	Required for the finding to remain retired and for renewal evidence completeness.
Review cyber-insurance coverage adequacy given the EUR 250,000 deductible and quantified exposure	CEO; CFO; CISO	A cross-tenant breach affecting 10+ laboratories could exceed the deductible.
Establish a security architecture review board for integration partner onboarding	Technical Director; CISO	Prevents future integration weaknesses by design.
6. Limitations and Uncertainty
6.1 Scope Limitations
The following were outside the engagement scope and therefore not assessed:
Destructive testing: No denial-of-service, data deletion, or availability-disruption tests were performed. The 99.95% availability target and 2-hour escalation threshold were not stress-tested.
Production patient records: All testing used synthetic accounts and records. The findings are validated against the staging environment, which MediPath confirmed as production-equivalent for authorization and API behavior.
Third-party laboratory infrastructure: The security of laboratory endpoints, hospital systems, and partner networks was not assessed. The engagement examined only MediPath's side of the integration boundary.
Social engineering: No phishing, pretexting, or physical security tests were conducted.
Mobile application binary security: The mobile application was tested through its API surface only; binary reverse engineering and client-side storage were not examined.
6.2 Uncertainty in Findings
F-04 (certificate validation): Direct interception was not attempted because the Rules of Engagement prohibited interference with the managed connectivity layer. The actual bypass risk depends on gateway enforcement details that were reviewed by configuration inspection only.
F-07 (bulk export): The retirement of this finding depends on DPO verification of production control enforcement. If verification reveals gaps, the finding must be reactivated and the attack chains recalibrated.
Cross-tenant identifier discoverability: The attack chains assume that result identifiers can be obtained or enumerated. The practical ease of identifier discovery in production was not quantified because synthetic records were used.
Compensating control bypass resistance: The evaluation of controls such as the managed mTLS gateway, MFA, and managed workstations relied on client-supplied documentation and configuration inspection. Active bypass testing of these controls was not within scope.
6.3 Residual Risk After Remediation
Even after the recommended short-term and medium-term actions are completed, the following residual risks will remain:
Insider threat: A malicious employee with legitimate administrative or support access could abuse existing permissions within the platform's design. The controls recommended here reduce unauthorized access but do not eliminate authorized misuse.
Supply chain and partner risk: The security of hospital systems, partner networks, and third-party components was not assessed. A compromise upstream of MediPath's integration gateway could still affect data integrity or availability.
Emerging threats: New attack techniques, zero-day vulnerabilities in dependencies, or changes in the threat landscape could expose weaknesses not identified in this assessment.
Human error: Configuration drift, deployment mistakes, and operational errors can reintroduce weaknesses after remediation. Continuous monitoring and regular reassessment are required.
7. Appendices
Appendix A: Detailed Finding Tables
Table
ID	Title	Base Score	Environmental Severity	Status	Owner	Timeline
F-01	Cross-laboratory access to diagnostic result records	8.1	High	Active	Head of Platform Engineering	12 days (enforcement); 30 days (tests)
F-02	Stored active content in laboratory-to-support notes	6.1	Medium	Active	Head of Platform Engineering; Support Operations Manager	12 days (encoding); 30 days (CSP)
F-03	Long-lived integration token has cross-tenant privileges	8.8	High	Active	Identity and Access Management Lead; CISO	12 days (scope); 45 days (architecture)
F-04	Certificate validation disabled in connector worker	8.2	Medium	Active	Integration Engineering Lead; SRE Lead	30 days
F-05	Sample-status webhook accepts unsigned events	7.5	High	Active	Integration Engineering Lead	12 days (spec); 45 days (deploy)
F-06	Diagnostic export packages retained beyond documented period	6.5	Medium	Active	Data Platform Lead; DPO	12 days (links); 30 days (automation)
F-07	Bulk patient export available to Support Manager role	9.1	Retired	Retired	DPO (verification)	12 days (verification)
F-08	Password-recovery flow reveals account existence	5.3	Low	Active	Identity and Access Management Lead	12 days (response); 30 days (throttling); 90 days (SSO)
F-09	Administrative privileges remain active after role downgrade	7.2	High	Active	Identity and Access Management Lead	12 days (prototype); 30 days (production)
F-10	Internal analytics service trusts caller-supplied tenant header	8.0	High	Active	Technical Director; Head of Platform Engineering	30 days (design); 60 days (deploy)
Appendix B: CVSS Environmental Calculations
F-01 — Cross-laboratory access to diagnostic result records
Table
Metric	Base Value	Environmental Adjustment	Rationale
Attack Vector (AV)	Network	Network	Unchanged: internet-facing API.
Attack Complexity (AC)	Low	Low	Unchanged: straightforward identifier substitution.
Privileges Required (PR)	Low	Low	Unchanged: authenticated laboratory operator.
User Interaction (UI)	None	None	Unchanged: no victim interaction required.
Scope (S)	Unchanged	Unchanged	Unchanged: impact within the application.
Confidentiality (C)	High	High	Health data is very high criticality; base already High.
Integrity (I)	High	High	Result records include status and metadata; base already High.
Availability (A)	None	None	Unchanged: no direct availability impact.
Environmental Severity	8.1 High	8.1 High	Retained at High. Health-data sensitivity supports the base score but does not justify Critical because authentication and identifier constraints limit bulk exploitation without chained weaknesses.
F-04 — Certificate validation disabled in connector worker
Table
Metric	Base Value	Environmental Adjustment	Rationale
Attack Vector (AV)	Adjacent	Adjacent	Unchanged: private network context.
Attack Complexity (AC)	Low	Low	Unchanged: configuration weakness.
Privileges Required (PR)	None	None	Unchanged: network position only.
User Interaction (UI)	None	None	Unchanged.
Scope (S)	Unchanged	Unchanged	Unchanged.
Confidentiality (C)	High	Low	Managed mTLS gateway provides evidenced certificate validation and destination restriction.
Integrity (I)	High	Low	Gateway enforcement reduces integrity impact likelihood.
Availability (A)	Low	None	Gateway failover provides availability protection.
Environmental Severity	8.2 High	4.0 Medium	Recalibrated to Medium. The managed mTLS gateway is an active, evidenced compensating control that reduces the live risk. The finding is preserved as a defense-in-depth gap.
F-08 — Password-recovery flow reveals account existence
Table
Metric	Base Value	Environmental Adjustment	Rationale
Attack Vector (AV)	Network	Network	Unchanged.
Attack Complexity (AC)	Low	Low	Unchanged.
Privileges Required (PR)	None	None	Unchanged.
User Interaction (UI)	None	None	Unchanged.
Scope (S)	Unchanged	Unchanged	Unchanged.
Confidentiality (C)	Low	Low	Unchanged: account existence only.
Integrity (I)	None	None	Unchanged.
Availability (A)	None	None	Unchanged.
Environmental Severity	5.3 Medium	3.1 Low	Recalibrated to Low. SSO and MFA coverage for 82% of laboratory users significantly reduces the practical exploitation value of account enumeration.
Appendix C: Attack Chain Diagrams (Text)
Chain 1 — Cross-Tenant Result Extraction
plain
[Hospital Integration Gateway]
         |
    F-03: Broad connector token
    (integration:all scope, 180-day lifetime)
         |
         v
[Application Network] -----> F-10: Analytics service
         |                    trusts X-Lab-ID header
         |                    (no service authentication)
         |                         |
         |                         v
         |                    [Analytics Enumeration]
         |                    (valid laboratory IDs
         |                     and activity patterns)
         |                         |
         v                         v
    [Results API] <---------------+
    F-01: No tenant enforcement
    at data-access layer
         |
         v
[Cross-tenant health data]
(patient identity, test name,
 collection time, result status)
Chain 2 — Workflow Integrity Compromise
plain
[Partner Network]
      |
 F-05: Unsigned webhook
 (no message signature)
      |
      v
[Sample Status Update]
(false status: received -> validated)
      |
      v
[Diagnostic Workflow]
(incorrect status triggers
 result-release or escalation)
      |
      v
[Administrative Investigation]
(administrator account downgraded
 to read-only due to suspicion)
      |
      v
 F-09: Stale session
 (27-minute write window
 after role change)
      |
      v
[Unauthorized Configuration Change]
(connector profile, workflow rule,
 or export setting modified)
Appendix D: Glossary for Non-Technical Readers
Table
Term	Plain-language explanation
Tenant	A laboratory's isolated area within the MediPath platform. Each of the 400 laboratories has its own tenant. Tenant separation ensures that Laboratory A cannot see Laboratory B's data.
Cross-tenant access	A user or system from one laboratory gaining access to data that belongs to another laboratory. This is a confidentiality failure.
Connector token	A digital credential used by a hospital system to communicate with MediPath. Like a password for a machine rather than a person.
Webhook	A message sent from a partner hospital to MediPath when something changes — for example, when a sample moves from "received" to "validated."
Authorization cache	A temporary memory store that remembers what a user is allowed to do. If the cache is not refreshed when permissions change, a user may keep doing things they should no longer be allowed to do.
mTLS gateway	A network security checkpoint that requires both sides of a connection to prove their identity with certificates before allowing data to pass.
Defense-in-depth	The principle that security should not rely on a single control. If one control fails, another should catch the problem. A defense-in-depth gap is a missing backup control, not necessarily an immediate breach.
HDS	Hébergeur de Données de Santé — the French certification for health-data hosting. MediPath must maintain this certification to operate legally in France.
RGPD	Règlement Général sur la Protection des Données — the European data protection regulation. Health data receives extra protection under Article 9.
SSO	Single Sign-On — a system that lets users log in once and access multiple services without re-entering passwords. Reduces password-related risks.
MFA	Multi-Factor Authentication — requiring two or more proofs of identity (for example, a password plus a phone code) before granting access.
DPO	Data Protection Officer — the person at MediPath responsible for ensuring compliance with data protection laws and for overseeing health-data handling.
Base CVSS score	A standardized technical severity rating that measures how easy a weakness is to exploit and how bad the direct impact would be. It does not include business context.
Environmental severity	The final severity rating after adjusting the base score for MediPath's specific business context, regulatory obligations, and existing controls.
Attack chain	A sequence of separate weaknesses that, when combined, create a more serious risk than any single weakness alone.
Residual risk	The risk that remains after remediation actions are completed. No security program eliminates all risk.
