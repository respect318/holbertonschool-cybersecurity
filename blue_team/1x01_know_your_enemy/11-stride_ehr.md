# STRIDE Threat Model: MedDefense EHR System

This report provides a systematic threat analysis of the MedDefense Electronic Health Record (EHR) system, including `ehr-srv-01`, `ehr-db-01`, and the associated clinical workstations and network paths.

---

## 1. Spoofing (S)

**Threat ID:** EHR-S1
* **Description:** An attacker sends a spear-phishing email to a doctor, harvesting their Active Directory credentials to log into the EHR portal as a legitimate provider.
* **Attack Vector:** Phishing / Spear Phishing.
* **Impact:** Unauthorized access to sensitive patient files and the ability to issue orders under the doctor's identity.
* **Existing Control:** Password complexity requirements.
* **Gap:** GAP-01 (Lack of Multi-Factor Authentication on internal/external portals).

**Threat ID:** EHR-S2
* **Description:** An attacker uses ARP spoofing on the flat network to impersonate `ehr-srv-01`, intercepting traffic between clinical workstations and the application server.
* **Attack Vector:** Unsecure Networks (Flat network/no segmentation).
* **Impact:** Interception of clinician session tokens and patient data in transit.
* **Existing Control:** None.
* **Gap:** GAP-02 (Flat network architecture with no internal "firebreaks").

---

## 2. Tampering (T)

**Threat ID:** EHR-T1
* **Description:** An attacker gains access to `ehr-db-01` and modifies a patient's allergy records or blood type information.
* **Attack Vector:** Vulnerable Software Exploit / Default Credentials.
* **Impact:** Life-safety risk; clinicians may administer incompatible medication or treatments based on falsified data.
* **Existing Control:** Database user permissions.
* **Gap:** GAP-03 (Excessive open service ports and lack of database activity monitoring).

**Threat ID:** EHR-T2
* **Description:** A malicious actor modifies the application logs or configuration files on `ehr-srv-01` to disable security alerts or change system behavior.
* **Attack Vector:** Insider (Malicious).
* **Impact:** System instability and the masking of unauthorized activities.
* **Existing Control:** Restricted physical access to the server room.
* **Gap:** GAP-06 (Manual/Delayed offboarding of administrative accounts).

---

## 3. Repudiation (R)

**Threat ID:** EHR-R1
* **Description:** A clinician accesses a high-profile patient's record out of curiosity and later denies the action.
* **Attack Vector:** Default / Shared Credentials (PACS/Radiology).
* **Impact:** Failure of clinical accountability and inability to prove HIPAA violations during an audit.
* **Existing Control:** EHR access logs (standard).
* **Gap:** GAP-05 (Lack of individual accountability due to shared accounts like `raduser`).

**Threat ID:** EHR-R2
* **Description:** A system administrator deletes the SQL transaction logs on `ehr-db-01` after performing unauthorized data exports.
* **Attack Vector:** Insider (Malicious).
* **Impact:** Inability to conduct a forensic investigation or reconstruct the timeline of a data breach.
* **Existing Control:** Basic log retention.
* **Gap:** GAP-03 (No centralized, immutable logging or SIEM).

---

## 4. Information Disclosure (I)

**Threat ID:** EHR-I1
* **Description:** Patient records are exfiltrated via the MedTech Solutions maintenance VPN after their corporate network is compromised.
* **Attack Vector:** Supply Chain Compromise.
* **Impact:** Massive data breach of Protected Health Information (PHI) leading to regulatory fines and loss of trust.
* **Existing Control:** Vendor contract/SLA.
* **Gap:** GAP-03 (No behavioral monitoring of third-party remote access).

**Threat ID:** EHR-I2
* **Description:** A nurse copies "convenience" files of patient data to an unencrypted personal NAS or USB drive.
* **Attack Vector:** Removable Devices / Unmanaged Endpoints.
* **Impact:** Data breach if the device is lost, stolen, or infected with malware.
* **Existing Control:** None.
* **Gap:** GAP-08 (Lack of USB/Removable media restrictions via GPO).

---

## 5. Denial of Service (D)

**Threat ID:** EHR-D1
* **Description:** Ransomware encrypts the `ehr-db-01` database and the connected Backup NAS.
* **Attack Vector:** Vulnerable Software Exploit / Phishing.
* **Impact:** Total loss of access to patient history, forcing ambulance diversions and halting all clinical operations.
* **Existing Control:** Periodic backups (NAS-based).
* **Gap:** GAP-04 (Backups are not isolated/air-gapped and are reachable on the flat network).

**Threat ID:** EHR-D2
* **Description:** A compromised medical IoT device on the flat network is used to flood `ehr-srv-01` with traffic (Internal DoS).
* **Attack Vector:** Unsecure Networks (Flat network).
* **Impact:** EHR application becomes unresponsive, preventing doctors from entering critical vitals or treatment updates.
* **Existing Control:** Perimeter firewall (not effective against internal traffic).
* **Gap:** GAP-02 (No internal network segmentation).

---

## 6. Elevation of Privilege (E)

**Threat ID:** EHR-E1
* **Description:** A billing clerk uses a local privilege escalation exploit on a shared workstation to gain local admin rights and dump the LSASS memory for Domain Admin credentials.
* **Attack Vector:** Vulnerable Software Exploit / Unsupported Systems.
* **Impact:** The attacker gains "keys to the kingdom," allowing full control over Active Directory and all connected assets.
* **Existing Control:** Standard user permissions.
* **Gap:** GAP-02 (Use of EOL systems like Windows XP which are easily exploited for escalation).

**Threat ID:** EHR-E2
* **Description:** An attacker exploits a vulnerability in the EHR application code to bypass role-based access controls (RBAC) and gain database administrator rights.
* **Attack Vector:** Vulnerable Software Exploit.
* **Impact:** Full, unrestricted access to modify or delete the entire EHR database.
* **Existing Control:** Basic RBAC configuration.
* **Gap:** GAP-01 (Unpatched/Outdated application server software).

---

## STRIDE Summary for EHR
The STRIDE category representing the greatest risk to the MedDefense EHR system is **Tampering (T)**. While Denial of Service (Ransomware) is a massive operational threat, **Tampering** is particularly dangerous in a healthcare context because it directly compromises patient safety through the "silent" corruption of data. If an attacker modifies a patient’s blood type, allergy list, or medication dosage within `ehr-db-01`, a clinician may unknowingly administer a fatal treatment. Because MedDefense lacks internal network segmentation (**GAP-02**) and behavioral monitoring (**GAP-03**), such modifications could remain undetected for months, leading to catastrophic clinical outcomes and permanent loss of life-safety integrity.
