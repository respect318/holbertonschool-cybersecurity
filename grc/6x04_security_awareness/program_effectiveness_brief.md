# Program Effectiveness Brief
**Organization:** MedDefense Security Awareness Program — 6x04  
**Prepared for:** Dr. Morales — Board of Directors  
**Program owner:** CISO James Chen  
**Classification:** Confidential — Board Distribution  
**Purpose:** Board-ready effectiveness brief template, quarterly metrics dashboard, incident correlation methodology, and program improvement triggers

---

> *"Three questions. Are we safer? Are we improving? What changes next?"*  
> — James Chen, CISO

---

## 1. Board-ready effectiveness brief

**[TEMPLATE — Program manager inserts actual data at each 6-month reporting period. Bracketed fields are fill-ins. All other language is pre-approved for board distribution.]**

---

### program summary

**Reporting period:** [Month 1] through [Month 6]  
**Date presented to board:** [DATE]  
**Presenter:** Dr. [Name], [Title]

Six months ago, MedDefense launched a structured security awareness program in response to a phishing incident in which 23 of 41 targeted employees clicked a malicious link — more than half the workforce tested. Only 6 employees reported the message, and the security team did not detect the campaign until more than four hours after the first click. The incident resulted in confirmed credential exposure and Cobalt Strike beacon activity on internal systems.

This program was designed to change three specific behaviors: how often employees recognize and avoid suspicious messages, how quickly they report suspicious messages when they receive them, and how consistently they verify unusual requests before acting on them. This brief reports on progress against those three behaviors after six months of structured simulation, role-based training, and measured feedback.

---

### metrics table

**How to read this table:** The baseline column shows where MedDefense stood after the Q1 2026 incident — before any training program existed. The current column shows where MedDefense stands today. The target column shows where the program committed to be at 6 months. The industry benchmark column shows what comparable healthcare organizations achieve after an established awareness program. Green means on track or better. Yellow means slightly behind target but trending in the right direction. Red means off target and requiring a program adjustment.

| Metric | Baseline (Q1 2026) | Current ([Q]) | 6-month target | Industry benchmark | Status |
|---|---|---|---|---|---|
| Overall phishing click rate | 56% (23 of 41 employees clicked) | [X]% | 35% or below | 20–28% (mature healthcare programs) | [Green/Yellow/Red] |
| Suspicious email report rate | 15% (6 of 41 employees reported) | [X]% | 35% or above | 40–55% | [Green/Yellow/Red] |
| Mean time to report | 74 minutes | [X] minutes | 25 minutes or less | 10–20 minutes | [Green/Yellow/Red] |
| Clinical staff click rate | 67% | [X]% | 40% or below | 22–30% | [Green/Yellow/Red] |
| Finance BEC verification rate | Not measured | [X]% | Baseline established | 75–85% | [Green/Yellow/Red] |
| Post-click microtraining completion | Not measured | [X]% | 90% within 72 hours | 85–95% | [Green/Yellow/Red] |
| Repeat clicker rate | Not measured | [X]% | Baseline established | 8–12% | [Green/Yellow/Red] |

**Industry benchmark source:** [Insert benchmarking source — healthcare sector phishing simulation data, current period]. Note: benchmarks reflect organizations with mature programs of 2+ years. MedDefense is in its first program year; benchmarks are directional targets, not immediate requirements.

---

### key findings

**[Program manager drafts this section using the template sentences below, substituting actual observations from the most recent simulation wave. Each bullet corresponds to a behavioral finding, not a metric dump.]**

**Finding 1 — Click behavior:**  
[Example: "Clinical staff clicked at a rate of [X]%, down from 67% at baseline. Clicks are now concentrated in [unit/segment] rather than distributed across all clinical floors, which suggests that general phishing recognition is improving but [specific lure type] remains effective against [specific group]."]

**Finding 2 — Reporting behavior:**  
[Example: "The report rate increased from 15% to [X]%. Employees are reporting faster — average time to report dropped from 74 minutes to [X] minutes — but a significant portion of employees still describe uncertainty about what happens after they report. A reinforcement communication reminding employees that reports trigger a review, not a blame process, is recommended for Month 7."]

**Finding 3 — High-risk role behavior:**  
[Example: "Finance staff correctly identified and challenged [X]% of BEC simulation scenarios — above the 75% baseline target for 6 months. One executive assistant scenario (V-03 vishing analog) showed that [X]% of assistants stayed on the line with the simulated caller while attempting to verify — a partial-pass behavior that indicates the right instinct but an unsafe execution. Additional vishing reinforcement is scheduled for Month 8."]

