# Insider Threat Awareness Program
**Organization:** MedDefense  
**Program owner:** CISO James Chen | HR Director Maria Santos  
**Classification:** Internal — Manager distribution requires Legal review before deployment  
**Version:** 6x04 Security Awareness Program  
**Reference incidents:** Module 5 Cobalt Strike compromise; 6x02 IAM Audit findings

---

> *"We are not building a surveillance program. We are building a framework for recognizing when something is wrong before it becomes a breach. There is a difference."*
> — James Chen, CISO

---

## 1. Behavioral indicator framework

Behavioral indicators are defined as observable, documentable actions or patterns — not assessments of personality, loyalty, or mental state. Each indicator below describes something a designated observer could see, note, and report without speculating about the subject's intent.

Indicators are organized into three categories: **access-based**, **behavioral**, and **contextual**.

---

### 1.1 Access-based indicators

Access-based indicators describe patterns involving system access, credentials, or permissions that are inconsistent with a person's documented role.

| # | Indicator | Description | Observer |
|---|---|---|---|
| A-1 | Access to systems outside assigned role | An employee or contractor regularly accesses systems, files, or patient records that have no documented relationship to their current duties — for example, a Finance analyst accessing server administration tools after a role transfer. (Reference: IAM finding IAM-005, `j.yamamoto`) | IT, SOC, manager |
| A-2 | Repeated requests for elevated access without ticket | An employee or vendor makes verbal or email-only requests for admin or privileged access, bypassing the standard change request process — particularly when a justification deadline or urgency is cited. | IT, manager |
| A-3 | Access to patient records inconsistent with role or unit | An employee accesses an unusually high number of patient records unrelated to their assigned clinical unit or care team, or accesses records during off-hours without a documented treatment, payment, or operations reason. | SOC, IT, HR |
| A-4 | Dormant account activating unexpectedly | A user or service account that has had no recent logon activity shows an authentication event outside normal working hours or without a corresponding approved task or change ticket. (Reference: `svc_helpdesk` IAM finding IAM-002; Module 5 incident) | SOC, IT |
| A-5 | Contractor or transferred employee retaining access after role change | A contractor whose engagement has ended, or an employee who has moved to a new department, continues to authenticate to systems associated with their previous role. (Reference: IAM findings IAM-003 `t.morrison`, IAM-005 `j.yamamoto`) | manager, HR, IT |

---

### 1.2 Behavioral indicators

Behavioral indicators describe actions in workplace interaction, workflow, and process that deviate from expected patterns in a way that is directly observable.

| # | Indicator | Description | Observer |
|---|---|---|---|
| B-1 | Repeated attempts to bypass documented approval processes | An employee or vendor consistently attempts to complete privileged or sensitive actions — access grants, data exports, payment initiations — without following the approval steps required for those actions, citing urgency or exceptions repeatedly. | manager, IT |
| B-2 | Asking colleagues for credentials or MFA codes | An employee directly requests a coworker's password, MFA code, or shared account credentials, regardless of the reason given. Legitimate IT processes do not require credential sharing between employees. | coworker, manager |
| B-3 | Removing or disabling logging or audit tools on a workstation | An employee makes configuration changes that disable security logging, endpoint monitoring, or audit trail capture on their own workstation or a shared system, without an approved change ticket. | SOC, IT |
| B-4 | Bulk copying or exporting data outside normal workflow | An employee downloads, prints, or transfers an unusually large volume of files, patient records, or financial data using personal devices, personal email, or external storage during or outside work hours, without a documented business purpose. | SOC, IT, coworker |
| B-5 | Pressuring IT or helpdesk staff to grant access without process | An employee or manager instructs IT staff to grant access, reset credentials, or make privilege changes "right now" and to document it later — or requests that no ticket be created for an access change. | IT, coworker |

---

### 1.3 Contextual indicators

Contextual indicators are observable situational factors that, when combined with access-based or behavioral indicators, suggest a pattern worth reporting. Contextual indicators alone do not constitute a report threshold. They provide supporting context.

