# Phishing Simulation Campaign Plan: MedDefense Health Systems

**Prepared by:** Security Awareness Program Team
**Date:** 2026-06-06
**Approved by:** CISO (campaign scope), HR Director (privacy boundaries)
**Distribution:** Security Team, CISO, HR Director

---

## Campaign overview

### Scope

**Total employee population:** 1,610 staff across six targeting segments (SEG-A through SEG-F).
**Simulation platform:** Approved phishing simulation platform integrated with MedDefense email gateway; simulation links route only to internal training landing pages. No external credential collection occurs.
**Duration:** 90-day initial rollout window with four simulation waves. Program continues quarterly thereafter with updated templates.

### Program objectives

| Objective | Baseline | click rate target (90-day) | report rate target (90-day) | 18-month trajectory |
|---|---:|---:|---:|---|
| Overall click rate | 56% | 35% or lower | — | 25% at 12 months; 12% at 36 months |
| Overall report rate | 15% | 35% or higher | — | 50% at 12 months; 70% at 36 months |
| Mean time to report | 74 min | 25 min or less | — | 15 min at 12 months; 10 min at 36 months |
| Repeat clicker rate | Unknown | Establish baseline | — | Below 8% at 12 months; below 4% at 36 months |
| Training completion | Not measured | 90% within 72h of click | — | 95% at 12 months; 98% at 36 months |
| Clinical click rate | 67% | 40% | — | 25% at 12 months; 12% at 36 months |

The program measures behavior change, not training completion. Click rate and report rate are primary indicators. Completion of assigned microtraining after a click is tracked separately as a secondary behavior metric.

### Governance framework

| Role | Responsibility |
|---|---|
| Security Awareness Program Manager | Runs campaign, assigns templates, reviews individual event data, triggers microtraining |
| CISO | approves templates before deployment; reviews results at each wave closeout; receives board-level aggregate summaries |
| HR Director | reviews results for escalation eligibility; signs off on manager-reporting exceptions; approves ethics policy updates |
| Legal | approves any vishing scripts that involve call recording |
| Department Managers | receive aggregate team trend data only; no individual click visibility |

**Template approval:** Every phishing template requires CISO and HR sign-off before deployment. Vishing scripts require CISO, HR, and Legal. No template may be deployed without written approval on file.

**Results review cadence:** Program Manager reviews wave metrics within 5 business days of wave close. CISO receives summary within 10 business days. Board-level summary delivered at quarterly governance meeting.

**Escalation to HR:** Escalation follows the criteria in Section 5. The Program Manager documents the trigger event and notifies HR in writing. HR confirms whether formal escalation conditions are met before any manager notification occurs.

---

## Employee segmentation

Total workforce: 1,610. Segmented into six groups based on role category, system access, and risk vector profile from the 6x02 IAM audit and threat profile.

### SEG-A — Clinical Leadership
**Estimated population:** 115 (charge nurses, nursing supervisors, department clinical leads)
**Primary systems:** Epic, LIS, secure messaging, phone escalation
**Primary risk vectors:** EHR impersonation, vendor support escalation, secure message lures, vishing
**Template assignment rationale:** Clinical leaders hold broader Epic access than floor staff and act as the verification hub for their units. They are targeted with intermediate and advanced templates including secure-message lures and vendor-callback scenarios. Vishing simulations are appropriate for this segment.
**Exclusion criteria:** Exclude during active patient safety events, Joint Commission accreditation rounding days, known ICU/OR surge windows, and any declared downtime.

### SEG-B — General Clinical Staff
**Estimated population:** 860 (nurses, patient care technicians, clinical assistants, radiology, laboratory, ED staff)
**Primary systems:** Epic, medication administration, workstation kiosks, LIS
**Primary risk vectors:** Epic account lures, patient message lures, secure message notifications
**Template assignment rationale:** Highest click rate in incident data (67% for clinical floor). Baseline EHR and secure-message lures deployed in Wave 1 and Wave 2. Lure realism increases across waves. Shift-start delivery windows required. ICU and ED staff receive limited-sample treatment only.
**Exclusion criteria:** Exclude ICU/OR during critical coverage windows and staffing shortages. Exclude ED during trauma surge and high-census alerts. Exclude Laboratory during STAT backlog periods. Do not send during flu-season peak (November–January) unless approved by CISO.

