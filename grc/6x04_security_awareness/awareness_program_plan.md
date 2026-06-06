# Annual Security Awareness Program Plan
**Organization:** MedDefense  
**Prepared for:** Dr. Morales — Board of Directors Presentation, Q3 2026  
**Program owner:** CISO James Chen  
**HR lead:** Maria Santos  
**Operations lead:** Sarah Park  
**Classification:** Confidential — Board Distribution

---

## Executive summary

**Problem statement**

In March 2026, MedDefense experienced a security incident that began with a phishing campaign and resulted in Cobalt Strike beacon activity, confirmed credential exposure, and lateral movement across internal systems. Forty-one phishing emails were delivered. Twenty-three employees clicked — a 56% click rate. Only two employees reported the email before the SOC detected beacon activity, and mean time to report was 74 minutes. The SOC did not correlate the incident until 4 hours and 33 minutes after the first click. Technical controls — email gateway, SIEM, endpoint detection — performed their designed functions. They could not prevent a trained employee from entering credentials into a convincing fake portal. The root cause at the human layer was a workforce that had received annual compliance training but had no practical framework for recognizing healthcare-specific lures, no habit of using the phishing report button, and no role-specific guidance for high-risk scenarios such as helpdesk impersonation or executive-authority pressure. A post-incident review documented a second failure: a helpdesk verification call was misdirected because the receiving employee had no framework for verifying a caller's identity. Two peer healthcare organizations reported vishing incidents targeting clinical supervisors and finance staff in Q1 2026, both beginning with publicly available information from LinkedIn and facility websites. The estimated cost of the Module 5 incident — including IR activation, endpoint containment, forensic analysis, credential reset at scale, legal review, and executive communications — exceeded the entire annual budget proposed for this program.

**Program approach**

This program is not annual compliance training. It is a continuous behavior-change system built on four principles that distinguish it from legacy checkbox programs. First, it uses realistic simulation under controlled conditions: employees encounter the actual cognitive pressure of a phishing lure or vishing call, then receive immediate feedback tied to that specific experience — not a generic awareness module deployed weeks later. Second, it is role-segmented: clinical staff receive lures that match clinical workflows; finance staff receive BEC and payment-verification scenarios; IT staff receive privilege-discipline and vendor-impersonation content. A nurse and a finance coordinator face different threats, and training that ignores this difference produces neither behavior change nor measurable risk reduction. Third, it measures behavior — click rate, report rate, mean time to report, post-click training completion — not attendance. The board will receive metrics that indicate whether the workforce is actually behaving more safely, not whether a learning management system recorded a completion. Fourth, it is constrained by healthcare operational reality: no new clinical simulations during the Joint Commission accreditation window or the November-through-January flu season peak; no finance simulations during month-end close; no executive targeting on board meeting days. Training that disrupts patient care or creates avoidable staff burden is not safer — it is counterproductive.

**Expected outcomes**

At 12 months, MedDefense targets an overall phishing click rate below 25% (down from 56%), a suspicious email report rate above 50% (up from 15%), and mean time to report below 15 minutes (down from 74 minutes). Finance staff BEC verification rate reaches 80%. Vishing simulation verification success reaches 75%. Post-click microtraining completion reaches 95% within 72 hours. At 36 months, click rate falls below 12%, report rate reaches 70%, mean time to report falls below 10 minutes, and finance BEC verification reaches 95%. These targets are drawn from the metrics baseline established from the Module 5 incident and validated against industry benchmarks for mature healthcare security awareness programs. If achieved, they represent a workforce that is a functioning early-warning layer — not a gap in MedDefense's security architecture.

---

## Annual campaign calendar

The calendar below covers months 1 through 12 of the program. Months are numbered from program launch (following CISO and HR sign-off). All campaigns respect the following hard constraints from Sarah Park and clinical operations:

- **No new clinical training content** during the Joint Commission accreditation window (assumed Q4, Month 10–11 in this plan).
- **No new clinical simulations** during flu season peak: November through January (Months 10–12 in a typical Q1 launch).
- Existing microtraining content and reinforcement reminders may continue during restricted windows.
- Finance simulations avoid month-end close weeks. Executive simulations avoid board meeting days. IT simulations avoid active incident response periods.

