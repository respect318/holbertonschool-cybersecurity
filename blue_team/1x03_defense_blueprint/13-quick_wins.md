Quick Win #1: Disable Dormant Active Directory Accounts
Risk Addressed: RISK-002 (Complete Enterprise Breach via Compromised VPN)
Action: 
1. Run a PowerShell script against Active Directory to identify all user accounts that have not logged in for over 45 days.
2. Cross-reference the list with HR's recent termination/leave list.
3. Disable (do not delete) the identified dormant accounts.
Owner: IT Director (Sarah Park)
Timeline: 2 Days
Cost: $0 (Built-in Active Directory functionality)
Risk Reduction: Disrupts the Initial Access phase (Kill Chain #1 and #2) by eliminating unmonitored, inactive accounts that Initial Access Brokers frequently target for credential stuffing or brute-force attacks.
Verification: Export the list of disabled AD users and verify it against the HR roster to ensure no active employees were impacted.

Quick Win #2: Enforce Automatic Screen Locking via Group Policy
Risk Addressed: RISK-003 (ePHI Breach via Physical Device Theft / Unauthorized Access)
Action: 
1. Open the Group Policy Management Console.
2. Create or edit a global GPO enforcing the "Interactive logon: Machine inactivity limit" setting.
3. Set the limit to 5 minutes (300 seconds) and deploy it to all clinical and administrative workstation OUs.
Owner: IT Director (Sarah Park)
Timeline: 1 Day
Cost: $0 (Standard Windows GPO feature)
Risk Reduction: Disrupts the Execution and Data Exfiltration phases of an Insider Threat/Physical Access scenario by preventing opportunistic "walk-by" access to unlocked medical carts or laptops.
Verification: Manually observe 3 randomly selected clinical workstations and verify the screen automatically locks after exactly 5 minutes of inactivity.

Quick Win #3: Disable USB AutoPlay/Autorun Enterprise-Wide
Risk Addressed: RISK-004 (Widespread Malware Infection via Unpatched Software)
Action: 
1. Access the domain Group Policy management.
2. Navigate to Windows Components > AutoPlay Policies.
3. Enable "Turn off AutoPlay" for all drives.
4. Force GPUpdate across the domain.
Owner: IT Director (Sarah Park)
Timeline: 1 Day
Cost: $0 (Standard Windows GPO feature)
Risk Reduction: Disrupts the Initial Access and Execution phases of physically delivered malware (Kill Chain #3 / opportunistic botnets) by preventing malicious scripts on infected USB drives from executing automatically when plugged in.
Verification: Insert a benign test USB drive containing an autorun.inf file into a standard workstation; verify that the OS does not attempt to execute it or prompt the AutoPlay menu.

Quick Win #4: Maximize Existing DNS Filtering Categories
Risk Addressed: RISK-001 (Ransomware Encryption of EHR System)
Action: 
1. Log into the administrative console of the existing enterprise DNS filter or firewall (e.g., FortiGate).
2. Review the currently blocked categories.
3. Explicitly set "Newly Registered Domains," "Parked Domains," and "Command and Control" categories to BLOCK globally.
Owner: Security Analyst (You)
Timeline: 1 Day
Cost: $0 (Utilizing features already paid for in the existing firewall/DNS license)
Risk Reduction: Disrupts the Command and Control (C2) phase of a Ransomware Syndicate (Kill Chain #1) by preventing the ransomware payload from successfully reaching out to its infrastructure to exchange encryption keys.
Verification: Attempt to resolve a safely known test C2 domain (or a newly registered test domain) from a guest VLAN and verify the DNS request is actively sinkholed or blocked.

Quick Win #5: Force Password Resets for All Domain Admins
Risk Addressed: RISK-002 (Complete Enterprise Breach via Compromised VPN)
Action: 
1. Update the Active Directory Default Domain Policy to enforce a minimum 14-character password length.
2. Flag all accounts in the "Domain Admins" and "Enterprise Admins" groups to "User must change password at next logon."
3. Notify the administrative team of the immediate change.
Owner: Deputy CISO (James Chen)
Timeline: 3 Days (Allows time for staff communication and staggered resets)
Cost: $0 (Standard Active Directory administration)
Risk Reduction: Disrupts Privilege Escalation and Lateral Movement by instantly invalidating any previously compromised or leaked administrative credentials that an attacker might be hoarding.
Verification: Review the Active Directory user properties for all Admin accounts to confirm the "Password Last Set" timestamp is newer than the policy enforcement date.

---

### The Organizational Purpose of Quick Wins

Quick wins matter far beyond their immediate technical risk reduction because they establish the security team's credibility, competence, and operational momentum within the organization. During the first month of a security program, presenting a board with expensive 6-month projects can cause security fatigue; however, decisively closing obvious, critical gaps using zero-dollar, existing resources demonstrates fiscal responsibility and a proactive defense posture. This approach transforms the security narrative from "a cost center asking for money" into "an agile team delivering immediate business value," which generates the crucial executive trust and political capital required to successfully drive the larger, more complex architectural overhauls later in the roadmap.
