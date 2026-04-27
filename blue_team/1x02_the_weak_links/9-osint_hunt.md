# 9-osint_hunt.md

## The OSINT Hunt: Uncovering the Blind Spots

### 1. FortiGate FortiOS Vulnerability
* **Source:** FortiGuard Labs Security Advisory (FG-IR-24-015) / NVD
* **CVE:** CVE-2024-21762
* **Affected Product:** FortiGate 100F (running FortiOS)
* **Why the Scan Missed It:** The automated scan was configured for internal subnets (10.10.0.0/16) and likely did not target the perimeter firewall's external management or SSL VPN interfaces. Furthermore, without authenticated API access to the FortiGate, OpenVAS cannot accurately fingerprint the exact FortiOS firmware version to flag the CVE.
* **CVSS / Severity:** 9.6 (Critical)
* **MedDefense Impact:** This vulnerability is an out-of-bounds write in the `sslvpnd` daemon. An unauthenticated remote attacker could execute arbitrary code or commands via specially crafted HTTP requests. Since the FortiGate 100F is the perimeter device, compromising it grants the attacker a direct pivot point into the entire internal flat network.
* **Recommendation:** Immediately upgrade the FortiOS firmware to a patched version (e.g., 7.4.3 or 7.2.7). If patching is not immediately possible, disable the SSL VPN service as a temporary mitigation.

### 2. Microsoft Office 365 / Entra ID Vulnerability
* **Source:** CISA Alerts / Microsoft Threat Intelligence Reports
* **CVE:** N/A (Attack Technique / Platform Abuse) - AiTM (Adversary-in-the-Middle) Phishing & MFA Fatigue
* **Affected Product:** Microsoft Office 365 E3 / Entra ID (Azure AD)
* **Why the Scan Missed It:** The scan methodology explicitly stated: *"This scan does NOT cover cloud services (O365)"*. The OpenVAS scanner was only probing local IP addresses, leaving the entire cloud identity perimeter unassessed.
* **CVSS / Severity:** High (Real-world risk equivalent to a Critical vulnerability)
* **MedDefense Impact:** Attackers actively target healthcare O365 tenants using reverse-proxy phishing frameworks (like Evilginx2) to intercept authentication tokens, bypassing traditional SMS or Authenticator App MFA. Once the session cookie is stolen, attackers gain full access to clinical emails, OneDrive, and SharePoint, allowing massive exfiltration of Protected Health Information (PHI) without touching the local network.
* **Recommendation:** Implement Phishing-Resistant MFA (such as FIDO2 security keys or Windows Hello for Business). Additionally, configure Entra ID Conditional Access policies to block access from unmanaged/unrecognized devices and locations outside the clinic's operating region.

### 3. Synology DSM Vulnerability
* **Source:** Synology Security Advisory (Synology-SA-22:20) / NVD
* **CVE:** CVE-2022-43931
* **Affected Product:** Synology NAS-01 (DSM 7.x)
* **Why the Scan Missed It:** The scan identified the NAS and its open ports (5000/5001) in Finding 015. However, because it was an unauthenticated scan, the scanner could only read the exposed web headers. It did not have the administrative credentials required to query the precise DSM core version and installed packages, resulting in a generic "Web Interface Accessible" finding rather than identifying the specific CVE.
* **CVSS / Severity:** 10.0 (Critical)
* **MedDefense Impact:** This is an out-of-bounds write vulnerability in the Out-of-Band (OOB) Management component of Synology DSM that allows remote attackers to execute arbitrary code. Since MedDefense stores its server backups completely unencrypted on this NAS (as noted in Finding 015), an attacker exploiting this CVE could wipe, encrypt, or exfiltrate the hospital's only fallback data, perfectly setting the stage for a devastating double-extortion ransomware attack.
* **Recommendation:** Update Synology DSM to the latest patched version (7.1.1 or newer). Concurrently, remove the NAS management interface from the general internal network and restrict it to a dedicated, strictly controlled IT administration VLAN.
