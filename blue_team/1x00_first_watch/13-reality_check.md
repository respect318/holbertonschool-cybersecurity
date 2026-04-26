# Reality Check: Real-World Breach Correlation

### Breach 1: Ransomware via Remote Access
* **Attack Vector Identification:** The initial entry point was a compromised employee credential obtained via phishing, which was then used to access the hospital's VPN. The primary weakness exploited was the lack of Multi-Factor Authentication (MFA) on remote access portals, allowing the attacker to enter the network and deploy ransomware.
* **MedDefense Correlation:** Once inside, this attack would succeed at MedDefense due to **GAP-003** (Absence of Centralized Logging/SIEM, meaning the intrusion goes unnoticed) and **GAP-004** (Missing Endpoint Protection on servers, allowing the ransomware to execute).
* **Blind Spot Check:** **YES.** While we identified VPN risks, we did not create a specific gap for the lack of MFA on remote access. 
  * **New Gap Identification:**
    * **Gap ID:** GAP-011
    * **Title:** Lack of Multi-Factor Authentication (MFA) on VPN
    * **Affected Asset(s):** FortiGate Firewall / VPN Gateway [Critical]
    * **Data at Risk:** Entire Network / All Data [Restricted]
    * **Current Control Status:** Weak (C-001 VPN rules allow access with only a password)
    * **What is Missing:** Technical Preventive (Multi-Factor Authentication)
    * **Risk Level:** Critical
    * **Risk Justification:** Affects Critical perimeter assets; compromised credentials guarantee direct access to the internal flat network.
    * **Potential Impact:** Attackers can bypass the perimeter instantly using stolen passwords, gaining full internal access to deploy ransomware or steal PHI.

### Breach 2: Lateral Movement via Medical IoT
* **Attack Vector Identification:** Attackers breached an external-facing system and then pivoted to unpatched, legacy medical IoT devices. The weakness exploited was a flat network architecture that allowed attackers to move laterally from general IT systems directly into life-critical medical equipment and core databases.
* **MedDefense Correlation:** This perfectly aligns with **GAP-001** (Flat Network Exposing Medical IoT) and **GAP-005** (End-of-Life MRI Workstation). 
* **Blind Spot Check:** **NO.** This exact scenario is thoroughly covered by GAP-001, which highlights the catastrophic risk of mixing clinical workstations, unpatched IoT (BD Alaris pumps), and legacy systems on the same 10.10.0.0/16 broadcast domain.

### Breach 3: Backup Destruction and Total Data Loss
* **Attack Vector Identification:** A ransomware gang specifically targeted the hospital's backup infrastructure before deploying the final encryption payload. The weakness exploited was storing backups on the same network and physical location as the primary servers, with no offline or immutable cloud replication.
* **MedDefense Correlation:** This directly correlates with **GAP-002** (Single Point of Failure for Disaster Recovery). 
* **Blind Spot Check:** **NO.** This vulnerability is already fully documented in GAP-002, which specifically warns that the local Synology NAS is highly vulnerable to a network-wide encryption event.

***

### Priority Reassessment
Based on the real-world data, the priority of **GAP-001 (Flat Network)** and **GAP-002 (Local Backups Only)** is completely validated as **Critical** and must remain the absolute top priority. However, I would upgrade the newly identified **GAP-011 (Lack of MFA on VPN)** to immediate **Critical** status. Real-world data proves that attackers do not "hack" in; they log in using stolen credentials. Securing the perimeter with MFA is the fastest way to drastically reduce initial compromise likelihood before the network segmentation (GAP-001) project is completed.

### Pattern Analysis
Across all three real-world breaches, the common factor is that attackers rely on exploiting basic IT hygiene failures—stolen passwords without MFA, flat unsegmented networks, and accessible on-premise backups—rather than using highly sophisticated zero-day exploits. This tells us that MedDefense should focus its limited security budget exclusively on fundamental cyber resilience: implementing MFA for all remote access, creating network VLANs to isolate medical IoT/legacy devices, and establishing an immutable, offline backup strategy. Fixing these foundational gaps provides exponentially more protection than buying advanced security tools.
