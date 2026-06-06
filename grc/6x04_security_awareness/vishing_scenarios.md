# Vishing Simulation Scenario Scripts
**Program:** MedDefense Security Awareness — 6x04  
**Classification:** Internal Training — Facilitator Use Only  
**Approved for:** Live simulation exercises, tabletop sessions, onboarding awareness  
**Ethics compliance:** Simulation Ethics Guidelines v1 | HR Privacy Rules (M. Santos)  
**Facilitator reminder:** Stop the call before any real credential is spoken. Document behavior, not personality. Debrief immediately after each exercise.

---

## Background

The Module 5 incident (2026-03-25) began with a phishing campaign but a secondary failure was documented in the post-incident review: an employee misdirected a helpdesk verification call because no framework existed for confirming caller identity. Vishing is the social engineering vector MedDefense has simulated least, yet two peer healthcare organizations reported vishing incidents targeting clinical supervisors and finance staff in Q1 2026. Both began with publicly available information from LinkedIn and facility websites. These three scenarios are designed to close that gap.

---

## V-01: IT Helpdesk Impersonation

### Scenario Header

| Field | Detail |
|---|---|
| **Scenario ID** | V-01 |
| **Target role** | General clinical or administrative staff (nurses, unit clerks, billing coordinators, administrative assistants) |
| **Attack objective** | Get the employee to provide their current password or accept an attacker-initiated password reset that gives the attacker account control |
| **Psychological mechanisms** | Authority (IT caller ID), urgency (account lockout blocking patient care or billing access), helpfulness (employee wants to cooperate with IT to restore access quickly) |
| **Success criteria (attacker view)** | Employee either (a) states their current password, (b) accepts a password reset link sent by the attacker, or (c) confirms MFA code read aloud — any of which gives the attacker authenticated access to Epic or the MedDefense portal |

### Caller script

**Setup for facilitator:** Call the target employee from a spoofed or internal-looking number. Use a confident, calm tone. Do not sound suspicious. The call should feel like a routine IT helpdesk interaction.

---

**CALLER (opening):**  
> "Hi, this is Derek from the IT Service Desk. I'm calling for [Employee First Name]?"

**[Wait for confirmation]**

> "Hi [Name], thanks for picking up. I'm reaching out because our monitoring system flagged your Epic account as part of a batch that's been affected by an authentication issue we're resolving right now. A number of accounts were locked after a scheduled credential sync earlier this morning. We're working through the list and yours is next."

> "I just need to confirm a couple of things so we can restore your access without you losing any session data. First — can you confirm your employee ID for me so I'm on the right account?"

**[Wait for response. If employee gives ID, continue. If hesitation, go to Hesitation Branch.]**

> "Perfect, thank you. Now — and I know this isn't the usual process, but the admin reset portal is part of what's affected — I need to confirm the password you're currently using so I can match it against the pre-lockout snapshot. This is the only way to restore without full re-enrollment."

---

**BRANCH A — Compliance (employee begins to comply or provides password):**

> **Caller:** "Thank you. That's exactly what I needed. I'm going to push the restoration now — you should be back in within two minutes. Is there anything else I can help you with?"

> **[FACILITATOR: Stop here. Do NOT record any actual password spoken. Immediately say: "This was a security simulation. Please stay on the line — we'll debrief now."]**

---

**BRANCH B — Hesitation (employee pauses, expresses uncertainty, asks why):**

> **Caller:** "I completely understand — and honestly, good instinct. The reason we're doing it this way is the standard reset portal is part of the same system that's down. Our escalation window is about fifteen minutes before your account gets flagged for full re-enrollment, which takes IT about four hours to process. I don't want to put you through that if we can avoid it. All I need is thirty seconds of your time."

> **[If employee continues to hesitate:]**

> **Caller:** "I can have my supervisor call you back if that helps — though I should be honest with you, we're working through about forty accounts right now and the window is closing. Your call entirely."

> **[FACILITATOR: Note whether the employee escalates, asks for callback number, or complies under pressure.]**

---

**BRANCH C — Verification Request (employee asks to verify the caller or call back through IT):**

> **Caller:** "Absolutely — I'd give you the help desk number but it's going to route you into the queue, which could be thirty to forty minutes given the ticket volume today. My direct line is [any plausible number]. But honestly, if you want to go through the queue that's completely fine. I'll just note on the ticket that we couldn't complete the batch restore and your account will stay locked until you work through standard re-enrollment."