### SEG-C — Administrative and Billing Staff
**Estimated population:** 420 (billing specialists, schedulers, registration, HR coordinators, remote administrative workers)
**Primary systems:** Billing portal, HRIS, email, document systems, VPN
**Primary risk vectors:** MFA enrollment lures, HR benefits deadlines, compliance portal tasks, remote-access verification
**Template assignment rationale:** Administrative staff responded to compliance and portal-access framing in the Q1 campaign (63% click rate). Baseline compliance templates assigned in Wave 1. Benefits-deadline lures require HR approval before deployment. Remote workers assigned remote-access compliance variant.
**Exclusion criteria:** Exclude during payroll close and month-end if finance-adjacent. HR segment within SEG-C must not receive benefits lures without HR Director written approval. Exclude first week of employment for all new hires.

### SEG-D — IT and Security Staff
**Estimated population:** 105 (helpdesk, sysadmins, SOC analysts, endpoint engineers)
**Primary systems:** IAM, EDR, SIEM, admin consoles, ticketing, remote support tools
**Primary risk vectors:** Vendor support impersonation, privileged access lures, fake IT ticket escalations, service account hygiene
**Template assignment rationale:** IT staff showed the lowest click rate (25%) but highest downstream impact per compromise given privileged access. Lures must be technically plausible: vendor patch coordination with fake ticket numbers, change-window requests, admin console notifications. Generic credential lures are unlikely to succeed and should not be used as baseline for this group.
**Exclusion criteria:** Exclude active incident responders during any live incident or declared security event. Exclude SOC staff scheduled for on-call during simulation delivery window.

### SEG-E — Finance and Procurement
**Estimated population:** 75 (finance analysts, AP/AR, procurement staff)
**Primary systems:** ERP, payment workflows, banking portal, contracts
**Primary risk vectors:** BEC, invoice fraud, vendor banking change requests, sensitive document review
**Template assignment rationale:** Finance users are more likely to engage offline or reply than to click links (40% click rate, but higher action risk per event). BEC templates must use realistic executive name references and reply-to mismatch cues. Payment verification behavior is the primary training objective.
**Exclusion criteria:** Exclude on month-end close days and audit submission days. Finance and procurement staff must not be targeted simultaneously with a BEC template referencing the same named executive without CISO approval.

### SEG-F — Executives and Executive Assistants
**Estimated population:** 35 (C-suite, executive assistants, board office)
**Primary systems:** Email, board portals, travel systems, calendar
**Primary risk vectors:** Spear phishing, BEC, confidential document requests, travel security notices
**Template assignment rationale:** Executives had a 50% click rate and 0% report rate in the Q1 campaign. Executive assistants manage authorization workflows and present significant BEC exposure. Templates must use named internal personnel and realistic workflow context. Board packet and acquisition-document themes require CISO and HR pre-approval. Delivery must be coordinated with the executive assistant to avoid board meeting days.
**Exclusion criteria:** Coordinate with executive office calendar before every wave. Exclude board meeting days, quarterly reporting windows, and any publicly announced M&A activity periods.

---

## Wave schedule

90-day rollout: four waves across 13 weeks. Cool-down rule: same population must not receive another simulation within 21 days. Employees who click receive microtraining immediately; they do not receive another lure until microtraining is confirmed complete.

### Wave 1 — Baseline Reconnaissance (Days 1–14)

**Delivery window:** Days 1–14
**Target segments:** SEG-B (general clinical, limited sample 200 of 860), SEG-C (administrative, full)
**Template difficulty tier:** Baseline
**Templates assigned:**
- SEG-B: Epic account hold notification (baseline EHR lure, authority + urgency)
- SEG-C: MFA enrollment compliance task (baseline compliance lure, familiarity + authority)

**Delivery timing:**
- SEG-B: 07:15–08:30 Tuesday or Wednesday (shift-start window, shift-overlap period)
- SEG-C: 09:30–11:00 Tuesday or Thursday (mid-morning, outside payroll close)

**Day-of-week rationale:** Tuesday and Wednesday are operationally stable for clinical staff. Thursday morning is stable for administrative staff. Avoid Monday (handoff backlog) and Friday (pre-weekend noise).

**Cool-down:** SEG-B and SEG-C not targeted again before Day 35.
**Wave 1 objective:** Establish baseline click rate and report rate for primary volume segments.

---

### Wave 2 — Intermediate Expansion (Days 22–36)

