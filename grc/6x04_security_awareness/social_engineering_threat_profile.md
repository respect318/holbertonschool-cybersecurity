# Social Engineering Threat Profile: MedDefense Health Systems

**Prepared by:** Security Awareness Program Team
**Date:** 2026-06-06
**Distribution:** Security Team, CISO, HR (Section 5 only)

---

## 1. Target Analysis

### Population A: Clinical Floor Staff (Nurses, Patient Care Technicians, Clinical Assistants)
**Targeting frequency:** Highest. Clinical floor staff received the largest volume of targeted lures in the MD-PHISH-Q1-2026 campaign. Of 15 emails delivered to clinical floor staff, 10 resulted in clicks (67% click rate), the highest rate across all departments.
**Attacker access objective:** EHR credential capture via Epic impersonation for ePHI access and lateral movement into clinical network segments. The March 2026 campaign confirmed that credential submission at the clinical layer preceded Cobalt Strike beacon activity and subsequent privileged account misuse.
**Exploitation timing:** Shift-start windows at 07:00–08:30 and 19:00–20:30. The first click in the Q1 campaign occurred within 9 minutes of delivery at 06:58, before shift handoff. Staff are simultaneously authenticating to Epic, reviewing handoff notes, and operating under time-critical care pressure. Credential prompts during these windows are processed with reduced scrutiny. Clinical schedule constraints specify 07:15–08:30 and 19:15–20:30 as realistic delivery windows for simulation baseline lures.

### Population B: Nursing Supervisors and Unit Leads
**Targeting frequency:** High. Nursing supervisors received 5 emails in the Q1 campaign with a 60% click rate and a 20% report rate. Their elevated access to clinical data and administrative systems makes them high-value targets.
**Attacker access objective:** Elevated EHR privilege access and administrative workflow credentials. Supervisors often hold broader access rights than floor staff, enabling wider lateral movement post-compromise.
**Exploitation timing:** Shift-start and handoff periods are also high-risk for supervisors. The campaign reconstruction shows supervisor clicks concentrated in early morning delivery windows. ICU and high-acuity unit supervisors require coordination with unit leadership due to surge sensitivity and should be targeted only outside peak clinical events.

### Population C: Billing and Administrative Staff
**Targeting frequency:** High. The billing wave of MD-PHISH-Q1-2026 delivered 8 emails with a 63% click rate. Administrative staff are consistently targeted in healthcare sector campaigns because they process financial and PHI-adjacent data while expecting routine compliance and portal-access messages.
**Attacker access objective:** Access to billing portals, insurance systems, and patient financial records. Successful compromise enables financial fraud, claim manipulation, or ePHI exposure through revenue cycle systems.
**Exploitation timing:** Tuesday through Thursday between 09:00–11:00, outside payroll close and month-end. Billing staff clicked when messages referenced compliance tasks or portal access, aligning with Pattern 2 (MFA/compliance enrollment). The billing wave in the Q1 campaign was delivered at 09:44 with first click at 10:02.

### Population D: Finance Staff and Department Administrators
**Targeting frequency:** Moderate-high. Finance received 5 emails in the Q1 campaign with a 40% click rate. Finance users were less likely to click links but more likely to engage offline, reply to threads, or take financial action without verbal verification.
**Attacker access objective:** Business email compromise resulting in fraudulent payment authorization, vendor re-routing, or access to financial systems and board-level documents.
**Exploitation timing:** Tuesday through Thursday between 10:00–14:00, avoiding month-end close and audit deadlines. The finance/executive wave of MD-PHISH-Q1-2026 was delivered Friday morning at 13:15, timed before vendor payment runs. The Reply-to mismatch pattern observed in MSG-003 is specifically effective against finance workflows.

### Population E: IT Staff and SOC Personnel
**Targeting frequency:** Moderate. IT staff received 4 emails in the Q1 campaign with a 25% click rate, the lowest among all groups, but their privileged access makes each successful compromise disproportionately damaging. The March 2026 incident showed that service account misuse followed the initial credential compromise at 02:14, implicating privileged account hygiene as a secondary failure.
**Attacker access objective:** Privileged account credentials, domain admin access, change-management system access, and the ability to create persistence mechanisms. IT-targeted lures in the phishing kit included fake internal ticket numbers to increase credibility.
**Exploitation timing:** Planned maintenance windows. The email header analysis confirmed that MSG-005, targeting the IT helpdesk, arrived during a known maintenance window. Vendor-support impersonation (Pattern 4) is the primary lure class for this population.

### Population F: Executives and Executive Assistants
**Targeting frequency:** Lower volume, highest impact per event. Executives received 4 emails in the Q1 campaign with a 50% click rate and a 0% report rate. Executive assistants manage calendar, communication, and authorization workflows that present BEC exposure.
**Attacker access objective:** Authorization of fraudulent financial transactions, sensitive document exfiltration, or credential access to executive communication channels. Employee feedback confirmed reluctance to challenge apparent executive requests: "If a director asks for something, you don't want to slow them down."
**Exploitation timing:** Delivery must be coordinated with the executive assistant to avoid board meeting days. The Q1 finance/executive wave arrived at 13:15 on a Friday to exploit pre-weekend payment pressure. BEC lures require named internal personnel and known workflow context rather than generic account-threat language.