**Finding 4 — Post-click intervention:**  
[Example: "Of employees who clicked in Wave [X], [X]% completed the post-click microtraining module within 72 hours. This is [above/below] the 90% target. Employees who did not complete cited [reason if known — e.g., 'module not accessible on mobile during shift']."]

**Attribution note:** Metrics in this brief reflect simulation behavior. They do not directly measure response to real phishing attacks, which occur at lower volume and vary in sophistication. Improvement in simulation metrics indicates behavior change in controlled conditions. Whether this translates to real-incident response improvement is assessed separately in the incident correlation analysis (see Section 3 of the program effectiveness brief). No causal claim is made that the awareness program alone caused any change in real incident frequency during this period, as concurrent technical improvements also occurred.

---

### recommendations for the next 6 months

**[Program manager selects and customizes from the template recommendations below based on actual data.]**

1. **[If clinical click rate is above target]:** Increase simulation frequency for clinical floor staff using a different lure type — shift from account-lockout lures to secure-message lures. Clinical staff have become less susceptible to one lure type but remain susceptible to others.

2. **[If report rate is below target]:** Run a targeted reporting reinforcement campaign in Month 7: a single communication to all staff showing how many real suspicious emails were reported this quarter and what the SOC did with them. Make reporting feel consequential and non-punitive.

3. **[If mean time to report is above target]:** Add a one-click report button prominently to the email client in clinical workstations. Reporting friction is the primary driver of delay. Technical improvement reduces mean time without requiring additional training.

4. **[If finance BEC verification is below 80%]:** Schedule a second facilitated tabletop (V-03 analog) for finance and procurement staff in Month 8. The simulated scenario showed that time pressure — not lack of knowledge — is the primary reason verification is skipped.

5. **[Standard for all periods]:** Review template library before Month 7 wave. Any template in rotation for more than 6 months should be refreshed or replaced. Employees recognize repeated lures, which inflates apparent improvement without reflecting genuine behavior change.

---

### bottom line

**[Program manager selects one of the following and inserts actual metrics. The bottom line is one sentence, no jargon, no hedging beyond the attribution note.]**

**If on track:**  
> "After six months, MedDefense employees are clicking on realistic phishing lures [X percentage points] less often than before this program began, reporting suspicious messages [X percentage points] more often, and doing so [X] minutes faster — meaning the security team now has more time to respond to real threats before they cause damage."

**If partially on track:**  
> "After six months, click rates have improved significantly, but reporting speed remains above target; the next six months will focus on reducing the time between recognizing a threat and alerting the security team, which is currently the largest remaining gap between MedDefense's human-layer defense and industry practice."

**If below target:**  
> "After six months, initial results are below target in [specific metric]; the program review initiated this quarter identified [specific cause] as the primary driver, and a modified campaign plan addressing [specific issue] begins in Month 7 with board notification if targets are not met by Month 9."

---

---

## 2. Quarterly metrics dashboard template

**Instructions for program manager:** Fill in each column at the end of every quarter. Delta column shows change from previous quarter in percentage points (use + for improvement, − for deterioration). Status uses Green/Yellow/Red. Overall program status at the bottom is determined by the worst single Red or by pattern across three or more Yellow metrics — see improvement triggers in Section 4.

---

### Metric definitions

| metric name | formula | measurement interval | 90-day target | 18-month target | deteriorating result means operationally |
|---|---|---|---|---|---|
| click rate | (employees who clicked ÷ employees who received simulation) × 100 | Per simulation wave | ≤35% | ≤20% | More employees are acting on malicious messages without pausing to verify — attacker dwell time risk increases |
| report rate | (employees who reported ÷ employees who received simulation) × 100 | Per simulation wave | ≥35% | ≥60% | Fewer employees are alerting the SOC — real attacks take longer to detect |
| mean time to report | minutes from message delivery to report submission, averaged across reporters | Per simulation wave | ≤25 min | ≤12 min | SOC early warning window is shrinking — attacker has more time before detection |
| repeat clicker rate | (employees who clicked in two consecutive waves ÷ total employees in both waves) × 100 | Consecutive wave pairs | Baseline established | ≤5% | Coaching intervention is not reaching high-risk employees — structural behavior change is not occurring |
| post-simulation training completion rate | (employees who completed microtraining within 72h of clicking ÷ employees who clicked) × 100 | Within 72h of each wave | ≥90% | ≥95% | Post-click intervention is not landing — learning opportunity is being lost at the highest-value moment |
| false-positive report rate | (legitimate emails reported as suspicious ÷ total emails reported) × 100 | Monthly | Track baseline | Stable with triage automation | SOC triage burden is increasing — employees are over-reporting or cannot distinguish lures from legitimate messages |

