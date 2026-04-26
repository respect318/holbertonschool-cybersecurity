# Gap-Threat Correlation Report: MedDefense

This report recalibrates the security priorities of MedDefense by correlating documented infrastructure gaps (Project 1x00) with observed threat actor behaviors, kill chains, and scenarios (Project 1x01).

---

## Gap-Threat Correlation Matrix

### Gap ID: GAP-01
* **Gap Description:** Unpatched public-facing services (Apache 2.4.29, FortiGate firmware).
* **Original Risk Level:** High
* **Threat Actors:** Organized Crime (BlackReef), Unskilled/Opportunistic, Nation-State APT.
* **Kill Chains:** Kill Chain #1 (Ransomware), Kill Chain #3 (Crypto-miner).
* **Scenarios:** Scenario #1 (BlackReef Campaign).
* **Updated Risk Level:** **CRITICAL** (Upgraded)
* **Justification:** Threat analysis proves this is the primary "front door" for the organization's most dangerous adversaries. It is no longer a theoretical risk; the presence of a crypto-miner confirms it is actively being exploited.

### Gap ID: GAP-02
* **Gap Description:** Flat network architecture with no internal segmentation.
* **Original Risk Level:** High
* **Threat Actors:** All (Organized Crime, Insiders, Nation-State, Hacktivists).
* **Kill Chains:** Kill Chain #1, #3, #4, #5.
* **Scenarios:** Scenario #1, #2.
* **Updated Risk Level:** **CRITICAL** (Upgraded)
* **Justification:** The flat network appears in nearly every kill chain as the primary enabler of lateral movement. It transforms a single workstation breach into a total hospital compromise.

### Gap ID: GAP-04
* **Gap Description:** Non-isolated/Network-accessible backup infrastructure (NAS).
* **Original Risk Level:** High
* **Threat Actors:** Organized Crime, Insider (Malicious).
* **Kill Chains:** Kill Chain #1, #4.
* **Scenarios:** Scenario #1, #2.
* **Updated Risk Level:** **CRITICAL** (Upgraded)
* **Justification:** BlackReef's playbook specifically targets backups to ensure payment. Threat analysis shows that without isolated backups, MedDefense has zero recovery capability against its top threat.

### Gap ID: GAP-06
* **Gap Description:** Manual and delayed employee offboarding process.
* **Original Risk Level:** Medium
* **Threat Actors:** Insider (Malicious), Organized Crime (credential abuse).
* **Kill Chains:** Kill Chain #4 (Terminated Admin).
* **Scenarios:** Scenario #2, Scenario #3.
* **Updated Risk Level:** **HIGH** (Upgraded)
* **Justification:** Originally seen as an administrative delay, threat modeling reveals it is a critical enabler for "ghost accounts" that allow long-term unauthorized access post-termination.

### Gap ID: GAP-03
* **Gap Description:** Lack of centralized monitoring, SIEM, or behavioral auditing.
* **Original Risk Level:** High
* **Threat Actors:** Organized Crime, Supply Chain, Insider (Malicious/Negligent).
* **Kill Chains:** Kill Chain #2, #4.
* **Scenarios:** Scenario #2, #3.
* **Updated Risk Level:** **HIGH** (Stayed Same)
* **Justification:** The lack of visibility ensures that "low and slow" attacks (like Scenario 3) or internal sabotage go completely unnoticed until the damage is irreversible.

### Gap ID: GAP-08
* **Gap Description:** Lack of removable media (USB) controls and unmanaged endpoints.
* **Original Risk Level:** Medium
* **Threat Actors:** Insider (Negligent), Insider (Malicious).
* **Kill Chains:** Kill Chain #5.
* **Scenarios:** Scenario #2 (Insider Data Theft).
* **Updated Risk Level:** **HIGH** (Upgraded)
* **Justification:** Threat analysis shows that USB drives are the primary vector for data exfiltration in insider scenarios where network-based exfiltration might be risky for the actor.

---

## Re-prioritized Gap List (Threat-Informed)

1. **GAP-02: Flat Network Architecture** [UPGRADED to CRITICAL]
2. **GAP-01: Unpatched Perimeter Services** [UPGRADED to CRITICAL]
3. **GAP-04: Non-isolated Backups** [UPGRADED to CRITICAL]
4. **GAP-03: Lack of Monitoring/SIEM** [STAYED HIGH]
5. **GAP-06: Manual Offboarding** [UPGRADED to HIGH]
6. **GAP-08: Unmanaged Endpoints/USB** [UPGRADED to HIGH]
7. **GAP-05: Shared Credentials** [STAYED MEDIUM]
8. **GAP-07: Low Training Completion** [STAYED MEDIUM]

---

## The Critical Three

The following three gaps represent the "Core Failure Chain" at MedDefense. Closing these three would disrupt approximately 90% of the attack paths identified in this project:

1. **GAP-02 (Flat Network):** By implementing segmentation, we break the "Lateral Movement" phase in every kill chain.
2. **GAP-01 (Unpatched Perimeter):** By hardening the VPN and web servers, we eliminate the primary "Initial Access" vector for external actors.
3. **GAP-04 (Non-isolated Backups):** By air-gapping backups, we negate the primary "Impact" (extortion leverage) of ransomware groups.

---

## The Surprise: GAP-06 (Manual Offboarding)

In Project 1x00, **GAP-06 (Manual Offboarding)** was rated as **Medium** because it was viewed as an inefficient administrative task. However, after the threat analysis in 1x01, it has been upgraded to **High**. 

**What changed:** We discovered through Scenario #2 and Scenario #3 that administrative "ghost accounts" are a primary weapon for malicious insiders and a key persistence mechanism for external attackers using vendor credentials. The realization that an account can remain active for 5+ days after termination in a high-urgency healthcare environment creates a massive, undefended window of opportunity that was previously undervalued.
