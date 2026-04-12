# First Impressions Summary

## 1. Scan Metadata
- **Target Scanned:** 10.10.0.0/16 (all internal subnets), total 47 responsive hosts.
- **When:** [Current - 5 days], during off-peak hours (02:00-06:00).
- **By Whom:** Executed by SecurePoint Consulting, requested by James Chen.
- **Scan Policy:** Full and Deep (authenticated where credentials were available).
- **NOT Scanned:** Cloud services (O365), mobile devices (iPads), and assets that were offline during the scan window. Medical devices were scanned unauthenticated.

## 2. Finding Distribution
- **Critical:** 4
- **High:** 7
- **Medium:** 11
- **Low:** 5
- **Informational:** 4
- **Highest Category:** Medium severity has the most findings (11 findings).

## 3. Asset Heat Map (Top 5 Hosts by Finding Count)
1. **10.10.2.15 (billing-srv-01):** 6 findings (001, 002, 006, 009, 011, 026)
2. **10.10.2.10 (ehr-srv-01):** 4 findings (017, 022, 030, 031)
3. **10.10.2.50 (web-srv-01):** 4 findings (005, 012, 013, 021)
4. **10.10.2.20 (ad-dc-01):** 3 findings (007, 018, 025)
5. **10.10.2.41 (NAS-01)** / **10.10.1.70 (WS-RAD-01):** 1-2 direct findings, but highly critical roles.
*(Note: Multiple clinical workstations and medical devices also share grouped findings).*

## 4. First Observations
- **Patterns:** A major pattern is the presence of End-of-Life (EOL) operating systems (Windows XP, Windows Server 2012, Ubuntu 18.04 without ESM) and misconfigurations in a flat network environment (no VLAN isolation).
- **Critical Concentration:** Critical findings are somewhat spread out (1 on MRI workstation, 1 on EHR database), but **two Critical findings are concentrated on a single host** (`billing-srv-01`).
- **Related Findings:** Finding 001 (RCE) and Finding 002 (Privilege Escalation) on `billing-srv-01` are directly related and form a complete exploit chain to root. 
- **Surprises:** The presence of unauthorized "Shadow IT" Linux devices (Findings 028, 029) exposing Jupyter and Grafana, and the fact that medical infusion pumps have unchanged default credentials (admin/admin).

## 5. Scan Limitations
- **What it does NOT tell us:** It does not provide information about active exploitation, zero-day vulnerabilities, or vulnerabilities on assets that were powered off. It also provides limited visibility into medical devices since they were scanned without credentials. It is only a point-in-time snapshot, meaning vulnerabilities disclosed after the scan date are not included.
