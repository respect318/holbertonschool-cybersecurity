# MedDefense Kill Chain Analysis

This document outlines the five most critical attack sequences targeting MedDefense, identifying key intervention points (break points) to interrupt the adversary's progress.

---

## Kill Chain #1: Ransomware Double Extortion (The BlackReef Playbook)
* **Threat Actor:** Organized Crime (BlackReef)
* **Target Asset:** EHR Database (`ehr-db-01`)
* **Expected Impact:** Total operational paralysis and massive data breach. (Availability & Confidentiality)

* **Step 1 - Initial Access:**
    * **Vector:** Phishing
    * **Surface:** Human
    * **Detail:** A clinician clicks a link in a well-crafted email, leading to a credential-harvesting site that captures their Active Directory (AD) login.
* **Step 2 - Establish Foothold:**
    * **Action:** Attacker uses harvested credentials to log into the MedDefense VPN.
    * **MedDefense Weakness:** Lack of Multi-Factor Authentication (MFA) on the VPN.
* **Step 3 - Lateral Movement / Escalation:**
    * **Action:** Attacker scans the network, identifies the EHR database, and uses BloodHound to find a path to Domain Admin.
    * **MedDefense Weakness:** **Flat Network (GAP-02)** allows unrestricted movement from the VPN segment to the server rack.
* **Step 4 - Objective Execution:**
    * **Action:** Attacker exfiltrates 40GB of patient data and deploys ransomware via a Group Policy Object (GPO).
    * **Data/System Affected:** EHR Database and all connected Windows workstations.
* **Step 5 - Impact:**
    * **Business Impact:** 18-day average hospital downtime, ambulance diversions, and multi-million dollar regulatory fines.
    * **CIA Pillars:** **Availability** (Systems encrypted) and **Confidentiality** (Data exfiltrated).

**Gaps Exploited:** GAP-01, GAP-02, GAP-04.
**Break Points:**
1. **Step 2:** Implementation of **MFA** would have prevented the attacker from using stolen credentials to enter the network.
2. **Step 3:** **Network Segmentation** would have contained the attacker in a restricted VLAN, preventing access to the EHR database.

---

## Kill Chain #2: The Trusted Maintenance Pivot (Supply Chain)
* **Threat Actor:** Nation-State APT or Sophisticated Crime Group
* **Target Asset:** EHR Database (`ehr-db-01`)
* **Expected Impact:** Silent, long-term theft of patient medical records. (Confidentiality)

* **Step 1 - Initial Access:**
    * **Vector:** Supply Chain Compromise
    * **Surface:** External
    * **Detail:** Attackers breach MedTech Solutions and steal the VPN credentials used for MedDefense EHR maintenance.
* **Step 2 - Establish Foothold:**
    * **Action:** Attacker logs in via MedTech's persistent maintenance VPN tunnel.
    * **MedDefense Weakness:** Inadequate monitoring of third-party vendor access.
* **Step 3 - Lateral Movement / Escalation:**
    * **Action:** Attacker uses "legitimate" maintenance privileges to access the EHR database directly.
    * **MedDefense Weakness:** Excessive privileges granted to the maintenance account.
* **Step 4 - Objective Execution:**
    * **Action:** Attacker slowly copies patient records over several months using encrypted channels.
    * **Data/System Affected:** EHR Patient Records.
* **Step 5 - Impact:**
    * **Business Impact:** Reputational damage and massive HIPAA notification costs once the breach is discovered.
    * **CIA Pillars:** **Confidentiality** (Medical records stolen).

**Gaps Exploited:** GAP-06 (Manual/Delayed offboarding), GAP-03 (No behavioral monitoring).
**Break Points:**
1. **Step 2:** **Just-in-Time (JIT) Access** controls would ensure the VPN is only active during scheduled maintenance windows.
2. **Step 5:** **SIEM/EDR Monitoring** would have alerted IT to anomalous data transfer volumes from the EHR server.

---

## Kill Chain #3: Opportunistic Public Exploit (The Crypto-miner)
* **Threat Actor:** Unskilled / Opportunistic Attacker
* **Target Asset:** Billing Server (`billing-srv-01`)
* **Expected Impact:** Resource theft and potential entry point for secondary attacks. (Integrity/Availability)

* **Step 1 - Initial Access:**
    * **Vector:** Vulnerable Software Exploit
    * **Surface:** External
    * **Detail:** Automated bots scan for the known Apache 2.4.29 RCE vulnerability on the public-facing billing server.