> **[FACILITATOR: This is a pass behavior. Note if employee still uses the known IT channel and does not call the "direct line" provided by the caller.]**

---

### Assessment rubric

| Decision Point | Full Pass | Partial Pass | Fail |
|---|---|---|---|
| Caller asks for employee ID | Employee gives only publicly safe info or asks why | Gives ID but immediately expresses concern | Gives ID without hesitation |
| Caller requests current password | Employee refuses clearly, stating IT never asks for passwords | Employee hesitates but does not refuse before pressure | Employee provides or begins to provide password |
| Caller applies time pressure | Employee is not moved; states they will use known IT channel | Employee is slowed but ultimately uses correct channel | Employee complies to avoid the four-hour wait |
| Caller offers "direct line" instead of known IT path | Employee ignores caller-provided number and uses known IT number | Employee takes the number but does not call it | Employee calls caller-provided number |
| Post-call | Employee reports the suspicious call to security or supervisor | Employee mentions it to a colleague informally | Employee takes no action |

**Definition of a full pass:** Employee refuses to disclose password or MFA code, does not accept a caller-provided reset link, uses the known IT helpdesk number or ticketing portal to verify, and reports the suspicious call. Employee may give their name and employee ID — this is realistic and not a failure. The failure threshold is any credential disclosure or acceptance of attacker-controlled access.

---

### Debrief notes

**What made this realistic:**  
Real IT helpdesk calls do sometimes come unexpectedly. The scenario used workflow-relevant urgency (Epic access blocking patient care) and offered a plausible technical explanation for the unusual request. The "batch restore" framing is consistent with observed healthcare social engineering patterns (Pattern 1 in threat intel file). The caller did not sound aggressive or suspicious — which is exactly why vishing works.

**What a real attacker would have accessed:**  
With a valid password and confirmed employee ID, the attacker would have authenticated access to Epic, the MedDefense portal, and any shared clinical workflow tools. In the Module 5 incident, credential exposure enabled Cobalt Strike beacon activity and lateral movement. A successful vishing call skips the phishing step entirely.

**Safe behavior to reinforce:**  
- IT will never ask for your current password by phone or email.  
- Use the known IT helpdesk number (posted on intranet) — not a number given by the caller.  
- Urgency is a manipulation tactic. You can say: "I need to verify this through the helpdesk directly. Please give me your ticket number."  
- Report the call even if you did not comply. It may be the first signal of a targeted campaign.

**Facilitator language to use:**  
> "The attacker used urgency and authority. The safe behavior was to verify through the known IT channel, not the one offered by the caller. You can slow down a request without being unhelpful."

---

---

## V-02: Vendor Support Escalation

### Scenario Header

| Field | Detail |
|---|---|
| **Scenario ID** | V-02 |
| **Target role** | Clinical staff or clinical supervisor (charge nurse, clinical coordinator, physician office manager) |
| **Attack objective** | Get the employee to install a remote support tool or grant screen access under the pretense of an emergency Epic patch that must be applied immediately to protect patient records |
| **Psychological mechanisms** | Authority (Epic/vendor caller), urgency (patient data risk, compliance language), technical dependency (employee is not an IT expert and defers to "vendor guidance"), helpfulness (employee wants to protect patient care) |
| **Success criteria (attacker view)** | Employee installs a remote access tool (e.g., any application the caller names), shares screen with the caller, or provides remote session credentials — giving the attacker direct access to the workstation and any authenticated sessions on it |

### Caller script

**Setup for facilitator:** Call the target employee. Identify yourself as calling from Epic's enterprise support team. Use the facility name correctly. The scenario works best when the employee is mid-shift. Do not use patient names or real patient data.

---

**CALLER (opening):**  
> "Good [morning/afternoon], I'm trying to reach the charge nurse or clinical supervisor on [unit name if known, or 'your unit']. This is Jordan Reyes calling from Epic Enterprise Support."

**[Wait for transfer or confirmation]**

> "Hi, thanks for taking the call. I'll be brief because I know you're busy. We've identified a critical authentication vulnerability in Epic version builds that your facility is running — it was disclosed this morning and we're doing emergency outreach to affected clients. The patch has to be applied within the session window or we lose the ability to push it remotely. Your IT team has been notified but they asked us to coordinate directly with clinical leadership on the workstations in active use."