---

| Month | Campaign type | Target audience | Delivery method | Success metric |
|---|---|---|---|---|
| **Month 1** | Baseline phishing simulation — Wave 1 (healthcare account lures: Epic account verification, MFA enrollment) | All staff: SEG-B (clinical), SEG-C (administrative/billing), SEG-D (IT), SEG-E (finance), SEG-F (executives) — staggered by segment | Simulated phishing email via platform; post-click landing page with immediate microtraining | Establish baseline click rate and report rate per segment; 90% landing page completion |
| **Month 2** | Post-click intervention reinforcement + phishing report button campaign | All staff who clicked in Wave 1; all staff for report-button awareness | Targeted microtraining (72h post-click); all-staff awareness email on how to use report button | 90% microtraining completion among clickers within 72h; report rate increase vs. Month 1 baseline |
| **Month 3** | Phishing simulation — Wave 2 (secure message lures, credential verification) + vishing tabletop exercise | SEG-B clinical supervisors (vishing tabletop); SEG-C administrative staff (Wave 2 phishing) | Wave 2 phishing via platform; live facilitated vishing tabletop for nursing supervisors and clinical leads | Click rate reduction vs. Wave 1; vishing tabletop: 75% of participants demonstrate correct verification behavior |
| **Month 4** | Role-based guidance rollout — quick reference guides for all segments | All segments: SEG-A through SEG-F | Intranet publication; manager briefing; department-level discussion facilitated by managers | 80% intranet access confirmation; manager survey on guide usability |
| **Month 5** | BEC and payment-verification simulation (executive authority impersonation, vendor banking change) | SEG-E (Finance, Procurement), SEG-F (Executive Assistants) | Simulated BEC email scenario via platform; facilitated tabletop for finance leads | Finance BEC verification rate baseline established; 75% pass rate on verification behavior in tabletop |
| **Month 6** | Insider threat awareness training — manager cohort | Department managers, IT, HR (all segments manager layer) | Facilitated manager briefing; insider_threat_program.md manager reference guide distribution (post-Legal review) | 90% manager attendance or async completion; manager escalation confidence survey baseline |
| **Month 7** | Phishing simulation — Wave 3 (intermediate difficulty: lures using internal workflow language) | SEG-C (billing, registration, remote admin), SEG-D (IT helpdesk, systems engineering) | Simulated phishing via platform — lures use MedDefense-specific workflow language; avoid clinical overload | Click rate at or below 25% for targeted segments; report rate above 40% |
| **Month 8** | Remote worker security campaign (VPN hygiene, home network awareness, device security) | SEG-C remote administrative staff (84 staff) | Async digital content module; short live Q&A session; post-module knowledge check | 85% module completion; knowledge check pass rate above 80% |
| **Month 9** | Program metrics review + mid-year board report preparation | CISO, HR, program manager — internal only | Internal metrics review session; draft board metrics summary | 12-month targets on track confirmed; board metrics package drafted |
| **Month 10** | **RESTRICTED WINDOW — Joint Commission accreditation period.** No new clinical content or simulations. | Non-clinical segments only if operationally feasible: SEG-E (Finance), SEG-F (Executives) — only if board meeting schedule permits | Reinforcement-only for clinical staff: existing microtraining available, no new sends. Optional: finance reinforcement email (no new simulation). | No clinical disruption; existing completion rates maintained |
| **Month 11** | **RESTRICTED WINDOW — Flu season peak begins (November).** No new clinical simulations. | Non-clinical staff only: SEG-D (IT) — vendor impersonation and privilege discipline reinforcement; SEG-F (Executives) if board schedule permits | IT-focused async content on privilege discipline; reinforcement for non-clinical staff only; no new clinical simulation sends | IT privilege-discipline awareness uptick; clinical staff not targeted |
| **Month 12** | Annual metrics consolidation + board presentation package + Year 2 plan draft | Program leadership (CISO, HR, clinical ops, finance rep) for internal review; Dr. Morales for board presentation | Internal metrics review; board metrics deck preparation; Year 2 calendar and budget draft | Year 1 metric targets assessed against baseline; board deck complete; Year 2 plan approved |

