Control 1: Network segmentation (VLAN implementation for server, workstation, medical device and guest zones)
CIS Control Reference: CIS Control 12
Annual Cost: $15,000 ($0 licensing + $15,000 IT consulting labor)
Risk(s) Addressed: Ransomware encrypts EHR system / Patient Safety Incident
ALE Reduction: $850,000 (Drastically reduces the Exposure Factor by containing lateral movement)
Net Value: $835,000
Verdict: Justified
Recommendation: Implement; this provides the foundational architecture to stop threat propagation and yields a massive ROI for a purely labor-based cost.

Control 2: MFA deployment on VPN and administrative accounts
CIS Control Reference: CIS Control 6
Annual Cost: $5,000 ($0 license via existing O365 E3 + $5,000 internal labor)
Risk(s) Addressed: Complete Enterprise Breach via Compromised VPN
ALE Reduction: $1,380,000 (Neutralizes credential-based initial access vectors)
Net Value: $1,375,000
Verdict: Justified
Recommendation: Implement; this is the absolute highest ROI control available and directly eliminates the most statistically common initial access vector.

Control 3: Enterprise SIEM deployment (Wazuh, open-source)
CIS Control Reference: CIS Control 8 & 13
Annual Cost: $85,000 ($5,000 cloud infrastructure + $80,000 dedicated SIEM engineer labor)
Risk(s) Addressed: Delayed Incident Response
ALE Reduction: $40,000
Net Value: -$45,000
Verdict: Not Justified
Recommendation: Reject; unlike Control 5 (EDR) which automates defense, a SIEM requires manual alert triage. The hidden labor costs to tune "free" open-source rules make this a severe negative ROI for a small IT team.

Control 4: Offsite backup replication (cloud immutable storage, AWS S3 Glacier)
CIS Control Reference: CIS Control 11
Annual Cost: $8,000 ($3,000 AWS Glacier storage + $5,000 testing/labor)
Risk(s) Addressed: Ransomware encrypts EHR system
ALE Reduction: $400,000
Net Value: $392,000
Verdict: Justified
Recommendation: Implement; cheap, immutable cloud storage guarantees MedDefense can recover from a destructive ransomware event without ever needing to pay the ransom.

Control 5: Endpoint Detection and Response upgrade (Sophos Intercept X)
CIS Control Reference: CIS Control 10
Annual Cost: $30,000 ($25,000 licensing + $5,000 deployment labor)
Risk(s) Addressed: Widespread Malware Infection
ALE Reduction: $40,000
Net Value: $10,000
Verdict: Marginal
Recommendation: Defer; while modern EDR is excellent, its ALE reduction is cannibalized by Control 1 (VLANs). Because lateral movement will already be blocked by the network segments, upgrading endpoint software is mathematically a lower priority this year.

Control 6: Dedicated firewall for Westside Clinic
CIS Control Reference: CIS Control 4 & 12
Annual Cost: $4,000 ($1,500 hardware + $2,500 configuration labor)
Risk(s) Addressed: Opportunistic Branch Compromise
ALE Reduction: $2,000
Net Value: -$2,000
Verdict: Not Justified
Recommendation: Reject; this is a classic "best practice" trap. Because Control 2 (MFA) fully secures the VPN tunnel to HQ and the clinic hosts zero local ePHI, this hardware firewall is completely redundant and mathematically unjustified.

Control 7: 24/7 Security Operations Center staffing (outsourced managed SOC)
CIS Control Reference: CIS Control 13 & 17
Annual Cost: $150,000 (Annual MSSP contract)
Risk(s) Addressed: Advanced Persistent Threats / After-hours compromises
ALE Reduction: $120,000
Net Value: -$30,000
Verdict: Not Justified
Recommendation: Reject; this single control exceeds the entire $120,000 annual security budget and ultimately yields a negative Net Value until core defenses are matured.

Control 8: Full medical device network isolation with dedicated monitoring
CIS Control Reference: CIS Control 12
Annual Cost: $80,000 ($40,000 specialized IoT licenses + $40,000 implementation labor)
Risk(s) Addressed: Patient Safety Incident via Legacy Clinical Software
ALE Reduction: $30,000
Net Value: -$50,000
Verdict: Not Justified
Recommendation: Reject; we are actively implementing Control 1 (VLAN segmentation) which inherently accomplishes 90% of the medical device network isolation for a fraction of the cost, making this dedicated tool entirely redundant.

### Cost-Benefit Summary Table

| Rank | Control | Annual Cost | ALE Reduction | Net Value | Verdict | Fits in $120k Budget? |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **1** | MFA on VPN/Admin (C2) | $5,000 | $1,380,000 | **$1,375,000** | Justified | **Yes** |
| **2** | Network segmentation (C1) | $15,000 | $850,000 | **$835,000** | Justified | **Yes** |
| **3** | Offsite immutable backups (C4) | $8,000 | $400,000 | **$392,000** | Justified | **Yes** |
| **4** | EDR upgrade (C5) | $30,000 | $40,000 | **$10,000** | Marginal | **Yes** (But deferred) |
| **5** | Dedicated clinic firewall (C6) | $4,000 | $2,000 | **-$2,000** | Not Justified | No |
| **6** | Enterprise SIEM (C3) | $85,000 | $40,000 | **-$45,000** | Not Justified | No |
| **7** | Dedicated IoT monitoring (C8) | $80,000 | $30,000 | **-$50,000** | Not Justified | No |
| **8** | 24/7 Outsourced SOC (C7) | $150,000 | $120,000 | **-$30,000** | Not Justified | No (Exceeds total budget) |

**Budget Allocation Summary:** By applying strict comparative analysis, only 3 controls are mathematically justified: MFA, Network Segmentation, and Offsite Backups. Redundant controls (such as the branch firewall and IoT monitor) were explicitly rejected because the core controls already mitigate those vectors. MedDefense will spend **$28,000** annually, neutralizing the most catastrophic ALEs while preserving $92,000 of the $120,000 budget for future phases or emergency response.
