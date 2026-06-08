# MedDefense SOC Automation Strategy
**Prepared for:** James Chen (SOC Staffing) · Dr. Morales (Budget)  
**Date:** 2026-06-08  
**Basis:** SOC volume baseline, integration test outcomes (Tasks 1–5), playbook decision logic

---

## 1. Current State Analysis

### Alert volume and analyst effort

MedDefense processes 150 alerts/day (midpoint of the 120–180 SIEM range).  
At 8 minutes per alert, the daily manual triage load is:

```
150 alerts/day × 8 min/alert = 1,200 min/day = 20 analyst-hours/day
```

The March triage review found that 67 percent of that time is enrichment activity — IP reputation lookups, domain classification, privilege checks — not judgment:

```
20 analyst-hours/day × 0.67 = 13.4 hours/day on lookup/enrichment
6.6 hours/day on actual analyst decision-making
```

At a 5-analyst SOC (40-hour week), enrichment alone consumes more than two full-time equivalent positions per week. That leaves the SOC chronically under-resourced for the work that requires human judgment.

### Cost of manual enrichment during a real incident

During the April 2026 Cobalt Strike intrusion, a single IP enrichment lookup — `198.51.100.42`, the C2 node that later appeared in ALT-20260428-007 — took **45 minutes** because the analyst had no automated IOC context. The phishing playbook built in Task 3 enriches that same IOC in under one second. During an active breach, 45 minutes of lost enrichment time is not a workflow inefficiency — it is attacker dwell time.

---

## 2. Automation Candidates

Prioritized by impact-to-risk ratio. "Enrich-and-act" is not approved until FP thresholds are measured in production.

| Process | Daily volume | Manual effort | Automation complexity | FP risk | Recommended tier | FP threshold required |
|---|---|---|---|---|---|---|
| Phishing IOC enrichment | 150/day | 8 min/alert | Low | Low | Enrich-only | N/A |
| Automated case creation from playbook verdict | 150/day | 2 min/alert | Low | Low | Enrich-and-triage | N/A |
| Credential exposure enrichment + privilege check | 12/day | 8 min/alert | Medium | Medium | Enrich-and-triage | N/A |
| Phishing benign auto-close (internal sender, private IP, all-ALLOW IOCs) | ~35/day | 3 min/alert | Medium | Medium | Enrich-and-triage → Enrich-and-act (Phase 2) | < 5% false-negative rate measured over 30 days |
| Endpoint isolation queue for BLOCK-IP + Domain Admin credential alerts | 4/day | 10 min/alert | High | High | Human-authorized action | < 1% FP before queue entry triggers auto-isolate |
| Mailbox quarantine for confirmed phishing (ESCALATE verdict) | 15/day | 6 min/alert | High | High | Human-authorized action | < 1% FP; clinical safety review required |
| Privileged account disablement | 1/day | 15 min/alert | High | Critical | Human-only | Not eligible for automation given clinical operations risk |

The integration test confirmed that the phishing playbook correctly classifies internal-sender alerts as CLOSE/Low (ALT-20260428-003) and that the credential playbook writes only BLOCK+Domain-Admin hosts to the isolation queue (ALT-20260428-007). Both of these outcomes are prerequisites for trusting the automation tier above them.

---

## 3. Expected Efficiency Gains

**Formula (as specified):**

```
hours_saved_per_day = (volume × manual_effort_minutes × automation_rate) / 60
```

Applying to phishing triage at 80% automation rate (conservative: ~20% of alerts require analyst override):

```
(150 alerts/day × 8 min/alert × 0.80) / 60 = 16 hours/day saved
Monthly: 16 × 22 working days = 352 analyst-hours/month
```

At a fully-loaded analyst cost of $75/hour (budget planning figure), that is approximately **$26,400/month** in reallocated capacity — not cost reduction, but redeployment toward threat hunting and incident response.

**Confidence level: Medium.**

This estimate is invalidated by any of the following:
- The measured false-negative rate for auto-close exceeds 5%, requiring manual re-review of closed cases.
- Alert volume shifts significantly from the 150/day baseline (e.g., after a major infrastructure change).
- The playbook is deployed without the IOC feed being kept current; stale feed data degrades enrichment accuracy and forces analyst overrides, collapsing the automation rate below 80%.
- Integration with the live SIEM introduces alert formats that differ from the JSON schema the playbook expects, requiring re-parsing logic.

---

## 4. Risks of Over-Automation

### Risk 1 — Auto-closure masking a multi-phase attack

**Scenario:** The phishing playbook closes ALT-20260428-003-type alerts (internal sender, private IP) as Low/benign. An attacker who has already compromised an internal mail relay uses that foothold to send credential-harvesting emails that appear to originate from `10.0.x.x`. The playbook closes them. The credential exposure playbook never fires because the phishing stage was suppressed.

**Consequence:** Phase 1 of the attack (phishing) is invisible in the case queue. The only alert that surfaces is a credential dump weeks later, by which time the attacker has had undetected access. Under HIPAA §164.308(a)(1), failure to detect a breach due to inadequate monitoring is a reportable deficiency.

**Control:** Auto-closed cases are logged to `playbook_audit.log` and reviewed in weekly batch by a senior analyst. Any auto-closed case whose source IP or sender domain appears in a subsequently opened case within 14 days is automatically re-opened and escalated.

---

### Risk 2 — Automated endpoint isolation disrupting active clinical operations

