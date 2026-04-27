Control 1: Network segmentation (VLAN implementation for server, workstation, medical device and guest zones)
CIS Control Reference: CIS Control 12
Annual Cost: $15,000 ($0 license + $15,000 IT labor/consulting)
Risk(s) Addressed: Ransomware encrypts EHR system
ALE Reduction: $850,000 (Significantly reduces the Exposure Factor and lateral movement probability)
Net Value: $835,000
Verdict: Justified
Recommendation: Implement; this foundational architecture provides the highest structural risk reduction for the lowest cost.

Control 2: MFA deployment on VPN and administrative accounts
CIS Control Reference: CIS Control 6
Annual Cost: $5,000 ($0 license via existing O365 E3 + $5,000 implementation labor)
Risk(s) Addressed: Complete Enterprise Breach via Compromised VPN
ALE Reduction: $1,380,000 (Drastically reduces the ARO of credential-based VPN breaches)
Net Value: $1,375,000
Verdict: Justified
Recommendation: Implement; this is the single highest ROI security control available to the organization.

Control 3: Enterprise SIEM deployment (Wazuh, open-source)
CIS Control Reference: CIS Control 8 & 13
Annual Cost: $25,000 ($5,000 cloud infrastructure + $20,000 internal engineering labor)
Risk(s) Addressed: Widespread Malware Infection / Delayed Incident Response
ALE Reduction: $150,000 (Lowers impact/EF by enabling early detection before full encryption)
Net Value: $125,000
Verdict: Justified
Recommendation: Implement; leveraging open-source tools keeps the cost highly competitive while meeting critical visibility requirements.

Control 4: Offsite backup replication (cloud immutable storage, AWS S3 Glacier)
CIS Control Reference: CIS Control 11
Annual Cost: $8,000 ($3,000 AWS Glacier storage + $5,000 testing/labor)
Risk(s) Addressed: Ransomware encrypts EHR system
ALE Reduction: $400,000 (Eliminates the risk of total data loss and reduces downtime costs drastically)
Net Value: $392,000
Verdict: Justified
Recommendation: Implement; cheap, immutable cloud storage guarantees recovery from a destructive ransomware event.

Control 5: Endpoint Detection and Response upgrade (Sophos Intercept X)
CIS Control Reference: CIS Control 10
Annual Cost: $30,000 ($25,000 licensing for ~300 endpoints + $5,000 deployment labor)
Risk(s) Addressed: Widespread Malware Infection via Unpatched Software
ALE Reduction: $180,000 (Reduces ARO by blocking advanced and fileless malware that bypasses legacy AV)
Net Value: $150,000
Verdict: Justified
Recommendation: Implement; modern EDR is mandatory for detecting ransomware behaviors early in the kill chain.

Control 6: Dedicated firewall for Westside Clinic
CIS Control Reference: CIS Control 4 & 12
Annual Cost: $4,000 ($1,500 hardware + $2,500 licensing/installation)
Risk(s) Addressed: Opportunistic Branch Compromise / Lateral Movement
ALE Reduction: $80,000 (Closes a massive perimeter vulnerability that could bridge into the main network)
Net Value: $76,000
Verdict: Justified
Recommendation: Implement; replacing a consumer router with an enterprise firewall is a basic, non-negotiable hygiene requirement.

Control 7: 24/7 Security Operations Center staffing (outsourced managed SOC)
CIS Control Reference: CIS Control 13 & 17
Annual Cost: $150,000 ($150,000 MSSP annual contract)
Risk(s) Addressed: Advanced Persistent Threats / After-hours compromises
ALE Reduction: $140,000 (Provides faster response, but MedDefense lacks the mature infrastructure for a SOC to monitor effectively right now)
Net Value: -$10,000
Verdict: Not Justified
Recommendation: Reject; the organization must first build its internal defenses (SIEM, MFA, Segmentation) before spending heavily on 24/7 outsourced monitoring.

Control 8: Full medical device network isolation with dedicated monitoring
CIS Control Reference: CIS Control 12
Annual Cost: $80,000 ($40,000 specialized IoT security tool licenses + $40,000 implementation labor)
Risk(s) Addressed: Patient Safety Incident via Legacy Clinical Software
ALE Reduction: $85,000 (Reduces ARO of a highly catastrophic but very rare event)
Net Value: $5,000
Verdict: Marginal
Recommendation: Defer; standard VLAN segmentation (Control 1) will provide 80% of the benefit for a fraction of the cost, making this expensive dedicated tool a future luxury, not a current necessity.

### Cost-Benefit Summary Table

| Rank | Control | Annual Cost | ALE Reduction | Net Value | Verdict | Fits in $120k Budget? |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **1** | MFA deployment on VPN/Admin | $5,000 | $1,380,000 | **$1,375,000** | Justified | **Yes** |
| **2** | Network segmentation (VLANs) | $15,000 | $850,000 | **$835,000** | Justified | **Yes** |
| **3** | Offsite backup replication (AWS) | $8,000 | $400,000 | **$392,000** | Justified | **Yes** |
| **4** | EDR upgrade (Sophos Intercept X) | $30,000 | $180,000 | **$150,000** | Justified | **Yes** |
| **5** | Enterprise SIEM (Wazuh) | $25,000 | $150,000 | **$125,000** | Justified | **Yes** |
| **6** | Dedicated firewall (Westside Clinic) | $4,000 | $80,000 | **$76,000** | Justified | **Yes** |
| **7** | Medical device isolation/monitoring | $80,000 | $85,000 | **$5,000** | Marginal | No |
| **8** | 24/7 SOC staffing (MSSP) | $150,000 | $140,000 | **-$10,000** | Not Justified | No |

*Note: Controls 1 through 6 total **$87,000**, leaving a $33,000 buffer while remaining well under the $120,000 annual budget.*
