Control 1: Network segmentation (VLAN implementation for server, workstation, medical device and guest zones)
CIS Control Reference: CIS Control 12
Annual Cost: $15,000 ($0 licensing + $15,000 IT consulting labor)
Risk(s) Addressed: Ransomware encrypts EHR system
ALE Reduction: $850,000
Net Value: $835,000
Verdict: Justified
Recommendation: Implement; this provides the foundational architecture to stop lateral movement and yields massive ROI for a purely labor-based cost.

Control 2: MFA deployment on VPN and administrative accounts
CIS Control Reference: CIS Control 6
Annual Cost: $5,000 ($0 license via existing O365 E3 + $5,000 internal labor)
Risk(s) Addressed: Complete Enterprise Breach via Compromised VPN
ALE Reduction: $1,380,000
Net Value: $1,375,000
Verdict: Justified
Recommendation: Implement; this is the highest ROI control available and directly neutralizes the most common initial access vector.

Control 3: Enterprise SIEM deployment (Wazuh, open-source)
CIS Control Reference: CIS Control 8 & 13
Annual Cost: $85,000 ($5,000 cloud infrastructure + $80,000 dedicated SIEM engineer labor)
Risk(s) Addressed: Delayed Incident Response
ALE Reduction: $60,000
Net Value: -$25,000
Verdict: Not Justified
Recommendation: Reject; "open-source" does not mean free, as the massive hidden labor costs to tune the rules far exceed the actual risk reduction for a small team.

Control 4: Offsite backup replication (cloud immutable storage, AWS S3 Glacier)
CIS Control Reference: CIS Control 11
Annual Cost: $8,000 ($3,000 AWS Glacier storage + $5,000 testing/labor)
Risk(s) Addressed: Ransomware encrypts EHR system
ALE Reduction: $400,000
Net Value: $392,000
Verdict: Justified
Recommendation: Implement; cheap, immutable cloud storage guarantees MedDefense can recover from a destructive ransomware event without paying the ransom.

Control 5: Endpoint Detection and Response upgrade (Sophos Intercept X)
CIS Control Reference: CIS Control 10
Annual Cost: $30,000 ($25,000 licensing + $5,000 deployment labor)
Risk(s) Addressed: Widespread Malware Infection / Ransomware Execution
ALE Reduction: $180,000
Net Value: $150,000
Verdict: Justified
Recommendation: Implement; upgrading to an automated prevention tool like modern EDR yields a strong return by stopping fileless malware before it spreads.

Control 6: Dedicated firewall for Westside Clinic
CIS Control Reference: CIS Control 4 & 12
Annual Cost: $4,000 ($1,500 hardware + $2,500 configuration labor)
Risk(s) Addressed: Opportunistic Branch Compromise
ALE Reduction: $5,000
Net Value: $1,000
Verdict: Marginal
Recommendation: Defer; while a good practice, the Westside clinic handles minimal local data, making the financial ROI extremely thin right now compared to core network needs.

Control 7: 24/7 Security Operations Center staffing (outsourced managed SOC)
CIS Control Reference: CIS Control 13 & 17
Annual Cost: $150,000 (Annual MSSP contract)
Risk(s) Addressed: Advanced Persistent Threats / After-hours compromises
ALE Reduction: $120,000
Net Value: -$30,000
Verdict: Not Justified
Recommendation: Reject; this single control completely blows the entire $120,000 security budget and ultimately yields a negative Net Value.

Control 8: Full medical device network isolation with dedicated monitoring
CIS Control Reference: CIS Control 12
Annual Cost: $80,000 ($40,000 specialized IoT licenses + $40,000 implementation labor)
Risk(s) Addressed: Patient Safety Incident via Legacy Clinical Software
ALE Reduction: $85,000
Net Value: $5,000
Verdict: Marginal
Recommendation: Defer; this is an over-engineered, expensive vendor solution that barely breaks even; standard VLANs (Control 1) will provide enough baseline protection for now.

### Cost-Benefit Summary Table

| Rank | Control | Annual Cost | ALE Reduction | Net Value | Verdict | Fits in $120k Budget? |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **1** | MFA on VPN/Admin (C2) | $5,000 | $1,380,000 | **$1,375,000** | Justified | **Yes** |
| **2** | Network segmentation (C1) | $15,000 | $850,000 | **$835,000** | Justified | **Yes** |
| **3** | Offsite immutable backups (C4) | $8,000 | $400,000 | **$392,000** | Justified | **Yes** |
| **4** | EDR upgrade (C5) | $30,000 | $180,000 | **$150,000** | Justified | **Yes** |
| **5** | Dedicated IoT monitoring (C8) | $80,000 | $85,000 | **$5,000** | Marginal | No |
| **6** | Dedicated clinic firewall (C6) | $4,000 | $5,000 | **$1,000** | Marginal | **Yes** (But deferred) |
| **7** | Enterprise SIEM (C3) | $85,000 | $60,000 | **-$25,000** | Not Justified | No |
| **8** | 24/7 Outsourced SOC (C7) | $150,000 | $120,000 | **-$30,000** | Not Justified | No (Exceeds total budget) |

**Budget Allocation Summary:** By approving only the 4 structurally critical and financially "Justified" controls (MFA, Network Segmentation, Offsite Backups, and EDR), MedDefense will spend **$58,000** annually. This successfully mitigates the most catastrophic ALEs while keeping the program well under the strict $120,000 budget, leaving $62,000 available for future phases or emergency expenditures.