---

## 2. Attack Vector Inventory

### Vector 1: EHR System Impersonation (Email)
**Description:** Email lures mimic Epic EHR system notifications using clinical workflow language such as "patient record access," "secure clinical portal," and "temporary access hold." The phishing kit analyzed in Module 4 copied the MedDefense clinical portal sign-in layout with familiar header and badge colors, and pre-filled the username field using a link token to reduce friction.
**Example lure:** "Your Epic account has been placed on a temporary access hold pending security verification. Complete verification before your next scheduled shift to avoid interruption to patient chart access."
**Attacker objective:** EHR credential capture for ePHI access and lateral movement into clinical network segments.
**Targeted asset:** Epic EHR, downstream ePHI repositories, clinical portal authentication layer.

### Vector 2: MFA and Compliance Enrollment Impersonation (Email)
**Description:** Email lures impersonate MedDefense IT or compliance departments issuing required enrollment or review tasks. Messages use familiarity and authority framing because staff routinely receive legitimate compliance communications. MSG-002 targeted billing staff using the sender display name "MedDefense IT Compliance" from the domain `meddefense-it-support.org`, which passed SPF checks despite being an externally registered domain.
**Example scenario:** "Required: Complete your MFA enrollment update by end of business Thursday to maintain access to the compliance portal and remote access systems. Accounts not updated will require manual IT reactivation."
**Attacker objective:** Credential capture or session token theft through a fake compliance portal.
**Targeted asset:** Identity provider, remote access systems, VPN credentials, compliance portal.

### Vector 3: Business Email Compromise / Executive Authority (Email)
**Description:** Lures impersonate executives or use Reply-to mismatch to route responses to attacker-controlled mailboxes. MSG-003 in the Q1 campaign used a display name resembling the CFO office while routing replies to an unrelated mailbox. Finance users were more likely to open and consider offline action than to click links, making reply-channel verification the key training objective for this vector.
**Example scenario:** "I need you to initiate a vendor payment adjustment before EOD. The invoice details are attached. Please do not route this through standard approval — this is time-sensitive and relates to an ongoing legal matter. Reply to confirm receipt."
**Attacker objective:** Fraudulent payment authorization, sensitive document exfiltration, or credential acquisition through a secondary follow-up request.
**Targeted asset:** Accounts payable systems, financial authorization workflows, executive communication channels.

### Vector 4: Vendor and IT Helpdesk Impersonation (Vishing / Email)
**Description:** Attackers impersonate healthcare vendors (Epic support, medical device vendors, biomedical engineering contacts) or internal IT helpdesk personnel. MSG-005 targeted the IT helpdesk using the sender display name "Vendor Patch Coordination" from `nexus-updates-support.net`, timed during a maintenance window. The phishing kit included a fake internal ticket number field to increase IT-specific credibility. Vishing variants involve callers requesting remote access or credential confirmation to resolve an "urgent ticket."
**Example scenario:** "This is MedTech support calling about your Alaris pump software patch scheduled for tonight. We need to verify your maintenance window credentials to proceed remotely. Can you confirm your IT service account?"
**Attacker objective:** Privileged credential capture, remote access to clinical or infrastructure systems.
**Targeted asset:** IT service accounts, remote administration tools, medical device management infrastructure, biomedical network segments.

---

## 3. Lure Effectiveness Analysis

| Rank | Lure Category | Mechanism | Healthcare Factor | Click Rate Range |
|---:|---|---|---|---:|
| 1 | EHR account suspension / access hold | Authority + Urgency | Blocked Epic access directly prevents patient care delivery; clinical staff cannot document orders or medication without EHR access | 40–62% |
| 2 | Secure patient message notification | Familiarity + Urgency | Staff routinely receive patient-context alerts; the lure pattern matches expected clinical workflow messages | 34–50% |
| 3 | MFA / compliance enrollment | Familiarity + Authority | Staff expect periodic IT compliance messages; the lure matches a known recurring administrative task | 25–42% |
| 4 | HR benefits deadline / payroll correction | Scarcity + Urgency | Financial consequence is personal and immediate; missed enrollment windows create real loss | 22–38% |
| 5 | Vendor emergency support | Authority + Urgency | Vendors are a routine and trusted part of healthcare operations; urgency is normalized in clinical IT support contexts | 18–35% |

**Behavioral notes:** A lower click rate does not equal lower risk. Executive and BEC lures (8–22% click rate) produce fewer clicks but can generate high-dollar or high-sensitivity outcomes. Clinical lures dominate click rate because workflow pressure at shift start removes deliberation time. The Q1 campaign confirmed: mean time to first click was 11 minutes; mean time to report was 74 minutes. Employees who suspected a lure frequently told coworkers verbally rather than using the report button, and several did not report at all after clicking due to fear of blame.

---

## 4. Detection and Disruption Opportunities

