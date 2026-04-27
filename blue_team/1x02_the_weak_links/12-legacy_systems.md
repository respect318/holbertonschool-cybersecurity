# 12-legacy_systems.md

## Permanent Exposure: The EOL Reality
An "unpatched" vulnerability means a fix exists from the vendor, but the organization has simply failed to apply it yet; the risk is remediable. An "End-of-Life" (EOL) system is categorically different because no future patches will ever be created by the vendor, regardless of how severe a new vulnerability is. You can never close this risk through patching alone because the software architecture itself becomes increasingly obsolete and indefensible against modern exploitation techniques, requiring isolation or full replacement as the only true mitigations.

---

## System 1: Windows XP SP3 (10.10.1.70, MRI Workstation)

* **EOL Research:** * *Results:* A search for Windows XP vulnerabilities published in the last 2 years technically yields **0 new results**, but not because it is secure. It is because researchers and Microsoft no longer even bother testing or filing CVEs for an OS that died in 2014. The system is structurally vulnerable to practically every modern SMB and RDP exploit.
  * *Most Critical:* CVE-2017-0144 (EternalBlue - CVSS 8.1) and CVE-2019-0708 (BlueKeep - CVSS 9.8) remain the most historically devastating flaws still active on this machine.
* **Scan Findings:** Finding 004 (Microsoft Windows XP End-of-Life Detection, featuring MS17-010, BlueKeep, MS08-067). These are explicitly exploitable *because* the OS is EOL and Microsoft stopped providing security updates for these protocols a decade ago.
* **Compensating Controls:** In 1x00 (T6), the standard compensating control proposed for legacy medical devices is **strict Network Segmentation (VLAN Isolation)**. However, the scan report explicitly states this MRI workstation is on the flat network (10.10.1.0/24). The controls completely failed. 
  * *Recommendation:* Immediately place this workstation in an isolated Clinical VLAN. Implement a strict hardware firewall rule that only allows inbound/outbound DICOM traffic specifically to the PACS server (`10.10.2.12`), dropping all SMB and RDP traffic.

## System 2: Windows Server 2012 R2 (10.10.2.31, Print Server)

* **EOL Research:** * *Results:* Standard support ended in late 2023. Searching NVD for Windows Server 2012 R2 in the last 2 years yields **40+ critical results** as the core NT kernel shares architecture with newer OSs, but this specific version no longer gets the fixes.
  * *Most Critical:* CVE-2021-34527 (PrintNightmare - CVSS 8.8) and CVE-2022-38023 (Netlogon Elevation of Privilege - CVSS 8.1).
* **Scan Findings:** Finding 008 (Windows Server 2012 R2 End-of-Life / PrintNightmare). The Print Spooler vulnerability is highly exploitable precisely because security patches for this specific OS version ceased, leaving known exploits permanently open.
* **Compensating Controls:** For a central print server, isolation is incredibly difficult because every workstation needs to communicate with it. 
  * *Recommendation:* Since network isolation isn't feasible, compensating controls must focus on identity: enforce strict Group Policy restrictions on who can install print drivers, disable the print spooler on all other servers, and strictly monitor RPC traffic targeting this host.

## System 3: Ubuntu 18.04 LTS (10.10.2.15, Billing Server)

* **EOL Research:** * *Results:* Standard support ended in mid-2023. In the last 2 years, there are **50+ critical results** affecting core Linux packages (Kernel, glibc, OpenSSH) utilized in 18.04. 
  * *Most Critical:* CVE-2023-4911 (Looney Tunables - CVSS 7.8 Local PrivEsc) and CVE-2024-1086 (Linux Kernel Use-After-Free PrivEsc - CVSS 7.8).
* **Scan Findings:** Finding 001 (Apache mod_lua RCE), Finding 002 (Apache PrivEsc), Finding 006 (MySQL Unrestricted Binding), Finding 009 (SSH Password Auth), Finding 011 (Ubuntu 18.04 EOL), and Finding 026 (Outdated Kernel). The kernel and Apache vulnerabilities are directly exploitable because the base OS no longer receives standard `apt` package security updates.
* **Compensating Controls:** Currently, no compensating controls exist (the database is bound to 0.0.0.0 and SSH is open). 
  * *Recommendation:* If migration is delayed, MedDefense MUST purchase an Ubuntu Pro (ESM - Extended Security Maintenance) license to instantly resume receiving security patches for the kernel and Apache. 

---

## Business Decision: Migration Priority

If MedDefense has the budget to migrate only **ONE** of these systems off EOL in the next quarter, it must be **System 3: Ubuntu 18.04 LTS (billing-srv-01)**.

**Justification:**
While the MRI workstation (Windows XP) represents a direct threat to patient safety (Asset Criticality), medical devices are typically closed FDA-regulated appliances. IT cannot simply "upgrade" an MRI machine to Windows 11; it requires purchasing a new, multi-million-dollar medical apparatus. The immediate risk to the MRI can be effectively neutralized with a *zero-cost compensating control*: Network Isolation (VLAN/ACLs). 

Conversely, `billing-srv-01` is a standard IT web server holding highly sensitive financial records. From a Threat Exposure standpoint (1x01), it is the most heavily targeted node on the network. It currently has a complete, unauthenticated exploit chain (CVSS 9.8 RCE + Local PrivEsc) exposed to a flat network. Migrating a Linux web/database server to a modern OS (like Ubuntu 22.04 LTS or 24.04 LTS) is a low-cost, standard IT operation that immediately eliminates the most active and weaponized initial access vector present in the entire hospital environment.