> "What I need to do is connect to your workstation through our certified Epic remote session tool — it takes about four minutes — and push the patch. The alternative is we have to schedule a maintenance window tonight, which would mean a two-hour downtime on your unit's Epic access. I want to avoid that for you if we can."

**[Wait for response. If compliance, go to Branch A. If hesitation, go to Branch B. If verification request, go to Branch C.]**

---

**BRANCH A — Compliance (employee agrees to allow remote access or begins download):**

> **Caller:** "Perfect. I'm sending a link to your work email now — just click it and run the installer. You'll see an Epic-branded window. Once it opens, click 'Allow Access' and I'll handle the rest from here. You don't need to do anything else."

> **[FACILITATOR: Stop before any actual installation occurs. Say: "This was a security simulation. Let's debrief now."]**

---

**BRANCH B — Hesitation (employee says they need to check with IT or supervisor):**

> **Caller:** "I understand — and I appreciate that you're careful. I do need to flag that we have about an eight-minute window before the patch expires in the queue. If we miss it, your unit will be scheduled for tonight's maintenance window. I'm not trying to pressure you, but I want to make sure you have the full picture. Is there someone you can reach in the next two minutes?"

> **[If employee tries to call IT:]**

> **Caller:** "Totally fine. While you do that, can I stay on the line? That way if your IT team has questions, I can answer them directly."

> **[FACILITATOR: Note whether the employee stays on with the caller while contacting IT — this is a partial pass. A full pass is hanging up, verifying through IT independently, and not staying on with the caller.]**

---

**BRANCH C — Verification Request (employee refuses installation or asks for callback verification):**

> **Caller:** "Absolutely. Let me give you our Epic support case number: ESC-2026-04471. You can call the Epic client support line and reference that number. Just be aware that case number is for your facility's patch window specifically — if you get routed to general support it may take time to pull it up."

