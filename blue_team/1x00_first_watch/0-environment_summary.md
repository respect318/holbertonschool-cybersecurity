# MedDefense Health Systems - Structured Environment Summary

## Organization Overview

MedDefense Health Systems operates three main locations serving both clinical and administrative functions. The **Central Hospital**, a 350-bed acute care facility in the downtown area, hosts departments such as Emergency, Surgery, Cardiology, Radiology, Oncology, Pediatrics, Maternity, Pharmacy, Laboratory, and Administration, with an approximate staff of 1,400. It consists of six floors plus a basement level that contains mechanical equipment and the server room, with both underground and surface parking available.  

The **Westside Clinic** is a suburban outpatient facility, approximately twelve minutes from Central Hospital. It provides primary care, diagnostic imaging (X-ray and ultrasound), blood work, minor procedures, and physical therapy. The clinic employs roughly 180 staff members. While it shares some IT services with Central, it maintains a local server closet for essential services.  

The **Corporate HQ**, located in the Greenfield Business Park, houses administrative offices for Finance, HR, Legal, Marketing, Executive Leadership, and IT, with an approximate staff of 220. The IT department, consisting of twelve personnel, is located here.  

From a security perspective, the reporting structure is as follows: the CEO, Dr. Patricia Morales, oversees the executive team including the CFO, COO, and General Counsel. The Chief Information Security Officer (CISO) position is vacant, with James Chen acting as Deputy CISO. James Chen supervises the security analyst role, while Sarah Park, IT Director, manages system administrators, network technicians, database administrators, helpdesk analysts, and desktop support technicians. This organizational layout is crucial for understanding decision-making authority and operational responsibilities in cybersecurity.

## IT Infrastructure Identified

The IT infrastructure across MedDefense includes multiple servers, network devices, endpoints, and medical IoT devices. At **Central Hospital**, key servers include ehr-srv-01 (EHR application server), ehr-db-01 (PostgreSQL database server), pacs-srv-01 (PACS imaging server), billing-srv-01 (billing/claims processing), two domain controllers (ad-dc-01 and ad-dc-02), file-srv-01 (department file shares), print-srv-01 [unverified], backup-srv-01 (Veeam backup server), and web-srv-01 (public website and patient portal).  

The **Westside Clinic** operates ws-srv-01 (local file server and scheduling). Additional servers may exist but are unverified. **Corporate HQ** relies primarily on cloud services and accesses Central’s infrastructure via a site-to-site VPN.  

Network infrastructure at Central consists of a Cisco core switch, two Cisco access switches per floor, and a Fortinet FortiGate 100F firewall. Westside’s network is minimally managed, with an unmanaged switch and consumer-grade router connecting to the VPN. WiFi access at Central uses Ubiquiti UniFi APs (12 units), with configuration unknown at Westside.  

Endpoints include approximately 320 Windows 10 workstations and 60 thin clients at Central, 45 Windows 10 workstations at Westside, and 120 Windows 10/11 workstations plus 30 laptops at HQ. Tablets (~25 iPads) are used by physicians for rounds, though management status is unclear.  

Medical IoT devices at Central include approximately 80 Philips IntelliVue patient monitors, 120 BD Alaris infusion pumps, one Siemens MAGNETOM MRI (running Windows XP), and one GE Revolution CT scanner (OS unknown). The nurse call system and badge/access system are IP-based and integrated with AD where applicable.

## Data and Services

MedDefense handles highly sensitive healthcare and administrative data. This includes electronic health records (EHR), PACS imaging data, billing and claims information, patient and staff personally identifiable information, and operational and financial records. Critical services dependent on IT infrastructure include the EHR system, PACS server, billing and claims processing, file sharing, printing, backup operations, public website and patient portal access, VPN connectivity for remote staff, and networked medical devices. Users of these systems encompass clinical personnel, administrative staff, IT/security staff, and patients through the portal. These services are essential for continuous hospital operations and patient care.

## Known Unknowns

Several critical gaps remain in MedDefense’s documentation. These include an incomplete inventory of endpoints and IoT devices, an unclear full network diagram and VLAN segmentation, unknown operating system details for the CT scanner, unverified guest WiFi isolation and VPN ACLs, pending vulnerability assessments and endpoint security status, a potentially incomplete cloud service inventory beyond O365, lack of formal HIPAA Security Rule compliance assessment, absent incident response and disaster recovery plans, and gaps in physical security, particularly at Westside Clinic and the Central server room. Legacy devices, such as the MRI running Windows XP, present additional security risks that require attention.
