# Findings Triage and Consolidation

**Engagement:** MediPath Diagnostics (VS-MPD-26-041)
**Basis:** This triage builds on the completed environmental recalibration (`3-cvss_recalibration.md`) and the client-context dossier. It makes three kinds of decisions: which findings are not reportable as live MediPath findings once client context is applied (retired), which findings are separate manifestations of one underlying weakness (merged), and which findings carry forward, individually or as merged items, into the prioritization work in Task 6. Every one of Sarah's ten original findings is accounted for below.

## Retired Findings

### Retired finding F-07

F-07 (bulk patient export available to the Support Manager role) is retired as a live finding. The client-context dossier documents this as an approved, DPO-owned emergency and regulatory-response workflow rather than an unauthorized capability: production use requires a DPO-approved ticket, WebAuthn step-up authentication, dual approval from the Support Operations Manager and a DPO delegate, encryption to a case-specific key, seven-day expiry, and immutable audit logging. Sarah's own test role was pre-approved specifically to exercise this control, which is why the export succeeded during testing. The dossier's engagement-interpretation rules state that intended, authorized functionality should not remain a live finding when the control design and enforcement are adequately evidenced, and that evidence is present here. This retirement is a technical judgment about applicability, not a statement that the underlying capability is risk-free — it is carried forward as an assurance item rather than a finding: the report should recommend that MediPath periodically validate, through control testing rather than a repeat pentest, that every production path to this function actually enforces the ticket and dual-approval requirement without exception, since the engagement observed the control under a pre-approved test condition rather than an unannounced production attempt.

## Merged Findings

### Merger F-01 and F-10 as F-01/F-10

F-01 (cross-laboratory access to diagnostic result records) and F-10 (internal analytics service trusting a caller-supplied laboratory header) are merged because they are two manifestations of the same architectural gap: MediPath's tenant model expects the API gateway to inject a verified tenant claim, but individual services are expected to independently re-verify tenant ownership at the data-access layer, and in both cases that second check is missing. In F-01, the Results API authenticates the caller but never confirms that the requested result belongs to the caller's own laboratory tenant, allowing identifier substitution across labs. In F-10, the analytics service goes a step further and trusts a tenant identifier supplied directly in a request header rather than deriving it from any verified claim at all, and is reachable from the internal application network without passing back through the gateway. Both manifestations should remain individually traceable in the merged entry because they sit on different components with different exposure paths and different data sensitivity (individual health records in F-01 versus aggregate analytics in F-10), but the remediation is a single architectural correction: enforce verified tenant identity at every service's data-access layer rather than relying on gateway-injected trust, and remove any path that lets a caller supply its own tenant context. The merged item is carried forward under a single root-cause remediation while keeping both original findings and evidence files referenced for reporting completeness.

### Merger F-03 and F-09 as F-03/F-09

F-03 (long-lived integration token with cross-tenant privileges) and F-09 (administrative privileges remaining active after role downgrade) are merged because both point to the same underlying identity-and-session lifecycle gap: MediPath's authorization state — whether for a service token or an administrative session — is not revoked or re-evaluated at the moment a change occurs, but instead expires or resynchronizes on a time-based schedule. In F-03, a 180-day connector token retains a broad scope well beyond what any single integration needs, with no evidence that revocation happens except by waiting out the token's lifetime. In F-09, a downgraded administrator's session keeps write access for approximately 27 minutes because the distributed authorization cache invalidates on a timer rather than on the role-change event itself. Both manifestations are preserved in the merged entry because they affect different identity types (a machine credential versus a human session) and different components (the Hospital Integration Gateway versus the administrative console), but they share one corrective principle: authorization decisions need to be revoked or re-checked at the moment of a triggering event — token misuse, role change, or account status change — rather than relying on elapsed time. The merged item is carried forward as a single identity-governance remediation while both original technical manifestations remain documented for evidence and reporting purposes.

## Consolidated Retained List

| Finding | Final severity | Carried to Task 6 |
| --- | --- | --- |
| F-01/F-10 (merged) | 9.0 (Critical) — driven by F-01's confirmed cross-tenant health-data exposure; F-10 retained as a related, lower-sensitivity manifestation of the same root cause | Yes — carried as a single architectural item (tenant-identity enforcement) with both manifestations documented |
| F-02 | 6.8 (Medium) | Yes |
| F-03/F-09 (merged) | 9.4 (Critical) — driven by F-03's cross-institutional credential exposure; F-09's stale-privilege window retained as a related manifestation of the same identity-lifecycle gap | Yes — carried as a single identity-governance item with both manifestations documented |
| F-04 | 5.6 (Medium) | Yes — retained as a defense-in-depth gap; not retired, since the dossier's own rule is that a compensating control may reduce exposure without automatically erasing the underlying weakness |
| F-05 | 8.6 (High) | Yes |
| F-06 | 7.9 (High) | Yes |
| F-07 | Retired — not carried as a scored finding | No — carried forward only as an assurance/validation recommendation, not a finding |
| F-08 | 4.8 (Medium) | Yes |

## Notes on scope and discipline

- Only one finding (F-07) was retired in this pass. The client-context dossier evidences full authorization, technical control coverage, and audit logging for that specific capability; no other finding had comparably strong documented evidence of intended, controlled functionality, so the rest are retained rather than assumed neutralized.
- F-04 was considered for retirement given the managed mTLS gateway, but was kept as a retained finding at its recalibrated severity: the gateway is a genuine compensating control that lowers live exploitability, but the worker-level misconfiguration is still a real defense-in-depth gap that MediPath should fix, consistent with the dossier's instruction that a control does not automatically erase a weakness.
- Two mergers were made, both grounded in a specific shared technical root cause rather than surface-level similarity (tenant-identity enforcement for F-01/F-10; identity and session lifecycle revocation for F-03/F-09). No other pairing in the finding set shares a comparably direct mechanism, so the remaining findings (F-02, F-05, F-06, F-08) are retained individually.
- This triage assigns final severities and retire/merge/retain status only. It does not build attack chains, assign remediation owners, or quantify business impact — that work belongs to later tasks in the engagement.