**Note on Months 10–12:** The Joint Commission window and flu season constraints mean clinical staff (SEG-A, SEG-B) receive no new simulation content from Month 10 through Month 12. This is by design and is documented in the board presentation as a scheduling discipline, not a program gap. Existing microtraining remains accessible to any employee who seeks it during this period.

---

## Budget justification

All figures are Year 1 estimates drawn from program budget assumptions. Each line item includes estimated cost, what it purchases, and the cost of not having it — expressed in operational and risk-reduction terms.

---

### simulation platform licensing

| Field | Detail |
|---|---|
| **Estimated cost** | $28,000 |
| **What it purchases** | A phishing simulation platform capable of role-segmented campaign scheduling, automated post-click landing pages with immediate microtraining delivery, per-segment metrics (click rate, report rate, time to report), HR-compliant individual data handling, and reporting dashboards for the CISO and board. Covers up to 1,281 staff across all segments for 12 months. |
| **Cost of not having it** | Without a platform, MedDefense can send manual phishing tests but cannot deliver immediate post-click microtraining, cannot enforce HR privacy controls on individual results, cannot produce consistent segment-level metrics, and cannot demonstrate measurable behavior change to the board. The Q1 incident occurred partly because no simulation program existed. A repeat incident with a conservative estimated direct cost of $200,000–$500,000 (IR, forensics, legal, credential reset, executive communications) dwarfs this line item. |

---

### content development

| Field | Detail |
|---|---|
| **Estimated cost** | $18,000 |
| **What it purchases** | Development of role-based phishing templates (healthcare-specific lures for clinical, administrative, finance, IT, and executive segments); post-click microtraining modules (maximum 5 minutes per module); vishing scenario scripts (V-01, V-02, V-03); insider threat manager reference guide; quick-reference guides for all six segments; plain-language all-staff communications; and annual template refresh after Year 1. Includes translation and accessibility review for workforce members who require it. |
| **Cost of not having it** | Generic, non-role-specific content does not produce behavior change in healthcare populations where clinical and financial workflows differ significantly. The 56% click rate in the Q1 incident was achieved partly because the lures matched clinical workflow language. Generic training would not teach staff to recognize those specific lures, and the program would fail its primary purpose while consuming staff time with no measurable return. |

---

### training delivery time

| Field | Detail |
|---|---|
| **Estimated cost** | $22,000 (opportunity cost calculation) |
| **What it purchases** | This line represents the estimated staff time cost of training delivery, not a vendor payment. Calculation: average of 45 minutes per employee per year for simulation participation and post-click microtraining, across 1,281 staff, at an average blended hourly rate of $38/hour. Clinical staff time is scheduled during documented low-acuity windows to minimize patient-care impact. This figure is presented to the board as the true program cost — the time investment MedDefense workforce members make in exchange for behavior change. |
| **Cost of not having it** | The alternative is not "no time spent" — it is time spent on ineffective annual compliance training that produces completion certificates but no behavior change. The Module 5 incident required credential resets, IT investigation, executive time, and legal review across multiple days. The opportunity cost of a second incident far exceeds the training time investment documented here. |

---

### external benchmarking

| Field | Detail |
|---|---|
| **Estimated cost** | $8,000 |
| **What it purchases** | Access to healthcare-sector phishing and social engineering benchmark data to validate MedDefense's metric targets and compare program performance against peer organizations. Used to contextualize board reporting ("MedDefense's 25% click rate target is consistent with the top quartile of peer healthcare organizations at 12 months"). Also funds the metrics dashboard for CISO and board quarterly reporting. |
| **Cost of not having it** | Without benchmarking, the board cannot assess whether MedDefense's targets are ambitious or inadequate. Dr. Morales would be presenting metrics with no external reference point, reducing board confidence in program design and governance. Two peer healthcare organizations reported Q1 2026 vishing incidents — this context requires ongoing sector intelligence to remain actionable. |

---

### program management overhead

