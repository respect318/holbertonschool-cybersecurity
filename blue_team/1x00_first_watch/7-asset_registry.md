# MedDefense Health Systems - Asset Registry

| Asset ID | Name | Type | Location | Owner (Dept) | OS/Platform | Critical Services | Network Segment | Status | Notes |
|---|---|---|---|---|---|---|---|---|---|
| A-001 | ehr-srv-01 | Server | Central | IT / Clinical | Ubuntu 20.04 | EHR Application | 10.10.2.0/24 | Active | |
| A-002 | ehr-db-01 | Data Store | Central | IT / Clinical | Ubuntu 20.04 | PostgreSQL | 10.10.2.0/24 | Active | Exposed to entire flat network |
| A-003 | pacs-srv-01 | Server | Central | Radiology | Win Server 2016 | PACS Imaging | 10.10.2.0/24 | Active | Uses shared accounts |
| A-004 | billing-srv-01 | Server | Central | Finance | Ubuntu 18.04 | Billing/Claims | 10.10.2.0/24 | Deprecated | EOL; infected with cryptominer |
| A-005 | ad-dc-01 | Server | Central | IT | Win Server 2019 | Primary DC | 10.10.2.0/24 | Active | |
| A-006 | ad-dc-02 | Server | Central | IT | Win Server 2019 | Secondary DC | 10.10.2.0/24 | Active | Not included in Veeam backups |
| A-007 | file-srv-01 | Server | Central | All | Win Server 2016 | File Shares | 10.10.2.0/24 | Active | |
| A-008 | print-srv-01 | Server | Central | IT | Win Server 2012 | Print Server | 10.10.2.0/24 | Deprecated | EOL; confirmed active in scan |
| A-009 | backup-srv-01 | Server | Central | IT | Ubuntu 22.04 | Veeam Backup | 10.10.2.0/24 | Active | Local backups only |
| A-010 | web-srv-01 | Server | Central | IT / Marketing | Ubuntu 20.04 | Public Portal | 10.10.2.0/24 | Active | Not in a real DMZ |
| A-011 | NAS-01 | Data Store | Central | IT | Synology DSM 7 | Backup Storage | 10.10.2.0/24 | Active | Mgmt UI exposed to network |
| A-012 | ws-srv-01 | Server | Westside | IT / Clinical | Win Server 2016 | Local File/Sched | 10.10.10.0/24 | Active | |
| A-013 | WS-RAD-01 | Endpoint | Central | Radiology | Windows XP SP3 | MRI Control | 10.10.1.0/24 | Deprecated | EOL; Critical security risk |
| A-014 | FortiGate 100F | Network Device | Central | IT | FortiOS | Firewall | Edge / VPN | Active | Permissive rules; no egress filtering |
| A-015 | Netgear Router | Network Device | Westside | IT | Netgear firmware | IPSec VPN | 10.10.10.0/24 | Active | Consumer-grade; insecure |
| A-016 | UNKNOWN-01 | Server | Central | Unknown | Linux 4.x | Web Services | 10.10.2.0/24 | Shadow IT | Undocumented; ports 8888, 9090 |
| A-017 | Westside Mystery | Server | Westside | Unknown | Linux 5.x | Unknown (Port 3000) | 10.10.10.0/24 | Shadow IT | Undocumented device |
| A-018 | MON-ICU-01 | IoT Medical | Central | Clinical | Philips IntelliVue | Patient Vitals | 10.10.3.0/24 | Active | Mgmt interface fully exposed |
| A-019 | PUMP-ICU-01 | IoT Medical | Central | Clinical | BD Alaris fw 12.1.2| Infusion Pump | 10.10.3.0/24 | Active | Unpatched; known CVEs |
| A-020 | WS-WC-XRAY | IoT Medical | Westside | Radiology | Unknown | X-Ray Control | 10.10.10.0/24 | Active | |
| A-021 | BADGE-READER-MAIN| Physical Infra | Central | Security | HID Global | Door Access | 10.10.3.0/24 | Active | |
| A-022 | AP-1F-01 | Network Device | Central | IT | Ubiquiti UniFi | WiFi AP | 10.10.1.0/24 | Active | |

# Reconciliation Notes

### 1. Shadow IT (Found in scan, missing in documentation)
* **10.10.2.99 (UNKNOWN-01):** A Linux 4.x device running web services (ports 8888, 9090) in the highly critical Central server subnet. It is completely undocumented.
* **10.10.10.200 (Unknown device):** A Linux 5.x device with port 3000 open at the Westside Clinic. Not in any IT asset list.

### 2. Missing Assets (Found in documentation, missing in scan)
* **Unconfirmed Westside Server:** Marcus's notes mentioned a possible second server at Westside (Mike Torres's tip). The scan only shows `ws-srv-01` and the mystery Linux device, leaving the Windows server unconfirmed or offline.
* **GE Revolution CT Scanner:** Mentioned in the original IT asset list, but does not explicitly appear in the scan summary (it may be offline, omitted, or entirely segmented).
* **Intern's Personal Laptop:** The device running the torrent client (from Incident F) did not appear in the scan, indicating it has either been removed from the network or was powered off during the scan window.

### 3. Discrepancies and Contradictions
* **Flat Network vs. DMZ:** Marcus's draft network diagram (Task 0) showed `web-srv-01` placed in a DMZ. However, the scan definitively proves the entire environment is a flat 10.10.0.0/16 network with zero segmentation; `web-srv-01` and vulnerable IoT devices can be reached directly from any workstation.
* **Print Server Verification:** `print-srv-01` was marked as `[UNVERIFIED]` in the original IT ticketing system report. The scan positively confirms it is active at 10.10.2.31 and running a deprecated OS (Windows Server 2012).
* **Medical IoT Exposure:** Documentation assumed basic segmentation, but the scan reveals that life-critical medical devices (Philips monitors, BD Alaris pumps) and critical databases (ehr-db-01 on port 5432) have their management ports fully exposed to the entire hospital staff and guest network.
