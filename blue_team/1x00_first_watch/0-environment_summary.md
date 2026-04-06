# MedDefense Health Systems - Structured Environment Summary

## Organization Overview

MedDefense Health Systems is a healthcare organization operating across three main locations, providing both clinical and administrative services. The organization supports approximately 2,000 employees across hospital, outpatient, and corporate environments.

The security-relevant structure includes executive leadership, IT operations, and security oversight. The CISO role is currently vacant, with James Chen acting as Deputy CISO. The IT department is led by Sarah Park, and both roles operate in parallel, which may create coordination challenges.

**Sites:**
- **MedDefense Central Hospital** – Acute care hospital (350 beds), ~1,400 staff, includes departments such as Emergency, Surgery, Cardiology, Radiology, Oncology, Pediatrics, Maternity, Pharmacy, Laboratory, and Administration. Main infrastructure location with server room in basement.
- **Westside Clinic** – Outpatient clinic, ~180 staff, provides primary care, diagnostic imaging (X-ray, ultrasound), blood work, minor procedures, and physical therapy. Has limited local IT infrastructure.
- **Corporate HQ** – Administrative office, ~220 staff, includes Finance, HR, Legal, Marketing, Executive Leadership, and IT. No on-prem servers; relies on cloud and VPN access.

---

## IT Infrastructure Identified

MedDefense operates a mix of on-premise, cloud-connected, and medical device infrastructure across its locations.

**Key Systems (Servers):**
- **ehr-srv-01** – Ubuntu 20.04 – EHR application server (Central)
- **ehr-db-01** – PostgreSQL database server (Central)
- **pacs-srv-01** – Windows Server 2016 – Imaging system (Central)
- **billing-srv-01** – Ubuntu 18.04 – Billing/claims processing (Central)
- **ad-dc-01 / ad-dc-02** – Windows Server 2019 – Domain controllers (Central)
- **file-srv-01** – File share server (Central)
- **print-srv-01** – Print server (unverified, Central)
- **backup-srv-01** – Backup server with Veeam (Central)
- **web-srv-01** – Public website + patient portal (Central)
- **ws-srv-01** – Local file and scheduling server (Westside)

**Network Infrastructure:**
- Central: Cisco core switch, multiple access switches, Fortinet FortiGate firewall
- Westside: Unmanaged switch + consumer-grade router (Netgear)
- HQ: Building-managed network with VLAN separation
- VPN connections between sites (IPSec)

**Endpoints:**
- Central: ~320 Windows 10 workstations, ~60 thin clients
- Westside: ~45 workstations
- HQ: ~120 workstations, ~30 laptops
- Tablets: ~25 iPads (management unclear)

**Medical Devices (IoT):**
- Patient monitors (~80, Philips IntelliVue)
- Infusion pumps (~120, BD Alaris)
- MRI scanner (Siemens MAGNETOM, runs Windows XP)
- CT scanner (OS unknown)
- Nurse call system (IP-based)
- Badge/access control system (HID Global, partially integrated with AD)

---

## Data and Services

MedDefense handles multiple types of sensitive and operational data critical to healthcare delivery.

**Data Types:**
- Electronic Health Records (EHR)
- Medical imaging data (PACS)
- Patient personal and health information
- Billing and insurance data
- Staff and administrative data

**Critical Services:**
- EHR system for patient care
- PACS imaging system
- Billing and claims processing
- File sharing and internal data access
- Backup and recovery systems
- Public website and patient portal
- VPN access for remote connectivity
- Network-connected medical devices

**Users:**
- Clinical staff (doctors, nurses)
- Administrative staff
- IT and security teams
- Patients (via portal)

---

## Known Unknowns

The onboarding documentation contains several gaps, inconsistencies, and unverified elements that impact visibility and risk assessment.

**Missing / Incomplete Information:**
- Full and accurate inventory of endpoints and devices
- Confirmation of all servers (possible unknown server at Westside)
- Complete and updated network topology
- VLAN segmentation details (currently flat network assumed)
- Operating system of CT scanner
- Management status of tablets (iPads)

**Security and Configuration Gaps:**
- Guest WiFi isolation status unclear
- VPN ACLs not audited
- Endpoint protection status not fully verified
- SSH configuration incomplete across servers
- Database access not properly restricted

**Compliance and Process Gaps:**
- No formal HIPAA Security Rule assessment
- No incident response plan
- No business continuity or disaster recovery plan

**Physical Security Gaps:**
- Server room access not restricted
- No camera coverage near critical IT areas
- Westside server closet not secured

**Other Unknowns:**
- Cloud service usage beyond O365 not fully identified
- No formal vulnerability assessment completed
- IoT device security posture unclear
