Asset ID | Name | Type | Location | Owner (Dept) | OS/Platform | Critical Services | Network Segment | Status | Notes
---|---|---|---|---|---|---|---|---|---
A-001 | billing-srv-01 | Server | Central | Finance | Ubuntu 18.04 | Billing | 10.10.2.0/24 | Deprecated | Source: Diagnostics (Task 2 cryptominer) & Incidents (Task 1 ransomware)
A-002 | Intern's Laptop | Endpoint | Central | Unknown | Unknown | None | 10.10.1.0/24 | Shadow IT | Source: Incidents (Task 1 - torrent client)
A-003 | WS-RAD-01 (MRI) | Endpoint | Central | Radiology | Windows XP SP3 | MRI Control | 10.10.1.0/24 | Deprecated | Source: Legacy Dilemma (Task 6) & Network Scan
A-004 | 2F Network Switch | Network Device | Central | IT | Cisco IOS | Floor Routing | 10.10.1.0/24 | Active | Source: Physical Observations (Task 3 - unlocked closet)
A-005 | 3F Nurse Wkstn | Endpoint | Central | Clinical | Windows 10 | EHR Access | 10.10.1.0/24 | Active | Source: Physical Observations (Task 3 - unattended session)
A-006 | MON-VITALS-3F-01 | IoT Medical | Central | Clinical | Unknown | Patient Vitals | 10.10.3.47 | Active | Source: Physical Observations (Task 3) & Network Scan
A-007 | FortiGate 100F | Network Device | Central | IT | FortiOS | Firewall | Edge / VPN | Active | Source: Control Artifacts (Task 4) & Onboarding
A-008 | NAS-01 | Data Store | Central | IT | Synology DSM 7 | Backups | 10.10.2.0/24 | Active | Source: Control Artifacts (Task 4)
A-009 | Analog DVR System | Physical Infrastructure | Central | Security | Unknown | Video Storage | N/A | Active | Source: Control Artifacts (Task 4 camera system)
A-010 | UNKNOWN-01 | Server | Central | Unknown | Linux 4.x | Web Services | 10.10.2.99 | Shadow IT | Source: Network Scan (Task 7 undocumented)
A-011 | Westside Mystery | Server | Westside | Unknown | Linux 5.x | Port 3000 App | 10.10.10.200 | Shadow IT | Source: Network Scan (Task 7 undocumented)
A-012 | GE Revolution CT | IoT Medical | Central | Radiology | Unknown | CT Scanner | Unknown | Unknown | Source: Onboarding Packet (Task 0) - Missing from scan
A-013 | Physician iPads | Endpoint | Central | Clinical | iOS | Mobile Rounds | WiFi | Active | Source: Onboarding Packet (Task 0)
A-014 | web-srv-01 | Server | Central | IT | Ubuntu 20.04 | Website | 10.10.2.0/24 | Active | Source: Incidents (Task 1 defacement) & Network Scan
A-015 | WS-PHARM-01 | Endpoint | Central | Pharmacy | Windows 10 | Pharmacy Sys | 10.10.1.0/24 | Active | Source: Incidents (Task 1 dosage bug) & Network Scan
A-016 | Cisco Core Switch | Network Device | Central | IT | Cisco IOS | Core Routing | 10.10.0.0/16 | Active | Source: Onboarding Packet (Task 0 diagram)
A-017 | Netgear Router | Network Device | Westside | IT | Netgear FW | IPSec VPN | 10.10.10.1 | Active | Source: Onboarding Packet & Network Scan
A-018 | ehr-srv-01 | Server | Central | Clinical | Ubuntu 20.04 | EHR App | 10.10.2.0/24 | Active | Source: Incidents (Task 1 outage)
A-019 | pacs-srv-01 | Server | Central | Radiology | Win Server 2016 | PACS Imaging | 10.10.2.0/24 | Active | Source: Onboarding Packet (Shared accounts)
A-020 | BADGE-READER-MAIN | Physical Infrastructure | Central | Security | HID Global | Door Access | 10.10.3.60 | Active | Source: Network Scan & Onboarding

Reconciliation Notes

1. Shadow IT (Found in scan, missing in documentation)
- 10.10.2.99 (UNKNOWN-01): Linux device running web services in the critical server subnet.
- 10.10.10.200 (Unknown device): Linux device with port 3000 open at Westside.

2. Missing Assets (Found in documentation, missing in scan)
- GE Revolution CT Scanner (From Onboarding Packet): Does not appear in scan.
- Intern's Personal Laptop (From Incidents): Not detected in scan, likely offline.
- Unconfirmed Westside Server (From Onboarding notes): Scan only shows ws-srv-01 and a mystery device.

3. Discrepancies and Contradictions
- Flat Network confirmed: The onboarding diagram showed a DMZ, but the network scan proves the entire 10.10.0.0/16 architecture is completely flat with no segmentation.
- Print Server verified: Marked as unverified in the onboarding packet, but confirmed active in the network scan running EOL Windows Server 2012.
- Medical IoT exposure: Documentation assumed isolation, but the scan shows life-critical monitors are fully exposed to the network.
