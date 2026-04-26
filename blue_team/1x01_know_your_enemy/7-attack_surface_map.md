# MedDefense Attack Surface Map

This document maps the various interaction points available to an adversary across the external, internal, and human dimensions of MedDefense.

## Section 1: External Surface
The external surface represents all entry points accessible from the public internet.

| Entry Point | Asset Behind It | Protection (1x00) | Documented Gap (1x00) |
| :--- | :--- | :--- | :--- |
| **Patient Portal** | `web-srv-01` | Basic Firewall / SSL | **GAP-01:** Unpatched web services. |
| **VPN Endpoints** | FortiGate 100F | Password Auth | **GAP-01:** Unpatched firmware vulnerabilities. |
| **Billing Server (Public)** | `billing-srv-01` | None (Exposed) | **GAP-01:** Apache 2.4.29 RCE vulnerability. |
| **Email Infrastructure** | Office 365 | Microsoft E3 Security | **Human Vector:** Susceptibility to Phishing/BEC. |
| **Public Website** | Web Host | External Hosting | **GAP-01:** Risk of defacement/watering hole. |
| **DNS Records** | Domain Registrar | Registrar Locks | **Typosquatting:** Risk of brand impersonation. |

## Section 2: Internal Surface
The internal surface represents the exposure available to an attacker once a foothold is established inside the network.

* **Network-Wide Database Access:**
    * **Asset:** `billing-srv-01` (MySQL - Port 3306)
    * **Asset:** `ehr-db-01` (PostgreSQL - Port 5432)
    * *Why it matters:* Due to the **Flat Network (GAP-02)**, these critical databases are reachable from any workstation or clinical device, allowing for easy lateral movement and unauthorized queries.
* **Management Interfaces:**
    * **Asset:** Backup NAS (Web Interface)
    * **Asset:** FortiGate Admin Console (HTTPS)
    * *Why it matters:* Insecure protocols and lack of isolation mean an attacker can directly target backup deletion (GAP-04) or firewall reconfiguration once inside.
* **Legacy Systems:**
    * **Asset:** Siemens MRI Workstation (Windows XP)
    * **Asset:** Legacy Servers (Windows Server 2012 R2)
    * *Why it matters:* These systems are EOL (End-of-Life) and susceptible to known exploits (e.g., EternalBlue) that cannot be patched.
* **Default Credentials & Shared Access:**
    * **Asset:** PACS Workstation (Radiology)
    * **Exposure:** Shared account `raduser/radiology1`.
    * *Why it matters:* **GAP-05 (Lack of Accountability)** allows an attacker to access medical imaging data without leaving a unique audit trail.

## Section 3: Human Surface
The human surface maps roles that can be manipulated or targeted via social engineering.

* **Clinical Staff (Doctors/Nurses):**
    * **Access:** High-level access to EHR and patient records.
    * **Targetability:** High stress and "helpful" culture make them prime targets for Vishing/Phishing.
    * **Gap:** **GAP-07 (Low Training Completion)** increases the risk of successful social engineering.
* **Reception / Front Desk:**
    * **Access:** Physical entry point and front-end EHR access.
    * **Targetability:** First contact for Vishing; susceptible to Smishing (parking alerts).
    * **Gap:** Direct interaction with the public creates a "soft" physical entry point.
* **IT Staff (James Chen):**
    * **Access:** Elevated administrative privileges (Domain Admin).
    * **Targetability:** Fatigue from being a one-person team makes him a target for BEC or technical pretexting.
    * **Gap:** Lack of automated monitoring (SIEM) increases reliance on manual, error-prone detection.
* **Executives (CEO/CFO):**
    * **Access:** Strategic data and financial authorization (Wire transfers).
    * **Targetability:** Targeted via "Whaling" or BEC due to high authority.
    * **Gap:** Inadequate out-of-band verification policies for large transactions.
* **External Contractors (MedTech Solutions):**
    * **Access:** Maintenance VPN access to EHR server.
    * **Targetability:** Beyond MedDefense's direct security control; high-value pivot point.
    * **Gap:** **GAP-06 (Manual Offboarding)** increases the risk of "ghost accounts."

## Surface Assessment Summary
The **Internal Surface** represents the greatest risk for MedDefense today. While the External and Human surfaces provide the initial entry points, the **Flat Network (GAP-02)** and the **lack of internal segmentation** mean that any single breach—whether through an unpatched VPN or a phished nurse—is immediately elevated to a total organizational compromise. In the current environment, there are no internal "firebreaks" to stop an attacker from pivoting from a low-security MRI workstation (Windows XP) directly to the core EHR database.
