# MITRE ATT&CK Mapping: MedDefense Attack Scenarios

This report maps observed attack behaviors at MedDefense to the MITRE ATT&CK framework, identifying the tactics and techniques used by both external and internal adversaries.

---

## Scenario Alpha: "Operation Flatline" -- Ransomware Campaign

**Step 1:** Affiliate purchases access list from an initial access broker.
* **Tactic:** Resource Development
* **Technique:** Acquire Infrastructure: Access (T1583.006)
* **MedDefense Factor:** Public-facing Fortinet VPN management interface exposed and cataloged by internet-wide scanners.

**Step 2:** Spear phishing email with malicious document sent to Sarah Park.
* **Tactic:** Initial Access / Execution
* **Technique:** Phishing: Spearphishing Link (T1566.002) and Command and Scripting Interpreter: PowerShell (T1059.001)
* **MedDefense Factor:** Lack of email filtering and high-level targets (IT Director) lacking strictly restricted execution environments.

**Step 3:** Reverse shell connects to C2 and establishes a persistent scheduled task.
* **Tactic:** Command and Control / Persistence
* **Technique:** Application Layer Protocol: Web Protocols (T1071.001) and Scheduled Task/Job: Scheduled Task (T1053.005)
* **MedDefense Factor:** No outbound traffic monitoring (SIEM/IDS gap) and GPO settings that allow local scheduled task creation.

**Step 4:** Network discovery commands run to map the flat network.
* **Tactic:** Discovery
* **Technique:** Network Service Discovery (T1046) and Remote System Discovery (T1018)
* **MedDefense Factor:** **Flat Network (GAP-02)** allows visibility across all clinical and administrative subnets from a single workstation.

**Step 5:** Mimikatz used to dump cached credentials from memory.
* **Tactic:** Credential Access
* **Technique:** OS Credential Dumping: LSASS Memory (T1003.001)
* **MedDefense Factor:** Sarah’s account has local admin rights; a Domain Admin account (`svc_backup`) was used on a non-hardened workstation.

**Step 6:** Pass-the-hash attack to authenticate to the Domain Controller.
* **Tactic:** Lateral Movement
* **Technique:** Use Alternate Authentication Material: Pass the Hash (T1550.002)
* **MedDefense Factor:** Active Directory lacks Multi-Factor Authentication (MFA) and internal segmentation to block direct DC access.

**Step 7:** Data exfiltration from EHR database via Rclone.
* **Tactic:** Collection / Exfiltration
* **Technique:** Data from Information Repositories (T1213) and Exfiltration Over Web Service: Exfiltration to Cloud Storage (T1567.002)
* **MedDefense Factor:** EHR database open network-wide (GAP-03) and no egress filtering to block unauthorized cloud sync tools.

**Step 8:** Deletion of backups and Volume Shadow Copies.
* **Tactic:** Impact
* **Technique:** Inhibit System Recovery (T1490)
* **MedDefense Factor:** Backups reside on the same network and use the same compromised credentials (GAP-04).

**Step 9:** Ransomware deployment via GPO.
* **Tactic:** Impact
* **Technique:** Data Encrypted for Impact (T1486) and Domain Policy Modification: Group Policy Modification (T1484.001)
* **MedDefense Factor:** Domain Admin compromise provides total, unhindered control over all Windows endpoints.

---

## Scenario Beta: "The Quiet Departure" -- Insider Data Theft

**Step 1:** Employee decides to steal records before layoff (Pre-tactic).
* **Tactic:** Reconnaissance / Resource Development (Insider Context)
* **Technique:** Not applicable as a technical technique, but represents Insider Threat Precursor.

**Step 2:** Assessing access levels in billing and EHR.
* **Tactic:** Discovery
* **Technique:** Permission Groups Discovery: Local Groups (T1069.001)
* **MedDefense Factor:** Excessive read access granted without "Least Privilege" reviews (GAP-05).

**Step 3:** Exporting patient records to CSV via EHR built-in function.
* **Tactic:** Collection
* **Technique:** Data from Information Repositories (T1213)
* **MedDefense Factor:** No rate-limiting or behavioral alerting on high-volume EHR exports (GAP-03).

**Step 4:** Transferring files to a personal USB drive.
* **Tactic:** Exfiltration
* **Technique:** Exfiltration Over Physical Medium: Exfiltration Over USB (T1052.001)
* **MedDefense Factor:** No USB/Removable Media restrictions enforced via GPO (GAP-08).

**Step 5:** Deleting files and emptying recycle bin to cover tracks.
* **Tactic:** Defense Evasion
* **Technique:** Indicator Removal: File Deletion (T1070.004)
* **MedDefense Factor:** Lack of real-time file integrity monitoring or proactive log review.

**Step 6:** Copying database configuration file with plaintext credentials.
* **Tactic:** Credential Access
* **Technique:** Credentials from Password Stores: Credentials from Files (T1552.001)
* **MedDefense Factor:** Insecure storage of administrative credentials in plaintext configuration files.

**Step 7:** Termination occurs but account remains active.
* **Tactic:** Persistence
* **Technique:** Valid Accounts: Local Accounts (T1078.003)
* **MedDefense Factor:** Manual offboarding process and lack of HR-to-IT integration (GAP-06).

**Step 8:** VPN access from home and direct database extraction.
* **Tactic:** Initial Access / Exfiltration
* **Technique:** External Remote Services (T1133) and Exfiltration Over C2 Channel (T1041)
* **MedDefense Factor:** No MFA on VPN and failure to revoke access for terminated employees.

---

## ATT&CK Coverage Assessment

Analyzing both scenarios reveals that **Initial Access**, **Discovery**, **Credential Access**, and **Exfiltration** are the core tactics appearing in both external and internal attacks. This consistency highlights that MedDefense is equally vulnerable to both a professional ransomware group and a low-skill employee because the fundamental controls—specifically **Multi-Factor Authentication (MFA)** and **Behavioral Monitoring**—are missing across all vectors. To reduce risk most urgently, MedDefense must implement detection for the "Initial Access" tactic (MFA logs) and "Exfiltration" tactic (DLP/USB blocking), as these are the points where both attacks could have been most easily interrupted.
