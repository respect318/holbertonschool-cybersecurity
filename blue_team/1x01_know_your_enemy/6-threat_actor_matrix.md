# MedDefense Threat Actor Matrix

This matrix provides a consolidated view of the threat landscape targeting MedDefense, prioritizing actors based on their likelihood of targeting the organization and their potential operational impact.

| Actor Type | Likelihood | Capability | Primary Motivation | Preferred Vector | Primary Target | MedDefense Exposure (Gap IDs) |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Ransomware Groups (Organized Crime)** | **Critical** | High (RaaS model, specialized roles) | Financial Gain | Phishing / Unpatched VPN (IABs) | EHR Server / Backup NAS | GAP-01 (Unpatched perimeter), GAP-02 (Flat network), GAP-04 (Accessible backups) |
| **Insider (Negligent)** | **High** | N/A (Accidental/Unintentional) | Helpfulness / Convenience | Shadow IT / Weak Password Hygiene | Patient EHR Records | GAP-05 (Shared credentials), GAP-07 (Lack of awareness training) |
| **Unskilled / Opportunistic** | **High** | Low (Automated tools/AI-assisted) | Financial Gain (Cryptojacking) | Automated Vulnerability Scanners | Billing Server / Public Web Server | GAP-01 (Unpatched Apache/FortiGate) |
| **Insider (Malicious)** | **Medium** | High (Authorized access, internal knowledge) | Revenge / Financial Gain | Privilege Abuse / Ghost Accounts | Production Databases / PII | GAP-06 (Manual offboarding), GAP-03 (No behavioral monitoring) |
| **Nation-State APT** | **Low** | Very High (Custom tools, Zero-days) | Espionage | Zero-day exploits / Supply Chain | Pharmaceutical R&D (if any) | GAP-01 (Vulnerable perimeter) |
| **Hacktivist** | **Low** | Low to Medium | Philosophical / Political | DDoS / Website Defacement | Public Website / Patient Portal | GAP-01 (Web server vulnerabilities) |

---

## Top 3 Priority Ranking

### 1. Ransomware Groups (Organized Crime)
**Justification:** This represents the single greatest threat to MedDefense's operational existence. The likelihood is categorized as Critical due to the high frequency of attacks in the regional healthcare sector (3 hospitals hit in 8 months) and the fact that MedDefense matches the ideal "Tier 1" target profile for RaaS affiliates. The potential impact is catastrophic: BlackReef-style groups specifically target backups first (GAP-04) and leverage the flat network (GAP-02) to ensure a total hospital lockout. The double-extortion model poses both a massive financial and a severe regulatory (HIPAA) risk.

### 2. Insider (Negligent)
**Justification:** While the individual impact of a negligent act may be lower than a ransomware attack, the frequency is significantly higher. Clinical staff at MedDefense prioritize speed of care, leading to widespread use of shared credentials in Radiology (GAP-05) and unauthorized Shadow IT devices like personal NAS drives (Scenario 3). These actions create "soft" openings that can be exploited by external actors or result in direct HIPAA breaches through accidental data exposure. Negligence is a persistent, daily drain on the organization’s security posture.

### 3. Unskilled / Opportunistic Attacker
**Justification:** This actor is a priority due to proven ongoing activity. The discovery of a crypto-miner on `billing-srv-01` confirms that automated scanners have already identified and exploited MedDefense’s unpatched public-facing assets (GAP-01). While these attackers often seek low-level financial gain (computational power), their presence indicates that the "front door" is unlocked. If an opportunistic attacker can drop a miner, a more sophisticated affiliate can just as easily drop a ransomware payload using the same entry point.

---