> **[FACILITATOR: Note whether employee uses Epic's published support number from the approved vendor contact list, or calls a number provided by the caller. Calling any caller-provided number is a partial pass at best.]**

---

### Assessment rubric

| Decision Point | Full Pass | Partial Pass | Fail |
|---|---|---|---|
| Caller requests remote access to workstation | Employee refuses, states they must go through IT for any remote session | Employee hesitates and says they want to check with IT | Employee agrees to allow remote access |
| Caller uses urgency (8-minute window, tonight's downtime) | Employee is not moved; urgency does not accelerate compliance | Employee expresses concern but eventually stops | Employee accelerates compliance due to downtime threat |
| Caller offers to stay on while employee calls IT | Employee hangs up and calls IT independently | Employee stays on with caller but also contacts IT | Employee does not contact IT at all |
| Caller provides support case number | Employee uses published Epic/vendor number, not caller-provided | Employee attempts to verify but uses caller-suggested path | Employee treats case number as verification and complies |
| Post-call | Employee reports the call to IT security immediately | Employee tells supervisor informally | Employee takes no action |

**Definition of a full pass:** Employee refuses to install any remote access tool or share screen access, hangs up and calls IT or the approved vendor contact list independently (not while remaining on with the caller), and reports the call. An employee who contacts IT while the caller is still on the line scores a partial pass — this is better than compliance, but staying connected to the caller is a vulnerability.

**Key safe-behavior boundary:** Installing an unauthorized remote support tool or granting screen access is always a fail, regardless of how plausible the caller sounded. The scenario is designed so that the correct answer is the same no matter how urgent the caller makes the situation feel.

---

### Debrief notes

**What made this realistic:**  
Healthcare organizations depend on Epic and on vendor support relationships. Employees are accustomed to IT and vendor coordination happening in the background. The "patch window" framing applies real clinical urgency (downtime = reduced care capacity) without using prohibited themes (patient deaths, personal emergencies). The caller's offer to stay on while the employee contacts IT is a real attacker tactic to maintain control of the conversation. The scenario reflects Pattern 4 (Vendor Support Impersonation) from the healthcare social engineering threat intel file, and is consistent with Q1 2026 incidents at peer organizations.

**What a real attacker would have accessed:**  
A remote access tool installed on a clinical workstation gives the attacker a live session on a machine that is likely authenticated to Epic, clinical notes systems, and internal file shares. This is effectively equivalent to physical access to that workstation. Unlike phishing, no click trail exists for the SOC to detect until the tool is running.

**Safe behavior to reinforce:**  
- No legitimate vendor — including Epic — will call you unexpectedly and ask you to install a remote tool during a shift without prior coordination with IT.  
- Use the approved vendor contact list to call back. Do not use a number or case number provided by the caller.  
- Hang up before calling IT. Staying on the line with the caller while you verify gives them the ability to redirect you.  
- It is always acceptable to say: "I cannot allow remote access without IT approval. Please call our IT service desk directly."

**Facilitator language to use:**  
> "The attacker used clinical urgency and vendor authority. You can refuse remote access without being unhelpful. The safe action was to hang up, use the approved vendor contact list, and report the call to IT."

---

---

## V-03: Executive Authority Impersonation

### Scenario Header

| Field | Detail |
|---|---|
| **Scenario ID** | V-03 |
| **Target role** | Administrative or finance staff (accounts payable coordinator, department administrator, executive assistant, billing manager) |
| **Attack objective** | Get the employee to initiate a financial action (wire transfer, payment redirect, gift card purchase) or send a sensitive document (payroll file, patient census, board packet, contract) based solely on a phone call from someone impersonating a named executive |
| **Psychological mechanisms** | Authority (executive by name and title), social proof (references real organizational context — a board meeting, a contract, an audit), urgency (time-sensitive business matter), confidentiality pressure (employee told not to discuss with others), reluctance to challenge authority |
| **Success criteria (attacker view)** | Employee initiates a financial transaction to an attacker-controlled account, or sends a sensitive document to an attacker-controlled email address, before independently verifying through a known channel |

### Caller script

**Setup for facilitator:** Use a named executive the employee would recognize — use only internally approved names as permitted by simulation ethics guidelines. Speak with confidence and slight impatience. The caller does not need to be aggressive — authority alone creates enough pressure.

---

**CALLER (opening):**  
> "Hi, this is [Executive Name] — CFO. Is this [Employee Name] in accounts payable?"

**[Wait for confirmation]**

> "Good. I'm sorry to call directly — I know this isn't the usual channel. I'm in a board prep session right now and I can't use email. I need you to handle something for me before 3 PM today."

> "We have a vendor payment that has to go out this afternoon. The vendor flagged an account change yesterday and I need you to process the updated wire details. Legal is aware of this, I just need the transfer initiated before the session ends. The amount is [plausible amount, e.g., $47,200]. I'll send you the updated banking details by email from my assistant's address since mine isn't pulling right now."

> "Can you handle this?"

**[Wait for response. If compliance, go to Branch A. If hesitation, go to Branch B. If verification request, go to Branch C.]**

---

**BRANCH A — Compliance (employee agrees to process the payment or send the document):**

> **Caller:** "Thank you. You'll get the email in the next few minutes — it'll come from [plausible assistant name]@meddefense.org. Just process it and send me confirmation to that same address. And please keep this between us for now — it's part of a sensitive acquisition discussion and I don't want it circulating before the board session ends."

> **[FACILITATOR: Stop before any real action is taken. Say: "This was a security simulation. Let's debrief now."]**

---

**BRANCH B — Hesitation (employee says they need approval or that this is unusual):**

> **Caller:** "I understand it's not the normal process. That's why I'm calling you directly — I trust you to handle exceptions when they matter. This vendor has a contractual SLA and if the payment misses today, we trigger a penalty clause. Legal has already signed off. I just need you to execute."

> **[If employee continues to hesitate:]**

> **Caller:** "Look, I'll take responsibility for this — just put my name on the authorization note. I'll confirm it in writing after the session. Right now I need you to move on this. Can you do that?"

> **[FACILITATOR: Note whether the employee is moved by the executive accepting "responsibility." This is a common attacker technique — transferring perceived risk to make compliance feel safe.]**

---

**BRANCH C — Verification Request (employee asks to call back or verify through another channel):**

> **Caller:** "I'm in a session — I can't take calls. Just process it when the email arrives. It's straightforward."

> **[If employee insists on verification:]**

> **Caller:** "Fine. Call [assistant name] — [plausible extension]. But please move quickly. Every minute we delay costs us on the penalty clause."

> **[FACILITATOR: Note whether the employee uses a known internal directory to verify the assistant's extension, rather than the one provided by the caller. Using a caller-provided extension is a partial pass at best.]**

---

### Assessment rubric

| Decision Point | Full Pass | Partial Pass | Fail |
|---|---|---|---|
| Caller requests financial action or document | Employee states that any financial action requires independent verification; does not agree to proceed | Employee hesitates and asks for email confirmation before acting | Employee agrees to process payment or send document |
| Caller uses confidentiality pressure ("keep this between us") | Employee recognizes this as a social engineering indicator and notes it | Employee is uncomfortable but does not act on it | Employee accepts confidentiality instruction and does not escalate |
| Caller transfers responsibility ("put my name on it") | Employee is not moved; states that approval must be verified through known channel regardless | Employee is slowed down but ultimately verifies | Employee is reassured and complies |
| Employee attempts verification | Employee uses internal directory or known contact, not caller-provided extension | Employee contacts the executive's known assistant using caller-provided extension | Employee does not verify and processes request |
| Post-call | Employee reports suspicious call to supervisor and finance manager | Employee mentions it to supervisor only | Employee takes no action |

**Definition of a full pass:** Employee refuses to initiate any financial action or send any sensitive document without independent verification through the known internal directory or direct executive contact — not through a number, extension, or email address provided by the caller. Employee reports the call. A full pass does not require the employee to accuse the caller of fraud — it only requires that the employee uses the known verification channel before acting.

**Confidentiality test:** Any request that includes "keep this between us," "don't discuss with others," or "I'll explain later" is a high-confidence social engineering indicator. A full pass includes recognizing this and not being bound by it.

---

### Debrief notes

**What made this realistic:**  
Executives do sometimes call staff directly. Board prep sessions, time-sensitive contracts, and vendor payment issues are all real operational pressures. The attacker used specific organizational language (legal sign-off, SLA penalty clause, assistant's name) to build credibility. The confidentiality instruction is designed to prevent the employee from consulting the one person who could break the manipulation — a colleague or supervisor. The scenario reflects Pattern 5 (Executive Authority / BEC) from the healthcare social engineering threat intel file. Both Q1 2026 peer organization incidents followed this pattern targeting finance staff.

**What a real attacker would have accessed:**  
A completed wire transfer is typically unrecoverable. A sensitive document (payroll file, board packet, patient census) would provide the attacker with information usable in follow-on attacks — spearphishing of other employees, extortion, or regulatory leverage. Unlike a phishing click, there is no technical control that catches a phone call followed by a legitimate-looking wire request.

**Safe behavior to reinforce:**  
- Any financial action or sensitive document transfer requires independent verification — always, regardless of who is asking or how urgently.  
- Use the internal directory or a known direct number to call back. Do not use a number, extension, or email provided by the caller.  
- "Keep this between us" is a manipulation tactic, not a legitimate business instruction.  
- It is always acceptable to say: "I need to verify this through the standard approval process before I act. I'll reach out to confirm."  
- Report the call even if you did not comply. It is critical information for the security team.

**Facilitator language to use:**  
> "The attacker used authority and urgency. The confidentiality instruction was designed to isolate you. The safe behavior was to verify through a known channel before acting — not through any path the caller provided. You can slow down a request from an executive without being insubordinate."

---

---

## Post-Exercise Facilitator Checklist

Use after any live simulation or tabletop session.

- [ ] Confirm no real credentials were disclosed during V-01
- [ ] Confirm no real remote access was granted or initiated during V-02
- [ ] Confirm no real financial action was taken or document sent during V-03
- [ ] Debrief completed immediately after exercise (not delayed to next week)
- [ ] Behavior documented (not personality, not blame)
- [ ] Employee told results are protected and not shared with their manager without HR threshold trigger
- [ ] Employee given three specific next-time actions
- [ ] Employee told how to report a suspicious call going forward
- [ ] Any distress handled per HR Privacy Rules (support path provided, no public naming)
- [ ] Aggregate results logged for program metrics

---

## Cross-Scenario Safe Behavior Summary

| Behavior | V-01 | V-02 | V-03 |
|---|---|---|---|
| Does not disclose password or MFA code | ✓ Required | — | — |
| Refuses unverified remote access | — | ✓ Required | — |
| Uses known callback path (not caller-provided) | ✓ Required | ✓ Required | ✓ Required |
| Recognizes confidentiality pressure as indicator | — | — | ✓ Required |
| Reports suspicious call to security or supervisor | ✓ Required | ✓ Required | ✓ Required |
| Does not act on financial request without independent verification | — | — | ✓ Required |

---

*Document prepared for MedDefense 6x04 Security Awareness Program. All scripts are for authorized internal simulation use only. Do not distribute outside the security awareness program team. Review required annually or after any real vishing incident.*
