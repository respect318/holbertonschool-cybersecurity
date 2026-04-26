Scenario 1:
  Vector Type: Phishing
  Target: IT Director (Sarah Park) - She is vulnerable because she manages critical infrastructure and feels a direct responsibility to prevent service termination mentioned in the alert.
  Psychological Lever: Fear
  Red Flags: 1) The sender domain "fortinet-support.net" is a lookalike of the official domain. 2) The email contains an unsolicited link to a firmware patch rather than using official portal notifications. 3) Use of high-pressure language threatening "service termination" within a short 24-hour window.
  Technical Control: Implement an Email Security Gateway with URL sandboxing and DMARC/SPF/DKIM enforcement.
  Administrative Control: Establish a policy that all critical infrastructure updates must only be sourced from verified, pre-approved vendor support portals.

Scenario 2:
  Vector Type: Business Email Compromise (BEC)
  Target: CFO (Robert Kim) - Vulnerable because he has the authority to process large financial transactions and is targeted using the CEO's perceived authority.
  Psychological Lever: Authority
  Red Flags: 1) The sender's email address has a subtle, non-standard variation from the CEO's real address. 2) The request for a high-value wire transfer is labeled as "confidential" to prevent routine verification. 3) The directive to use "email only" deliberately cuts off out-of-band communication channels.
  Technical Control: Enable external sender warning banners and implement automated detection for executive name spoofing.
  Administrative Control: Enforce a strict dual-authorization policy for all wire transfers, requiring a secondary out-of-band verbal confirmation.

Scenario 3:
  Vector Type: Vishing
  Target: Clinical Nurse - Vulnerable because clinical environments prioritize helpfulness and the nurse may not feel comfortable challenging a person claiming to be from "IT" during an "emergency."
  Psychological Lever: Helpfulness
  Red Flags: 1) An unsolicited caller asking for a plaintext EHR password, which violates standard IT protocols. 2) The use of a recent real-world incident (billing server) to create a false sense of urgency. 3) The caller's request to "verify login works" as a pretext to harvest credentials.
  Technical Control: Implement Multi-Factor Authentication (MFA) across all EHR and clinical systems to render stolen passwords useless.
  Administrative Control: Conduct training stating that IT personnel will never ask for passwords over the phone and provide an internal extension for staff to verify the caller's identity.

Scenario 4:
  Vector Type: Phishing
  Target: All MedDefense employees - Vulnerable because parking permits are a universal concern and the urgency of "towing" triggers a fast, uncritical response via mobile device.
  Psychological Lever: Urgency
  Red Flags: 1) An official administrative notice sent via SMS instead of corporate email or the HR portal. 2) The extreme urgency of "expiry tomorrow" combined with a punitive threat. 3) The link points to a non-hospital domain that mimics the internal HR login page.
  Technical Control: Deploy Mobile Device Management (MDM) with web content filtering to block known malicious URLs on employee devices.
  Administrative Control: Communicate a clear policy that the organization will never use SMS to request credentials or send urgent administrative notices.

Scenario 5:
  Vector Type: Watering hole attack
  Target: MedDefense physicians - Vulnerable because they regularly visit the Regional Healthcare Association site for CME credits, making it a trusted, high-traffic destination.
  Psychological Lever: Familiarity
  Red Flags: 1) Unexpected browser redirects to unfamiliar domains while on a trusted professional site. 2) Sudden, anomalous browser performance issues or certificate errors. 3) Automated security alerts from endpoint protection software after visiting the site.
  Technical Control: Use DNS filtering and sinkholing to prevent connections to known malicious domains used in drive-by download redirects.
  Administrative Control: Maintain an aggressive patching schedule for browsers and web-based plugins to close the vulnerabilities exploited by these attacks.

Scenario 6:
  Vector Type: Brand impersonation
  Target: Patients and staff - Vulnerable because the fake portal is visually identical to the real one and appears as a top result in search engines, exploiting the users' trust in the MedDefense brand.
  Psychological Lever: Familiarity
  Red Flags: 1) The URL uses an incorrect spelling ("defence" instead of "defense"). 2) The site appears as a "Sponsored" advertisement rather than an organic search result. 3) Small discrepancies in SSL certificate details or site metadata compared to the legitimate portal.
  Technical Control: Proactively register common typosquatted domains and utilize automated brand protection services to report and take down fraudulent websites.
  Administrative Control: Educate users to access the patient portal exclusively through the official meddefense.com homepage or through verified bookmarks.

Scenario 7:
  Vector Type: Tailgating
  Target: IT department staff - Vulnerable due to the "politeness trap" where employees are conditioned to hold doors for people who look like colleagues (scrubs and hospital branding).
  Psychological Lever: Helpfulness
  Red Flags: 1) The individual does not have a visible, currently valid employee ID badge. 2) The person attempts to gain access to a high-security IT area while dressed in clinical scrubs. 3) The individual provides a vague verbal excuse to bypass physical security controls.
  Technical Control: Install physical access controls such as optical turnstiles or mantraps that allow only one person to pass per valid badge swipe.
  Administrative Control: Implement a strict "no-tailgating" policy and train all employees on their responsibility to ensure every individual swipes their own badge for entry.
