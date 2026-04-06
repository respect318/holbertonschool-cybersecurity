## Organization Overview

MedDefense Health Systems operates **three primary locations**:

- **MedDefense Central Hospital**  
  - Type: Acute care hospital (350 beds)  
  - Function: Full clinical services including Emergency, Surgery, Cardiology, Radiology, Oncology, Pediatrics, Maternity, Pharmacy, Laboratory, Administration  
  - Staff: ~1,400 employees  
  - Notes: Includes 6 floors plus basement (server room) and multiple parking options  

- **Westside Clinic**  
  - Type: Outpatient clinic (suburban)  
  - Function: Primary care, diagnostic imaging (X-ray, ultrasound), blood work, minor procedures, physical therapy  
  - Staff: ~180 employees  
  - Notes: Shares some IT with Central but has a local server closet for essential needs  

- **Corporate HQ**  
  - Type: Administrative offices  
  - Function: Finance, HR, Legal, Marketing, Executive Leadership, IT  
  - Staff: ~220 employees  
  - Notes: IT department located here (12 staff), relies on cloud services, connects to Central via VPN

## IT Infrastructure Identified

Key servers and IT systems at MedDefense include:

1. **ehr-srv-01** – Ubuntu 20.04 LTS – EHR Application Server – Central  
2. **ehr-db-01** – Ubuntu 20.04 LTS – EHR Database (PostgreSQL) – Central  
3. **pacs-srv-01** – Windows Server 2016 – PACS Imaging Server – Central  
4. **billing-srv-01** – Ubuntu 18.04 LTS – Billing/Claims Processing – Central  
5. **ad-dc-01 / ad-dc-02** – Windows Server 2019 – Domain Controllers – Central  
6. **file-srv-01** – Windows Server 2016 – Department File Shares – Central  
7. **print-srv-01** – Windows Server 2012R2 – Print Server [UNVERIFIED] – Central  
8. **backup-srv-01** – Ubuntu 22.04 LTS – Backup Server (Veeam) – Central  
9. **web-srv-01** – Ubuntu 20.04 LTS – Public Website + Patient Portal – Central  
10. **ws-srv-01** – Windows Server 2016 – Local file server + scheduling – Westside  

Other infrastructure includes:

- **Networking**: Cisco core switch, access switches, Fortinet firewall (Central), unmanaged switch + consumer router (Westside), building-managed network (HQ), Ubiquiti WiFi APs  
- **Endpoints**: Windows 10/11 workstations, thin clients, laptops, iPads (~25), clinical medical devices  
- **Medical IoT Devices**: Patient monitors, infusion pumps, MRI (Windows XP), CT scanner
