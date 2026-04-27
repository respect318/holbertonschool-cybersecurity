# 16-triage.md

## Finding Triage List

* Finding 001 | Critical | 10.10.2.15 (billing-srv-01) | Category: AC | Reason: Active RCE on a flat network overrides any patching schedule and requires immediate 24h remediation.
* Finding 002 | High | 10.10.2.15 (billing-srv-01) | Category: AS | Reason: Scanner rates this high, but since it requires an existing initial foothold to exploit locally, it is secondary to fixing Finding 001.
* Finding 003 | N/A | 10.10.2.11 (ehr-db-01) | Category: AC | Reason: Despite having no CVSS score, this misconfiguration grants immediate network-wide access to PHI, making it a critical emergency.
* Finding 004 | High | 10.10.1.70 (WS-RAD-01) | Category: AC | Reason: EOL OS on a medical device poses a lethal ransomware risk, demanding emergency network isolation rather than waiting for a patch.
* Finding 005 | Medium | Multiple Hosts | Category: I | Reason: Exploiting TLS 1.0 requires a complex Man-in-the-Middle position, making this finding low-priority scanner noise compared to flat network exposures.
* Finding 006 | N/A | 10.10.2.15 (billing-srv-01) | Category: AS | Reason: Unrestricted MySQL binding requires scheduled firewall adjustments but is not instantly exploitable without credentials.
* Finding 007 | High | 10.10.2.20 (ad-dc-01) | Category: AS | Reason: Missing LDAP signing is a structural issue requiring a scheduled GPO update to avoid breaking legacy authentications.
* Finding 008 | High | 10.10.2.31 (print-srv-01) | Category: AC | Reason: PrintNightmare provides a trivial path for standard users to instantly compromise the domain, demanding emergency patching.
* Finding 009 | High | 10.10.2.15 (billing-srv-01) | Category: AS | Reason: Password auth is risky but requires brute-forcing, meaning key-enforcement can wait for a scheduled maintenance window.
* Finding 010 | Critical | BD Alaris Pumps | Category: AC | Reason: Medical IoT vulnerabilities directly threaten patient life via dosing manipulation, overriding standard IT patching schedules.
* Finding 011 | High | 10.10.2.15 (billing-srv-01) | Category: AS | Reason: EOL OS migration takes months to plan and cannot be done in 48 hours, categorizing it as a planned project.
* Finding 012 | Low | 10.10.2.50 (web-srv-01) | Category: I | Reason: Missing HTTP headers are pure scanner noise that do not lead to direct server compromise.
* Finding 013 | Medium | Multiple Hosts | Category: AS | Reason: Expiring certificates cause business disruption, requiring a scheduled renewal before the 30-day expiration window hits.
* Finding 014 | High | 10.10.10.1 (Westside Clinic) | Category: AC | Reason: A consumer router at the perimeter provides a trivial gateway to bypass the main firewall, needing immediate enterprise replacement.
* Finding 015 | High | nas-srv-01 | Category: AS | Reason: Internal NAS exposure is bad architecture but requires credentials or 0-days to abuse, slotting it into standard 30-day fixes.
* Finding 016 | High | Philips IntelliVue Monitors | Category: AC | Reason: Unauthenticated clinical monitors can be crashed remotely, directly threatening emergency care uptime.
* Finding 017 | Medium | 10.10.2.10 (ehr-srv-01) | Category: I | Reason: Version disclosure is informational noise; action must be focused entirely on fixing the actual Ghostcat exploit (Finding 031).
* Finding 018 | Medium | 10.10.2.20 (ad-dc-01) | Category: AS | Reason: Weak crypto requires scheduled GPO updates but is not an immediate remote code execution vector.
* Finding 019 | Medium | Clinical Workstations | Category: AS | Reason: Internal RDP allows lateral movement and must be firewalled off during a standard operational window.
* Finding 020 | Critical | backup-srv-01 | Category: FP | Reason: The scanner falsely assumes agent-forwarding is used; contextual verification proves it is not, making this a false positive.
* Finding 021 | Medium | 10.10.2.50 (web-srv-01) | Category: I | Reason: The TRACE method is a legacy scanner finding that rarely leads to actual exploitation in modern browsers, qualifying as noise.
* Finding 022 | Low | Multiple Hosts | Category: I | Reason: Clock skew generates log anomalies but offers zero direct exploitation value, categorizing it purely as non-actionable noise.
* Finding 023 | High | Clinical Workstations | Category: AS | Reason: Blocking USBs requires a massive policy rollout and clinical testing to avoid disrupting legitimate hospital workflows.
* Finding 024 | High | Imaging Devices | Category: AC | Reason: Cleartext DICOM actively leaks HIPAA-protected data on the wire, requiring immediate network-level encryption.
* Finding 025 | Medium | 10.10.2.20 (ad-dc-01) | Category: I | Reason: Zone transfers leak IPs, but on a flat network attackers already have full visibility, making this low-priority noise.
* Finding 026 | High | 10.10.2.15 (billing-srv-01) | Category: AS | Reason: Applying the outdated kernel patch requires rebooting a financial server, which must happen during scheduled downtime.
* Finding 027 | High | Multiple Hosts | Category: AC | Reason: Disabled AV leaves hosts completely blind to initial payloads, requiring a 24h emergency reactivation.
* Finding 028 | High | Unknown Linux Hosts | Category: AC | Reason: Shadow IT bypasses all organizational controls and must be physically hunted down and unplugged immediately.
* Finding 029 | High | Shadow IT | Category: AS | Reason: The Grafana traversal vulnerability is secondary; the primary action is taking the shadow IT host offline entirely.
* Finding 030 | Medium | 10.10.2.10 (ehr-srv-01) | Category: FP | Reason: Browsing by IP instead of hostname generates an error but is a user training issue, not a cryptographic vulnerability.
* Finding 031 | Critical | 10.10.2.10 (ehr-srv-01) | Category: AC | Reason: Ghostcat allows trivial unauthenticated exfiltration of EHR database credentials, demanding emergency mitigation.

