# STRIDE Architecture Threat Model

This report applies the STRIDE threat modeling framework across three additional critical systems of the MedDefense infrastructure to identify high-priority risks outside of the core EHR system.

---

## 1. System: PACS / Medical Imaging
**Architecture Notes:** Includes `pacs-srv-01`, a legacy MRI workstation running Windows XP, and various radiology workstations. These systems communicate over a flat network and often utilize shared credentials for operational speed.

| STRIDE | Threat | Impact | Severity |
|:---|:---|:---|:---|
| **S** | Unauthorized use of shared `raduser` credentials to access imaging data. | Unauthorized viewing of sensitive patient PHI. | **H** |
| **T** | Modification of DICOM images on the vulnerable Windows XP workstation. | Life-safety risk due to potential misdiagnosis. | **C** |
| **R** | Deletion of medical records using shared accounts, leaving no audit trail. | Inability to identify the perpetrator during a HIPAA audit. | **H** |
| **I** | Unencrypted transmission of medical images over the flat internal network. | Passive sniffing leads to mass information disclosure. | **H** |
| **D** | Ransomware exploiting EternalBlue on the unsupported Windows XP system. | Total loss of access to diagnostic imaging services. | **C** |
| **E** | Using legacy exploits on Windows XP to gain local administrator rights. | Pivot point for a full-scale internal network compromise. | **H** |

**Top Threat:** **Denial of Service (D) via Windows XP Exploitation.**
The presence of an unsupported, internet-connected Windows XP workstation on a flat network is a critical liability. It is highly susceptible to legacy exploits (like EternalBlue) that can serve as a catalyst for automated ransomware, leading to a permanent loss of imaging data and diagnostic capabilities.

---

## 2. System: Active Directory
**Architecture Notes:** Consists of `ad-dc-01` and `ad-dc-02` running Windows Server 2012 R2. It serves as the central identity provider for the entire hospital without the protection of MFA.

| STRIDE | Threat | Impact | Severity |
|:---|:---|:---|:---|
| **S** | Harvesting NTLM hashes via LLMNR poisoning to impersonate a Domain Admin. | Full takeover of the hospital's digital identity. | **C** |
| **T** | Malicious modification of Group Policy Objects (GPOs) to push malware. | Organization-wide infection of all managed endpoints. | **C** |
| **R** | An attacker clearing the Security Event Logs to hide credential dumping. | Critical failure of post-incident forensic investigation. | **M** |
| **I** | Unauthorized dumping of the `ntds.dit` database to extract user hashes. | Complete compromise of all organizational passwords. | **C** |
| **D** | A targeted attack on both Domain Controllers to crash the authentication service. | Complete hospital lockout; no staff can log into any systems. | **C** |
| **E** | Exploiting unpatched PrintNightmare or similar flaws on Server 2012 R2. | Escalation from a guest/staff account to Domain Admin. | **C** |

**Top Threat:** **Spoofing (S) and Elevation of Privilege (E) due to Lack of MFA.**
Without Multi-Factor Authentication, the organization's entire security hinges on password strength. The ability to spoof a Domain Admin or elevate privileges through unpatched legacy DC software represents a "keys to the kingdom" scenario, making it the most dangerous intersection for MedDefense.

---

## 3. System: Network Infrastructure
**Architecture Notes:** Centered on an unpatched FortiGate 100F firewall, a core switch, and a Westside consumer-grade router, with no internal network segmentation.

| STRIDE | Threat | Impact | Severity |
|:---|:---|:---|:---|
| **S** | Man-in-the-Middle (MITM) attack via the unpatched FortiGate admin portal. | Interception of administrative credentials for the firewall. | **H** |
| **T** | Unauthorized change of firewall rules to allow external RDP (Port 3389). | Direct path for external ransomware groups to enter the network. | **C** |
| **R** | Disabling firewall logging before performing a large data exfiltration. | Inability to track the volume and destination of stolen data. | **M** |
| **I** | Sniffing internal traffic on the consumer-grade Westside router. | Exposure of sensitive credentials or patient data in transit. | **H** |
| **D** | DDoS attack on the FortiGate, which is the only perimeter defense point. | Total loss of external connectivity and cloud-synced EHR data. | **H** |
| **E** | Exploiting an RCE vulnerability in the outdated FortiGate firmware. | Complete bypass of perimeter security and internal network access. | **C** |

**Top Threat:** **Elevation of Privilege (E) via Unpatched Firewall Firmware.**
The FortiGate firewall is the only "firebreak" between the internet and MedDefense's flat internal network. If an attacker exploits the unpatched firmware (as noted by Marcus as a major risk), they gain system-level control over the gateway, allowing them to bridge the gap from the internet to any internal database or clinical system.
