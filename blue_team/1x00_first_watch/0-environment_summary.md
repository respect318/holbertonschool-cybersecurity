# 0-environment_summary.md

## 1. Organization Overview
MedDefense Health Systems is a healthcare provider operating across three distinct locations with approximately **2,000 total employees**.

### Sites and Locations
| Site Name | Location Type | Function | Headcount |
| :--- | :--- | :--- | :--- |
| **Central Hospital** | Urban / Downtown | 350-bed acute care facility; main clinical hub. | ~1,400 |
| **Westside Clinic** | Suburban | Outpatient services, diagnostics, and minor procedures. | ~180 |
| **Corporate HQ** | Business Park | Administrative, Finance, HR, Legal, and IT operations. | ~220 |

### Departments and Reporting Structure
* **Leadership:** Led by CEO Dr. Patricia Morales.
* **Security & IT:** * **James Chen:** Deputy CISO (Acting CISO), reports to the CEO. Responsible for security policy.
    * **Sarah Park:** IT Director, peer to James Chen. Manages 11 staff (SysAdmins, Network Techs, DBA, Helpdesk).
    * **Structural Friction:** James Chen has authority over security policy but lacks authority over IT operations, leading to implementation delays.
* **Clinical:** Managed by Clinical Directors per department (Surgery, Cardiology, etc.).

---

## 2. IT Infrastructure Identified
The infrastructure is centralized at the Hospital, with other sites connecting via VPN.

### Servers (MedDefense Central)
| Name/Type | Function | Technical Details |
| :--- | :--- | :--- |
| `ehr-srv-01` | EHR Application | Ubuntu 20.04 LTS |
| `ehr-db-01` | EHR Database | PostgreSQL (Ubuntu 20.04); accessible to entire subnet |
| `pacs-srv-01` | Imaging Server | Windows Server 2016 |
| `billing-srv-01`| Billing/Claims | Ubuntu 18.04 LTS; history of performance/malware issues |
| `ad-dc-01/02` | Domain Controllers | Windows Server 2019 |
| `file-srv-01` | File Shares | Windows Server 2016 |
| `print-srv-01` | Print Server | Windows Server 2012 R2 (**End of Life**) |
| `backup-srv-01`| Backup Server | Ubuntu 22.04 LTS (Veeam); backs up to local NAS |
| `web-srv-01` | Public Portal | Ubuntu 20.04 LTS; located in DMZ |

### Infrastructure at Other Sites
* **Westside Clinic:** `ws-srv-01` (Windows Server 2016) for files/scheduling. Uses a **consumer-grade Netgear Nighthawk router** for VPN/Internet.
* **Corporate HQ:** No on-premise servers; relies on cloud services (O365) and VPN to Central.

### Network and Endpoints
* **Network Hardware:** Fortinet FortiGate 100F (Central), Cisco core/access switches, Ubiquiti UniFi APs.
* **Endpoints:** * **Workstations:** ~485 Windows machines (10/11) and ~60 thin clients.
    * **Mobile:** ~30 laptops (HQ) and ~25 iPads (managed status unknown).
* **Medical IoT:** Siemens MRI (Windows XP), GE CT Scanner, 80 Philips patient monitors, 120 BD Alaris infusion pumps, and an IP-based Nurse Call system.

---

## 3. Data and Services
### Data Types
* **PHI/ePHI:** Electronic Health Records and medical imaging (PACS) subject to HIPAA.
* **PII:** Employee records (HR) and patient identity information.
* **Financial Data:** Billing records, insurance claims, and corporate financial data.

### Critical Services
* **Clinical Operations:** EHR and PACS availability is essential for patient care.
* **Life-Safety:** Network-connected patient monitors and infusion pumps (dosage updates).
* **Patient Access:** Public-facing Patient Portal and scheduling services.
* **Communication:** Office 365 (Email) and IP-based nurse call systems.

---

## 4. Known Unknowns
### Documentation Gaps & Contradictions
* **Westside Inventory:** Marcus's notes suggest a second unconfirmed server exists in the Westside closet.
* **Endpoint Accuracy:** The Active Directory report is 8 months old; current workstation/laptop counts and OS versions are unverified.
* **WiFi Security:** The isolation of the Guest WiFi at Central is suspected but unverified.
* **IoT Specifications:** The OS for the GE CT Scanner is unknown.
* **Software/Cloud:** Use of Shadow IT (unauthorized cloud services) is suspected by Marcus but not audited.

### Missing Critical Information
* **Network Topology:** A comprehensive, updated network map does not exist (only a "messy" draft).
* **Vulnerability Status:** No formal vulnerability assessment or endpoint security audit (Sophos status) has been performed.
* **Asset Ownership:** Management status of physician iPads is unclear.
* **Physical Security:** The specific model of the Cisco core switch and the brand of the Westside switch are unknown.

### Risks/Ambiguities
* **Compliance:** No evidence exists for HIPAA compliance despite legal claims.
* **Disaster Recovery:** No formal IR, BCP, or DR plans exist.
* **Infrastructure Debt:** The "planned" network segmentation has no confirmed start date.
