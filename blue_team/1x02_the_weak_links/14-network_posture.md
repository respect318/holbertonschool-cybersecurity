# 14-network_posture.md

## Network Posture & Segmentation Analysis

### 1. CVE-2021-44790 (Apache mod_lua Buffer Overflow)
* **Host:** 10.10.2.15 (billing-srv-01)
* **CVSS Base Score:** 9.8 (Critical)

**Scenario A: Current (flat network)**
* **Who can reach this vulnerability:** Any device on the `10.10.0.0/16` network, including compromised nurse workstations, exposed IoT medical devices, or a receptionist's PC that clicked a phishing link.
* **What the attacker can reach AFTER exploitation:** Once the attacker gains root on the billing server, they have unrestricted network access to the Domain Controller, the EHR Database, and the Backup NAS.
* **Effective Risk:** Critical (Total network compromise).

**Scenario B: Hypothetical (segmented network)**
* **Who can reach this vulnerability:** Only systems in a designated "Finance/Billing VLAN" or specific load balancers.
* **What the attacker can reach AFTER exploitation:** The attacker is trapped within the Billing VLAN. Firewalls block them from pinging or accessing clinical servers, medical devices, or the core domain infrastructure.
* **Effective Risk:** High (Financial data compromised, but the hospital survives).

**Risk Amplification Factor:** Massive. The flat network transforms a localized departmental breach into a hospital-wide catastrophic compromise.

---

### 2. CVE-2020-1938 (Tomcat AJP Ghostcat)
* **Host:** 10.10.2.10 (ehr-srv-01)
* **CVSS Base Score:** 9.8 (Critical)

**Scenario A: Current (flat network)**
* **Who can reach this vulnerability:** Every single IP in the hospital. Since it requires no authentication, anyone who can route to port 8009 can pull sensitive files from the Electronic Health Records application server.
* **What the attacker can reach AFTER exploitation:** By reading configuration files via Ghostcat, the attacker extracts database credentials and directly queries the EHR database (`10.10.2.11`) over the flat network to steal patient records.
* **Effective Risk:** Critical (Massive HIPAA breach and data extortion).

**Scenario B: Hypothetical (segmented network)**
* **Who can reach this vulnerability:** Only the reverse proxy/web front-end in the DMZ. Direct access to port 8009 from standard user workstations is blocked by ACLs.
* **What the attacker can reach AFTER exploitation:** Even if they exploit the web app and steal database credentials, a strict firewall between the Application Tier and the Database Tier drops their unapproved database connections.
* **Effective Risk:** Medium/High (Vulnerability exists, but exploitation path is structurally broken).

**Risk Amplification Factor:** High. The flat network enables trivial lateral movement, turning a localized file-read vulnerability into complete database exfiltration.

---

### 3. CVE-2017-0144 (MS17-010 / EternalBlue)
* **Host:** 10.10.1.70 (WS-RAD-01 - MRI Workstation)
* **CVSS Base Score:** 8.1 (High)

**Scenario A: Current (flat network)**
* **Who can reach this vulnerability:** A self-propagating ransomware worm (like WannaCry) executing on a phished HR laptop can scan the entire `10.10.0.0/16` range, find port 445 open on the MRI workstation, and infect it instantly.
* **What the attacker can reach AFTER exploitation:** The malware encrypts the MRI control system, completely halting radiological imaging and directly threatening patient lives. It then uses the MRI machine to infect infusion pumps and other legacy devices.
* **Effective Risk:** Critical (Physical danger to life).

**Scenario B: Hypothetical (segmented network)**
* **Who can reach this vulnerability:** The MRI workstation is placed in a highly restricted "Clinical Devices VLAN" and can only communicate with the PACS Image Server over a specific port. Standard laptops cannot reach it.
* **What the attacker can reach AFTER exploitation:** The ransomware on the HR laptop tries to scan for port 445 on the MRI machine, but the network switch/firewall drops the packets. The MRI machine is never infected.
* **Effective Risk:** Low (The vulnerability cannot be reached by the threat).

**Risk Amplification Factor:** Extreme. The flat network is the *only* reason this unpatchable, end-of-life medical device is exposed to general office malware.

---

## Network Posture Summary

The flat network architecture acts as a massive risk multiplier, elevating every localized software flaw into a systemic, hospital-wide threat. In a flat network, the "blast radius" of any single exploited vulnerability is the entire organization, enabling trivial lateral movement and unrestricted access to the most critical assets. Network segmentation is arguably far more impactful than patching any single CVE because patching is a reactive, never-ending battle against the latest zero-days and unpatchable legacy systems (like the Windows XP MRI). Segmentation, however, provides a proactive, structural defense that contains breaches, restricts lateral movement, and fundamentally breaks the attacker's kill chain, regardless of what software flaws exist on the isolated systems.
