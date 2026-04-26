Scenario 1:
  Vector Type: Phishing
  Target: IT Director (Sarah Park) - She is vulnerable because she manages the network infrastructure, is highly aware of recent incidents, and feels a direct responsibility to quickly resolve "critical vulnerabilities" to prevent downtime.
  Psychological Lever: Fear
  Red Flags: 1) The sender domain is "fortinet-support.net" instead of the official "fortinet.com". 2) A vendor sending an unsolicited direct email with an executable "emergency patch" link rather than advising logging into an official portal. 3) The aggressive threat of "service termination" within 24 hours to force immediate action.
  Technical Control: Implement an Email Security Gateway with strong anti-phishing filters, URL rewriting, and DMARC/SPF/DKIM validation to block spoofed or lookalike domains.
  Administrative Control: Conduct specific security awareness training on proper vendor patch management procedures, emphasizing that patches must only be downloaded from official vendor portals.

Scenario 2:
  Vector Type: Business Email Compromise (BEC)
  Target: CFO (Robert Kim) - He is vulnerable because his role involves moving large sums of money, and he is structurally expected to follow urgent, confidential directives from the CEO.
  Psychological Lever: Authority
  Red Flags: 1) A subtle typo or deviation in the CEO's sender email address. 2) A highly urgent request to transfer $85,000 to an unknown account for a "confidential" acquisition. 3) Explicit instructions to bypass normal verification ("email only", "do not discuss with anyone").
  Technical Control: Configure external sender warning tags in the email client (e.g., "[EXTERNAL]") to immediately alert users when an email originates from outside the organization.
  Administrative Control: Implement a strict financial policy requiring mandatory two-person out-of-band verification (such as a voice call to a known number) for any wire transfer requests exceeding a specific threshold.

Scenario 3:
  Vector Type: Vishing
  Target: Clinical Nurse at MedDefense Central - Vulnerable because clinical staff are constantly busy, trained to be inherently helpful, and often lack the technical confidence to question someone claiming to be from "IT".
  Psychological Lever: Helpfulness
  Red Flags: 1) The caller asks directly for an Active Directory/EHR password, which legitimate IT staff never need or ask for. 2) The caller creates a sudden "emergency" out of nowhere to rush the nurse. 3) The caller uses a vague internal reference ("billing server incident") to fabricate trust and authority.
  Technical Control: Enforce Multi-Factor Authentication (MFA) for the EHR system, ensuring that even if a password is stolen over the phone, the attacker cannot log in without the physical token.
  Administrative Control: Establish and communicate a definitive organizational policy stating that IT will never ask for passwords, and train staff to hang up and independently dial the official IT helpdesk number to verify callers.

Scenario 4:
  Vector Type: Smishing
  Target: All MedDefense employees - Vulnerable because parking is a universal, mundane administrative concern, and people generally trust SMS messages more than emails, reacting quickly to avoid personal inconvenience.
  Psychological Lever: Urgency
  Red Flags: 1) Receiving an administrative request via SMS rather than through official internal company email channels. 2) The threat of an immediate, punitive consequence (towing tomorrow). 3) The link provided points to an external or suspicious URL rather than the known internal HR intranet portal.
  Technical Control: Deploy Mobile Device Management (MDM) solutions on corporate phones with SMS phishing protection and web filtering to block access to known malicious domains.
  Administrative Control: Standardize internal communications by publishing a policy that MedDefense HR or facilities will never request AD credentials or send critical alerts via SMS links.

Scenario 5:
  Vector Type: Watering hole attack
  Target: MedDefense physicians - Vulnerable because they frequently visit this specific industry website for professional reasons (CME credits) and implicitly trust it to be safe.
  Psychological Lever: Familiarity
  Red Flags: 1) Unexpected browser redirects when navigating specific pages on the usually stable site. 2) Sudden browser security warnings or SSL certificate errors appearing on a trusted domain. 3) Unexplained system slowdowns or anomalous behavior immediately after visiting the association's website.
  Technical Control: Implement DNS sinkholing and enterprise web content filtering (e.g., Cisco Umbrella) to block malicious redirect IPs, coupled with Endpoint Detection and Response (EDR) to catch browser-based exploit executions.
  Administrative Control: Enforce an aggressive patch management policy to ensure that all clinical endpoints and web browsers are strictly updated to patch the vulnerabilities these drive-by downloads exploit.

Scenario 6:
  Vector Type: Typosquatting
  Target: MedDefense Patients and remote staff - Vulnerable because they rely on search engines rather than bookmarks to find the login portal and are unlikely to notice a regional spelling difference ("defence" vs "defense") in the URL.
  Psychological Lever: Familiarity
  Red Flags: 1) The incorrect British spelling ("defence") in the URL domain. 2) Discovering the portal via a "Sponsored" Google Ad at the top of search results rather than an organic, direct link. 3) Missing custom security warnings, incorrect SSL certificates, or lack of expected personalization on the landing page.
  Technical Control: Proactively register common typo domains (defensive registration) and utilize continuous brand monitoring services to issue rapid takedown requests to registrars and search engines.
  Administrative Control: Distribute educational materials to patients and staff strongly recommending they bookmark the exact, official portal URL and avoid using Google Search to navigate to login pages.

Scenario 7:
  Vector Type: Impersonation
  Target: MedDefense staff member - Vulnerable due to human politeness (holding the door for others) and the visual camouflage of the attacker (scrubs, stethoscope, hospital-branded cup) which creates a false sense of belonging.
  Psychological Lever: Helpfulness
  Red Flags: 1) The person does not have a visible, currently valid MedDefense ID badge. 2) The person provides an unverified, generic excuse ("badge is in my locker") to bypass security controls. 3) A person in clinical attire (scrubs) is attempting to access a highly restricted, non-clinical IT corridor.
  Technical Control: Install anti-tailgating physical security controls, such as mantraps or full-height turnstiles, that physically prevent more than one person from entering per badge swipe.
  Administrative Control: Implement and heavily enforce a "Challenge Policy" requiring all staff to actively confront and report anyone without a visible, valid badge in a restricted area, explicitly overriding social politeness.