**Delivery window:** Days 22–36
**Target segments:** SEG-A (clinical leadership), SEG-D (IT), remaining SEG-B sample (300 additional)
**Template difficulty tier:** Intermediate
**Templates assigned:**
- SEG-A: Secure patient message notification (familiarity + urgency, intermediate)
- SEG-D: Vendor patch coordination with fake ticket number (authority + technical specificity, intermediate)
- SEG-B (second cohort): Epic account hold (same baseline template; SEG-B first cohort excluded by cool-down)

**Delivery timing:**
- SEG-A: 07:15–08:30 Wednesday (shift-start, coordinate with unit leads)
- SEG-D: 10:00–11:30 Tuesday (mid-morning, outside maintenance windows unless specifically targeting maintenance-window timing)
- SEG-B: 19:15–20:30 Wednesday (evening shift-start)

**Cool-down:** SEG-A and SEG-D not targeted again before Day 57.
**Wave 2 objective:** Extend coverage; test IT-specific and clinical leadership lure effectiveness; measure report rate improvement from Wave 1 microtraining.

---

### Wave 3 — Advanced Targeting (Days 43–57)

**Delivery window:** Days 43–57
**Target segments:** SEG-E (finance), SEG-F (executives), SEG-C (second pass)
**Template difficulty tier:** Advanced
**Templates assigned:**
- SEG-E: BEC invoice fraud — vendor banking change request with executive name reference (authority + social proof)
- SEG-F: Confidential document review request with reply-to mismatch (authority + social proof, spear-phishing variant)
- SEG-C: HR benefits deadline scarcity lure (scarcity + urgency, intermediate-to-advanced)

**Delivery timing:**
- SEG-E: 10:30–12:00 Wednesday (mid-week, outside month-end)
- SEG-F: Coordinated with executive assistant; Tuesday or Wednesday 09:00–11:00
- SEG-C: 09:30–10:30 Tuesday (outside payroll close)

**Day-of-week rationale:** Wednesday mid-morning is the most operationally neutral window for finance and executive segments. Avoid Friday for BEC templates (pre-weekend urgency artificially inflates action rate in ways that skew training data).

**Cool-down:** SEG-E, SEG-F, SEG-C not targeted again before Day 78.
**Wave 3 objective:** Test high-impact low-volume segments; confirm BEC recognition behavior; measure reply-channel verification as a training outcome.

---

### Wave 4 — Full Coverage and Repeat Clicker Assessment (Days 64–78)

**Delivery window:** Days 64–78
**Target segments:** SEG-A (second pass), SEG-B (final cohort, remaining 360), SEG-D (second pass)
**Template difficulty tier:** Intermediate to advanced
**Templates assigned:**
- SEG-A: Vendor emergency support callback — vishing warm-up email (intermediate, authority + urgency)
- SEG-B: Secure patient message notification (intermediate; population now trained on baseline Epic lure)
- SEG-D: Admin console privilege request with change-ticket reference (advanced)

**Delivery timing:**
- SEG-A: 07:15–08:30 Thursday
- SEG-B: 07:15–08:30 Wednesday and 19:15–20:30 Wednesday (split by shift group)
- SEG-D: 10:00–11:30 Wednesday

**Cool-down:** All segments have completed 90-day rollout. Quarterly cadence begins post-Day 90.
**Wave 4 objective:** Complete coverage of full workforce; identify repeat clickers for coaching escalation; compare Wave 4 metrics to Wave 1 baseline to assess 90-day behavior change.

---

## Metrics framework

All metrics are tracked per wave and cumulatively. Individual event data is visible only to the Program Manager. Segment and department aggregates are reported to CISO and department managers respectively.

### click rate

**Formula:** (Employees who clicked ÷ Employees who received simulation email) × 100
**Measurement interval:** Per wave; cumulative 90-day
**90-day target:** 35% or lower overall; 40% or lower for SEG-B clinical
**18-month target:** 25% overall; 12% at 36 months
**Deteriorating result:** A click rate that increases wave over wave within the same segment indicates lure escalation is outpacing training absorption. Pause escalation tier and repeat baseline lure with reinforced microtraining before advancing.

### report rate

