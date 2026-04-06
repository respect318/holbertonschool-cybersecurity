# MedDefense Health Systems - Structured Environment Summary

## Organization Overview

**Sites:**

- **MedDefense Central Hospital**  
  350-bed acute care hospital, downtown location  
  Departments: Emergency, Surgery, Cardiology, Radiology, Oncology, Pediatrics, Maternity, Pharmacy, Laboratory, Administration  
  Staff: ~1,400  
  Building: 6 floors + basement (mechanical/server room)  
  Parking: underground (staff) + surface (visitors)

- **Westside Clinic**  
  Outpatient facility, suburban (12 min from Central)  
  Services: Primary care, diagnostic imaging (X-ray, ultrasound), blood work, minor procedures, physical therapy  
  Staff: ~180  
  Building: 2-story medical office complex  
  IT: Shares some services with Central, has local server closet

- **Corporate HQ**  
  Administrative offices, Greenfield Business Park  
  Departments: Finance, HR, Legal, Marketing, Executive Leadership, IT  
  Staff: ~220  
  Building: 3rd floor of 5-story leased office  
  IT Department: 12 staff

**Organizational Structure (security relevant):**

- CEO: Dr. Patricia Morales  
  - CFO: Robert Kim  
  - COO: Angela Torres  
    - Clinical Directors per department  
  - General Counsel: David Park  
  - CISO (vacant, James Chen acting Deputy CISO)  
    - James Chen, Deputy CISO  
      - Security Analyst: [YOU]  
    - Sarah Park, IT Director  
      - 3x System Administrators, 2x Network Technicians, 1x DBA, 2x Helpdesk Analysts, 2x Desktop Technicians, 1x IT Intern (vacant)

## IT Infrastructure Identified

**Servers - Central Hospital:**  
- ehr-srv-01 (EHR app)  
- ehr-db-01 (PostgreSQL)  
- pacs-srv-01  
- billing-srv-01  
- ad-dc-01/02  
- file-srv-01  
- print-srv-01 [UNVERIFIED]  
- backup-srv-01  
- web-srv-01  

**Servers - Westside Clinic:**  
- ws-srv-01, possible additional unverified server  

**Servers - HQ:** cloud-based, connects via VPN to Central  

**Network Equipment:**  
- Central: Cisco core switch, 2x Cisco access per floor, Fortinet FortiGate 100F  
- Westside: unmanaged switch + consumer router  
- HQ: building-managed network, VLANs unknown  
- WiFi: Ubiquiti UniFi APs (Central:12, Westside unknown)  

**Endpoints:**  
- Central: ~320 Windows 10 workstations + 60 thin clients  
- Westside: ~45 workstations  
- HQ: ~120 workstations + 30 laptops  
- ~25 iPads  

**Medical Devices:**  
- Patient monitors (~80 Philips IntelliVue)  
- Infusion pumps (~120 BD Alaris)  
- MRI (Windows XP)  
- CT (unknown OS)  
- Nurse call system  
- Badge/access system (HID, AD-connected)

## Data and Services

**Data handled:**  
- EHR, PACS imaging, billing/claims, personal info (patients/staff), operational/financial data  

**Critical Services:**  
- EHR system, PACS server, billing/claims processing, file shares, print services, backups, public website/patient portal, VPN connectivity, IoT medical devices  

**Users:**  
- Clinical staff, administrative staff, IT/security staff, patients (portal)

## Known Unknowns

- Complete IT asset inventory (endpoints, IoT)  
- Full network diagram & VLAN segmentation  
- OS of CT scanner  
- Guest WiFi isolation & HQ VPN ACLs  
- Vulnerability assessment & endpoint security status  
- Cloud services beyond O365  
- Formal HIPAA Security Rule compliance  
- Incident response, business continuity, disaster recovery plans  
- Physical security status at Westside & Central server rooms  
- MRI/legacy device risks