### Vector 1: EHR System Impersonation
**Disruption point:** At email receipt, before clicking the link.
**What the employee should notice:** Sender domain does not match Epic or MedDefense IT. MSG-001 used `epic-healthsystems.net` rather than any legitimate Epic or MedDefense domain. Link text uses process framing ("Complete Epic verification") rather than direct account management language. Message arrived before shift start, precisely when EHR access pressure is highest.
**Action to take:** Use the Outlook phishing report button or call ext. 4-SECURITY. Do not click the link. Navigate to Epic directly through the known desktop shortcut or intranet bookmark.
**Why it is difficult:** The lure matched clinical workflow language exactly. The page pre-filled the username field, creating apparent legitimacy. Clinical staff under shift-start pressure process authentication prompts with reduced deliberation. Patient care urgency is normalized, making urgency cues less distinguishable.

### Vector 2: MFA and Compliance Enrollment Impersonation
**Disruption point:** At email receipt; secondary opportunity at the credential entry page.
**What the employee should notice:** Email originates from an external domain (`meddefense-it-support.org`) rather than an internal MedDefense address. MedDefense IT does not send login tasks or enrollment links from newly registered external domains. The instruction to click an embedded link rather than use the known intranet compliance portal is a behavioral mismatch.
**Action to take:** Report via the Outlook report button. Navigate to the compliance portal through the known intranet bookmark, not through the email link. Confirm with IT through ext. 4-SECURITY before completing any enrollment action.
**Why it is difficult:** Staff expect compliance tasks and remote-access enrollment messages. Display name trust ("MedDefense IT Compliance") overrides domain inspection for most recipients. MSG-002 passed SPF authentication, providing no gateway-level warning to the employee.

### Vector 3: Business Email Compromise / Executive Authority
**Disruption point:** Before taking any financial or document-disclosure action; before replying to the email thread.
**What the employee should notice:** The reply address or sender domain does not match a legitimate MedDefense executive mailbox. The request bypasses standard approval workflow with a confidentiality or urgency justification. Finance or document requests that arrive outside normal channels or reference legal or acquisition matters require independent verification.
**Action to take:** Do not reply to the email thread. Verify through an independent known channel — call the executive directly using a number on record, not one provided in the message. Follow standard payment authorization procedures regardless of stated urgency.
**Why it is difficult:** Reluctance to challenge apparent authority is well-documented in MedDefense post-incident employee feedback. Reply-to mismatch is not visible in standard email clients unless the user inspects headers or clicks Reply and examines the destination address. Confidentiality framing ("ongoing legal matter") actively discourages peer consultation.

### Vector 4: Vendor and IT Helpdesk Impersonation
**Disruption point:** Before granting remote access or providing credentials; at point of initial caller or sender contact.
**What the employee should notice:** Unsolicited vendor support contact that requests credential confirmation or remote access is outside normal vendor engagement procedures. Legitimate vendor patch coordination follows a scheduled change window process with internal IT approval. Sender domains like `nexus-updates-support.net` do not correspond to known approved vendors.
**Action to take:** Do not confirm credentials or grant remote access on an inbound call or unsolicited email. End the call or suspend the email interaction. Verify by calling the vendor directly using the approved vendor contact list maintained by IT. Confirm any maintenance window actions with the internal IT change management team.
**Why it is difficult:** Clinical operations depend on rapid vendor support. Urgency ("tonight's patch window") creates time pressure. IT and biomedical staff are accustomed to vendor contact and may not question a technically plausible request. The phishing kit replicated an internal ticket number field, adding specificity that increases credibility.

---

## 5. Simulation Design Requirements

1. All phishing simulation templates must reference MedDefense-specific systems by name — Epic, not "your EHR"; MedDefense IT, not "your IT department" — because the Q1 campaign phishing kit succeeded by using operational specificity, not generic account-threat language.

2. Delivery timing for clinical staff segments must target shift-start windows at 07:00-08:30 and evening equivalents at 19:15–20:30, consistent with the clinical schedule constraints, because the Q1 incident confirmed that the first click occurred within 9 minutes of pre-shift delivery and that clinical pressure windows produce the highest click velocity.

3. At least one template per simulation wave must combine authority with an operational consequence affecting patient care workflow — for example, threatened EHR access hold rather than simple account expiration — because lures that block clinical function produce click rates of 40–62% compared to generic credential-expiry lures.

4. Executive-targeted templates must use named internal personnel and realistic workflow context (document review, payment approval, acquisition reference) rather than generic titles, because the post-incident review confirmed that executive lures require authority combined with social proof, and that a 0% report rate among executives in Q1 was associated with reluctance to challenge authority.

5. Lure difficulty must increase across waves: baseline EHR and compliance lures should be deployed first, with BEC and vendor-impersonation variants introduced only after employees have been exposed to and received microtraining on simpler lure patterns, because the lure effectiveness benchmarks confirm that advanced variants (BEC: 8–22% click rate) have lower click rates but higher-impact outcomes and require different detection behaviors than credential-phishing lures.
