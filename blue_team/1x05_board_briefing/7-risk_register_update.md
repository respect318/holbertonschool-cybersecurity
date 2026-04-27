# Risk Register Update: Crimson Tide Campaign

## Part 1 - Updated Risk Entry: Ransomware (RISK-002)

* **Risk ID:** RISK-002
* **Risk Description:** Targeted ransomware attack resulting in data exfiltration and total system encryption.
* **Threat Source:** Crimson Tide (CT) RaaS Affiliate Group.
* **Vulnerability:** Flat network architecture and unencrypted backups/databases.
* **Likelihood (ARO):** 2.0 (Previously 0.25)
* **Impact (SLE):** $1,500,000 (Includes data breach liability).
* **ALE:** $3,000,000.
* **Treatment Justification:** The previous "Mitigate" decision is now an **Emergency Priority**. The current budget allocation must be expanded immediately. The cost of controls (EDR, Segmentation) is now negligible compared to the 10x increase in ALE.
* **New KRI (Key Risk Indicator):** Number of unauthorized `rclone.exe` executions or detection of outbound traffic exceeding 5GB to cloud storage providers (e.g., mega.nz) within a 24-hour window.

---

## Part 2 - New Entry: Edge Device Vulnerability (RISK-NEW-001)

| Field | Details |
| :--- | :--- |
| **Risk ID** | RISK-NEW-001 |
| **Risk Name** | Critical Perimeter Remote Code Execution (CVE-2023-27997) |
| **Description** | Unauthenticated buffer overflow in FortiGate SSL-VPN allowing full system takeover. |
| **Owner** | Sarah Park (IT Manager) |
| **Likelihood** | High (Actively exploited in region) |
| **Impact** | Critical (Complete loss of perimeter control and internal access) |
| **SLE** | $1,500,000 |
| **ARO** | 2.0 |
| **ALE** | $3,000,000 |
| **Treatment Decision** | **MITIGATE** (Immediate Patching) |
| **Mitigation Cost** | $2,400 (Support contract renewal fee) |

**Cost-Benefit Analysis:**
The cost to mitigate ($2,400) represents only **0.08%** of the annual risk ($3,000,000). The mitigation cost is profoundly justified; every hour the system remains unpatched, the organization effectively "leaks" risk value at an unsustainable rate.

---

## Part 3 - Register Governance Test

**Does the Crimson Tide advisory qualify as an out-of-cycle review trigger?**
**Yes.**

**Trigger Criteria Quote (from 1x03):**
> "An out-of-cycle review is triggered by a significant change in the threat landscape, the discovery of a critical vulnerability in a core asset, or a security incident at a peer organization within the same sector/region."

**Explanation:**
The Crimson Tide event meets **all three** criteria:
1.  **Threat Landscape Change:** A specific RaaS group (Crimson Tide) is actively targeting the healthcare sector with a high-velocity campaign.
2.  **Critical Vulnerability:** CVE-2023-27997 is a 9.8 CVSS vulnerability discovered on the FortiGate 100F, which is MedDefense's sole perimeter defense.
3.  **Peer Incident:** The advisory confirms "Hospital C," located only 45 miles from MedDefense, was compromised 3 days ago.
