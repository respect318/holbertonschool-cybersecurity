Control 1: Network segmentation (VLAN implementation for server, workstation, medical device and guest zones)
CIS Control Reference: CIS Control 12
Annual Cost: $15,000 ($0 licensing + $15,000 external engineering labor)
Risk(s) Addressed: Ransomware encrypts EHR system / Complete Enterprise Breach
ALE Reduction: $850,000 (Drastically reduces the Exposure Factor by containing lateral movement)
Net Value: $835,000
Verdict: Justified
Recommendation: Implement; this is the structural foundation of the defense strategy and provides massive impact for a purely labor-based cost.

Control 2: MFA deployment on VPN and administrative accounts
CIS Control Reference: CIS Control 6
Annual Cost: $5,000 ($0 license via existing O365 E3 + $5,000 IT labor)
Risk(s) Addressed: Complete Enterprise Breach via Compromised VPN
ALE Reduction: $1,380,000 (Neutralizes credential-based initial access vectors)
Net Value: $1,375,000
Verdict: Justified
Recommendation: Implement; this is the highest ROI control available and should be deployed immediately.

Control 3: Enterprise SIEM deployment (Wazuh, open-source)
CIS Control Reference: CIS Control 8 & 13
Annual Cost: $65,000 ($5,000 cloud infrastructure + $60,000 internal engineering/tuning labor)
Risk(s) Addressed: Delayed Incident Response
ALE Reduction: $70,000 (Provides visibility, but MedDefense lacks the dedicated IR staff to act quickly on the alerts)
Net Value: $5,000
Verdict: Marginal
Recommendation: Defer; "open-source" does not mean free, as the massive labor cost to tune rules will overwhelm a small team; rely on automated blocking (EDR) first.

Control 4: Offsite backup replication (cloud immutable storage, AWS S3 Glacier)
CIS Control Reference: CIS Control 11
Annual Cost: $8,000 ($3,000 AWS Glacier storage + $5,000 testing labor)
Risk(s) Addressed: Ransomware encrypts EHR system
ALE Reduction: $400,000 (Eliminates total data loss and reduces downtime)
Net Value: $392,000
Verdict: Justified
Recommendation: Implement; cheap, immutable cloud storage guarantees survival against a catastrophic ransomware event.

Control 5: Endpoint Detection and Response upgrade (Sophos Intercept X)
CIS Control Reference: CIS Control 10
Annual Cost: $30,000 ($25,000 licensing + $5,000 deployment labor)
Risk(s) Addressed: Widespread Malware Infection / Ransomware Execution
ALE Reduction: $180,000 (Automates the blocking of fileless malware and ransomware behaviors)
Net Value: $150,000
Verdict: Justified
Recommendation: Implement; for a small team, an automated prevention tool like EDR yields a much better ROI than manually monitoring a SIEM.

Control 6: Dedicated firewall for Westside Clinic
CIS Control Reference: CIS Control 4 & 12
Annual Cost: $4,000 ($1,500 hardware + $2,500 configuration)
Risk(s) Addressed: Opportunistic Branch Compromise
ALE Reduction: $80,000 (Secures a vulnerable perimeter bridging into the main network)
Net Value: $76,000
Verdict: Justified
Recommendation: Implement; replacing an unmanaged consumer router with an enterprise firewall is a foundational hygiene requirement.

Control 7: 24/7 Security Operations Center staffing (outsourced managed SOC)
CIS Control Reference: CIS Control 13 & 17
Annual Cost: $150,000 (Annual MSSP contract)
Risk(s) Addressed: Advanced Persistent Threats / After-hours compromises
ALE Reduction: $120,000 (Faster response to alerts)
Net Value: -$30,000
Verdict: Not Justified
Recommendation: Reject; this control exceeds the entire security budget and yields a negative ROI until foundational controls (like MFA and segmentation) are built.

Control 8: Full medical device network isolation with dedicated monitoring
CIS Control Reference: CIS Control 12
Annual Cost: $80,000 ($40,000 specialized IoT licenses + $40,000 labor)
Risk(s) Addressed: Patient Safety Incident via Legacy Clinical Software
ALE Reduction: $60,000
Net Value: -$20,000
Verdict: Not Justified
Recommendation: Reject; this is an over-engineered, expensive vendor solution; standard VLANs (Control 1) achieve 80% of this isolation for a fraction of the cost.

### Cost-Benefit Summary Table

| Rank | Control | Annual Cost | ALE Reduction | Net Value | Verdict | Fits in $120k Budget? |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **1** | MFA on VPN/Admin (C2) | $5,000 | $1,380,000 | **$1,375,000** | Justified | **Yes** |
| **2** | Network segmentation (C1) | $15,000 | $850,000 | **$835,000** | Justified | **Yes** |
| **3** | Offsite immutable backups (C4) | $8,000 | $400,000 | **$392,000** | Justified | **Yes** |
| **4** | EDR upgrade (C5) | $30,000 | $180,000 | **$150,000** | Justified | **Yes** |
| **5** | Dedicated clinic firewall (C6) | $4,000 | $80,000 | **$76,000** | Justified | **Yes** |
| **6** | Enterprise SIEM (C3) | $65,000 | $70,000 | **$5,000** | Marginal | No (Exceeds remaining buffer) |
| **7** | Dedicated IoT monitoring (C8) | $80,000 | $60,000 | **-$20,000** | Not Justified | No |
| **8** | 24/7 Outsourced SOC (C7) | $150,000 | $120,000 | **-$30,000** | Not Justified | No (Blows entire budget) |

**Budget Allocation Summary:** By implementing the 5 highest-ranked "Justified" controls (MFA, Segmentation, Backups, EDR, and the Branch Firewall), MedDefense will spend **$62,000**. This strategically mitigates the most critical ALEs while leaving $58,000 of the $120,000 budget available for unforeseen IT challenges or future phases, proving sound fiscal responsibility to the CFO.
