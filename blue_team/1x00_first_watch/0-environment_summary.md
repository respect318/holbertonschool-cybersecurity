# MedDefense Health Systems - Structured Environment Summary

## Organization Overview

**Sites:**

- **MEDDEFENSE CENTRAL HOSPITAL**  
  350-bed acute care facility, downtown location  
  Departments: Emergency, Surgery, Cardiology, Radiology, Oncology, Pediatrics, Maternity, Pharmacy, Laboratory, Administration  
  Staff: ~1,400  
  Building: 6 floors + basement (mechanical/server room)  
  Parking: underground (staff) + surface lot (visitors)

- **WESTSIDE CLINIC**  
  Outpatient facility, suburban location (12 min from Central)  
  Services: Primary care, diagnostic imaging (X-ray, ultrasound), blood work, minor procedures, physical therapy  
  Staff: ~180  
  Building: 2-story medical office complex, shared parking with retail plaza  
  IT: Shares some services with Central, has local server closet

- **CORPORATE HQ**  
  Administrative offices in Greenfield Business Park (15 min from Central)  
  Departments: Finance, HR, Legal, Marketing, Executive Leadership, IT  
  Staff: ~220  
  Building: 3rd floor of 5-story leased office  
  IT Department: 12 staff

**Organization Structure (security relevant):**

- CEO: Dr. Patricia Morales  
  - CFO: Robert Kim  
  - COO: Angela Torres  
    - Clinical Directors (per department)  
  - General Counsel: David Park  
  - CISO (vacant, James Chen acting Deputy CISO)  
    - James Chen, Deputy CISO  
      - Security Analyst: [YOU]  
    - Sarah Park, IT Director  
      - 3x System Administrators, 2x Network Technicians, 1x DBA, 2x Helpdesk Analysts, 2x Desktop Technicians, 1x IT Intern (vacant)

---

## IT Infrastructure Identified

**Servers - MedDefense Central:**

- ehr-srv-01: Ubuntu 20.04 LTS, EHR Application Server  
- ehr-db-01: Ubuntu 20.04 LTS, EHR Database (PostgreSQL)  
- pacs-srv-01: Windows Server 2016, PACS Imaging Server  
- billing-srv-01: Ubuntu 18.04 LTS, Billing/Claims  
- ad-dc-01/02: Windows Server 2019, Primary/Secondary Domain Controllers  
- file-srv-01: Windows Server 2016, Department File Shares  
- print-srv-01: Windows Server 2012 R2, Print Server [UNVERIFIED]  
- backup-srv-01: Ubuntu 22.04 LTS, Backup Server (Veeam agent)  
- web-srv-01: Ubuntu 20.04 LTS, Public Website + Patient Portal

**Servers - Westside Clinic:**

- ws-srv-01: Windows Server 2016, Local file server + scheduling  
- Possible additional unverified server

**Servers - Corporate HQ:**

- No on-premise servers; staff use cloud services via VPN to Central

**Network Equipment:**

- Central: Cisco core switch, 2x Cisco access switches per floor, Fortinet FortiGate 100F firewall  
- Westside: 1x unmanaged switch, 1x consumer-grade router, VPN to Central  
- HQ: Building-managed network, MedDefense VLAN  
- WiFi: Ubiquiti UniFi APs (Central: 12 units, Westside: unknown)

**Endpoints:**

- Central: ~320 Windows 10 workstations, ~60 thin clients  
- Westside: ~45 Windows 10 workstations  
- HQ: ~120 Windows 10/11 workstations, ~30 laptops (remote-capable)  
- Tablets: ~25 iPads for physicians

**Medical Devices (IoT):**

- Patient monitors: ~80 Philips IntelliVue  
- Infusion pumps: ~120 BD Alaris  
- MRI: Siemens MAGNETOM (Windows XP)  
- CT: GE Revolution (unknown OS)  
- Nurse call system: IP-based  
- Badge/access system: HID Global, AD-connected

---

## Data and Services

**Data types handled:**

- Electronic Health Records (EHR)  
- Medical imaging (PACS)  
- Billing and claims data  
- Staff and patient personal information  
- Operational and financial data

**Critical Services:**

- EHR system (ehr-srv-01, ehr-db-01)  
- PACS imaging server  
- Billing/claims processing  
- File shares and print services  
- Backup (backup-srv-01)  
- Public website and patient portal  
- VPN connectivity for remote staff  
- IoT medical devices (monitors, pumps, MRI/CT integration)

**Users:**

- Clinical staff (doctors, nurses, technicians)  
- Administrative staff (finance, HR, legal, marketing)  
- IT staff and security personnel  
- Patients (via portal)

---

## Known Unknowns

- Complete IT asset inventory, including endpoints and IoT devices  
- Full network diagram and VLAN segmentation  
- Exact OS versions of some medical devices (CT scanner)  
- Guest WiFi isolation and HQ VPN ACLs  
- Formal vulnerability assessment and endpoint security status  
- Cloud service inventory beyond O365  
- Formal compliance with HIPAA Security Rule  
- Incident response, business continuity, and disaster recovery plans  
- Status of MRI and other legacy medical devices (Windows XP)  
- Physical security of server rooms at Westside and Central
