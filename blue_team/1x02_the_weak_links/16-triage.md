# 16-triage.md

## Finding Triage List

* Finding 001 | Critical (9.8) | 10.10.2.15 (billing-srv-01) | Category: AC | Reason: Unauthenticated remote code execution on a core financial database server allows immediate network compromise.
* Finding 002 | High (7.8) | 10.10.2.15 (billing-srv-01) | Category: AS | Reason: Local privilege escalation should be patched, but requires initial access (like Finding 001) to be exploited.
* Finding 003 | Critical | 10.10.2.11 (ehr-db-01) | Category: AC | Reason: Unrestricted database access on the flat network directly exposes all Protected Health Information (PHI) to any compromised endpoint.
* Finding 004 | Critical (8.1) | 10.10.1.70 (WS-RAD-01) | Category: AC | Reason: Windows XP runs unpatched SMB services exposed to the network, posing an immediate ransomware worm risk to a critical medical device.
* Finding 005 | Medium | Multiple Hosts | Category: AS | Reason: Deprecated TLS 1.0 support needs to be disabled to meet compliance, but active exploitation requires a Man-in-the-Middle position.
* Finding 006 | High | 10.10.2.15 (billing-srv-01) | Category: AS | Reason: MySQL bound to all interfaces is risky on a flat network and should be restricted to localhost or the application tier.
* Finding 007 | High | 10.10.2.20 (ad-dc-01) | Category: AS | Reason: Missing LDAP signing allows potential relay attacks, requiring a scheduled group policy update to enforce security.
* Finding 008 | High (8.8) | 10.10.2.31 (print-srv-01) | Category: AC | Reason: PrintNightmare provides a trivial path for standard users to gain SYSTEM privileges and compromise the domain.
* Finding 009 | High | 10.10.2.15 (billing-srv-01) | Category: AS | Reason: Password authentication for SSH increases susceptibility to brute-force attacks and must be replaced with keys.
* Finding 010 | Critical (7.5+) | BD Alaris Pumps | Category: AC | Reason: Vulnerable medical IoT firmware threatens patient safety directly by allowing unauthenticated remote disruption of infusion dosing.
* Finding 011 | High | 10.10.2.15 (billing-srv-01) | Category: AS | Reason: End-of-Life Ubuntu 18.04 requires a scheduled OS migration or ESM subscription to restore patch availability.
* Finding 012 | Low | 10.10.2.50 (web-srv-01) | Category: I | Reason: Missing security headers represent a best-practice deviation rather than a direct, easily exploitable vulnerability.
* Finding 013 | Medium | Multiple Hosts | Category: AS | Reason: Expiring SSL certificates will eventually cause service disruptions and need to be renewed within the 30-day window.
* Finding 014 | High | 10.10.10.1 (Westside Clinic) | Category: AC | Reason: A consumer-grade router acts as an insecure VPN gateway, requiring immediate replacement with an enterprise firewall to secure the perimeter.
* Finding 015 | High | nas-srv-01 | Category: AS | Reason: The NAS management interface is unnecessarily exposed internally and should be moved to a restricted administration VLAN.
* Finding 016 | High | Philips IntelliVue Monitors | Category: AC | Reason: Unauthenticated web interfaces on patient monitors allow critical care disruption and require immediate network isolation.
* Finding 017 | Medium | 10.10.2.10 (ehr-srv-01) | Category: I | Reason: Tomcat version disclosure is useful for reconnaissance but does not pose a direct threat on its own.
* Finding 018 | Medium | 10.10.2.20 (ad-dc-01) | Category: AS | Reason: Weak Kerberos encryption types (DES/RC4) must be disabled via Active Directory settings in a planned maintenance window.
* Finding 019 | Medium | Clinical Workstations | Category: AS | Reason: Unnecessary RDP exposure enables lateral movement and should be restricted via Windows Firewall.
* Finding 020 | Critical (9.8) | backup-srv-01 | Category: FP | Reason: The specific prerequisite of SSH agent-forwarding is not utilized in this backup server's administrative workflow.
* Finding 021 | Medium | 10.10.2.50 (web-srv-01) | Category: AS | Reason: The HTTP TRACE method should be disabled in the web server config to prevent Cross-Site Tracing attacks.
* Finding 022 | Low | Multiple Hosts | Category: I | Reason: Minor system clock skew requires NTP synchronization but poses minimal immediate security risk.
* Finding 023 | High | Clinical Workstations | Category: AS | Reason: Unrestricted USB mass storage poses malware delivery risks and should be blocked via Group Policy.
* Finding 024 | Critical | Imaging Devices | Category: AC | Reason: Transmitting DICOM medical imagery in cleartext over a flat network allows trivial interception of PHI.
* Finding 025 | Medium | 10.10.2.20 (ad-dc-01) | Category: AS | Reason: DNS zone transfers to unauthorized requesters map the internal network and must be restricted to trusted secondary servers.
* Finding 026 | High | 10.10.2.15 (billing-srv-01) | Category: AS | Reason: The outdated Linux kernel requires a reboot to apply pending updates during the next scheduled downtime.
* Finding 027 | High | Multiple Hosts | Category: AC | Reason: Inactive endpoint protection (Sophos) leaves devices completely blind to malware execution and requires immediate reactivation.
* Finding 028 | High | Unknown Linux Hosts | Category: AC | Reason: Undocumented "Shadow IT" bypasses all security controls and must be identified and isolated immediately.
* Finding 029 | High | Shadow IT | Category: AS | Reason: The Grafana path traversal vulnerability needs patching, but locating the shadow IT host (Finding 028) takes precedence.
* Finding 030 | Medium | 10.10.2.10 (ehr-srv-01) | Category: FP | Reason: The certificate mismatch is a user operational error (navigating to IP instead of hostname) rather than a cryptographic flaw.
* Finding 031 | Critical (9.8) | 10.10.2.10 (ehr-srv-01) | Category: AC | Reason: Tomcat Ghostcat allows unauthenticated file read on the EHR server, directly threatening the core medical database.

