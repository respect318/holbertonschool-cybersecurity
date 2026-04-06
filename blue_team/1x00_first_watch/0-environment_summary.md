# Structured Environment Summary

## 1. Organization Overview

### Sites

**MedDefense Central Hospital**
- Location Type: Main hospital (downtown)
- Function: Core healthcare operations (Emergency, Surgery, Cardiology, Radiology, Oncology, Pediatrics, Maternity, Pharmacy, Laboratory, Administration)
- Approximate Headcount: ~1,400
- Notes: 6 floors + basement (server room located in basement)

**Westside Clinic**
- Location Type: Outpatient clinic (suburban)
- Function: Primary care, diagnostics (X-ray, ultrasound), blood work, minor procedures, physical therapy
- Approximate Headcount: ~180
- Notes: Shares some IT services with Central but also has a local server closet

**Corporate HQ**
- Location Type: Administrative office (business park)
- Function: Finance, HR, Legal, Marketing, Executive Leadership, IT
- Approximate Headcount: ~220
- Notes: IT department located here (12 staff), no on-prem servers

---

### Departments & Reporting Structure

- Executive Leadership:
  - CEO: Dr. Patricia Morales
  - CFO, COO, General Counsel

- Security:
  - Acting lead: James Chen (Deputy CISO)
  - Role: Security policy, risk management
  - CISO position currently vacant

- IT Department (under IT Director Sarah Park):
  - System Administrators (3)
  - Network Technicians (2)
  - Database Administrator (1)
  - Helpdesk Analysts (2)
  - Desktop Support (2)
  - IT Intern (vacant)

- Reporting Notes:
  - Deputy CISO reports effectively to CEO
  - IT Director and Deputy CISO are peers
  - Security has policy authority but no operational control → potential conflict

---

## 2. IT Infrastructure Identified

### Servers – Central Hospital

- ehr-srv-01
  - Type: Application Server
  - Function: EHR application
  - Location: Central
  - OS: Ubuntu 20.04

- ehr-db-01
  - Type: Database Server
  - Function: PostgreSQL database for EHR
  - Location: Central
  - OS: Ubuntu 20.04

- pacs-srv-01
  - Type: Imaging Server
  - Function: PACS system
  - Location: Central
  - OS: Windows Server 2016

- billing-srv-01
  - Type: Application Server
  - Function: Billing/claims processing
  - Location: Central
  - OS: Ubuntu 18.04

- ad-dc-01 / ad-dc-02
  - Type: Domain Controllers
  - Function: Active Directory authentication
  - Location: Central
  - OS: Windows Server 2019

- file-srv-01
  - Type: File Server
  - Function: Department file shares
  - Location: Central
  - OS: Windows Server 2016

- print-srv-01
  - Type: Print Server
  - Function: Print services
  - Location: Central
  - OS: Windows Server 2012R2
  - Note: UNVERIFIED

- backup-srv-01
  - Type: Backup Server
  - Function: Backup via Veeam
  - Location: Central
  - OS: Ubuntu 22.04

- web-srv-01
  - Type: Web Server
  - Function: Public website + patient portal
  - Location: Central (DMZ)
  - OS: Ubuntu 20.04

---

### Servers – Westside Clinic

- ws-srv-01
  - Type: Local server
  - Function: File server + scheduling
  - Location: Westside
  - OS: Windows Server 2016

- Unknown server (unconfirmed)
  - Mentioned but not verified

---

### Servers – Corporate HQ

- No on-prem servers
- Uses cloud services and VPN to Central

---

### Network Infrastructure

- Central:
  - Fortinet FortiGate 100F firewall
  - Cisco core switch (model unknown)
  - Cisco access switches (per floor)
  - Flat network: 10.10.0.0/16 (no VLANs)

- Westside:
  - Consumer router (Netgear Nighthawk)
  - Unmanaged switch
  - Site-to-site VPN to Central

- HQ:
  - Network managed by landlord
  - Separate VLAN for MedDefense
  - VPN to Central

- WiFi:
  - Central: Ubiquiti UniFi APs (~12)
  - Westside: unknown

---

### Endpoints

- Central:
  - ~320 Windows 10 workstations
  - ~60 thin clients

- Westside:
  - ~45 Windows 10 workstations

- HQ:
  - ~120 Windows 10/11 workstations
  - ~30 laptops

- Tablets:
  - ~25 iPads (management status unclear)

---

### Medical / IoT Devices

- Patient monitors (~80, Philips IntelliVue)
- Infusion pumps (~120, BD Alaris)
- MRI scanner (Siemens, runs Windows XP)
- CT scanner (OS unknown)
- Nurse call system (IP-based)
- Badge/access system (HID Global, partially integrated with AD)

---

## 3. Data and Services

### Data Types

- Patient data (EHR, imaging, medical records)
- Financial data (billing, claims)
- Employee data (HR records)
- Operational data (scheduling, internal documents)

---

### Critical Services

- Electronic Health Record (EHR) system
- Medical imaging (PACS)
- Billing and claims processing
- Active Directory authentication
- File sharing services
- Patient portal (public-facing web service)
- Backup system (Veeam)
- Network connectivity (VPN between sites)

---

### Users

- Clinical staff (doctors, nurses, technicians)
- Administrative staff (HR, finance, management)
- IT staff
- Patients (via portal)
- External vendors (e.g., EHR provider)

---

## 4. Known Unknowns

- Incomplete asset inventory (explicitly stated in IT list)
- Unverified systems (e.g., print-srv-01, possible extra Westside server)
- No full endpoint inventory (last report outdated)
- Unknown OS for some devices (e.g., CT scanner)
- Unknown WiFi setup at Westside
- Cloud services not fully inventoried
- Network diagram incomplete and simplified
- No VLAN segmentation (but unclear if partial segmentation exists anywhere)
- Unclear security controls on IoT devices
- Tablet (iPad) management status unknown
- Backup strategy lacks offsite copy (risk not fully assessed)
- No formal vulnerability assessment completed
- No incident response plan
- No disaster recovery or business continuity plan
- Compliance status (HIPAA) not formally assessed
- Potential contradictions between documentation and reality (not fully verified systems)