---

### Quarterly tracking dashboard

**Quarter:** [Q1 / Q2 / Q3 / Q4] — Year [1 / 2 / 3]  
**Reporting period:** [Start date] to [End date]  
**Completed by:** [Program manager name]  
**Reviewed by:** [CISO name]

| Metric | Q-2 result | Q-1 result | This quarter | Delta (vs. Q-1) | Annual target | Status |
|---|---|---|---|---|---|---|
| Overall click rate | [X]% | [X]% | [X]% | [+ or −X pp] | ≤25% at 12 mo | [Green / Yellow / Red] |
| Clinical staff click rate | [X]% | [X]% | [X]% | [+ or −X pp] | ≤25% at 12 mo | [Green / Yellow / Red] |
| Finance click rate | [X]% | [X]% | [X]% | [+ or −X pp] | ≤20% at 12 mo | [Green / Yellow / Red] |
| IT staff click rate | [X]% | [X]% | [X]% | [+ or −X pp] | ≤15% at 12 mo | [Green / Yellow / Red] |
| Suspicious email report rate | [X]% | [X]% | [X]% | [+ or −X pp] | ≥50% at 12 mo | [Green / Yellow / Red] |
| Mean time to report (minutes) | [X] | [X] | [X] | [+ or −X min] | ≤15 min at 12 mo | [Green / Yellow / Red] |
| Post-simulation training completion rate | [X]% | [X]% | [X]% | [+ or −X pp] | ≥95% at 12 mo | [Green / Yellow / Red] |
| Repeat clicker rate | [X]% | [X]% | [X]% | [+ or −X pp] | ≤8% at 12 mo | [Green / Yellow / Red] |
| false-positive report rate | [X]% | [X]% | [X]% | [+ or −X pp] | Stable/manageable | [Green / Yellow / Red] |
| Finance BEC verification rate | [X]% | [X]% | [X]% | [+ or −X pp] | ≥80% at 12 mo | [Green / Yellow / Red] |
| Vishing verification pass rate | [X]% | [X]% | [X]% | [+ or −X pp] | ≥75% at 12 mo | [Green / Yellow / Red] |
| Manager escalation confidence | [score] | [score] | [score] | [+ or −X pp vs. baseline] | +25% vs. baseline at 12 mo | [Green / Yellow / Red] |

**Status key:**  
- **Green:** At or within 5 percentage points of target, trending flat or improving  
- **Yellow:** 6–15 percentage points below target, or flat for two consecutive quarters  
- **Red:** More than 15 percentage points below target, or deteriorating for two consecutive quarters

---

### Narrative fields (complete each quarter)

**Campaigns run this quarter:**  
[List simulation waves, vishing exercises, and awareness communications delivered. Include segments targeted, lure types used, and delivery windows. Example: "Wave 3 phishing — SEG-C and SEG-D, vendor-impersonation lure — delivered Month 7, Tuesdays 09:00–11:00 per clinical constraints."]

**Notable behavioral observations:**  
[One to three sentences on what employee behavior showed — not just metric values. Example: "Finance staff correctly escalated all three BEC scenarios, but two executive assistants remained on the call with the simulated caller while verifying — this partial-pass pattern has appeared in two consecutive quarters and will be addressed with targeted reinforcement in Q3."]

**aggregate vs. individual disclosure:**  
[Confirm that department managers received only aggregate team-level data this quarter. Individual results shared only with HR where formal repeat-click threshold was met. Document any HR referrals made this quarter: [number] referrals, all documented per HR Privacy Rules.]

**post-simulation support:**  
[Confirm whether any employees experienced distress following a simulation this quarter. If yes: [number] cases, each received [non-punitive landing page / HR support path / manager-neutral outreach] per Simulation Ethics Guidelines. If none: "No post-simulation distress events reported this quarter."]

**governance sign-off:**  
[CISO sign-off: ___________. HR Director sign-off: ___________. Clinical Operations confirmation that no campaign violated scheduling constraints: ___________.]