**Formula:** (Employees who reported simulation email ÷ Employees who received it) × 100
**Measurement interval:** Per wave; cumulative 90-day
**90-day target:** 35% or higher
**18-month target:** 50% at 12 months; 70% at 36 months
**Deteriorating result:** A report rate below 15% in any wave signals that employees are neither clicking nor reporting — passive non-engagement. Review whether reporting path (Outlook button, ext. 4-SECURITY) is accessible and whether post-simulation messaging is suppressing reporting due to fear of blame.

### repeat clicker rate

**Formula:** (Employees who clicked in two consecutive waves ÷ total employees in both waves) × 100
**Measurement interval:** Calculated after Wave 2 closes; updated after each subsequent wave
**90-day target:** Establish baseline
**18-month target:** Below 8% at 12 months; below 4% at 36 months
**Deteriorating result:** A repeat clicker rate above 15% in any segment after Wave 2 indicates that microtraining assigned after Wave 1 did not produce behavior change. Escalate to HR for coaching review per Section 5 criteria.

### mean time to report

**Formula:** Average of (report timestamp − delivery timestamp) across all reporting events in a wave, in minutes
**Measurement interval:** Per wave
**90-day target:** 25 minutes or less
**18-month target:** 15 minutes at 12 months; 10 minutes at 36 months
**Deteriorating result:** If mean time to report increases wave over wave, employees are delaying after suspecting a message. Review post-simulation messaging to confirm that reporting-after-clicking is explicitly encouraged. Consider deploying a visible reporting-rate leaderboard at team aggregate level to normalize the behavior.

### post-simulation training completion rate

**Formula:** (Employees who completed assigned microtraining within 72 hours of click ÷ total employees who clicked) × 100
**Measurement interval:** Per wave, measured at 72-hour and 7-day marks
**90-day target:** 90% within 72 hours
**18-month target:** 95% at 12 months; 98% at 36 months
**Deteriorating result:** Completion below 80% after Wave 2 indicates that microtraining assignment or access is failing operationally. Confirm that the training link is accessible from both clinical kiosks and mobile devices. Escalate persistent non-completion to the Program Manager for follow-up.

### false-positive report rate

**Formula:** (Real legitimate emails reported as phishing ÷ total emails reported) × 100
**Measurement interval:** Ongoing; reviewed monthly
**90-day target:** Track and establish baseline; no suppression target in Year 1
**18-month target:** Operationally manageable within SOC triage workflow; stable with triage automation at 36 months
**Deteriorating result:** A sharply rising false-positive rate signals over-sensitization — employees are reporting indiscriminately. This requires targeted guidance on what a reportable signal looks like versus normal business email. Do not penalize employees for false positives; adjust training cues instead.

---

## Escalation framework

Simulation results remain training events unless one or more of the following escalation criteria are met. Escalation criteria are evaluated by the Program Manager after each wave closeout.

### Level 1 — Coaching Trigger (Program Manager to HR, no manager notification)

Conditions: An employee clicks in two consecutive simulation waves AND does not complete assigned microtraining within 7 days of the second click.

Action: Program Manager notifies HR in writing. HR schedules a private coaching conversation with the employee. Department manager is not notified at this stage. This is a coaching event, not a disciplinary event.

### Level 2 — Manager Notification (HR-confirmed escalation only)

Conditions: All four of the following must be true:
1. The employee has clicked in two consecutive simulation waves.
2. The employee has not completed assigned microtraining after two consecutive waves.
3. HR has confirmed the formal escalation trigger in writing.
4. The purpose of manager notification is to arrange coaching support, not to initiate discipline.

Action: HR notifies the department manager with aggregate context only. Individual click events are described as a "repeated training gap requiring coaching support." The second confirmed offense condition required by the HR privacy rules is satisfied before any manager contact occurs.

### Level 3 — Security Investigation Referral

Conditions: Any of the following observed in simulation telemetry or correlated IAM/SIEM data:
- An employee submits credentials to a simulation landing page and then immediately attempts to access systems inconsistent with their role.
- A simulation click correlates with anomalous privileged access activity in the IAM or SIEM within the same session window.
- A simulation event reveals that an account has been compromised by a third party (non-employee activity on the account in the click window).
- An employee pattern matches insider threat indicators documented in the insider threat reference materials (dormant account activation, role-inconsistent data movement following simulation interaction).

Action: Program Manager escalates to SOC and CISO immediately. HR is notified in parallel. The event transitions from a training record to a security incident. The employee's manager is not the first point of contact; SOC and HR lead the investigation jointly.

### Level 4 — Formal HR Process