---

## Triage Summary

* **Actionable Critical (AC):** 11
* **Actionable Standard (AS):** 12
* **Informational (I):** 6
* **False Positive (FP):** 2

---

## Actionable Findings List

**Priority 1: Actionable Critical (Immediate Remediation 24-48h)**
1. Finding 001 (Apache mod_lua RCE)
2. Finding 031 (Tomcat Ghostcat on EHR)
3. Finding 003 (PostgreSQL Unrestricted Access)
4. Finding 010 (BD Alaris Pump Firmware)
5. Finding 004 (Windows XP SMB on MRI)
6. Finding 016 (Philips IntelliVue Exposure)
7. Finding 024 (DICOM Cleartext Transmission)
8. Finding 008 (PrintNightmare on Print Server)
9. Finding 028 (Undocumented Shadow IT Devices)
10. Finding 027 (Inactive Sophos Endpoint Protection)
11. Finding 014 (Consumer-grade Router at Clinic)

**Priority 2: Actionable Standard (Scheduled Remediation 7-30 days)**
1. Finding 002 (Apache Local PrivEsc)
2. Finding 006 (MySQL Unrestricted Binding)
3. Finding 007 (LDAP Signing Not Required)
4. Finding 009 (SSH Password Auth)
5. Finding 011 (Ubuntu 18.04 EOL Migration)
6. Finding 026 (Linux Kernel Outdated)
7. Finding 015 (Synology NAS Exposed)
8. Finding 023 (USB Mass Storage Allowed)
9. Finding 019 (Internal RDP Enabled)
10. Finding 029 (Grafana Path Traversal)
11. Finding 018 (Weak Kerberos Encryption)
12. Finding 013 (SSL Certificate Expiring)
