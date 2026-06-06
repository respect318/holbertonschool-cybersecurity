# Post-Click Intervention Design: MedDefense Health Systems

**Prepared by:** Security Awareness Program Team
**Date:** 2026-06-06
**Applies to:** T-EPIC-01, T-MFA-02, T-HR-03, T-BEC-04
**HR privacy boundary:** Individual click results are not shared with department managers unless the formal escalation threshold is met. See Section 3.

---

## Landing page variants

Each landing page loads immediately when the employee clicks a simulation link. It renders in the same browser window, completes in under 5 minutes, and uses no shaming language. The page confirms the training context in the first sentence.

---

### LPV-01 — Epic EHR Account Management

**Linked template:** T-EPIC-01
**Target:** SEG-B (General clinical floor staff)

---

**You just completed a security awareness exercise.**

This was a simulated phishing email, not a real threat. Your access to Epic and patient systems is not affected. You are not in trouble. This page exists because this type of message is one of the most effective attack techniques used against healthcare staff — and the best time to learn what to look for is right now.

**Why this message was designed to work**

This email was built to feel like an urgent system notification during a shift-start window — exactly when clinical staff are already logging into Epic and thinking about patient care. Messages that threaten to block your access to patient records create pressure to act quickly, which is the attacker's goal.

**The three signals in this specific email:**

1. **The sender domain was not MedDefense.** The From address showed `epic-healthsystems.net` — not `meddefense.org` or any Epic address you would recognize from internal IT communications. Display names can be typed by anyone; the domain after the `@` is the real signal.
2. **The urgency was tied to patient care, not just your account.** Phrases like "access to patient records will be unavailable" are designed to override deliberation. Real IT notifications about account issues do not typically threaten immediate patient-care impact.
3. **The link asked you to verify through the email, not through a known path.** MedDefense IT does not resolve account issues through links in external emails. The known path is ext. 4-HELP or help@meddefense.org, navigated directly — not clicked from a message.

**You are not in trouble. Reporting after a click still helps the security team.** If you have not already, you can report this message now using the Outlook phishing report button.

---

### LPV-02 — IT Helpdesk MFA Enrollment

**Linked template:** T-MFA-02
**Target:** SEG-C (Administrative and billing staff)

---

**You just completed a security awareness exercise.**

This was a simulated phishing email. Your account has not been affected and no enrollment action is required. You are not in trouble. This message was designed to look like a routine IT compliance task — the kind your team receives regularly — because that familiarity is exactly what makes it effective.

**Why this message was designed to work**

Administrative and billing staff receive legitimate compliance communications from IT regularly. This email imitated that pattern: a task with a deadline, a reasonable explanation, and a familiar process name (MFA enrollment). The goal was to make completing the link feel like finishing a required to-do item.

**The three signals in this specific email:**

1. **The sender domain was external.** The From address used `meddefense-it-support.org` — not `meddefense.org`. MedDefense IT compliance communications come from internal addresses. An unfamiliar domain that resembles but does not exactly match your organization's domain is a documented phishing technique.
2. **It asked for your current network password.** Real MFA enrollment does not require your existing password to be entered on a web form. Any enrollment step that requests your current credentials is a red flag regardless of how professional the page looks.
3. **The 3-business-day reactivation penalty was specific but unverifiable.** Specific-sounding consequences create urgency. The safe response is to verify through a known channel — not to act because the message sounds official.

**The known path for any IT compliance task:** Use your intranet bookmark for the compliance portal. If you are unsure whether a task is real, call ext. 4-HELP directly. Do not use phone numbers or links provided in the email itself.

**Reporting after a click still helps.** Use the Outlook phishing report button or email security@meddefense.org.

---

### LPV-03 — HR Open Enrollment Benefits Deadline

**Linked template:** T-HR-03
**Target:** SEG-C and SEG-E (Administrative, billing, finance, and procurement staff)

---

**You just completed a security awareness exercise.**

This was a simulated phishing email. Your benefits enrollment status has not changed. You are not in trouble. Benefits deadline messages are among the most effective phishing lures because they combine a process everyone has experienced with a financial consequence that feels personally significant.

**Why this message was designed to work**

Every MedDefense employee has gone through open enrollment. The process is familiar: a deadline, a required action, consequences for missing it. This email used that familiarity and added dependent verification language to create urgency that felt both official and personal.

**The three signals in this specific email:**