| # | Indicator | Description | Observer |
|---|---|---|---|
| C-1 | Access activity inconsistent with known work schedule | System access events occur at times that do not correspond to an employee's documented shift, travel, or leave status — for example, file access at 02:00 when the employee is on approved leave. | SOC, IT |
| C-2 | Role or status change not reported to IT by manager | An employee's access profile does not change after a documented promotion, department transfer, contractor end date, or termination — indicating the manager did not initiate the required access review notification. | HR, IT, manager |
| C-3 | Unusually frequent access to sensitive directories immediately before departure or resignation | An employee who has given notice, or whose contract is ending, accesses sensitive file repositories, financial records, or patient data at a volume or rate inconsistent with their remaining duties. | SOC, IT, manager |
| C-4 | Vendor support activity without a corresponding approved ticket | A vendor support session, remote access event, or configuration change occurs without a traceable service ticket or prior approval from IT, regardless of whether the vendor cited urgency. (Reference: Case C, vendor support overreach) | IT, manager |
| C-5 | Repeated security simulation failures without follow-through on assigned microtraining | An employee fails multiple consecutive security simulations and does not complete assigned microtraining — an observable administrative pattern, not a character judgment. Note: this indicator is for program tracking purposes only and must not be included in performance reviews per HR Privacy Rules (M. Santos). | HR, manager (aggregate only) |

---

## 2. Technical indicator framework

The following five technical indicators are recommended for MedDefense SOC monitoring. Each is tied to a specific log source and detection logic, and is cross-referenced to 6x02 IAM audit findings and Module 5 incident patterns where directly applicable.

---

### TI-1: Dormant privileged account activation

| Field | Detail |
|---|---|
| **Log source** | Windows Security Event ID 4624 (successful logon); IAM audit export |
| **Detection logic** | Alert when any account with Domain Admin or Server Admin group membership has had no authentication event in the preceding 90 or more days and then logs in successfully — particularly between 22:00 and 06:00. |
| **6x02 reference** | `svc_helpdesk` (IAM-002) was dormant for over 300 days before interactive logon at 02:13 was observed. `admin.legacy` (IAM-004) similarly dormant. |
| **Misuse pattern** | Attackers or malicious insiders prefer dormant accounts because detection baselines do not include them. Reactivation outside business hours with no approved change ticket is a high-confidence signal. |
| **Triage question** | Is this logon tied to an approved change, an active incident response task, or a scheduled maintenance window? If not, treat as suspicious until confirmed. |

---

### TI-2: Service account interactive logon

| Field | Detail |
|---|---|
| **Log source** | Windows Security Event ID 4624, LogonType 2 (interactive) or LogonType 10 (remote interactive) |
| **Detection logic** | Alert when any account whose SAM name begins with `svc_` generates a LogonType 2 or 10 event. Service accounts are automation accounts; they should never be used for interactive sessions by a human operator. |
| **6x02 reference** | `svc_helpdesk` was a ticket-routing automation account with Domain Admin rights (IAM-002). `svc_epic_int` held Domain Admin with no current business justification (IAM-001). Both are in scope for this detection. |
| **Misuse pattern** | An attacker using a compromised service account credential to pivot laterally will authenticate interactively. An insider misusing a shared service credential will do the same. Neither is a legitimate operational pattern. |
| **Triage question** | Is there a documented reason for a human to log in as this service account? If no owner is documented, escalate immediately. |

---

### TI-3: Privileged group membership change without change ticket

| Field | Detail |
|---|---|
| **Log source** | Windows Security Event IDs 4728 (member added to global security group), 4732 (member added to local security group), 4756 (member added to universal security group) |
| **Detection logic** | Alert when any account is added to Domain Admins, Server Admins, or other defined high-privilege groups. Correlate against open change tickets in the ITSM system. Alert if no approved ticket reference exists within 15 minutes of the event. |
| **6x02 reference** | Multiple accounts in the 6x02 audit held Domain Admin without documented business justification. `b.carter` (IAM-007) remained in privileged groups after account was disabled. |
| **Misuse pattern** | Privilege escalation is a precondition for most insider-misuse scenarios and all lateral-movement attacks. Unauthorized group membership changes are high-confidence indicators regardless of who initiated them. |
| **Triage question** | Who made the change, and is there a ticket with an approver? If not, suspend the change and investigate. |

---

### TI-4: LSASS memory access from unexpected process context

