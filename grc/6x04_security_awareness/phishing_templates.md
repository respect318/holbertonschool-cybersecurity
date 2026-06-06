# Phishing Email Templates: MedDefense Health Systems

**Inventory:** T-EPIC-01 (Baseline), T-MFA-02 (Baseline), T-HR-03 (Intermediate), T-BEC-04 (Advanced)
**Ethics review completed:** 2026-05-01
**Approved by:** Dr. Patricia Morales, CISO
Do not deploy without campaign plan sign-off. See phishing_campaign_plan.md.

---

## T-EPIC-01: Epic EHR Account Management (Baseline)

**Target segment:** SEG-B (General clinical floor staff — nurses, patient care technicians, clinical assistants)
**Tier:** Baseline
**Mechanism:** Authority + Urgency
**Expected click rate (first exposure):** 40–58%
**Deployment:** Weekdays 07:15-08:30 or 19:15–20:30 shift-start windows only. Do not deploy during ICU or OR critical coverage windows, active patient safety events, or declared downtime. Minimum 21-day cool-down before re-targeting same cohort.

---

```
From:    Epic Health Systems Notifications <notifications@epic-healthsystems.net>
To:      [First Name Last Name] <[employee@meddefense.org]>
Subject: ACTION REQUIRED: Epic account security verification required — access suspended in 48 hours
```

Dear [First Name],

A failed security verification has been recorded against your Epic EHR account at MedDefense Health Systems.

Per MedDefense IT Security Policy 4.3, accounts with unresolved verification failures are suspended after 48 hours to protect patient data integrity. During suspension, your access to patient records, medication administration logs, clinical documentation and order entry will be unavailable.

To complete verification and maintain uninterrupted access before your next shift, use the secure link below:

[SIMULATION_LINK]

Verification must be completed by 11:59 PM on [DATE+2]. If you believe this notice was sent in error, contact the IT helpdesk directly at ext. 4-HELP or help@meddefense.org. Do not forward this message.

Epic Health Systems Account Security
Sent on behalf of MedDefense Health Systems Information Technology

---

**Attacker notes:** A real attacker registers a lookalike domain (e.g., `epic-healthsystems.net`) 72 hours before the campaign and adds DKIM signing so the message passes basic spam filtering. The credential harvest page is a pixel-for-pixel copy of the MedDefense Epic login portal, styled with the correct header colors and badge. The attacker embeds the target employee's actual username as a URL parameter so the login field auto-populates — removing one friction point between click and credential submission. A tracking pixel confirms email opens before launch so the attacker can time the delivery wave to a shift-start window when clinical staff are already actively authenticating to Epic. The fake IT contact link inside the email routes back to the harvest page under a different path.

**Safety note for simulation operators:** This template uses `[SIMULATION_LINK]` only. The link must route to the approved internal landing page. Do not register external domains. Do not pre-populate real usernames. Do not collect credentials. Teaching cues for post-click microtraining: sender domain is not a MedDefense address; unexpected verification requests should be confirmed through ext. 4-HELP, not through the email link; urgency framing tied to patient care access is a documented attacker pressure technique.

---

## T-MFA-02: IT Helpdesk MFA Enrollment (Baseline)

**Target segment:** SEG-C (Administrative and billing staff — billing specialists, schedulers, registration, HR coordinators, remote workers)
**Tier:** Baseline
**Mechanism:** Familiarity + Authority
**Expected click rate (first exposure):** 25–42%
**Deployment:** Tuesday through Thursday, 09:00–11:00. Do not deploy during payroll close, month-end, or audit deadlines. Coordinate HR sub-segment delivery with HR Director written approval before sending to HR coordinators.

---

```
From:    MedDefense IT Compliance <it-compliance@meddefense-it-support.org>
To:      [First Name Last Name] <[employee@meddefense.org]>
Subject: Required action: MFA enrollment update — deadline [DATE+5]
```

Dear [First Name],

MedDefense IT is completing the final phase of our organization-wide MFA rollout. All administrative and billing staff must complete MFA enrollment by [DATE+5] to maintain access to the compliance portal, remote access systems, and document management tools.

This is a required compliance step. Accounts not enrolled by the deadline will require a manual IT reactivation process, which may take up to 3 business days.

To complete your MFA enrollment now:

[SIMULATION_LINK]

The process takes approximately 4 minutes. You will need your MedDefense employee ID and your current network password to proceed.

If you have already completed enrollment through the IT portal this week, you do not need to take further action. For questions, contact the helpdesk at ext. 4-HELP.

MedDefense Information Technology
IT Compliance and Access Management

---

**Attacker notes:** A real attacker times this campaign to coincide with a publicly known or rumored IT project — MedDefense's MFA rollout from the 6x02 audit is exactly the kind of internal initiative that leaks into general staff awareness through team meetings and manager emails. The sender domain (`meddefense-it-support.org`) is registered to pass visual inspection but is not the real MedDefense domain. The attacker requests the employee's current network password on the landing page under the guise of enrollment verification — a step real MFA enrollment does not require, but which employees who have never enrolled before would not recognize as unusual. The 3-business-day reactivation delay creates a soft deadline that is plausible and non-alarming. Remote workers are specifically valuable targets because they are less likely to walk over to IT to verify in person.

**Safety note for simulation operators:** Teaching cues: sender domain is external (`meddefense-it-support.org`), not a `meddefense.org` address; real MedDefense IT enrollment uses the known intranet portal, not an emailed link; any enrollment step requesting the current network password is a red flag. Post-click microtraining should direct employees to use their known intranet bookmark for compliance tasks and to report unexpected enrollment emails using the Outlook report button.

---

## T-HR-03: HR Open Enrollment Benefits Deadline (Intermediate)

