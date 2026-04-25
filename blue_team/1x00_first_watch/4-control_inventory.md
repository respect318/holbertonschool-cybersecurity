Control ID: C-001
Control Name: FortiGate Edge Firewall (Inbound Web Rule)
Description: Firewall rule restricting inbound WAN traffic strictly to HTTP/HTTPS for the web server.
Category: Technical
Function: Preventive
Asset(s) Protected: Internal Network / Server Subnet
Source: Artifact 1

Control ID: C-002
Control Name: FortiGate Traffic Logging
Description: Firewall feature enabled to log allowed and denied traffic for manual review.
Category: Technical
Function: Detective
Asset(s) Protected: Network Perimeter
Source: Artifact 1

Control ID: C-003
Control Name: SSH Public Key Authentication
Description: Requires cryptographic keys instead of passwords for remote server access.
Category: Technical
Function: Preventive
Asset(s) Protected: ehr-srv-01
Source: Artifact 2

Control ID: C-004
Control Name: Active Directory Account Lockout
Description: Automatically locks user accounts after 5 failed login attempts for 30 minutes.
Category: Technical
Function: Preventive
Asset(s) Protected: Active Directory / User Accounts
Source: Artifact 3

Control ID: C-005
Control Name: Sophos Endpoint Protection
Description: Antivirus software deployed to workstations to block and quarantine malware.
Category: Technical
Function: Preventive
Asset(s) Protected: Windows Workstations
Source: Artifact 4

Control ID: C-006
Control Name: Veeam Nightly Backups
Description: Automated nightly full backups of critical VMs to a local NAS.
Category: Technical
Function: Corrective
Asset(s) Protected: Central Hospital Critical VMs
Source: Artifact 5

Control ID: C-007
Control Name: Written Password Policy
Description: Official administrative policy defining password length, complexity, and rotation rules.
Category: Administrative
Function: Preventive
Asset(s) Protected: Organizational Credentials
Source: Artifact 3

Control ID: C-008
Control Name: CyberSafe Basics Security Training
Description: Annual mandatory online security awareness training module for all staff.
Category: Administrative
Function: Preventive
Asset(s) Protected: MedDefense Personnel
Source: Artifact 7

Control ID: C-009
Control Name: ClearView Security Guard
Description: Uniformed security guard stationed at the main entrance lobby for visitor registration.
Category: Physical
Function: Preventive
Asset(s) Protected: MedDefense Central Hospital
Source: Artifact 6

Control ID: C-010
Control Name: Standalone Analog Camera System
Description: Four analog cameras recording entrances and parking to a local DVR for 30 days.
Category: Physical
Function: Detective
Asset(s) Protected: MedDefense Central Hospital Perimeter
Source: Artifact 6

Control ID: C-011
Control Name: Standalone System Logs
Description: Local system logs written to Event Viewer and /var/log for manual review after an incident.
Category: Technical
Function: Detective
Asset(s) Protected: Servers and Operating Systems
Source: Artifact 8

Control ID: C-012
Control Name: Shared Account Password Rotation Procedure
Description: Administrative rule mandating password changes when a user sharing an account leaves, offsetting the risk of shared accounts.
Category: Administrative
Function: Compensating
Asset(s) Protected: Systems requiring shared accounts (e.g., PACS workstation)
Source: Artifact 3

Control ID: C-013
Control Name: Visibly Positioned Security Cameras
Description: The visible presence of cameras acts to discourage physical intrusion attempts.
Category: Physical
Function: Deterrent
Asset(s) Protected: MedDefense Facilities
Source: Artifact 6

Control ID: C-014
Control Name: EHR Application Audit Log
Description: Built-in vendor-managed audit logging for tracking actions taken within the EHR system.
Category: Technical
Function: Detective
Asset(s) Protected: Electronic Health Records Database
Source: Artifact 8

Control Summary Matrix

| Category | Preventive | Detective | Corrective | Compensating | Deterrent |
|---|---|---|---|---|---|
| Technical | C-001, C-003, C-004, C-005 | C-002, C-011, C-014 | C-006 | | |
| Administrative | C-007, C-008 | | | C-012 | |
| Physical | C-009 | C-010 | | | C-013 |