---

### overall program status

| Quarter | Overall status | Rationale |
|---|---|---|
| Q1 Year 1 | [Green / Yellow / Red] | [One sentence: e.g., "Six of eleven metrics Green; click rate and report rate trending toward 12-month targets."] |
| Q2 Year 1 | [Green / Yellow / Red] | [One sentence] |
| Q3 Year 1 | [Green / Yellow / Red] | [One sentence] |
| Q4 Year 1 | [Green / Yellow / Red] | [One sentence] |

**Overall status determination rule:** If any single metric is Red for two consecutive quarters → overall status Red regardless of other metrics. If three or more metrics are Yellow → overall status Yellow even if no metric is individually Red. Otherwise, overall status reflects the majority of metrics.

---

---

## 3. Incident correlation methodology

### Why correlation is not causation — and why we report it anyway

You cannot run a controlled experiment on a live workforce. MedDefense cannot split employees into a trained group and an untrained group and expose both to real phishing campaigns to measure infection rates. The awareness program runs at the same time as other security improvements — email gateway tuning, endpoint detection updates, IAM remediation from the 6x02 audit, MFA enforcement. Any reduction in real security incidents reflects some combination of all of these changes. The awareness program cannot claim exclusive credit, and this brief will not claim it.

What we can do is collect evidence that is consistent with the awareness program contributing to risk reduction, and present that evidence honestly with its limitations. This is the methodology.

---

### Data to collect

**Category 1 — Simulation behavior trends**  
Collect quarterly: click rate per segment, report rate per segment, mean time to report per wave, post-click completion rate. This data directly measures whether employees are changing their behavior under controlled conditions that closely approximate real phishing pressure. Trend direction in simulation metrics is the strongest internal evidence the program produces.

**Category 2 — Real phishing incident data**  
Collect quarterly from the SOC: number of real phishing emails reported by employees (not detected by gateway), number of real phishing emails that resulted in credential entry or link click, mean time from delivery to SOC awareness, number of incidents where employee report was the first signal. Track these metrics against the baseline period (pre-program). This data is noisy and volume-dependent but provides directional evidence.

**Category 3 — Concurrent security improvement log**  
Maintain a running log of non-awareness security improvements deployed during the program period: email gateway rule updates, MFA enforcement dates, IAM access remediations, EDR policy changes. This log is required for honest attribution. When incident frequency drops, this log is how we determine whether the awareness program was the likely driver, a contributing factor, or incidental.

**Category 4 — Employee-reported SOC leads**  
Track quarterly: how many SOC investigations were initiated based on employee reports (not technical detection). If this number increases over time, it is direct evidence that employee behavior is generating operational security value — employees are functioning as sensors, not just subjects of training.

---

### Attribution framework

When presenting results to the board, apply this attribution framework:

**Strong attribution (program likely contributed):**  
Simulation click rate improved AND real-incident employee-initiated reports increased AND no major gateway or EDR changes occurred in the same period. Conclusion: "Employee behavior improvement is the most plausible explanation for the observed change in real-incident reporting."

**Partial attribution (program is one of several factors):**  
Simulation metrics improved AND real incident frequency dropped AND concurrent technical controls were also tightened. Conclusion: "The improvement reflects both technical and human-layer changes. The awareness program contributed to the human-layer component. We cannot isolate its share of the total effect."

**Inconclusive (honest non-attribution):**  
Simulation metrics improved but real-incident data shows no change, or real-incident frequency dropped but simulation metrics did not improve. Conclusion: "Simulation behavior improvement has not yet translated to a measurable change in real-incident patterns — or real-incident patterns changed for reasons not attributable to the awareness program. We continue to collect data."

**Board language for uncertainty:**  
> "Our simulation data shows employees are behaving more safely under realistic test conditions. We believe this is making MedDefense harder to compromise, and the SOC is receiving more employee-initiated reports than before the program began. We cannot yet prove with certainty how much of the improvement in real incident metrics is due to employee behavior vs. technical controls, but both are improving, and that is the right direction."

This language is honest, board-appropriate, and does not overstate the program's contribution.

---

### What not to say

Do not tell the board: "This program prevented X incidents" unless you can document specific incidents where employee behavior was the causal factor (e.g., an employee reported a real phishing email that the SOC confirmed would not have been caught by the gateway). Attribution of prevented incidents requires case-by-case documentation, not statistical inference.