---

## Triage Summary

* **Actionable Critical (AC):** 11 findings
* **Actionable Standard (AS):** 15 findings
* **Informational (I):** 3 findings
* **False Positive (FP):** 2 findings

---

## Actionable Findings List

**Priority 1: Actionable Critical (Immediate Remediation 24-48h)**
1. Finding 001 (Apache mod_lua RCE on billing-srv-01)
2. Finding 031 (Tomcat Ghostcat on ehr-srv-01)
3. Finding 003 (PostgreSQL Unrestricted Access on ehr-db-01)
4. Finding 010 (BD Alaris Pump Firmware)
5. Finding 004 (Windows XP SMB on WS-RAD-01)
6. Finding 016 (Philips IntelliVue Exposed Interface)
7. Finding 024 (DICOM Cleartext Transmission)
8. Finding 008 (PrintNightmare on print-srv-01)
9. Finding 027 (Inactive Sophos Endpoint Protection)
10. Finding 028 (Undocumented Shadow IT Devices)
11. Finding 014 (Consumer-grade Router at Westside Clinic)

**Priority 2: Actionable Standard (Scheduled Remediation 7-30 days)**
1. Finding 002 (Apache Local PrivEsc)
2. Finding 011 (Ubuntu 18.04 EOL Migration/ESM)
3. Finding 009 (SSH Password Auth)
4. Finding 006 (MySQL Unrestricted Binding)
5. Finding 007 (LDAP Signing Not Required)
6. Finding 026 (Linux Kernel Outdated)
7. Finding 029 (Grafana Path Traversal)
8. Finding 023 (USB Mass Storage Allowed)
9. Finding 015 (Synology NAS Exposed)
10. Finding 019 (RDP Enabled)
11. Finding 005 (TLS 1.0 Supported)
12. Finding 018 (Weak Kerberos Encryption)
13. Finding 021 (HTTP TRACE Enabled)
14. Finding 025 (DNS Zone Transfer)
15. Finding 013 (SSL Certificate Expiring)