| Field | Detail |
|---|---|
| **Log source** | Sysmon Event ID 10 (ProcessAccess targeting lsass.exe) |
| **Detection logic** | Alert when any process other than defined, explicitly allow-listed security or backup tools accesses lsass.exe memory. Filter known-good security tooling. Alert on all others, prioritizing access from processes running under privileged account contexts. |
| **Incident reference** | The Module 5 Cobalt Strike compromise included an LSASS memory dump executed from a privileged account context — the same pattern used in post-exploitation credential harvesting. This indicator is relevant to both external compromise and insider misuse of privileged access. |
| **Misuse pattern** | LSASS access is the primary method for credential dumping. An insider with local admin access who wants additional credentials (to move laterally or cover tracks) would follow the same access pattern as an external attacker. |
| **Triage question** | Is the accessing process approved security tooling? If not, treat as credential access attempt. Activate IR playbook if paired with TI-1 or TI-2 signals. |

---

### TI-5: Bulk data access or exfiltration outside normal hours or role pattern

| Field | Detail |
|---|---|
| **Log source** | EHR audit log; file share access logs; EDR telemetry (file write/copy events to external media or personal cloud) |
| **Detection logic** | Alert when a user accesses more than a defined threshold of patient records within a session (threshold set by clinical operations to distinguish normal role activity from anomalous volume), or when large file transfers to external storage or personal cloud services are detected from a workstation. Correlate access time against shift schedule. |
| **6x02 reference** | Case D in insider threat case notes: administrative staff accessed unusually high number of patient records unrelated to role. EHR audit log review identified the pattern. |
| **Misuse pattern** | Data exfiltration is the end goal of most insider threats involving patient data or business records. Bulk access before a departure date or to records outside role scope is a high-fidelity signal when confirmed by audit log review. |
| **Triage question** | Does the employee's current role, shift, and care assignment justify this access volume and timing? If not, escalate to HR for minimum-necessary privacy review before broader investigation. |

---

## 3. Reporting process

### 3.1 Reporting channels

| Channel | Intended use | Response commitment |
|---|---|---|
| Anonymous web form (intranet security portal) | Employee concern — reporter does not want to identify themselves | Acknowledged within one business day; triage within three business days |
| security@meddefense.org | Non-urgent security concern with optional identity | Acknowledged within one business day |
| ext. 4-SECURITY | Immediate security concern | Live response during business hours; on-call SOC after hours |
| HR hotline | Concern with personnel or workplace sensitivity | Routed to HR and Legal as appropriate |
| Manager escalation | Operational context concern the manager has observed directly | Manager documents and escalates to IT Security or HR |

### 3.2 What to report

Report observable facts. Do not report speculation about intent, personality, or protected characteristics.

**Report:**
- An account used outside its expected purpose or hours
- An access request that bypasses normal approval
- A vendor or contractor asking for elevated access without a ticket
- A colleague asking for credentials or MFA codes
- A data access pattern that does not match the employee's role
- A vendor support session with no approved ticket reference
- A contractor or transferred employee still accessing systems after role change

**Do not report:**
- Personality conflicts or general workplace disagreements
- Speculation about a coworker's intentions or mental state
- Protected characteristics (race, health status, national origin, etc.)
- Simulation performance — report channels are not for simulation tracking

### 3.3 Anonymous reporting: triage steps

The anonymous reporting path is documented so that reports received through this channel are handled consistently, and so that the path can go live only once triage procedures are confirmed operational (per HR Director Maria Santos).

**Step 1 — Intake.** Security awareness program coordinator receives the report. Logs: date received, channel (anonymous), observable facts stated, any system or account referenced. No attempt to identify the reporter.

**Step 2 — Security triage.** SOC or IT Security reviews whether technical evidence corroborates the reported behavior. If technical evidence exists, proceed to Step 3. If no evidence and the report is not corroborated, log as unverified and monitor.

**Step 3 — HR inclusion threshold.** HR is notified when the concern involves employee conduct, a manager's action, or when coaching is the appropriate next step. HR is not included for purely technical investigations unless a workforce member is identified as the subject.

**Step 4 — Legal inclusion threshold.** Legal is notified when the investigation involves potential privacy exposure (patient records), employment law implications, regulatory reporting obligations, or any likelihood of formal action against a workforce member.

**Step 5 — Investigation.** Proceeds with minimum necessary disclosure. The subject of a report is not informed of the investigation until Legal and HR confirm the appropriate point of notification.

**Step 6 — Reporter acknowledgment.** For anonymous reports, the security portal posts a general status update when the report has been triaged. Individual acknowledgment is not possible without reporter identity.

### 3.4 Escalation threshold

Escalate to HR and legal counsel when any of the following conditions are met:

