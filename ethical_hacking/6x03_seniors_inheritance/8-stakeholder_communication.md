Stakeholder Communication Mapping
Purpose
This document maps each priority finding and retained attack chain to its primary decision-making audience within MediPath, identifies secondary audiences who require visibility or oversight, specifies the communication channel and level of detail appropriate to each primary audience, and defines the sequencing in which items should be presented to the audit committee and operational leadership.
The mapping is designed for the MediPath audit committee context: a multi-stakeholder body where the CEO brings business and care-delivery perspective, the DPO brings regulatory and health-data accountability, the Technical Director brings architecture and feasibility judgment, the Board Observer brings governance oversight, and the CISO owns the report and remediation budget.
Priority Findings and Attack Chains Communication Matrix
Table
Item	Primary audience	Secondary audiences	Channel and detail	Sequencing
F-01 — Cross-laboratory access to diagnostic result records	Head of Platform Engineering	CISO, DPO, CEO, Compliance and HDS Manager	Channel: Technical remediation briefing with executive summary annex. Detail: Full API path analysis, tenant-isolation gap, synthetic evidence, proposed data-layer enforcement pattern, negative-test requirements, and timeline. Executive annex: patient-volume exposure, regulatory implication under RGPD Article 9, and HDS renewal risk.	Sequence 1 (Opening). Present first because it is the most direct health-data confidentiality breach, establishes the tenant-isolation theme that recurs across findings, and prepares the committee for the compounded attack chains. The CEO and DPO need this context before F-03 and Chain 1 are discussed.
F-03 — Long-lived integration token has cross-tenant privileges	Identity and Access Management Lead	CISO, Technical Director, Integration Engineering Lead, DPO	Channel: Joint technical and identity-governance briefing. Detail: Token scope analysis (integration:all), 180-day lifetime, cross-tenant invocation evidence, revocation architecture gap, and lifecycle-control recommendations. Include mapping to F-09 shared root cause (authorization cache invalidation).	Sequence 2. Follows F-01 because it extends the tenant-isolation failure into the integration boundary. The Technical Director needs this before Chain 1 so the gateway-to-service trust model can be discussed coherently.
F-09 — Administrative privileges remain active after role downgrade	Identity and Access Management Lead	CISO, Technical Director, Support Operations Manager, DPO	Channel: Identity-governance deep-dive with governance appendix. Detail: 27-minute cache window, session revocation gap, role-change event handling, and shared lifecycle-control gap with F-03. Governance appendix: privileged-action monitoring, quarterly access review limitation, and insider-risk framing.	Sequence 3. Follows F-03 to reinforce the shared authorization-lifecycle root cause. Present before Chain 1 so the committee understands how privilege persistence enables lateral movement.
F-10 — Internal analytics service trusts caller-supplied tenant header	Head of Platform Engineering	CISO, Technical Director, Data Platform Lead, DPO	Channel: Architecture review with data-governance overlay. Detail: Gateway bypass path, X-Lab-ID header trust model, service-to-service authentication gap, network segmentation review, and connection to F-01 (analytics identifiers may help locate cross-tenant result objects).	Sequence 4. Follows the identity findings to show how the same tenant-trust weakness propagates into the analytics layer. The Data Platform Lead needs this before Chain 2 is presented.
Chain 1 — Cross-tenant result extraction via broad connector token → analytics enumeration → bulk export	CISO (report owner and remediation-budget sponsor)	CEO, DPO, Technical Director, Head of Platform Engineering, Identity and Access Management Lead, Integration Engineering Lead, Board Observer	Channel: Executive strategic briefing with technical appendix. Detail: Attack chain narrative: F-03 token scope → F-10 analytics header trust → F-07 bulk export path. Business-impact quantification: affected laboratory range, patient-record volume, outage and notification cost estimates, regulatory-response scenario, and churn risk. Technical appendix: remediation sequencing, dependency mapping, and verification criteria.	Sequence 5 (Mid-report pivot). Present after the individual findings (F-01, F-03, F-09, F-10) have established the component weaknesses. This is the first attack chain and requires the committee to shift from isolated gaps to systemic risk. The CEO and Board Observer need the business framing; the DPO needs the regulatory-response scenario.
F-05 — Sample-status webhook accepts unsigned events	Integration Engineering Lead	CISO, Technical Director, Product Owner (Diagnostic Workflow), DPO, Compliance and HDS Manager	Channel: Integration security workshop with workflow-integrity annex. Detail: Unsigned event acceptance, source-IP allowlist limitation, state-transition manipulation evidence, downstream trust implications (result-release and export workflows), and signed-event design requirements. Workflow annex: state-machine rules, replay protection, and partner-key management.	Sequence 6. Follows Chain 1 to introduce the integrity dimension. The Product Owner needs this before Chain 2 because workflow-integrity failures can cascade into data-quality and patient-safety concerns.
F-04 — Certificate validation disabled in connector worker	Integration Engineering Lead	CISO, Technical Director, Site Reliability Engineering Lead	Channel: Defense-in-depth technical review. Detail: verify_peer=false configuration, managed mTLS gateway compensating control, traffic-path validation, bypass-risk assessment, monitoring and fail-closed behavior verification, and remediation priority (defense-in-depth gap, not standalone high risk).	Sequence 7. Follows F-05 to complete the integration-boundary review. The Site Reliability Engineering Lead needs this context before the network-controls discussion in Chain 2. Positioned after F-05 because the webhook integrity issue carries higher immediate operational impact.
Chain 2 — Workflow integrity compromise via unsigned webhook → stale admin session → unauthorized configuration change	Technical Director	CISO, CEO, DPO, Integration Engineering Lead, Identity and Access Management Lead, Support Operations Manager, Board Observer	Channel: Executive and technical joint session. Detail: Attack chain narrative: F-05 unsigned webhook → F-09 stale admin session → unauthorized connector or workflow configuration change. Integrity-impact quantification: sample-status corruption, diagnostic-pathway disruption, patient-safety risk framing, and HDS audit implication. Technical appendix: remediation sequencing (webhook signing first, then session revocation), verification criteria, and monitoring enhancements.	Sequence 8. Present after F-04 to show how integration-integrity and identity-governance weaknesses compound into a workflow-integrity attack. The Technical Director leads because this chain spans integration and identity domains. The CEO needs the patient-safety and business-continuity framing; the DPO needs the health-data integrity and HDS implication.
F-02 — Stored active content in laboratory-to-support notes	Support Operations Manager	CISO, DPO, Head of Platform Engineering	Channel: Support-portal security review with browser-controls annex. Detail: Stored markup execution, same-origin request evidence, output-encoding gap, Content Security Policy status (report-only vs enforcement), managed workstation and MFA compensating controls, and remediation plan (contextual encoding, legacy sanitization, CSP enforcement after compatibility testing).	Sequence 9. Positioned after the attack chains because this is a contained, same-origin issue with existing compensating controls. The Support Operations Manager owns the portal; the CISO and DPO need visibility because support analysts access multi-tenant data.
F-06 — Diagnostic export packages retained beyond documented period	Data Platform Lead	CISO, DPO, Compliance and HDS Manager	Channel: Data-retention governance review with technical remediation plan. Detail: 24-hour documented expiry vs. 30-day actual retention, signed-link validity gap, object-storage encryption status, access-logging review, DPO-approved retention policy alignment, and automated deletion control design.	Sequence 10. Follows F-02 because both are data-governance items. The DPO needs this for RGPD accountability and HDS renewal evidence. Present before F-07 so the committee understands retention-policy enforcement before the bulk-export discussion.
F-07 — Bulk patient export available to Support Manager role	DPO (regulatory interpretation and notification analysis)	CISO, CEO, Technical Director, Support Operations Manager, Compliance and HDS Manager, Board Observer	Channel: Regulatory and governance briefing with intended-functionality review. Detail: Intended emergency/regulatory-response workflow design, DPO-approved ticket requirement, WebAuthn step-up, dual approval, case-specific encryption, seven-day expiry, immutable audit logging, and verification that all production paths enforce mandatory controls. If controls are fully evidenced, frame as intended functionality with control-governance recommendation rather than live finding. If gaps exist, frame as authorization weakness with remediation priority.	Sequence 11. Positioned late because this item requires the committee to distinguish between intended functionality and control weakness. The DPO must lead the intended-functionality determination. The CEO needs the business-continuity framing (emergency export capability). Present after F-06 so the retention discussion informs the export-lifecycle context.
F-08 — Password-recovery flow reveals account existence	Identity and Access Management Lead	CISO, Technical Director, Support Operations Manager	Channel: Identity-hardening technical brief. Detail: Response differentiation (reset_requested vs account_not_found), source-IP rate-limiting gap, account-aware throttling design, uniform response requirement, monitoring enhancement, and SSO/MFA coverage context (82% SSO adoption, remaining local-account risk).	Sequence 12. Positioned near the end because this is a reconnaissance enabler, not a direct data breach. The Identity and Access Management Lead owns the fix. Lower sequencing priority because existing MFA and SSO coverage reduce immediate exploitation likelihood.
Sequencing Rationale Summary
Table
Phase	Items	Purpose
Phase 1: Tenant Isolation Foundation	F-01, F-03, F-09, F-10	Establish the core tenant-isolation and authorization-lifecycle weaknesses that enable cross-tenant data access. These findings share root causes and must be presented sequentially so the committee understands the systemic pattern before attack chains are introduced.
Phase 2: Attack Chain Presentation	Chain 1, F-05, F-04, Chain 2	Shift from isolated gaps to compounded risk. Chain 1 demonstrates cross-tenant extraction; Chain 2 demonstrates workflow integrity compromise. F-05 and F-04 provide the integration-boundary context between the two chains.
Phase 3: Contained and Governance Items	F-02, F-06, F-07, F-08	Present findings with existing compensating controls, intended-functionality questions, or lower immediate impact. F-07 requires the committee to make an intended-functionality determination, which is best done after the systemic risks have been established.
Audience-Specific Communication Design
Chief Executive Officer (CEO)
Channel: Executive summary annexes attached to technical briefings; direct presentation for attack chains.
Detail level: Business-impact quantification (EUR), regulatory-response cost, churn risk, care-delivery disruption, and strategic remediation timeline. Avoid technical implementation detail.
Key items: Chain 1, Chain 2, F-01 (patient-volume exposure), F-07 (intended-functionality business continuity).
Data Protection Officer (DPO)
Channel: Regulatory-precision briefings; direct involvement in F-07 intended-functionality review.
Detail level: RGPD Article 9 health-data sensitivity, HDS renewal implication, notification-analysis framework, retention-policy alignment, and export-approval governance.
Key items: F-01, F-06, F-07, Chain 1 (regulatory-response scenario), Chain 2 (integrity and HDS audit implication).
Technical Director
Channel: Architecture and feasibility review sessions; joint technical briefings for cross-domain items.
Detail level: Remediation feasibility, architecture pattern changes, dependency mapping, verification criteria, and engineering-resource estimation.
Key items: Chain 2 (integration + identity cross-domain), F-04 (defense-in-depth assessment), F-10 (service-to-service authentication), F-03 (token architecture).
Chief Information Security Officer (CISO)
Channel: Report-owner briefings; remediation-budget sponsorship sessions; all-item visibility.
Detail level: Full technical and business detail for all findings; risk-treatment coordination, incident-readiness implications, and control-gap analysis.
Key items: All findings and chains; CISO is the secondary audience for every item and primary for Chain 1.
Board Observer
Channel: Governance oversight briefings; strategic-risk framing for attack chains.
Detail level: Governance implications, committee challenge points, risk-acceptance decisions, and oversight verification.
Key items: Chain 1, Chain 2, F-07 (governance of intended functionality).
Head of Platform Engineering
Channel: Technical remediation briefings; API and data-layer design reviews.
Detail level: Implementation patterns, negative-test requirements, tenant-enforcement mechanisms, and service-to-service authentication design.
Key items: F-01, F-10, Chain 1 (technical appendix).
Identity and Access Management Lead
Channel: Identity-governance deep-dives; token and session architecture reviews.
Detail level: Token scope, lifetime, revocation architecture, session invalidation, cache design, and role-change event handling.
Key items: F-03, F-09, F-08, Chain 1 (token path), Chain 2 (session path).
Integration Engineering Lead
Channel: Integration security workshops; webhook and connector design reviews.
Detail level: Webhook signing, certificate validation, partner-key management, state-transition rules, and connector-worker configuration.
Key items: F-03, F-04, F-05, Chain 2 (webhook path).
Site Reliability Engineering Lead
Channel: Network and gateway control reviews; monitoring and fail-closed behavior verification.
Detail level: mTLS gateway enforcement, traffic-path validation, bypass detection, and alerting criteria.
Key items: F-04, F-10 (network segmentation).
Support Operations Manager
Channel: Support-portal security reviews; break-glass and workforce-control briefings.
Detail level: Output encoding, CSP enforcement, support-workforce access controls, and bulk-export workflow governance.
Key items: F-02, F-07 (support role involvement), F-09 (support session context).
Data Platform Lead
Channel: Data-retention and analytics governance reviews.
Detail level: Export retention automation, analytics service authentication, data-warehouse access controls, and reporting governance.
Key items: F-06, F-10, Chain 1 (analytics enumeration path).
Product Owner, Diagnostic Workflow
Channel: Workflow-integrity design reviews; state-machine and result-release rule sessions.
Detail level: State-transition rules, downstream workflow trust, result-release dependencies, and patient-safety impact.
Key items: F-05, Chain 2 (workflow integrity).
Compliance and HDS Manager
Channel: Certification evidence and audit-readiness briefings.
Detail level: HDS control traceability, renewal evidence gaps, audit coordination, and regulatory-alignment verification.
Key items: F-01, F-05, F-06, F-07, Chain 2 (HDS audit implication).
Communication Sequence for Audit Committee Presentation
F-01 — Open with the direct health-data breach to establish urgency and the tenant-isolation theme.
F-03 — Extend the tenant theme into the integration boundary; introduce the token-scope weakness.
F-09 — Show how privilege persistence compounds the identity-governance gap; link to F-03 shared root cause.
F-10 — Demonstrate tenant-trust propagation into the analytics layer; set up Chain 1 technical path.
Chain 1 — Pivot to systemic risk: cross-tenant extraction via compounded weaknesses. CEO and Board Observer receive business framing; DPO receives regulatory scenario.
F-05 — Introduce the integrity dimension after the confidentiality chains; Product Owner receives workflow impact.
F-04 — Complete integration-boundary review with defense-in-depth assessment; lower priority due to gateway compensating control.
Chain 2 — Present the second systemic risk: workflow integrity compromise via unsigned webhook and stale session. Technical Director leads cross-domain discussion.
F-02 — Contained support-portal issue with existing controls; lower sequencing priority.
F-06 — Data-retention governance; DPO leads for RGPD accountability.
F-07 — Intended-functionality determination; DPO must verify control enforcement before the committee classifies this item.
F-08 — Reconnaissance enabler; lowest sequencing priority due to MFA/SSO compensating controls.
Notes on Prioritization Coherence
This mapping follows the priority order established in prior work:
Critical/High findings (F-01, F-03, F-09, F-10, F-05) are sequenced early and receive executive and technical dual-channel communication.
Attack chains (Chain 1, Chain 2) are positioned mid-report as strategic pivots from isolated gaps to systemic risk.
Medium findings with compensating controls or intended-functionality questions (F-02, F-06, F-07, F-08) are sequenced later, with governance and regulatory audiences taking the lead where appropriate.
F-07 is deliberately positioned late because its classification (intended functionality vs. live finding) depends on control-evidence verification that the DPO must complete.
F-04 is downgraded in sequencing relative to its base CVSS score because the managed mTLS gateway provides evidenced compensating control; it is framed as defense-in-depth gap rather than standalone high risk.