* **Step 2 - Establish Foothold:**
    * **Action:** Attacker executes a shell script to install a persistent Monero miner.
    * **MedDefense Weakness:** **GAP-01** (Unpatched public-facing services).
* **Step 3 - Lateral Movement / Escalation:**
    * **Action:** Attacker attempts to brute-force the local MySQL database on the same server.
    * **MedDefense Weakness:** Flat network architecture allows the server to attempt connections to internal assets.
* **Step 4 - Objective Execution:**
    * **Action:** The server CPU remains at 100% usage, slowing down billing operations.
    * **Data/System Affected:** Billing system performance and integrity.
* **Step 5 - Impact:**
    * **Business Impact:** System instability, increased electricity/cloud costs, and evidence of a compromised perimeter.
    * **CIA Pillars:** **Integrity** (System configuration modified) and **Availability** (Reduced performance).

**Gaps Exploited:** GAP-01.
**Break Points:**
1. **Step 1:** **Vulnerability Management** (Patching Apache) would have removed the entry point.
2. **Step 2:** **Endpoint Detection and Response (EDR)** would have detected and blocked the execution of the unauthorized mining script.

---

## Kill Chain #4: The Terminated Admin's Revenge
* **Threat Actor:** Insider (Malicious)
* **Target Asset:** Active Directory & Backup NAS
* **Expected Impact:** Permanent data destruction and organization-wide lockout. (Availability)

* **Step 1 - Initial Access:**
    * **Vector:** Default / Shared Credentials (Ghost Account)
    * **Surface:** Internal
    * **Detail:** A disgruntled admin creates a "ghost" VPN account before their termination hearing.
* **Step 2 - Establish Foothold:**
    * **Action:** Two days post-termination, the admin logs in using the hidden account from their home IP.
    * **MedDefense Weakness:** **GAP-06** (Lack of automated offboarding and account auditing).
* **Step 3 - Lateral Movement / Escalation:**
    * **Action:** Attacker uses Domain Admin rights to access the production database and the Backup NAS.
    * **MedDefense Weakness:** Flat network and shared administrative access.
* **Step 4 - Objective Execution:**
    * **Action:** Attacker deletes all production database tables and formats the Backup NAS.
    * **Data/System Affected:** Entire claims database and all organizational backups.
* **Step 5 - Impact:**
    * **Business Impact:** Permanent loss of financial records, inability to process claims, and high likelihood of business closure.
    * **CIA Pillars:** **Availability** (Data destroyed).

**Gaps Exploited:** GAP-06, GAP-04.
**Break Points:**
1. **Step 2:** **Automated Offboarding** would have disabled all accounts linked to the identity the moment HR triggered the termination.
2. **Step 3:** **Immutable Backups** or an isolated backup vault would have prevented the admin from deleting the secondary data copies.

---

## Kill Chain #5: The "Helpful" Shadow IT Bridge
* **Threat Actor:** Negligent Insider (leveraged by an External Attacker)
* **Target Asset:** Medical IoT (Infusion Pumps)
* **Expected Impact:** Direct threat to patient safety through device malfunction. (Integrity/Availability)

* **Step 1 - Initial Access:**
    * **Vector:** Unsecured Networks / Removable Devices
    * **Surface:** Internal
    * **Detail:** A nurse connects a personal Raspberry Pi to the medical network to "monitor performance," inadvertently exposing it to the internet.
* **Step 2 - Establish Foothold:**
    * **Action:** An external attacker finds the Pi via Shodan and logs in using default credentials (`pi/raspberry`).
    * **MedDefense Weakness:** **GAP-08** (Unmanaged endpoints and Shadow IT).
* **Step 3 - Lateral Movement / Escalation:**
    * **Action:** Attacker pivots from the Pi to scan the medical device network for Alaris pumps.
    * **MedDefense Weakness:** **Flat Network (GAP-02)** connects clinical devices directly to the general staff network.
* **Step 4 - Objective Execution:**
    * **Action:** Attacker accesses the web interface of an infusion pump using default vendor credentials.
    * **Data/System Affected:** Medical IoT device configuration.
* **Step 5 - Impact:**
    * **Business Impact:** Life-safety risk, severe legal liability, and loss of public trust.
    * **CIA Pillars:** **Integrity** (Device settings changed) and **Availability** (Device rendered unusable).

**Gaps Exploited:** GAP-02, GAP-08, GAP-05 (Default credentials).
**Break Points:**
1. **Step 1:** **Network Access Control (NAC)** would have blocked the unauthorized Raspberry Pi from connecting to the network.
2. **Step 3:** **Micro-segmentation** would have isolated medical IoT devices from the rest of the hospital network.
