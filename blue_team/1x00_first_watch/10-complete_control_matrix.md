# The Complete Control Matrix

## Part 1: Control Registry (Updated)

| Control ID | Control Name | Category | Function | Asset(s) Protected | Effectiveness (Strong/Adequate/Weak) | Evidence/Source |
|---|---|---|---|---|---|---|
| C-001 | FortiGate Edge Firewall (Inbound Rules) | Technical | Preventive | Internal Network / Server Subnet | Weak (Too permissive, no egress filter) | Task 4 (Artifact 1) |
| C-002 | FortiGate Traffic Logging | Technical | Detective | Network Perimeter | Adequate (Logged locally, 30 days) | Task 4 (Artifact 1) |
| C-003 | SSH Public Key Authentication | Technical | Preventive | ehr-srv-01 | Strong (Properly configured) | Task 4 (Artifact 2) |
| C-004 | Active Directory Account Lockout | Technical | Preventive | AD User Accounts | Strong (Standard 5 attempts / 30 mins) | Task 4 (Artifact 3) |
| C-005 | Sophos Endpoint Protection | Technical | Preventive | Windows Workstations | Adequate (Missing on servers, some outdated) | Task 4 (Artifact 4) |
| C-006 | Veeam Nightly Backups | Technical | Corrective | Central Critical VMs | Weak (Local NAS only, same physical rack) | Task 4 (Artifact 5) |
| C-007 | Written Password Policy | Administrative | Preventive | Organizational Credentials | Adequate (Standard complexity, 90-day rotation)| Task 4 (Artifact 3) |
| C-008 | CyberSafe Basics Security Training | Administrative | Preventive | MedDefense Personnel | Weak (Low completion rates, generic content) | Task 4 (Artifact 7) |
| C-009 | ClearView Security Guard | Physical | Preventive | Central Hospital Perimeter | Weak (Main entrance only, business hours only)| Task 4 (Artifact 6) |
| C-010 | Standalone Analog Camera System | Physical | Detective | Central Hospital Entrances | Weak (No coverage of server rooms, 30-day overwrite) | Task 4 (Artifact 6) |
| C-011 | Standalone System Logs | Technical | Detective | Servers and OS | Weak (No SIEM, manual review only) | Task 4 (Artifact 8) |
| C-012 | Shared Account Password Rotation | Administrative | Compensating | Systems with shared accounts | Weak (Discouraged but used, hard to enforce) | Task 4 (Artifact 3) |
| C-013 | Visibly Positioned Security Cameras | Physical | Deterrent | MedDefense Facilities | Adequate (Visible but unmonitored) | Task 4 (Artifact 6) |
| C-014 | EHR Application Audit Log | Technical | Detective | EHR Database | Adequate (Requires 48hr vendor export) | Task 4 (Artifact 8) |
| C-015 | Network Isolation & Strict ACLs (Microsegmentation) | Technical | Preventive | WS-RAD-01 (MRI) | Strong (Proposed in Task 6) | Task 6 (Compensating Controls) |
| C-016 | Physical Port Blockers & Strict Access | Physical | Preventive | WS-RAD-01 (MRI) | Strong (Proposed in Task 6) | Task 6 (Compensating Controls) |
| C-017 | Dedicated Network Intrusion Detection (NIDS) | Technical | Detective | WS-RAD-01 (MRI) | Strong (Proposed in Task 6) | Task 6 (Compensating Controls) |

## Part 2: Updated Control Summary Matrix

| Category | Preventive | Detective | Corrective | Compensating | Deterrent |
|---|---|---|---|---|---|
| **Technical** | 5 (Adequate) | 4 (Adequate) | 1 (Weak) | 0 (None) | 0 (None) |
| **Administrative** | 2 (Weak) | 0 (None) | 0 (None) | 1 (Weak) | 0 (None) |
| **Physical** | 2 (Adequate) | 1 (Weak) | 0 (None) | 0 (None) | 1 (Adequate) |

## Part 3: Control Coverage Map

| Critical Asset | Preventive | Detective | Corrective | Compensating | Coverage Assessment |
|---|---|---|---|---|---|
| **1. ehr-db-01 (EHR Database)** | C-001, C-004, C-007 | C-011, C-014 | C-006 | None (Missing) | **Under-Protected** (Relies on weak perimeter and local backups) |
| **2. PUMP-ICU / PUMP-ER (BD Alaris Pumps)** | None (Missing) | None (Missing) | None (Missing) | None (Missing) | **Unprotected** (Fully exposed on flat network) |
| **3. Core Network Switch / FortiGate Firewall** | C-004, C-007 | C-002, C-011 | None (Missing) | None (Missing) | **Under-Protected** (No MFA, no automated alerting) |
| **4. WS-RAD-01 (MRI Control Workstation)** | C-001 (Current), C-015, C-016 (Proposed) | C-017 (Proposed) | None (Missing) | C-015, C-016, C-017 (Proposed) | **Partially Protected** (Only if proposed compensating controls are applied) |
| **5. NAS-01 (Backup Storage System)** | C-001, C-004 | C-011 | None (Missing) | None (Missing) | **Under-Protected** (No offsite replication, exposed management UI) |