**Scenario:** `svc_helpdesk` (Domain Admin, currently in the isolation queue for WST-WS-031) is running the clinical helpdesk ticketing system. Auto-isolation of that workstation severs the ticketing interface used by nursing staff to report medication dispensing errors. The isolation fires at 02:00 during a night shift with no analyst available to review.

**Consequence:** Clinical staff lose access to the incident-reporting tool during the isolation window. If a medication error occurs during that window and goes unreported due to system unavailability, MedDefense faces both a patient safety event and a potential Joint Commission reporting obligation.

**Control:** The isolation queue (`isolation_queue.json`) is a **human-authorization queue only** — as implemented in the credential exposure playbook. No automatic isolation executes without analyst sign-off. The queue entry includes the host, alert ID, and privilege level so the on-call analyst has full context before authorizing. This gate is not bypassed in any phase of the roadmap until the FP rate is measured below 1% and a clinical impact assessment is completed.

---

### Risk 3 — Stale IOC feed producing systematic false negatives in a regulated environment

**Scenario:** The enrichment engine downgrades a threat from BLOCK to INVESTIGATE because the IOC feed has not been updated and a new C2 infrastructure IP is not yet listed. The phishing playbook returns REVIEW instead of ESCALATE for 20 alerts that all contain the same new C2 domain. Those alerts sit in the analyst review queue during a holiday weekend.

**Consequence:** Under HIPAA Breach Notification Rule, MedDefense has 60 days from discovery of a breach to notify affected patients. If automated triage suppresses the alert severity, the discovery date is delayed — shortening the response window and potentially constituting a compliance violation if notification is late.

**Control:** The IOC feed has a `updated` timestamp. The enrichment engine must check that this timestamp is within 24 hours before running; if stale, it defaults all unknown IPs and domains to INVESTIGATE rather than ALLOW and pages the threat intel owner. Feed currency is a Phase 1 success criterion.

---

## 5. Implementation Roadmap

### Why this sequence is non-negotiable

Phase 1 collects ground-truth data. Without a measured FP rate, any auto-close or auto-escalate decision is a guess applied at machine speed. Robert Kim's concern — that automation will produce an automated version of MedDefense's existing problems — is precisely the failure mode that gating on FP measurement prevents. No analyst should authorize Phase 2 unless Phase 1 has produced a defensible FP number.

---

### Phase 1 — Enrichment Only (Days 1–90)

**Scope:** Deploy enrichment engine and both playbooks in log-and-recommend mode. Playbooks run against all live alerts. They create cases, assign severity, and write recommendations — but no case is closed and no isolation queue entry fires automatically without analyst review of every output.

**Deliverables:**
- Enrichment engine integrated with live SIEM feed
- Both playbooks running in production with full audit logging
- `playbook_audit.log` reviewed weekly; analyst override rate tracked
- IOC feed update SLA defined and monitored (≤ 24 hours)
- FP rate dashboard: per-playbook, per-verdict, per-alert-type

**Success criteria:**
- Enrichment reduces average analyst triage time from 8 min to < 3 min per alert
- IOC feed currency maintained ≥ 99% of days
- Playbook audit log reviewed with zero unreviewed overrides

**Gate condition for Phase 2:** Measured false-negative rate for phishing CLOSE verdicts is below 5% over a minimum 30-day window with at least 500 processed alerts. This must be signed off by the SOC lead (James Chen) and documented.

---

### Phase 2 — Enrich-and-Triage with Auto-Close for Confirmed Benign (Days 91–180)

**Scope:** Enable automatic case closure for alerts where the phishing playbook returns CLOSE/Low AND the source IP is in the RFC-1918 internal range AND all IOCs are ALLOW. All other verdicts still require analyst confirmation.

**Deliverables:**
- Auto-close logic enabled for the specific condition above
- Weekly batch review of all auto-closed cases remains in place
- Re-open trigger implemented (same-IP/domain match within 14 days)
- Analyst override rate monitored; if it rises above 10%, auto-close is suspended

**Success criteria:**
- Auto-close FP rate stays below 5% in production
- Zero auto-closed cases later identified as part of an active incident
- Analyst hours freed by auto-close are documented and reallocated

**Gate condition for Phase 3:** Auto-close has operated for 60 days with zero incidents attributable to suppressed alerts, and the credential exposure enrichment FP rate is below 2% over 30 days.

---

### Phase 3 — Conditional Escalation (Days 181–270)

**Scope:** Enable automatic escalation (SIEM ticket + on-call page) for ESCALATE/Critical verdicts from both playbooks when the source IP verdict is BLOCK with confidence ≥ 90. The isolation queue remains human-authorized; no automatic endpoint action executes in this phase.

**Deliverables:**
- Auto-escalation pipeline integrated with on-call paging system
- Clinical safety review completed for any action that touches patient-care systems
- Rollback procedure tested and documented
- Change-management record filed per MedDefense ITSM policy

**Success criteria:**
- Mean time to escalation for Critical alerts reduced from current baseline to < 5 minutes
- Zero missed escalations for BLOCK-verdict alerts over 30 days
- On-call analyst confirms each auto-escalation is valid within 15 minutes (audit trail)

---

*This document is derived from measured SOC baseline data and confirmed integration test outcomes. All numeric claims are traceable to `strategy/soc_volume_baseline.md` and `integration/expected_outcomes.csv`. Assumptions are labelled as such in Section 3.*
