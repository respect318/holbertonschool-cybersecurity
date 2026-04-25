Structured Environment Summary: MedDefense Health Systems
1. Organization Overview
MedDefense Health Systems is a healthcare organization with approximately 2,000 total employees operating across three main locations.

MedDefense Central Hospital:

Type: 350-bed acute care facility (Downtown).

Function: Emergency, Surgery, Cardiology, Radiology, Oncology, Pediatrics, Maternity, Pharmacy, Laboratory, and Administration.

Headcount: ~1,400 (clinical and support staff).

Infrastructure Note: The basement houses the mechanical/server room.

Westside Clinic:

Type: Outpatient medical office facility (Suburban).

Function: Primary care, diagnostic imaging (X-ray, ultrasound), blood work, minor procedures, and physical therapy.

Headcount: ~180 staff.

Corporate HQ:

Type: Administrative leased office space (Greenfield Business Park).

Function: Finance, HR, Legal, Marketing, Executive Leadership, and IT.

Headcount: ~220 staff (including 12 IT department staff).

Reporting Structure (Security & IT):
The security team is led by James Chen (Deputy CISO/Acting CISO), who practically reports directly to the CEO (Dr. Patricia Morales). The IT operations are led by Sarah Park (IT Director). James and Sarah are peers, but James holds policy authority while lacking operational control, causing friction. The new Security Analyst reports directly to James Chen.

2. IT Infrastructure Identified
MedDefense Central Hospital (10.10.0.0/16 Flat Network):

Servers:

ehr-srv-01 (Ubuntu 20.04 LTS): EHR Application Server.

ehr-db-01 (Ubuntu 20.04 LTS): PostgreSQL EHR Database.

pacs-srv-01 (Windows Server 2016): PACS Imaging Server.

billing-srv-01 (Ubuntu 18.04 LTS): Billing/Claims Processing.

ad-dc-01 & ad-dc-02 (Windows Server 2019): Primary & Secondary Domain Controllers.

file-srv-01 (Windows Server 2016): Department File Shares.

print-srv-01 (Windows Server 2012R2 - End of Life): Print Server [UNVERIFIED].

backup-srv-01 (Ubuntu 22.04 LTS): Veeam Backup Server backing up to a local NAS in the same rack.

web-srv-01 (Ubuntu 20.04 LTS): Public Website & Patient Portal (located in DMZ).

Network Equipment: 1x Fortinet FortiGate 100F firewall, 1x Cisco core switch (model unknown), 2x Cisco access switches per floor, 12x Ubiquiti UniFi APs.

Endpoints: ~320 Windows 10 workstations, ~60 clinical thin clients, ~25 iPads for physicians.

Medical IoT: ~80 Philips IntelliVue connected patient monitors, ~120 BD Alaris network-connected infusion pumps, 1x Siemens MAGNETOM MRI scanner (Critical: Runs Windows XP), 1x GE Revolution CT scanner (OS unknown), IP-based Nurse call system, HID Global AD-connected badge system.

Westside Clinic:

Servers: ws-srv-01 (Windows Server 2016) for local files and scheduling.

Network Equipment: 1x Netgear Nighthawk consumer-grade router (handles IPSec VPN to Central), 1x unmanaged switch. NO firewall.

Endpoints: ~45 Windows 10 workstations.

Corporate HQ:

Servers: No on-premise servers (reliant on cloud/O365 and VPN).

Network Equipment: Managed by building landlord (MedDefense has an isolated VLAN). Site-to-site VPN to Central.

Endpoints: ~120 Windows 10/11 workstations, ~30 remote-capable laptops.

3. Data and Services
Data Types Handled: Protected Health Information (PHI) stored in EHR/PACS, sensitive financial/billing data, personnel/HR data, and patient authentication data (Patient Portal).

Critical Services: * Electronic Health Records (EHR) and database for clinical care.

PACS Imaging service for radiology diagnostics.

Active Directory (AD) for user authentication and physical door access.

Network routing for life-critical IoT devices (infusion pumps, monitors).

VPN services for cross-site connectivity (Westside and HQ to Central).

Backup and restore capabilities (Veeam).

Users: Clinical providers (doctors/nurses), diagnostic technicians, hospital administration, executive leadership, IT support staff, and external patients (via portal).

4. Known Unknowns
Missing or Outdated Inventories: Endpoint counts are based on an 8-month-old AD report and are inaccurate. Cloud service usage beyond Office 365 (Shadow IT) is unknown.

Unverified Hardware/Systems: The existence of a second server at Westside is unconfirmed. print-srv-01 has not been physically verified. Management status of the 25 iPads is unclear. The Cisco core switch model, Westside unmanaged switch brand, and GE CT scanner OS are completely unknown.

Security & Network Status: * It is unknown if the Guest WiFi at Central is genuinely isolated from the flat 10.10.0.0/16 network.

The deployment and update status of Sophos antivirus on endpoints is unconfirmed.

The HQ VPN Access Control Lists (ACLs) have not been audited.

The extent of shared accounts across departments is unknown (only the Radiology PACS shared login is confirmed).

Contradictions in Documentation: The network diagram shows web-srv-01 in a "DMZ", but Marcus's notes explicitly state everything is on the same flat 10.10.0.0/16 broadcast domain with no VLANs configured.

Compliance & Policy Gaps: There is no evidence supporting Legal's claim of HIPAA compliance. Formal incident response, disaster recovery, and business continuity plans do not exist.