1. **The sender domain was not MedDefense HR.** The From address used `meddefense-hr-portal.com` — not `meddefense.org`. The domain looks plausible at a glance but is not the organization's real domain. Any HR communication that does not come from a `meddefense.org` address should be verified before you act on it.
2. **It asked for dependent SSN digits via an email link.** MedDefense HR does not collect dependent verification data through emailed links. Benefits enrollment is completed through the HR intranet portal accessed directly through your bookmark — not through a link sent by email.
3. **The financial consequence language was calibrated to create urgency.** "Dependents will be removed" and "re-enrollment will not be available until next year" are specific enough to feel real but are designed to make you act before you verify. Urgency framing tied to financial loss is a documented attacker technique.

**The known path for benefits questions:** ext. 4-HRBEN or hr-benefits@meddefense.org, contacted directly — not by replying to the email. Navigate to the HR portal through your known intranet bookmark.

**Reporting after a click still counts.** Use the Outlook phishing report button.

---

### LPV-04 — Executive Wire Fraud (BEC)

**Linked template:** T-BEC-04
**Target:** SEG-F and SEG-E (Executives, executive assistants, finance and procurement staff)

---

**You just completed a security awareness exercise.**

This was a simulated phishing email. No financial action has been initiated and no vendor payment has been changed. You are not in trouble. This type of message — a business email compromise — is the highest-damage attack category in healthcare finance and the hardest to detect because it contains no links, no attachments, and no obvious technical errors. The only defense is process.

**Why this message was designed to work**

Executive finance requests are often time-sensitive and confidential. This message combined a plausible executive name, a vendor reference number, a legal-hold framing that discouraged peer consultation, and a request that bypassed standard AP workflow. Each element was chosen to make normal verification feel like an obstacle to completing a legitimate task.

**The three signals in this specific email:**

1. **The reply-to address was not the CFO's real email.** The From address used `meddefense-exec.com` — not `meddefense.org`. In most email clients, this mismatch is only visible if you click Reply and inspect the destination before sending. Finance staff should check the reply-to address before responding to any payment or document request from an executive.
2. **The confidentiality instruction prevented peer verification.** "Do not discuss this with anyone else on the finance team" is a deliberate isolation technique. Legitimate executive requests do not prevent you from following standard financial controls. If a request asks you to bypass process, that is the signal, not an excuse.
3. **The vendor reference number created false specificity.** MD-VND-2026-0441 sounds like a real internal identifier. Real attackers research your naming conventions before sending. The presence of a plausible reference number is not verification that a request is legitimate.

**The safe behavior for any finance request that bypasses AP workflow:** Call the executive directly using their known internal extension — not a number from the email. Do not reply to the email thread. Do not initiate any payment or routing change until you have independent verbal confirmation. Standard AP process applies regardless of stated urgency or seniority.

**Reporting after a click or a close call still helps.** Use the Outlook phishing report button or call ext. 4-SECURITY.

---

## Microtraining module structure

Each module maps to a landing page variant and delivers four structured components in approximately 5 minutes. All modules use role-appropriate language. Content is presented as a short scrollable page or three-screen mobile-optimized flow.

---

### Module MT-01 — Epic EHR Account Management (LPV-01)
**Audience:** SEG-B clinical floor staff | **Time:** 5 minutes

**What you saw**
The email used three specific techniques: (1) a sender domain that visually resembled Epic but was externally registered (`epic-healthsystems.net`); (2) urgency language tied directly to patient-care access rather than generic account expiration; (3) a deadline framed around your shift, not a calendar date. These are documented techniques from actual healthcare phishing campaigns, not generic threats.

**what a real attacker gains**
If you had entered your Epic credentials on the linked page, a real attacker would have your username and password for the EHR. With those credentials they can access patient records, medication administration logs, and clinical documentation. In the March 2026 MedDefense incident, credential capture at the clinical layer preceded lateral movement and a Cobalt Strike beacon — technical controls did not prevent the initial entry.

**what to do next time**
Before clicking any email that threatens to block your Epic or system access:
1. Check the sender domain — not just the display name. If it is not `meddefense.org` or a known Epic address, do not click.
2. Use your known path: navigate to Epic through your desktop shortcut, not through the email link.
3. Call ext. 4-HELP directly if you are unsure whether your account has a real issue. Real IT staff can confirm or deny in under two minutes.

**how to report**
Use the Outlook phishing report button (flag icon in the toolbar). You can also call ext. 4-SECURITY or email security@meddefense.org. Reporting after clicking still helps — it starts the security team's response clock.

---

### Module MT-02 — IT Helpdesk MFA Enrollment (LPV-02)
**Audience:** SEG-C administrative and billing staff | **Time:** 5 minutes

