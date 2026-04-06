# 0-environment_summary.md

## 1. Organization Overview

MedDefense Health Systems is a community healthcare provider operating across three distinct locations with approximately 2,000 total staff members.

### Identified Sites
* **MedDefense Central Hospital (Downtown):** A 350-bed acute care facility (6 floors + basement). Functions as the main hub for clinical departments including Emergency, Surgery, Cardiology, Radiology, Oncology, Pediatrics, Maternity, Pharmacy, Laboratory, and Administration. (Staff: ~1,400)
* **Westside Clinic (Suburban):** A 2-story outpatient facility providing primary care, diagnostic imaging (X-ray, ultrasound), blood work, minor procedures, and physical therapy. (Staff: ~180)
* **Corporate HQ (Greenfield Business Park):** Administrative offices located on the 3rd floor of a commercial building. Houses Finance, HR, Legal, Marketing, Executive Leadership, and the IT department. (Staff: ~220)

### Reporting Structure
* **Executive:** Dr. Patricia Morales (CEO) oversees the organization.
* **Security:** James Chen (Deputy CISO/Acting CISO) handles security policy and reports to the CEO.
* **IT Operations:** Sarah Park (IT Director) manages 11 staff members (3 SysAdmins, 2 Network Techs, 1 DBA, 2 Helpdesk, 2 Desktop Support).
* **Conflict:** James Chen and Sarah Park are peers; James lacks direct authority over the IT operations team, creating friction in security implementation.

---

## 2. IT Infrastructure Identified

### Server Inventory (Central Hospital)
| Server Name | OS / Technical Details | Function |
| :--- | :--- | :--- |
| **ehr-srv-01** | Ubuntu 20.04 LTS | EHR Application Server |
| **ehr-db-01** | Ubuntu 20.04 LTS (PostgreSQL) | EHR Database (Open to 10.10.0.0/16) |
| **pacs-srv-01** | Windows Server 2016 | PACS Imaging Server |
| **billing-srv-01** | Ubuntu 18.04 LTS | Billing/Claims Processing (Performance issues) |
| **ad-dc-01** | Windows Server 2019 | Primary Domain Controller |
| **ad-dc-02** | Windows Server 2019 | Secondary Domain Controller |
| **file-srv-01** | Windows Server 2016 | Department File Shares |
| **print-srv-01** | Windows Server 2012R2 | Print Server (Unverified/End of Life) |
| **backup-srv-01** | Ubuntu 22.04 LTS (Veeam) | Backup Server (Backs up to local NAS) |
| **web-srv-01** | Ubuntu 20.04 LTS | Public Website + Patient Portal (DMZ) |

### Server Inventory (Westside Clinic)
| Server Name | OS / Technical Details | Function |
| :--- | :--- | :--- |
| **ws-srv-01** | Windows Server 2016 | Local file server + scheduling |
| **[Unconfirmed]** | Unknown | Rumored second server in the clinic closet |

### Network & Endpoints
* **Networking:** Fortinet FortiGate 100F (Central Firewall), Cisco core/access switches, Ubiquiti UniFi APs. Westside uses a consumer-grade Netgear Nighthawk router for site-to-site VPN.
* **Endpoints:** Approximately 485 Windows 10/11 workstations, 60 thin clients, 30 laptops (HQ), and 25 physician iPads.
* **Medical IoT:** Siemens MAGNETOM MRI (Critical: Runs **Windows XP**), GE Revolution CT Scanner, 80 Philips patient monitors, 120 BD Alaris infusion pumps (network-connected).

---

## 3. Data and Services

### Data Types Managed
* **PHI/ePHI:** Patient medical records, lab results, and diagnostic imaging (EHR/PACS).
* **PII:** Employee HR files and patient identification data.
* **Financial:** Billing, insurance claims, and corporate financial data.

### Critical IT Services
* **Clinical Operations:** Access to patient health records and medical imaging (EHR/PACS).
* **Patient Safety:** Networked medical devices (Infusion pumps, monitors).
* **Business Continuity:** Office 365 services and site-to-site VPN connectivity.

---

## 4. Known Unknowns

### Information Gaps
* **Inventory Accuracy:** The Active Directory endpoint report is 8 months old; physical verification of the Westside server and `print-srv-01` is missing.
* **IoT Specifications:** The Operating System of the GE CT Scanner is unknown.
* **Endpoint Security:** The current installation and update status of Sophos AV across all 500+ endpoints is unverified.
* **Cloud Usage:** Potential "Shadow IT" (unauthorized cloud services) outside of O365 has not been audited.

### Ambiguities & Contradictions
* **Network Isolation:** The actual level of isolation for the Guest WiFi at Central and the VLANs at HQ is unverified.
* **Compliance Gap:** Legal claims HIPAA compliance, but the existence of Windows XP and flat network topology suggests otherwise.
* **Physical Security:** No surveillance cameras in the Central server room corridor; Westside server closet is reported to be unlocked.