| Field | Detail |
|---|---|
| **Estimated cost** | $8,000 |
| **What it purchases** | Program coordination cost covering: HR and Legal review of templates and insider threat materials (required before deployment); clinical operations review of simulation timing with Sarah Park; SOC coordination for false-positive triage during active simulation waves; annual governance review; contingency budget for template refresh following a real incident or new threat pattern. Includes the documented triage procedures required by HR Director Maria Santos before the anonymous insider reporting path goes live. |
| **Cost of not having it** | Without governance overhead, templates launch without approval, simulations conflict with patient care or legal constraints, and board reporting is inconsistent. The HR Privacy Rules and Simulation Ethics Guidelines in this program require documented review processes — skipping them creates legal and HR exposure independent of the security risk. |

---

**Year 1 total estimated program cost: $84,000**

For comparison: the Q1 2026 incident generated IR, forensics, credential reset, legal review, and executive communications costs conservatively estimated at two to six times this figure. The board is being asked to fund a prevention program at a fraction of the cost of a single significant incident.

---

## Governance framework

### Roles and responsibilities

| Role | Person | Responsibilities |
|---|---|---|
| **program owner** | CISO (James Chen) | Approves program strategy, all simulation templates, board reporting, and high-risk scenario content. Final authority on campaign launch and pause decisions. |
| **content approver** | HR Director (Maria Santos) + Legal Counsel | Reviews all templates and insider threat materials for privacy compliance and legal exposure before launch. No template deploys without sign-off from both. Clinical content also requires Clinical Operations Representative review. |
| **simulation operator** | IT Security Awareness Lead | Schedules and executes phishing and vishing simulations, manages platform configuration, delivers post-click microtraining, monitors metrics, produces segment-level reports, and manages HR data controls for individual results. |
| **metrics reviewer** | IT Security Awareness Lead + CISO | Reviews campaign metrics after each wave. Produces quarterly board metrics package. Flags anomalies and recommends program adjustments. |
| **escalation authority** | CISO + HR Director | Joint escalation authority for insider threat reports, retaliation concerns, repeat-click coaching referrals, and any simulation that generates an employee distress event. Legal is included when regulatory or employment exposure exists. |

---

### Reporting cadence
<!-- anchor: reporting cadence -->

| Report | Audience | Frequency | Contents |
|---|---|---|---|
| Wave results summary | CISO, SOC Manager | After each simulation wave | Click rate, report rate, mean time to report, post-click completion — by segment |
| Department aggregate | Department managers | Quarterly | Team-level click and report trends; no individual data |
| HR coaching referral | HR Director only | When repeat-click threshold met | Individual referral per documented HR Privacy Rules (not in performance file) |
| Program metrics report | CISO, Dr. Morales | Quarterly | All key metrics vs. baseline and targets; trend direction; upcoming campaign calendar |
| Board brief | Board of Directors | Quarterly (via Dr. Morales) | Simplified metrics dashboard: click rate, report rate, time to report vs. targets; program status; budget vs. plan |
| Annual review | CISO, HR, Legal, Clinical Ops | Year-end | Full program performance vs. all 12-month targets; Year 2 plan and budget recommendation |

---

### Review cycle
<!-- anchor: review cycle -->

**Template retirement:** Any simulation template in active rotation for more than 6 months is reviewed for retirement or redesign. Templates are retired immediately if they become associated with a real incident at MedDefense or a widely reported peer incident that would cause employees to recognize the lure as a simulation rather than a real threat.

**Targeting strategy updates:** Segment targeting is reviewed after each quarterly metrics cycle. If a segment reaches its 12-month click rate target early, campaign difficulty increases for that segment in the next wave. If a segment shows no improvement after two consecutive waves, content approach is reviewed with the relevant segment representative (clinical ops, finance, IT).

**Real phishing incident during active simulation wave:** If a real phishing campaign is detected or reported while a simulation wave is active, the simulation wave is paused immediately. The SOC Manager notifies the simulation operator. All active lures are recalled from the delivery queue. Employees who receive a message during the overlap period are not scored — their response is logged for operational awareness only. The simulation resumes no sooner than 14 days after the real incident is contained, and only after CISO confirmation that the workforce is not in active elevated-stress response to the real event. This rule is non-negotiable: running a simulation during a real incident degrades both trust and the operational incident response.

---

## Success criteria

