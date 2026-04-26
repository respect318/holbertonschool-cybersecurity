Scenario 1:
  Vector Type: Phishing
  Target: IT Director (Sarah Park) - Vulnerable due to her high-level responsibility over infrastructure, making her prone to reacting quickly to perceived critical firmware threats.
  Psychological Lever: Fear
  Red Flags: 1) Sender domain "fortinet-support.net" is a deceptive lookalike. 2) Unsolicited attachment/link for a "patch" instead of using official vendor channels. 3) High-pressure language threatening "service termination" to force immediate action.
  Technical Control: Implement an Email Security Gateway with active link scanning and sandboxing.
  Administrative Control: Policy requiring all technical updates to be verified through the vendor's official support portal.

Scenario 2:
  Vector Type: Business Email Compromise (BEC)
  Target: CFO (Robert Kim) - Vulnerable because he handles financial disbursements and is targeted via the assumed authority of the CEO.
  Psychological Lever: Authority
  Red Flags: 1) Subtle discrepancy in the CEO's email address. 2) Urgent, confidential wire transfer request bypassing normal protocols. 3) Insistence on "email only" communication to prevent out-of-band verification.
  Technical Control: Tag all external emails with a warning banner and implement executive impersonation protection.
  Administrative Control: Mandatory multi-person approval and voice verification for all high-value financial transfers.

Scenario 3:
  Vector Type: Vishing
  Target: Clinical Nurse - Vulnerable due to clinical "helpfulness" culture and high-stress environments where questioning "IT" seems counterproductive.
  Psychological Lever: Helpfulness
  Red Flags: 1) Caller asking for a password, which IT never does. 2) Fabricated urgency based on a recent real-world incident. 3) Request for sensitive login credentials over a non-secure phone line.
  Technical Control: Enforcement of Multi-Factor Authentication (MFA) on all EHR access.
  Administrative Control: Security awareness training specifically emphasizing that passwords are never to be shared with anyone, including IT.

Scenario 4:
  Vector Type: Phishing
  Target: All MedDefense employees - Vulnerable because parking is a personal convenience issue and SMS prompts a faster, less critical response on mobile devices.
  Psychological Lever: Urgency
  Red Flags: 1) Administrative notice regarding parking sent via SMS rather than official internal channels. 2) Threat of "towing" used to provoke an emotional, hasty reaction. 3) Link leads to an external, unauthorized credential-harvesting site.
  Technical Control: Mobile Device Management (MDM) with active web filtering.
  Administrative Control: Formal policy stating the organization will never use SMS to collect Active Directory credentials.

Scenario 5:
  Vector Type: Typosquatting
  Target: MedDefense physicians - Vulnerable because they frequently visit industry sites and may not notice a subtle variation in a trusted URL when seeking CME credits.
  Psychological Lever: Familiarity
  Red Flags: 1) Subtle character changes or domain suffix differences in the industry association's URL. 2) Unexpected browser redirects or malicious pop-ups on a site that is normally static. 3) Browser warnings regarding the site's security certificate or reputation.
  Technical Control: Implement DNS-level filtering to block known malicious or recently registered lookalike domains.
  Administrative Control: Training staff to use pre-verified bookmarks for all professional association and regulatory websites.

Scenario 6:
  Vector Type: Phishing
  Target: Patients and remote staff - Vulnerable because the site is a pixel-perfect replica of a trusted portal and appears as a top-tier search result.
  Psychological Lever: Familiarity
  Red Flags: 1) Use of a deceptive domain name ("defence" vs "defense"). 2) Site is promoted via a "Sponsored" ad rather than appearing in organic search. 3) Deceptive interface designed solely to capture and exfiltrate user credentials.
  Technical Control: Proactive registration of common typosquatted domains and continuous brand monitoring for takedowns.
  Administrative Control: Directing patients and staff to access portals only via the main hospital website (meddefense.com).

Scenario 7:
  Vector Type: Tailgating
  Target: IT department staff - Vulnerable due to social norms of politeness and the physical "props" (scrubs, coffee) that mask the intruder's lack of authorization.
  Psychological Lever: Helpfulness
  Red Flags: 1) Person lacks a visible, valid ID badge. 2) Use of a verbal excuse ("badge in locker") to bypass electronic access controls. 3) This is a physical security breach where the attacker follows a staff member through a secure door without swiping.
  Technical Control: Installation of physical barriers like mantraps or turnstiles that enforce one entry per badge swipe.
  Administrative Control: Strict enforcement of a "No Tailgating" policy, requiring all employees to challenge anyone attempting to follow them into secure areas.
