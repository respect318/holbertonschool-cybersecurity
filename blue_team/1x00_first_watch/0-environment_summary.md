# 0-environment_summary.md

## 1. Organization Overview

MedDefense Health Systems operates across three distinct locations with a total staff of approximately 2,000.

### Sites and Functions
| Site Name | Location Type | Function & Departments | Headcount |
| :--- | :--- | :--- | :--- |
| **Central Hospital** | Downtown (6 floors + basement) | **350-bed acute care facility.** Departments: Emergency, Surgery, Cardiology, Radiology, Oncology, Pediatrics, Maternity, Pharmacy, Laboratory, Administration. | ~1,400 |
| **Westside Clinic** | Suburban (2-story) | **Outpatient facility.** Services: Primary care, diagnostic imaging (X-ray/Ultrasound), blood work, minor procedures, physical therapy. | ~180 |
| **Corporate HQ** | Commercial (3rd floor) | **Administrative hub.** Departments: Finance, HR, Legal, Marketing, Executive Leadership, and IT. | ~220 |

### Reporting Structure (Security & IT)
* **Executive Leadership:** Dr. Patricia Morales (CEO) oversees all operations.
* **Security Leadership:** James Chen (Deputy CISO/Acting CISO) handles security policy. He reports directly to the CEO.
* **IT Operations:** Sarah Park (IT Director) manages a team of 11 (3 SysAdmins, 2 Network Techs, 1 DBA, 2 Helpdesk, 2 Desktop Support).
* **Operational Friction:** James Chen (Security) and Sarah Park (IT) are peers. While James sets security policy, he lacks authority over the IT operations team, leading to implementation gaps (e.g., delayed network segmentation).

---

## 2. IT Infrastructure Identified

### Server Inventory
* **Central Hospital:**
    * `ehr-srv-01` (Ubuntu 20.04): EHR Application.
    * `ehr-db-01` (Ubuntu 20.04): PostgreSQL Database.
    * `pacs-srv-01` (Windows Server 2016): Imaging server.
    * `billing-srv-01` (Ubuntu 18.04): Billing/Claims (History of performance/malware issues).
    * `ad-dc-01/02` (Windows Server 2019): Domain Controllers.
    * `file-srv-01` (Windows Server 2016): Department file shares.
    * `print-srv-01` (Windows Server 2012R2): **Unverified** and End-of-Life.
    * `backup-srv-01` (Ubuntu 22.04): Veeam backups to a local, non-isolated NAS.
    * `web-srv-01` (Ubuntu 20.04): Public Website/Portal in DMZ.
* **Westside Clinic:**
    * `ws-srv-01` (Windows Server 2016): Local file/scheduling.
    * Possible second unconfirmed server in the equipment closet.

### Network Devices
* **Central:** Fortinet FortiGate 100F Firewall, Cisco core switch, Cisco access switches (2 per floor), Ubiquiti UniFi APs (12 units).
* **Westside:** Netgear Nighthawk consumer-grade router (handles site-to-site VPN), unmanaged switch.
* **HQ:** Managed by landlord; MedDefense resides on a specific VLAN.

### Endpoints & IoT
* **Workstations:** ~485 total (Windows 10/11), ~60 thin clients (Central).
* **Mobile/Tablets:** ~30 HQ laptops, ~25 iPads (Physician rounds).
* **Medical IoT:** Siemens MRI (Critical: Runs **Windows XP**), GE CT Scanner, ~80 Philips patient monitors, ~120 BD Alaris infusion pumps (network-connected), IP-based Nurse Call system.

---

## 3. Data and Services

### Data Types
* **Electronic Protected Health Information (ePHI):** Patient records (EHR), medical imaging (PACS), and lab results.
* **Personally Identifiable Information (PII):** Employee HR records and patient demographic data.
* **Financial Data:** Insurance claims, billing processing, and corporate financial records.

### Critical Services
* **Clinical Continuity:** Availability of EHR and PACS for patient treatment and emergency surgery.
* **Life-Safety Systems:** Network-dependent infusion pumps and patient monitors.
* **Business Operations:** Office 365 (Email/Teams), billing services, and site-to-site VPN connectivity.

---

## 4. Known Unknowns

### Missing Information & Gaps
* **Unverified Assets:** The existence of a second server at Westside Clinic is unconfirmed. The status of `print-srv-01` has not been physically verified in over a year.
* **Stale Data:** All endpoint counts (workstations/laptops) are based on an AD report from 8 months ago and are likely inaccurate.
* **Security Coverage:** It is unknown if Sophos Endpoint Protection is current or even installed on all machines.
* **Network Visibility:** There is no formal inventory of cloud services (Shadow IT) or a complete, verified network map.
* **IoT Details:** The Operating System and patch status of the GE CT scanner are unknown.

### Contradictions & Ambiguities
* **Compliance Paradox:** The Legal department claims HIPAA compliance, yet there is no evidence of a formal assessment, and several clear violations (Windows XP, flat network, shared passwords) exist.
* **WiFi Isolation:** There is a Guest WiFi SSID, but Marcus noted it may not be logically isolated from the clinical network.
* **Physical Security:** While Central has guard services, it is unclear if the server room itself is monitored, as there are no cameras in that corridor.
* **Management status:** It is unclear if the 25 iPads used by physicians are managed via MDM or are personal devices.