**What you saw**
The email used three specific techniques: (1) a sender domain that resembled an internal IT address but was externally registered (`meddefense-it-support.org`); (2) a task-completion framing that matched the pattern of real compliance communications your team receives; (3) a specific penalty (3-business-day reactivation delay) that sounded official and created urgency without being verifiable.

**what a real attacker gains**
If you had entered your credentials on the linked page, the attacker would have captured your MedDefense network password. Network credentials can be used to access email, shared drives, billing systems, and patient financial data. Administrative and billing staff accounts hold access to ePHI-adjacent data that is valuable for identity fraud and insurance manipulation.

**what to do next time**
Before completing any IT compliance task sent by email:
1. Check the sender domain. MedDefense IT communications come from `meddefense.org` addresses — not external domains that resemble the organization's name.
2. Open the compliance portal through your known intranet bookmark rather than the link in the email. If the task is real, it will appear in your task queue.
3. Call ext. 4-HELP directly to confirm whether a compliance task is active before you act on an emailed request.

**how to report**
Use the Outlook phishing report button. Alternatively, call ext. 4-SECURITY or email security@meddefense.org. You can report even after clicking — it is still useful to the security team.

---

### Module MT-03 — HR Open Enrollment Benefits Deadline (LPV-03)
**Audience:** SEG-C and SEG-E administrative, billing, and finance staff | **Time:** 5 minutes

**What you saw**
The email used three specific techniques: (1) a sender domain that resembled HR but was externally registered (`meddefense-hr-portal.com`); (2) a familiar enrollment process combined with a personal financial consequence (dependent coverage removal); (3) a request for dependent SSN digits that sounded like a routine verification step but is not a real MedDefense HR procedure.

**what a real attacker gains**
If you had submitted the requested information, the attacker would have captured your employee ID and partial dependent SSN data. This is identity data — valuable for downstream account takeover, financial fraud, and medical identity theft. For finance staff, a follow-up BEC request after this initial click can use the demonstrated willingness to act under financial pressure.

**what to do next time**
Before acting on any HR benefits email:
1. Check the sender domain. MedDefense HR communications come from `meddefense.org` — not `meddefense-hr-portal.com` or similar lookalike domains.
2. Navigate to the HR benefits portal through your known intranet bookmark. If a task is real, it will be in your queue there.
3. Call ext. 4-HRBEN directly to confirm any dependent verification requirement before submitting personal data through an email link.

**how to report**
Use the Outlook phishing report button. You can also email security@meddefense.org or call ext. 4-SECURITY. Reporting after clicking still helps — it alerts the security team that a campaign may be active.

---

### Module MT-04 — Executive Wire Fraud / BEC (LPV-04)
**Audience:** SEG-F and SEG-E executive, finance, and procurement staff | **Time:** 5 minutes

**What you saw**
The email used three specific techniques: (1) a sender domain that resembled the executive office but was externally registered (`meddefense-exec.com`), visible only on reply inspection; (2) a confidentiality instruction specifically designed to prevent the one behavior that would have stopped this — asking a colleague; (3) a vendor reference number formatted to look legitimate, providing false specificity that substitutes for real verification.

**what a real attacker gains**
In a real BEC attack, the attacker does not need you to click anything. The objective is to get you to initiate a payment, change a vendor's banking details, or send a sensitive document to the attacker-controlled reply address. The average BEC loss in healthcare is in the hundreds of thousands of dollars per event. No technical control catches this after you have replied with the routing information — the only defense is process.

**what to do next time**
Before acting on any executive request that bypasses standard workflow:
1. Do not reply to the email thread. Call the executive directly using their known internal extension — not a number provided in the email.
2. Follow the standard AP authorization process for any payment or routing change, regardless of stated urgency or seniority of the requester.
3. Treat any instruction that tells you not to consult your team as a red flag, not a reason for secrecy. Legitimate executive requests do not disable financial controls.

**how to report**
Use the Outlook phishing report button. Call ext. 4-SECURITY or email security@meddefense.org. If you received a similar message and took any offline action (replied, initiated a payment inquiry), contact ext. 4-SECURITY immediately so the security team can assess.

---

## Repeat-click escalation protocol

This protocol governs the response to employees who click in two or more consecutive simulation waves. It is a training-first protocol. The goal is behavior change, not accountability. Escalation follows the HR privacy boundary: individual results are not shared with department managers without a second confirmed offense and formal HR escalation confirmation.

**who is notified** at each stage is defined below.

---

### Stage 1 — First click (any wave)

