Scenario 1:
  Classification: Negligent - The use of a shared account is driven by a desire for operational convenience to speed up clinical workflows, completely lacking any deliberate intent to harm the organization or steal data.
  Behavioral Indicators: 1) Multiple concurrent logins originating from the same account across different physical workstations. 2) Unusually long session durations with no logout events for an entire shift. 3) A disproportionately high volume of disparate patient records accessed by a single account in one day.
  Existing Control (from 1x00): Identity and Access Management (IAM) / Access Control Policy.
  Gap Exploited (from 1x00): Lack of individual accountability and reliance on shared credentials (the radiology shared account vulnerability).
  Recommended Mitigation: Technical - Implement "Tap and Go" proximity badge readers combined with Single Sign-On (SSO) to allow rapid, secure logins tied strictly to individual user identities.

Scenario 2:
  Classification: Malicious - Authenticating via a ghost account weeks after contract termination, specifically during unusual off-hours (e.g., 2 AM), strongly indicates a deliberate intent to exploit unauthorized access for nefarious purposes.
  Behavioral Indicators: 1) VPN authentication originating from an account belonging to a terminated contractor. 2) Network login activity occurring strictly during abnormal, non-business hours.
  Existing Control (from 1x00): Offboarding Procedure / Identity Lifecycle Management.
  Gap Exploited (from 1x00): Lack of automated offboarding.
  Recommended Mitigation: Administrative - Implement a formalized, automated offboarding process where an HR termination update immediately and automatically disables Active Directory and VPN access.

Scenario 3:
  Classification: Negligent - Dr. Patel is motivated purely by efficiency and making his daily work easier ("convenience copies"). He has no malicious intent to expose the hospital's data, just a severe lack of security awareness.
  Behavioral Indicators: 1) An unrecognized MAC address or unknown device footprint appearing on the internal network. 2) Large, anomalous data transfers originating from the EHR database targeting a local IP address in the Cardiology department.
  Existing Control (from 1x00): Asset Management / Hardware Inventory.
  Gap Exploited (from 1x00): Shadow IT and the absence of a segmented flat network.
  Recommended Mitigation: Technical - Deploy Network Access Control (NAC) requiring 802.1X certificate-based authentication to prevent unapproved hardware from communicating on the network.

Scenario 4:
  Classification: Malicious - Despite not modifying data, curiosity-driven unauthorized access (VIP snooping) is a deliberate, knowing violation of HIPAA privacy rules without any legitimate clinical justification.
  Behavioral Indicators: 1) Accessing the medical record of a high-profile patient who is not currently under the clerk's assigned care or department. 2) EHR access patterns that significantly deviate from the clerk's normal daily workflow.
  Existing Control (from 1x00): Role-Based Access Control (RBAC) / Privacy Policy.
  Gap Exploited (from 1x00): Lack of behavioral monitoring combined with excessively broad clinical access.
  Recommended Mitigation: Technical - Implement an EHR behavioral auditing tool configured to trigger immediate alerts whenever VIP records or files completely outside an employee's typical scope are accessed.

Scenario 5:
  Classification: Negligent - The sysadmin is simply trying to manage an overwhelming workload and assist a colleague. This action demonstrates terrible security hygiene, but there is no malicious intent to sabotage the network.
  Behavioral Indicators: 1) The creation of plaintext files containing keywords like "password" or "admin" on a local desktop. 2) The transmission of scripts containing sensitive credential strings via the internal email system.
  Existing Control (from 1x00): Secure Configuration Management / Security Awareness Training.
  Gap Exploited (from 1x00): Lack of Data Loss Prevention (DLP) controls and inadequate privileged credential management.
  Recommended Mitigation: Technical - Deploy a Privileged Access Management (PAM) vault to manage and inject administrative credentials securely, replacing the need for hardcoded scripts.

Pattern Assessment:
The systemic weakness making insider threats particularly dangerous at MedDefense is the organization's heavy reliance on inherent trust combined with a complete absence of automated technical enforcement and continuous monitoring. Because clinical workflows demand broad and rapid access to patient data, MedDefense treats identity simply as an initial perimeter rather than continuously verifying behavior. As identified in Project 1x00, the "lack of automated offboarding" allows ghost accounts to linger indefinitely, while the "lack of behavioral monitoring and DLP" means employees can freely hoard data on unauthorized devices (Shadow IT) or share credentials without triggering any alarms. Until MedDefense shifts from static access controls to behavioral visibility, both negligent and malicious insiders will continue to operate completely undetected.