Conditions: Security investigation (Level 3) confirms intentional non-compliance, deliberate credential disclosure, or policy violation beyond simulation failure.

Action: HR and Legal lead. Simulation records are provided as supporting documentation under HR-approved legal hold. Program Manager role in this stage is documentation only.

---

## Governance framework

### Template lifecycle

| Stage | Owner | Requirement |
|---|---|---|
| Draft | Program Manager | Based on approved lure categories from ethics guidelines |
| Review | CISO + HR | Written sign-off required before deployment |
| Deployment | Program Manager | Simulation platform only; no external credential collection |
| Retirement | Program Manager | Templates retired after 3 uses or if click rate drops below 5% (indicating population recognition) |
| Post-campaign review | CISO | Wave results reviewed within 10 business days |

### Reporting cadence

| Report | Audience | Frequency | Contents |
|---|---|---|---|
| Wave closeout summary | CISO | After each wave | Segment click rate, report rate, mean time to report, microtraining completion |
| Department aggregate | Department managers | After each wave | Team trend only; no individual data |
| Executive summary | CISO + board | Quarterly | 90-day progress vs. targets; 18-month trajectory |
| HR escalation log | HR Director | As triggered | Escalation events only; no bulk individual data |

---

## Exclusion and ethics policy

### Exclusion criteria

The following employees are excluded from all simulation waves regardless of segment:

- Employees on approved leave (medical, personal, FMLA)
- Employees in their first week of employment
- Employees involved in an active patient safety event
- Employees assigned to active incident response
- Employees under an HR-approved support plan where simulation would be clinically or personally inappropriate
- ICU and OR staff during declared critical coverage windows
- SOC analysts during active security incidents
- ED staff during declared trauma surge or high-census alerts

Exclusions are reviewed by the Program Manager before each wave delivery. Exclusion list is maintained in the simulation platform and updated no later than 48 hours before delivery.

### Individual vs. aggregate disclosure framework

Individual simulation results are not to appear in performance reviews. Click results are not shared with department managers unless the second confirmed offense and formal HR escalation conditions are both met. Managers receive aggregate team data only. Individual data is retained for 18 months for trend analysis, then aggregated or deleted unless an active HR-reviewed coaching process is ongoing.

### Post-simulation support

Employees who click are directed to a landing page that: states this was a simulation; avoids blame or shaming language; identifies the specific cues that indicated a phishing message; explains what a real attacker could have gained; provides three next-time actions; shows how to report using the Outlook button or ext. 4-SECURITY; and completes in 5 minutes or less.

If an employee contacts HR or their manager expressing distress after a simulation, the Program Manager is notified. The employee is offered a private conversation with HR or an EAP contact. The simulation result is not referenced in that conversation unless the employee raises it.

### Governance sign-off requirements

No template may be deployed without written approval on record:

| Template type | Required approvers |
|---|---|
| Phishing email template | CISO + HR Director |
| Vishing script (not recorded) | CISO + HR Director |
| Vishing script (recorded) | CISO + HR Director + Legal |
| Insider threat manager guide | HR Director + Legal |
| Benefits lure (HR segment) | HR Director explicit written approval |
| BEC template with named executive | CISO written approval per template |

---

## Success criteria

### 12 months

- Overall click rate at or below 25%
- Overall report rate at or above 50%
- Mean time to report at or below 15 minutes
- Repeat clicker rate below 8%
- Post-simulation training completion rate at or above 95%
- Finance BEC payment verification rate at or above 80%
- All six segments have completed at least two simulation waves with wave-over-wave click rate reduction

### 24 months

- Overall click rate at or below 18%
- Overall report rate at or above 60%
- Mean time to report at or below 12 minutes
- Repeat clicker rate below 6%
- False-positive report rate operationally manageable within SOC triage workflow
- Vishing verification success rate at or above 75% in SEG-A and SEG-D
- Manager escalation confidence baseline survey shows +25% improvement from program launch

### 36 months

- Overall click rate at or below 12%
- Overall report rate at or above 70%
- Mean time to report at or below 10 minutes
- Repeat clicker rate at or below 4%
- Post-simulation training completion rate at or above 98%
- Finance BEC payment verification rate at or above 95%
- False-positive report rate stable and manageable with triage automation
- Program is self-sustaining with quarterly template refresh cycle and no manual campaign manager escalation required for routine waves
