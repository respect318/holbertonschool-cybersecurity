# Shadow IT Assessment

### 1. Dr. Patel's Personal NAS (Cardiology)
* **Risk Assessment:**
  * **Sensitive Data:** Contains medical research data, which highly likely includes patient Protected Health Information (PHI) and clinical trial details.
  * **Missing Controls:** Not covered by Veeam Backups (C-006), Sophos Antivirus (C-005), System Logging (C-011), or AD Account Lockout (C-004).
  * **Worst-case scenario:** A ransomware infection spreads via the flat network to the unpatched NAS, permanently destroying unique, unbacked-up clinical research, or exposing unencrypted PHI resulting in a severe HIPAA violation.
* **Recommended Response:** **Migrate**. The data must be migrated to the officially managed file server (`file-srv-01`) or a newly provisioned, IT-governed high-speed storage volume if performance is the genuine issue. Personal, unmanaged hardware cannot legally or securely store hospital PHI.

### 2. Marketing Team's Google Drive (Personal Gmail)
* **Risk Assessment:**
  * **Sensitive Data:** Contains embargoed press releases, strategic marketing communications, internal hospital media, and potentially employee or patient PII used in promotional materials.
  * **Missing Controls:** Not covered by the corporate Password Policy (C-007) or Active Directory Authentication/Lockout (C-004). IT has zero visibility or access control.
  * **Worst-case scenario:** The employee who owns the personal Gmail account leaves the organization, taking permanent ownership and access of corporate data with them, or their personal account is compromised, leaking sensitive corporate strategies to the public.
* **Recommended Response:** **Migrate**. MedDefense already pays $432,000 annually for an enterprise Microsoft O365 E3 environment. The data should be immediately migrated to an official corporate SharePoint/OneDrive repository where access is governed by Active Directory and IT policies.

### 3. Abandoned Raspberry Pi (Second Floor, Central)
* **Risk Assessment:**
  * **Sensitive Data:** Positioned on the unsegmented 10.10.0.0/16 flat network, this device has visibility into all unencrypted internal network traffic, including database queries, PACS image transfers, and medical IoT communications.
  * **Missing Controls:** Completely unmanaged. Not covered by Sophos Antivirus (C-005), System Logs (C-011), or any vulnerability patching procedures.
  * **Worst-case scenario:** An attacker discovers this forgotten, unpatched Linux device and uses it as a stealthy, persistent backdoor to sniff network traffic, harvest credentials, and pivot freely into the EHR database without triggering any alarms.
* **Recommended Response:** **Decommission**. This device serves no current business purpose, is completely undocumented, and poses a massive pivoting risk on a flat network. It must be physically unplugged, wiped, and removed from the facility immediately.

### Asset Registry Update (Shadow Systems)

| Asset ID | Name | Type | Location | Owner (Dept) | OS/Platform | Critical Services | Network Segment | Status | Notes |
|---|---|---|---|---|---|---|---|---|---|
| A-023 | Dr. Patel Personal NAS | Data Store | Central (Cardiology) | Cardiology | Unknown (NAS OS) | Research Data | 10.10.1.0/24 | Shadow IT | Bypasses corporate storage; unbacked up. |
| A-024 | Marketing Shared G-Drive | Application | Cloud | Marketing | Google Workspace | Media / PR Comms | External Cloud | Shadow IT | Tied to an unmanaged personal Gmail account. |
| A-025 | Abandoned Raspberry Pi | Server | Central (2nd Floor) | IT (Former Intern) | Linux | Network Monitor | 10.10.1.0/24 | Shadow IT | Unpatched, forgotten device on flat network. |

### Shadow IT Policy Recommendation
The most effective policy change to reduce future shadow IT at MedDefense is the implementation of a **Streamlined IT Procurement and Acceptable Use Policy coupled with Network Access Control (NAC)**. Shadow IT typically occurs when employees view the IT department as a blocker rather than an enabler (e.g., the shared drive being "too slow"). By establishing a fast-track, user-friendly process for staff to request and receive approved technological solutions, and simultaneously implementing strict NAC at the switch level to technically block unauthorized MAC addresses from connecting to physical wall ports, MedDefense can eliminate both the motivation and the technical ability to deploy rogue systems.