**Trigger:** Employee clicks a simulation link.
**Response:** Employee receives the landing page variant and the corresponding microtraining module immediately. Microtraining completion is tracked by the Program Manager. The click event is logged in the simulation platform as an individual record visible only to the Program Manager.
**Employee is told:** Landing page confirms this is training, not discipline. Language: "You are not in trouble. This page is here to help you recognize this type of message next time."
**who is notified**: Program Manager only (for training assignment).
**Manager notified:** No.

---

### Stage 2 — Microtraining non-completion after first click

**Trigger:** Employee has not completed assigned microtraining within 7 days of the first click.
**Response:** Program Manager sends a direct reminder through the simulation platform. A second automated reminder goes out at day 10. If incomplete at day 14, Program Manager logs the gap.
**Employee is told:** "Your security training module from [wave date] is still open. Completing it takes about 5 minutes and helps you recognize this type of message in the future."
**who is notified**: Program Manager only.
**Manager notified:** No.

---

### Stage 3 — Second click in a consecutive wave (repeat-click threshold)

**Trigger:** Employee clicks in two or more consecutive simulation waves.
**Response:** Program Manager notifies HR in writing, documenting the two click events and microtraining completion status. HR reviews for formal escalation eligibility. The Program Manager does not contact the employee's manager directly.
**Employee is told:** A private message from the simulation platform (not from their manager): "We noticed you have completed two simulation exercises where a phishing link was clicked. We would like to schedule a brief optional coaching session to review what to look for. This is a support step, not a disciplinary one."
**who is notified**: Program Manager and HR Director.
**Manager notified:** No — not at this stage.

---

### Stage 4 — HR-confirmed coaching escalation

**Trigger:** HR confirms all four conditions are met: (1) employee clicked in two consecutive waves; (2) employee did not complete assigned microtraining after both clicks; (3) HR has confirmed the formal escalation trigger in writing; (4) the purpose is coaching support.
**Response:** HR schedules a private coaching conversation with the employee. The department manager is notified by HR with aggregate context only: "A team member has been identified for additional security awareness coaching support." No individual click data is shared with the manager.
**Employee is told:** "This is a confidential coaching conversation to help you build skills for identifying phishing messages. It is not a performance review and will not appear in your employment record."
**who is notified**: HR Director, department manager (aggregate framing only), Program Manager.
**Manager notified:** Yes — aggregate context only, no individual click data.

---

### Stage 5 — Security investigation referral

**Trigger:** Simulation click correlates with anomalous system access, IAM anomaly, or insider threat indicator within the same session window; or HR-confirmed coaching has not produced behavior change after two further waves.
**Response:** Program Manager escalates to SOC and CISO. HR is notified in parallel. Event transitions from a training record to a security review. SOC and HR lead jointly.
**who is notified**: SOC, CISO, HR Director. Department manager is not the first point of contact.
**Employee is told:** SOC and HR determine communication in coordination with Legal if required.

---

## Positive reinforcement design

When an employee correctly reports a simulation email using the Outlook phishing report button, the following automated response is triggered within 60 seconds.

---

### Automated response — correct simulation report

**Delivery method:** Automated email sent from the simulation platform to the reporting employee's inbox within 60 seconds of the report action.
**Tone:** Immediate, specific, proportional. Not overblown. Not a generic "thanks for participating."

---

**Subject:** You caught it — good catch on that phishing simulation

Hi [First Name],

You just reported a simulated phishing email — and you were right to do it.

Here is what you noticed that made this the correct call: **[specific signal from the reported template, e.g., "The sender domain was epic-healthsystems.net, not a MedDefense address — that is a documented attacker technique."]**

That is exactly the kind of signal to look for on real messages too.

**What happens next:** The security team has logged your report. If this had been a real phishing campaign, your report would have started the triage clock and potentially protected your colleagues who had not yet opened the same message. Reports like yours are how the team catches real threats early.

You do not need to do anything else. If you have questions about what you saw in that message or want to talk through what to look for in the future, contact the security team at security@meddefense.org or ext. 4-SECURITY.

Thank you,
MedDefense Security Awareness Program

---

**Design rationale:** The response is immediate to reinforce the reporting behavior in the moment it occurs. It is specific because generic praise ("great job!") does not anchor the behavior to the correct signal — the employee needs to know what they noticed so they can repeat it. It is proportional because overcelebration of a routine safe action can feel condescending; the tone is collegial and matter-of-fact. The "what happens next" paragraph closes the feedback loop by explaining the operational value of the report — connecting the individual action to team-level protection, which is the most durable motivator for sustained reporting behavior.

**Tracking:** Each report event is logged with a timestamp. The Program Manager reviews report rate and mean time to report per wave. Employees who report consistently across multiple waves are recognized in aggregate team summaries shared with managers — no individual names, team-level recognition only.