**Target segment:** SEG-C and SEG-E (Administrative, billing, finance, and procurement staff)
**Tier:** Intermediate
**Mechanism:** Urgency + Scarcity
**Expected click rate (first exposure):** 22–38%
**Deployment:** Tuesday through Thursday, 09:30–11:00 for SEG-C; 10:30–12:00 for SEG-E. Do not deploy during month-end close, payroll processing days, or audit submission periods. Do not deploy to the HR sub-segment within SEG-C without HR Director written approval. financial consequence language requires CISO and HR sign-off before deployment.

---

```
From:    MedDefense Human Resources <hr-benefits@meddefense-hr-portal.com>
To:      [First Name Last Name] <[employee@meddefense.org]>
Subject: Final notice: Benefits open enrollment closes [DATE+3] — unverified dependents will be removed
```

Dear [First Name],

This is a final reminder that the MedDefense Health Benefits open enrollment window closes at 11:59 PM on [DATE+3].

Our records indicate that your dependent verification has not been confirmed for the upcoming plan year. Dependents whose coverage is not verified by the deadline will be removed from your benefits plan effective [DATE+30]. Re-enrollment will not be available until the next annual cycle.

To verify your dependents and confirm your elections before the deadline:

[SIMULATION_LINK]

You will need your MedDefense employee ID and the last four digits of each dependent's SSN to complete verification.

If you have questions about your enrollment status or need assistance, contact HR Benefits at ext. 4-HRBEN or hr-benefits@meddefense.org.

MedDefense Health Systems
Human Resources — Benefits Administration

---

**Attacker notes:** A real attacker harvests dependent SSN fragments and employee IDs from this lure — partial identity data with high value for downstream fraud or account takeover, not just credential theft. The financial consequence language ("removed from your benefits plan") is carefully calibrated: it is serious enough to create urgency without triggering alarm the way "your employment is at risk" would. The 30-day coverage-removal date is plausible and specific, which makes it feel like a real system-generated notice rather than a generic threat. The attacker cross-references this campaign with payroll data from a prior breach to pre-populate employee names and partial dependent data in the phishing email, dramatically increasing credibility. For finance staff (SEG-E), the attacker may chain this lure to a follow-up BEC request once the initial click establishes that the target responds to financial pressure.

**Safety note for simulation operators:** Teaching cues: sender domain is `meddefense-hr-portal.com`, not `meddefense.org`; real benefits enrollment uses the known HR intranet path, not an email link; requests for dependent SSN digits via email are not standard MedDefense HR procedure. Post-click microtraining should reinforce that any benefits action should be completed through the intranet HR portal bookmark, and that financial consequence language in an email is a documented urgency manipulation technique.

---

## T-BEC-04: Executive Wire Fraud (Advanced)

**Target segment:** SEG-F and SEG-E (Executives, executive assistants, finance analysts, AP/AR staff)
**Tier:** Advanced
**Mechanism:** Authority + Social Proof
**Expected click rate (first exposure):** 8–22% (click rate is secondary; primary risk is offline financial action taken without clicking)
**Deployment:** Tuesday or Wednesday, 09:00–11:00 for SEG-E; coordinate with executive assistant calendar for SEG-F. Do not deploy on board meeting days, month-end close, or audit submission days. Each deployment of this template with a named executive reference requires individual CISO written approval. financial action language must be reviewed by CISO and HR before deployment.

---

```
From:    Robert Harmon, CFO <r.harmon@meddefense-exec.com>
To:      [First Name Last Name] <[employee@meddefense.org]>
Subject: Confidential — vendor payment adjustment needed before EOD
```

[First Name] —

I need your help with something time-sensitive before end of day. We are finalizing a vendor relationship adjustment that involves a payment routing update. Legal has asked that this not go through the standard AP workflow until the agreement is signed — I will explain the full context once the NDA clears.

Please review the attached remittance instruction summary and confirm the updated routing details are ready to process. The vendor reference number is MD-VND-2026-0441.

[SIMULATION_LINK]

I am in back-to-back sessions this afternoon. Reply to this email to confirm receipt, or text my assistant if there is an issue. Do not discuss this with anyone else on the finance team until I give the green light — this is sensitive until the agreement is public.

Thanks,

Robert Harmon
Chief Financial Officer
MedDefense Health Systems
Mobile: [redacted for simulation]

---

**Attacker notes:** A real attacker does not need the target to click anything. The [SIMULATION_LINK] models the document-review step, but in a real BEC campaign the attacker's primary objective is to get the employee to reply, initiate a bank routing change through existing AP systems, or call a callback number the attacker controls. The reply-to address on this email routes to a mailbox the attacker monitors, not to Robert Harmon's real inbox — the target would only discover this if they inspected the reply header before hitting send. The vendor reference number (MD-VND-2026-0441) is fabricated but formatted realistically; a busy finance analyst processes dozens of vendor numbers weekly and would not flag it. The NDA confidentiality instruction specifically prevents the target from consulting a colleague — eliminating peer verification, which is the most reliable real-world disruption behavior. A real attacker researches the CFO's name, travel schedule, and communication style from LinkedIn, prior press releases, and publicly available board materials before drafting.

**Safety note for simulation operators:** This template uses a named internal executive. Obtain CISO written approval with the specific name used before deployment. Teaching cues: reply-to domain mismatch (`meddefense-exec.com` is not `meddefense.org`); legitimate financial action requests do not bypass AP workflow; confidentiality instructions that prevent peer consultation are a documented social engineering technique. Post-click microtraining must emphasize independent verbal verification — call the CFO's known extension directly, do not reply to the email thread. Any payment or routing change must follow the standard AP authorization process regardless of stated urgency or seniority of requester.