- Technical evidence supports a policy violation by a workforce member
- A repeated pattern exists after prior coaching or awareness intervention
- Privileged access misuse is suspected or confirmed
- Patient record misuse is suspected or confirmed
- A retaliation concern is raised by the reporter or subject
- The subject of the report is a manager or supervisor

### 3.5 Non-retaliation statement

MedDefense prohibits retaliation of any kind against any workforce member who raises a security, privacy, or safety concern in good faith — whether through named or anonymous channels, and whether or not the concern is substantiated upon review.

Retaliation includes adverse employment actions, hostile treatment, exclusion, or any action that would discourage a reasonable employee from reporting a concern. Any workforce member who believes they have experienced retaliation after making a report should contact HR directly. Retaliation concerns are reviewed jointly by HR and Legal and are treated as independent from the underlying security matter.

Enforcement reference: this non-retaliation commitment applies under MedDefense workforce policy, applicable employment law, and HIPAA workforce member protection provisions where patient privacy concerns are involved.

---

## 4. Manager reference guide

**MedDefense Insider Threat Awareness — Manager Reference**  
*One page. For department manager use. Requires Legal review before distribution.*

---

**What they are responsible for observing**

<!-- anchors: what they are responsible for observing | what to document | when to escalate | what not to do -->

You are positioned to see things that security tools cannot: who works in your department, what their role is today (not six months ago), and whether their behavior fits what you know about their job. You are not being asked to investigate. You are being asked to notice and report.

Observe and document when you see:
- A role transfer, promotion, or contractor end date — and whether you reported it to IT for access review
- An employee accessing systems that do not match their current assignment
- A request for elevated access without a ticket or approval process
- A vendor or contractor asking for broader system access than their work requires
- Repeated attempts by any employee to bypass documented approval steps

---

**What to document before escalating**

Before you raise a concern, write down:
- Date and time of the event or pattern
- What you observed — specific, factual, behavioral description
- Which system, process, or resource was involved
- Whether anyone else was present
- The business context you are aware of (is there a known project, audit, or approved task that might explain this?)
- Whether there is an immediate safety or compliance risk

Do not wait for a complete picture before escalating if an immediate risk exists.

---

**When to escalate**

Escalate to IT Security (ext. 4-SECURITY) or HR when:
- The behavior involves access to systems or patient records outside the employee's role
- The behavior repeats after a prior conversation or coaching session
- A vendor or employee is requesting unusual privilege and bypassing process
- A contractor or transferred employee appears to still have access they should not have
- An employee expresses distress or fear after a security simulation or incident

---

**What not to do**

- Do not confront the employee directly as a suspected insider threat
- Do not search the employee's personal devices, bags, or personal accounts
- Do not discuss your concern with other team members or the broader department
- Do not include security simulation performance in performance reviews or compensation decisions
- Do not make conclusions about motive — document facts and escalate
- Do not delay escalating an urgent security concern in order to handle it at the team level
- Do not accept verbal assurances from an employee or vendor as a substitute for a verified ticket or approval

---

*Questions: contact IT Security (ext. 4-SECURITY) or HR. This guide does not authorize investigation — it documents what to observe and where to send it.*

---

## 5. Culture and ethics statement

**To all MedDefense workforce members:**

This program exists because real threats to our patients, our colleagues, and our organization can come from unexpected directions — including from access that was once legitimate but was misused or compromised. The Module 5 incident showed that technical controls alone cannot protect us. A dormant account activated in the middle of the night. A credential harvested from a legitimate session. Both were visible before they became a breach.

This program does not exist to monitor you. It exists to give every member of our workforce a way to recognize when something is wrong and report it safely, without confronting anyone, without making accusations, and without fear of retaliation.

Your individual behavior in security training exercises is protected. Individual results are not shared with your manager without a documented HR process. Simulation performance cannot be used in performance reviews. Your reports — whether named or anonymous — are triaged by a defined process, not acted on impulsively.

What we are building is a shared awareness that access and trust should match role and context. When they do not — when an account is active at 2 AM with no explanation, when a vendor asks for more than their work requires, when a contractor is still logging in after their contract ended — those are the signals worth reporting.

This is not surveillance. This is the safety system that technical controls cannot replace on their own. We need every member of this workforce to be part of it.

— James Chen, CISO | Maria Santos, HR Director

---

*Document prepared for MedDefense 6x04 Security Awareness Program. Manager distribution of Section 4 requires Legal review and approval before deployment. All sections subject to annual review or immediate revision following any confirmed insider threat incident.*
