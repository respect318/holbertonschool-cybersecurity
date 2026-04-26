# Technical Vector Assessment: MedDefense

This report maps the technical (non-human) attack vectors identified within the MedDefense environment, utilizing evidence from the Project 1x00 network scan and posture assessment.

## 1. Vulnerable Software
* **Vector Category:** Vulnerable Software
* **MedDefense Evidence:** `billing-srv-01` running Apache 2.4.29 (known RCE vulnerabilities) and multiple systems on Ubuntu 18.04 LTS which has reached End-of-Life (EOL).
* **Affected Asset(s):** `billing-srv-01`, public-facing web servers, and Ubuntu-based application servers.
* **Actor Most Likely to Exploit:** Unskilled / Opportunistic Attacker.
* **Exploitation Scenario:** An attacker uses an automated scanner to identify the outdated Apache version on the billing server. They execute a known Remote Code Execution (RCE) exploit to gain a shell, which is then used to deploy a cryptocurrency miner or pivot further into the network.
* **Current Protection:** Basic perimeter firewall (FortiGate), but no active Web Application Firewall (WAF) or automated patch management.
* **Gap Reference:** GAP-01 (Unpatched public-facing services).

## 2. Unsupported Systems
* **Vector Category:** Unsupported Systems
* **MedDefense Evidence:** Windows XP running on the MRI Workstation (Radiology) and Windows Server 2012 R2 on `print-srv-01`.
* **Affected Asset(s):** MRI Scanner Workstation, `print-srv-01`.
* **Actor Most Likely to Exploit:** Ransomware Groups (Organized Crime) or Nation-State APT.
* **Exploitation Scenario:** Attackers target the Windows XP machine using legacy exploits like EternalBlue (MS17-010) that cannot be officially patched. Because the system is unsupported, it serves as a permanent, high-risk foothold for lateral movement.
* **Current Protection:** Physical isolation within the Radiology department (though network-connected).
* **Gap Reference:** GAP-02 (Presence of EOL/Unsupported legacy systems).

## 3. Open Service Ports
* **Vector Category:** Open Service Ports
* **MedDefense Evidence:** MySQL (Port 3306) on `billing-srv-01` and PostgreSQL (Port 5432) on `ehr-db-01` are accessible network-wide. Medical IoT (BD Alaris pumps) web interfaces are also exposed.
* **Affected Asset(s):** `ehr-db-01`, `billing-srv-01`, and clinical medical devices.
* **Actor Most Likely to Exploit:** Ransomware Groups (Organized Crime).
* **Exploitation Scenario:** After gaining access to a standard staff workstation, the attacker scans the internal network and finds the EHR database ports open. They attempt credential stuffing or exploit database misconfigurations to exfiltrate the patient database directly over the flat network.
* **Current Protection:** Password authentication on databases.
* **Gap Reference:** GAP-02 (Flat network architecture) and GAP-03 (Excessive open service ports).

## 4. Default Credentials
* **Vector Category:** Default Credentials
* **MedDefense Evidence:** Shared Radiology account (`raduser/radiology1`) and default vendor credentials on BD Alaris pump web interfaces.
* **Affected Asset(s):** PACS Workstation, Medical IoT devices (Infusion pumps).
* **Actor Most Likely to Exploit:** Insider (Malicious) or Insider (Negligent).
* **Exploitation Scenario:** A disgruntled employee or an external attacker who has moved laterally uses the well-known `raduser` credentials to log into the PACS system. They can then view or download sensitive medical imaging data without triggering any unique user-based alerts.
* **Current Protection:** None (Credentials are shared and documented).
* **Gap Reference:** GAP-05 (Lack of individual accountability / Shared credentials).

## 5. Unsecure Networks
* **Vector Category:** Unsecure Networks
* **MedDefense Evidence:** Completely flat internal network with no VLAN segmentation; use of a "Westside" consumer-grade router for specific segments.
* **Affected Asset(s):** Entire MedDefense network, including EHR and Billing servers.
* **Actor Most Likely to Exploit:** Ransomware Groups (Organized Crime).
* **Exploitation Scenario:** An affiliate gains a foothold via a phished nurse's laptop. Because there is no internal segmentation or "firebreaks," the attacker moves freely from the guest-accessible segment to the production server rack in minutes.
* **Current Protection:** Single FortiGate perimeter firewall.
* **Gap Reference:** GAP-02 (Flat network architecture / No segmentation).

## 6. Removable Devices / Unmanaged Endpoints
* **Vector Category:** Removable Devices / Unmanaged Endpoints
* **MedDefense Evidence:** No Group Policy Object (GPO) to restrict USB devices; unmanaged staff iPads; Dr. Patel’s unauthorized personal NAS (Shadow IT).
* **Affected Asset(s):** Clinical workstations, EHR data, and internal network bandwidth.
* **Actor Most Likely to Exploit:** Insider (Negligent).
* **Exploitation Scenario:** A staff member plugs in a personal, unencrypted USB drive to move patient records for "home work." The drive is either lost in a public area or contains malware that auto-runs upon being connected to a hospital workstation.
* **Current Protection:** None (USB ports are active and unrestricted).
* **Gap Reference:** GAP-08 (Unmanaged endpoints and lack of removable media controls).
