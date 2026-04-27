# 13-web_exposure.md

## Web Exposure Analysis

### 1. Host: web-srv-01 (10.10.2.50) - Patient Portal
* **Exposure:** Internet-facing
* **Findings:** Finding 012 (Missing HTTP Security Headers), Finding 021 (HTTP TRACE method enabled).
* **Combined Risk:** Medium / High. While the individual vulnerabilities are medium severity, the internet-facing nature of the portal amplifies the risk. 
* **Attack Scenario:** An external attacker targets patients using the portal. By leveraging the missing security headers and the enabled TRACE method, the attacker executes Cross-Site Scripting (XSS) or Cross-Site Tracing (XST) attacks. This allows them to steal patient session cookies, bypass authentication, and access Protected Health Information (PHI) directly from the internet.
* **Priority:** 2. Despite having no critical CVEs, its direct exposure to the public internet makes it a highly attractive and accessible target for initial compromise.

### 2. Host: ehr-srv-01 (10.10.2.10) - EHR Application Server
* **Exposure:** Internal but flat network accessible
* **Findings:** Finding 017 (Apache Tomcat Information Disclosure - default error pages), Finding 031 (Tomcat AJP Ghostcat - CVSS 9.8), Finding 030 (TLS Certificate Common Name Mismatch).
* **Combined Risk:** Critical.
* **Attack Scenario:** An attacker gains an initial foothold on a low-level clinical workstation (e.g., via phishing). Because the network is flat, they can scan the internal network and hit the EHR server. They see the default Tomcat error page (Finding 017) which reveals the exact version of Tomcat running. Knowing the version, the attacker deploys the Ghostcat exploit (Finding 031) to read the `web.xml` file, extracts the database credentials, and pivots to the EHR database to steal all medical records.
* **Priority:** 1 (Highest). This server holds the most sensitive data in the hospital and possesses a trivial, unauthenticated Remote Code Execution/File Read vulnerability.

### 3. Host: nas-srv-01 - Backup NAS
* **Exposure:** Internal but flat network accessible
* **Findings:** Finding 015 (Synology NAS management web interface unnecessarily exposed to the entire network).
* **Combined Risk:** High.
* **Attack Scenario:** A Ransomware-as-a-Service (RaaS) affiliate breaches the network. Before deploying the ransomware payload, they actively hunt for backups. They find the NAS web interface on the flat network. They either brute-force the admin credentials (if default/weak) or use an unauthenticated DSM exploit (like CVE-2022-43931) to log in and permanently wipe the hospital's disaster recovery backups, forcing the hospital to pay the ransom.
* **Priority:** 3. While critical for business continuity, it generally requires a secondary step (brute-force or 0-day exploit) to compromise compared to the readily exploitable Ghostcat on the EHR server.

---

## The Value of "Medium" Information Disclosure Findings

Finding 017 (Tomcat information disclosure) led SecurePoint to manually discover Finding 031 (Ghostcat - CVSS 9.8). 

**What does this tell you?**
It proves that "Medium" or "Low" severity findings that reveal version information are actually the foundational blueprints for critical attacks. Information disclosure is the equivalent of the Reconnaissance phase in the cyber kill chain. An attacker (or a penetration tester) does not blindly throw exploits at a server; they use version disclosures to accurately fingerprint the software stack. By simply reading the version number leaked on an error page, the security team (and potential attackers) knew exactly which CVEs the server was vulnerable to, turning a "Medium" information leak into a "Critical" system compromise. Dismissing reconnaissance findings as "low risk" gives attackers the exact intelligence they need to weaponize their attacks.
