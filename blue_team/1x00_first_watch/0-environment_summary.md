# 0-environment_summary.md

## Organization Overview

MedDefense Health Systems operates across three primary locations with approximately 2,000 total employees.

### Sites
* **MEDDEFENSE CENTRAL HOSPITAL**: Located downtown. It is a 6-floor (plus basement) acute care facility with 350 beds. Functions include Emergency, Surgery, Cardiology, Radiology, Oncology, Pediatrics, Maternity, Pharmacy, Laboratory, and Administration. Approximate headcount: 1,400.
* **WESTSIDE CLINIC**: A suburban outpatient facility located 12 minutes from Central. Functions include Primary care, diagnostic imaging (X-ray, ultrasound), blood work, minor procedures, and physical therapy. Approximate headcount: 180.
* **CORPORATE HQ**: Administrative offices in Greenfield Business Park. Functions include Finance, HR, Legal, Marketing, Executive Leadership, and the IT department. Approximate headcount: 220.

### Reporting Structure
* **James Chen**: Deputy CISO (Acting CISO), reports directly to the CEO. Responsible for security policy.
* **Sarah Park**: IT Director, managing a team of 11 (3 SysAdmins, 2 Network Techs, 1 DBA, 2 Helpdesk, 2 Desktop Support).
* **Conflict**: James and Sarah are peers. James has authority over security policy but no authority over IT operations, leading to implementation friction.

---

## IT Infrastructure Identified

### Servers and Systems
* **ehr-srv-01**: EHR Application Server (Ubuntu 20.04 LTS) located at Central Hospital.
* **ehr-db-01**: EHR Database (PostgreSQL on Ubuntu 20.04) located at Central Hospital.
* **pacs-srv-01**: PACS Imaging Server (Windows Server 2016) located at Central Hospital.
* **billing-srv-01**: Billing and Claims Processing server (Ubuntu 18.04 LTS) located at Central Hospital.
* **ad-dc-01**: Primary Domain Controller (Windows Server 2019) located at Central Hospital.
* **ad-dc-02**: Secondary Domain Controller (Windows Server 2019) located at Central Hospital.
* **file-srv-01**: Department File Shares (Windows Server 2016) located at Central Hospital.
* **print-srv-01**: Print Server (Windows Server 2012R2) located at Central Hospital [UNVERIFIED].
* **backup-srv-01**: Backup Server running Veeam (Ubuntu 22.04 LTS) located at Central Hospital.
* **web-srv-01**: Public Website and Patient Portal (Ubuntu 20.04 LTS) located at Central Hospital.
* **ws-srv-01**: Local file server and scheduling server (Windows Server 2016) located at Westside Clinic.
* **NAS**: Local storage for backups, connected to backup-srv-01 at Central.

### Network Devices
* **Fortinet FortiGate 100F**: Main firewall at Central Hospital.
* **Cisco Core Switch**: Centralized switching at Central Hospital.
* **Cisco Access Switches**: Two per floor at Central Hospital.
* **Netgear Nighthawk**: Consumer-grade router at Westside Clinic used for site-to-site VPN.
* **Ubiquiti UniFi APs**: 12 wireless access points at Central Hospital.

### Endpoints and IoT
* **Workstations**: ~320 at Central, ~45 at Westside, ~120 at HQ (Windows 10/11).
* **Medical Devices**: Siemens MAGNETOM MRI (Windows XP), GE Revolution CT scanner, Philips IntelliVue patient monitors (~80 units), and BD Alaris infusion pumps (~120 units).
* **Others**: ~60 thin clients, ~30 laptops, ~25 iPads, HID Global badge access system, and IP-based nurse call system.

---

## Data and Services

### Data Types
* **ePHI (Electronic Protected Health Information)**: Patient health records in EHR and medical images in PACS.
* **PII (Personally Identifiable Information)**: Staff data in HR systems and patient identity details.
* **Financial Data**: Billing records and insurance claims processing.

### Critical Services
* **Clinical Operations**: Dependent on EHR, PACS, and connected medical devices. Used by clinicians and nursing staff.
* **Administrative Services**: Office 365, Billing, and Finance applications. Used by HQ and Admin staff.
* **External Access**: Patient Portal for community access to health data.

---

## Known Unknowns

### Missing or Incomplete Information
* **Westside Inventory**: Marcus mentions a potential second server in the Westside closet that is unconfirmed.
* **Asset Accuracy**: Endpoint counts and AD reports are 8 months old and unverified.
* **IoT Details**: The Operating System for the GE Revolution CT scanner is unknown.
* **WiFi Isolation**: The actual isolation status of the Guest WiFi at Central is unverified.

### Contradictions
* **Compliance Status**: Legal claims HIPAA compliance, but documented issues (Windows XP, flat network, shared accounts) contradict this.
* **Physical Security**: There is a contradiction between "secure facility" claims and the fact that Westside's server closet remains unlocked and Central's server corridor lacks cameras.