The following metrics constitute program success at 12, 24, and 36 months. These are the exact metrics Dr. Morales reports to the board. Each is expressed so that a board member with no security background can assess whether the program is working.

---

### 12 months

| Metric | Baseline | 12-month target | What it means for the board |
|---|---|---|---|
| Overall phishing click rate | 56% | 25% or below | Before this program, more than half of employees clicked a realistic phishing lure. At 12 months, fewer than 1 in 4 should click. |
| Suspicious email report rate | 15% | 50% or above | Before this program, only 15% of employees who received a phishing lure reported it. At 12 months, at least half should report, giving the SOC early warning of real attacks. |
| Mean time to report | 74 minutes | 15 minutes or less | In the Q1 incident, the SOC did not learn of the phishing campaign until hours after it began. At 12 months, the average employee should report within 15 minutes of receiving a suspicious email. |
| Post-click microtraining completion | Not measured | 95% within 72 hours | Every employee who clicks a simulation should complete a short training module within 3 days. This measures whether the intervention is working. |
| Finance BEC verification rate | Not measured | 80% or above | 8 in 10 finance and procurement staff should correctly verify an unusual payment or account-change request before acting on it. |
| Vishing simulation pass rate | Not measured | 75% or above | 3 in 4 employees tested by phone impersonation should correctly verify the caller's identity through a known channel before complying with any request. |
| Clinical staff click rate | 67% | 25% or below | Clinical staff had the highest click rate in the Q1 incident. At 12 months, their click rate should match the overall target. |

---

### 24 months

| Metric | 12-month target | 24-month target | What it means for the board |
|---|---|---|---|
| Overall phishing click rate | 25% | 18% or below | Continued reduction — the program is sustaining behavior change, not producing a one-time improvement. |
| Suspicious email report rate | 50% | 60% or above | Reporting is a habit, not a response to a recent training event. |
| Mean time to report | 15 minutes | 12 minutes or less | Early warning capability continues to improve. |
| Repeat clicker rate | Baseline established | 5% or below | Fewer than 1 in 20 employees clicks in two consecutive simulation waves — the coaching intervention is working. |
| Manager escalation confidence | Baseline survey | +25% improvement vs. baseline | Managers surveyed on their confidence in recognizing and escalating security concerns show measurable improvement. |
| Finance BEC verification rate | 80% | 88% or above | Finance staff maintain and improve verification behavior. |

---

### 36 months

| Metric | 24-month target | 36-month target | What it means for the board |
|---|---|---|---|
| Overall phishing click rate | 18% | 12% or below | MedDefense is performing in the top quartile of peer healthcare organizations for human-layer phishing resistance. |
| Suspicious email report rate | 60% | 70% or above | The workforce functions as an active early-warning system. The SOC receives useful signals from employees before automated detection in a meaningful proportion of real incidents. |
| Mean time to report | 12 minutes | 10 minutes or less | Detection speed is competitive with technical controls, not lagging behind them. |
| Repeat clicker rate | 5% | 4% or below | The program has reduced chronic high-risk behavior through targeted coaching, not shame or discipline. |
| Finance BEC verification rate | 88% | 95% or above | Near-universal verification before acting on unusual financial requests — the most common path for business email compromise incidents in healthcare. |
| Vishing verification success | 75% (at 12 months) | 90% or above | Phone-based social engineering is resisted by 9 in 10 employees tested. |
| Manager escalation confidence | +25% vs. baseline | +50% vs. baseline | Managers are functioning security partners — they recognize, document, and escalate concerns through the right channels. |

**Board interpretation note:** These targets were set using the metrics baseline derived from the Module 5 incident and validated against healthcare sector benchmarks. If the program meets 12-month targets, MedDefense will have transformed the workforce from one of the most vulnerable populations in the sector (56% click rate) to one performing at industry average. If the program meets 36-month targets, MedDefense will have a measurable human-layer security capability that did not exist before this program.

---

*Document prepared for MedDefense 6x04 Security Awareness Program. Board distribution version prepared by program owner for Dr. Morales Q3 2026 board presentation. All metric targets subject to annual review. Template and campaign calendar subject to operational constraint review by Sarah Park (Clinical Operations) and Maria Santos (HR) before each wave launch.*