Do not say: "ROI is $[X] based on incidents prevented" unless the incident cost estimate is documented and the attribution is supported. Use cost-of-program vs. cost-of-incident comparisons as directional context, not hard ROI claims.

---

---

## 4. Program improvement triggers

### What a deteriorating trend looks like

A deteriorating trend across three consecutive quarters is defined as any of the following patterns appearing in the quarterly dashboard:

**Trigger 1 — Click rate stagnation or reversal:**  
Overall click rate does not decrease by at least 5 percentage points over any three consecutive quarters after the first wave, or click rate increases between any two consecutive quarters by more than 3 percentage points in a segment that has received at least two simulation waves.

**Trigger 2 — Report rate failure:**  
Report rate remains below 30% after two consecutive simulation waves, or report rate declines in any two consecutive quarters after initially improving.

**Trigger 3 — Post-click completion collapse:**  
Post-simulation training completion rate falls below 80% for any two consecutive quarters. This indicates the intervention is not reaching employees after click events — the highest-value learning moment is being lost.

**Trigger 4 — Repeat clicker rate above threshold:**  
Repeat clicker rate exceeds 15% after two full simulation cycles (i.e., two waves have been run in the same segment). This indicates the current content approach is not reaching the highest-risk population.

**Trigger 5 — False-positive report rate spike:**  
False-positive report rate exceeds 40% in any single quarter. This indicates employees cannot distinguish lures from legitimate messages — over-reporting degrades SOC triage capacity and signals that training is producing anxiety rather than skill.

---

### Who initiates a formal program review

Any single Trigger 1 through Trigger 5 sustained across three consecutive quarters initiates a **formal program review**. The review is initiated by the **IT Security Awareness Lead** (simulation operator) and escalated to the **CISO** within 5 business days of the third consecutive quarter showing the deteriorating pattern.

The formal program review must include:
- Quarterly dashboard for all three trigger quarters
- Campaign log (what content was delivered, to whom, in what format)
- Post-click completion records
- SOC false-positive triage volume
- Segment-level breakdown identifying which populations are driving the deterioration
- HR record of coaching referrals in the same period (aggregate only)

The CISO and HR Director jointly determine whether the program requires content redesign, segment retargeting, platform adjustment, or a pause of simulation activity.

---

### Authority to pause a simulation wave

The following individuals have explicit authority to pause a simulation wave at any point during the campaign:

| Authority | Condition for pause |
|---|---|
| CISO (James Chen) | At any time for any reason, including board direction or emerging real incident |
| IT Security Awareness Lead (simulation operator) | Real phishing campaign detected during active simulation wave — mandatory pause, no discretion |
| HR Director (Maria Santos) | employee welfare concern raised by employee, manager, or HR representative during active wave |
| Clinical Operations Representative (Sarah Park) | Clinical constraint violation identified — simulation is delivering to clinical staff during a restricted window (Joint Commission, flu season peak, active patient safety event) |
| SOC Manager | Active incident response is underway that overlaps with the simulated scenario — confusion between real and simulated traffic would compromise the investigation |

**Pause procedure:** The person invoking the pause notifies the simulation operator immediately. The simulation operator halts all pending deliveries in the active wave queue. Employees who received a message in the overlap period are not scored. The pause decision and rationale are logged. Resume requires CISO and HR Director sign-off.

---

### employee welfare pause — specific conditions

The **HR Director has unilateral authority** to pause a simulation wave when any of the following employee welfare conditions exist:

- An employee reports distress, fear, or significant anxiety directly attributed to receiving a simulation message
- An employee reports that a simulation message arrived during a period of documented personal hardship (bereavement, medical leave re-entry, recent trauma) — even if the employee was not on the formal exclusion list
- A manager reports that a simulation message disrupted patient care or created a clinical safety concern during the wave
- Three or more employees from the same unit report the simulation as inappropriate within 48 hours of delivery

**Response to employee welfare pause:**  
The employee receives the non-punitive post-simulation landing page immediately (even without clicking). HR provides the manager-neutral support path. The simulation operator removes the employee from all active and future waves pending HR review. No performance or HR record is created unless the employee requests documentation of the support provided.

---

*Document prepared for MedDefense 6x04 Security Awareness Program. This template is updated quarterly by the IT Security Awareness Lead and reviewed by the CISO and HR Director before board distribution. Attribution language in Section 3 is reviewed by Legal before any board communication claiming specific risk reduction outcomes.*
