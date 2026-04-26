# MedDefense Threat Scenarios

This document presents three comprehensive and realistic threat scenarios tailored to the MedDefense environment, demonstrating the operational consequences of existing security gaps.

---

## Scenario 1: External - The BlackReef Ransomware Campaign
* **Title:** Operation Critical Care
* **Threat Actor:** Organized Crime / RaaS Group (BlackReef - Profile Reference T2/T6)
* **Motivation:** Financial Gain
* **Initial Vector:** VPN Exploit (T4/T8)
* **Attack Surface Exploited:** External (FortiGate VPN Endpoint)

### Attack Sequence:
* **Step 1:** Attacker exploits an unpatched CVE in the FortiGate 100F VPN appliance to gain remote code execution. (**Initial Access**)
* **Step 2:** Attacker deploys a reverse shell and creates a hidden local account for persistence. (**Persistence**)
* **Step 3:** Attacker scans the internal network, discovering the EHR and Billing servers reachable from the VPN segment. (**Discovery**)
* **Step 4:** Using a privilege escalation exploit on the flat network, the attacker captures Domain Admin credentials from the Domain Controller. (**Privilege Escalation**)
* **Step 5:** Attacker exfiltrates 50GB of EHR patient data to a cloud storage account via Rclone. (**Exfiltration**)
* **Step 6:** Attacker deletes all online backups on the network-accessible NAS and deploys ransomware organization-wide. (**Impact**)

* **STRIDE Categories Triggered:** Denial of Service (D), Information Disclosure (I), Elevation of Privilege (E).
* **MedDefense Assets Impacted:** EHR Database, Billing Server, Backup NAS, Clinical Workstations.
* **Business Impact:** Total cessation of clinical operations, ambulance diversions, $2M+ ransom demand, and severe HIPAA regulatory penalties.
* **Gaps Exploited:** * **GAP-01:** Unpatched VPN firmware provided the initial entry point.
    * **GAP-02:** Flat network enabled unrestricted lateral movement.
    * **GAP-04:** Non-isolated backups allowed the attacker to destroy the organization's recovery capability.
* **Detection Opportunities:** * **Step 1:** Could be detected by an Intrusion Detection System (IDS) monitoring for exploit signatures.
    * **Step 5:** Could be detected by Data Loss Prevention (DLP) or egress traffic monitoring for high-volume cloud transfers.

---

## Scenario 2: Internal - The Disgruntled Administrator
* **Title:** The Ghost in the Server Room
* **Threat Actor:** Malicious Insider (Terminated Admin - Profile Reference T3/T6)
* **Motivation:** Revenge / Sabotage
* **Initial Vector:** Legitimate Access Abused (Ghost Account)
* **Attack Surface Exploited:** Internal (Active Directory / VPN)

### Attack Sequence:
* **Step 1:** Before his termination hearing, an IT admin creates a secondary "emergency" VPN account not linked to his identity. (**Persistence**)
* **Step 2:** Three days after termination, he logs in from home via the ghost VPN account. (**Initial Access**)
* **Step 3:** He uses his existing knowledge of the flat network to reach the primary Billing and EHR databases. (**Discovery**)
* **Step 4:** He executes a script to drop (delete) all production database tables containing claims and patient records. (**Impact**)
* **Step 5:** He formats the Backup NAS and clears system logs to prevent forensic reconstruction. (**Defense Evasion**)

* **STRIDE Categories Triggered:** Tampering (T), Repudiation (R), Denial of Service (D).
* **MedDefense Assets Impacted:** Billing Server, EHR Database, Backup NAS, Active Directory.
* **Business Impact:** Permanent loss of critical financial records, inability to process medical claims, and potential business closure due to data loss.
* **Gaps Exploited:**
    * **GAP-06:** Manual and delayed offboarding allowed the ghost account to remain active.
    * **GAP-05:** Shared administrative practices prevented immediate attribution.
    * **GAP-04:** Lack of immutable or offsite backups made the data deletion permanent.
* **Detection Opportunities:**
    * **Step 2:** Could be detected by an Identity and Access Management (IAM) audit identifying unauthorized VPN usage from a terminated employee's IP.
    * **Step 4:** Could be detected by real-time Database Activity Monitoring (DAM) alerting on mass "DROP TABLE" commands.

---

## Scenario 3: Third Party - The Maintenance Bridge
* **Title:** The Trusted Vendor Pivot
* **Threat Actor:** External Attacker using a vendor as a stepping stone (MedTech Solutions - Reference T5/T6)
* **Motivation:** Espionage / Financial Gain
* **Initial Vector:** Vendor Access Pathway (Maintenance VPN)
* **Attack Surface Exploited:** External / Human (Vendor Supply Chain)

### Attack Sequence:
* **Step 1:** Attackers compromise MedTech Solutions' internal network and steal the remote maintenance certificate for MedDefense. (**Resource Development**)
* **Step 2:** Attacker uses the stolen certificate to log into the MedDefense EHR server via the persistent maintenance VPN. (**Initial Access**)
* **Step 3:** Attacker executes "living off the land" techniques to browse the file system for sensitive configuration files. (**Discovery**)
* **Step 4:** Attacker uses database credentials found in a plaintext config file to access the PostgreSQL EHR database. (**Credential Access**)
* **Step 5:** Attacker slowly exfiltrates 200 patient records per day over a period of 4 months to avoid triggering bandwidth alerts. (**Collection / Exfiltration**)

* **STRIDE Categories Triggered:** Information Disclosure (I), Spoofing (S), Elevation of Privilege (E).
* **MedDefense Assets Impacted:** EHR Database (ehr-db-01), EHR Application Server (ehr-srv-01).
* **Business Impact:** Massive undetected data breach of 24,000+ records, long-term legal liability, and catastrophic loss of patient trust once disclosed.
* **Gaps Exploited:**
    * **GAP-03:** Lack of behavioral monitoring allowed the "slow and low" exfiltration to go unnoticed.
    * **GAP-01:** Unpatched/Outdated application software enabled the credential harvest.
    * **GAP-06:** Insecure storage of administrative credentials in plaintext.
* **Detection Opportunities:**
    * **Step 2:** Could be detected by anomaly detection alerting on vendor VPN logins outside of scheduled maintenance windows.
    * **Step 5:** Could be detected by an EHR-specific behavioral auditing tool identifying unusual record access patterns.
