Gap ID: GAP-011
Gap Title: Lack of Multi-Factor Authentication (MFA) on VPN
Risk Level: Critical

Treatment Strategy: Mitigate

Justification: Real-world healthcare breaches consistently show compromised credentials on remote access portals as the primary entry point. Implementing MFA is highly feasible, inexpensive, and provides the single greatest immediate return on investment for perimeter defense.
  - Proposed Control(s): Technical Preventive (Enforce MFA via Authenticator app/tokens on FortiGate VPN).
  - Estimated Cost: $1-10K (Licensing for MFA integration, estimated ~$5,000).
  - Implementation Effort: Quick Win < 1 week
  - Expected Risk Reduction: Drastically reduces the risk of initial perimeter breach via stolen passwords or brute-force attacks, securing the main entry point to the flat network.
Trade-offs: Introduces slight operational friction for remote staff who must now perform a secondary authentication step.

***

Gap ID: GAP-002
Gap Title: Single Point of Failure for Disaster Recovery (Local Backups Only)
Risk Level: Critical

Treatment Strategy: Mitigate

Justification: We cannot accept or avoid the risk of total data loss. A ransomware attack will destroy the local NAS alongside the servers. We must implement the offsite backup solution previously requested by Marcus.
  - Proposed Control(s): Technical Corrective (Veeam Cloud Connect or AWS S3 immutable storage replication).
  - Estimated Cost: $10-50K (Specifically ~$14,400 based on the quote found in Artifact 5).
  - Implementation Effort: Short-term < 1 month
  - Expected Risk Reduction: Completely eliminates the single point of failure. Immutable cloud backups guarantee recovery capability even if the physical hospital burns down or suffers a total network encryption event.
Trade-offs: Creates a permanent, recurring annual operating expense that consumes a portion of the IT budget every year.

***

Gap ID: GAP-001
Gap Title: Flat Network Exposing Medical IoT and Legacy Systems
Risk Level: Critical

Treatment Strategy: Mitigate

Justification: Leaving life-critical IoT and unpatched databases exposed to every workstation is unacceptable. Because MedDefense already owns a Cisco Core Switch and a FortiGate firewall, this mitigation relies heavily on internal labor and configuration rather than expensive hardware purchases.
  - Proposed Control(s): Technical Preventive (Configure strict VLANs and routing ACLs separating IoT, Servers, and Endpoints).
  - Estimated Cost: $0-1K (Internal labor only).
  - Implementation Effort: Long-term > 1 month
  - Expected Risk Reduction: Contains malware outbreaks to a single subnet and prevents attackers from easily pivoting from a nurse's PC directly to life-critical infusion pumps.
Trade-offs: High risk of accidental operational disruption; strict network rules may inadvertently block legitimate clinical application traffic during the rollout phase.

***

Gap ID: GAP-003
Gap Title: Complete Absence of Centralized Security Logging
Risk Level: Critical

Treatment Strategy: Transfer

Justification: Purchasing an $80,000 enterprise SIEM license would consume nearly the entire security budget. Furthermore, MedDefense lacks the dedicated 24/7 SOC analysts required to monitor a SIEM. Transferring this function to a third-party Managed Security Service Provider (MSSP) provides immediate 24/7 monitoring without the massive capital expenditure of building an internal SOC.
  - Transfer Mechanism: Retain a Managed Detection and Response (MDR) / MSSP vendor to ingest critical logs and provide 24/7 security monitoring and alerting.
  - Residual Risk: MedDefense still owns the fundamental risk of the breach; the MSSP only detects and alerts. Internal IT staff must still physically respond to and remediate the incidents.
Trade-offs: Requires sharing sensitive network telemetry with a third-party vendor and involves a significant, recurring annual service contract.

***

Gap ID: GAP-004
Gap Title: Missing Endpoint Protection on Production Servers
Risk Level: Critical

Treatment Strategy: Mitigate

Justification: Servers host MedDefense's most valuable assets (PHI, billing) and are currently undefended against malware execution. Since Sophos is already deployed on workstations, purchasing the server tier is a logical, easily integrated step.
  - Proposed Control(s): Technical Preventive (Purchase and deploy Sophos Server Protection licenses).
  - Estimated Cost: $1-10K (Estimated ~$5,000 for 15 servers).
  - Implementation Effort: Quick Win < 1 week
  - Expected Risk Reduction: Provides active blocking of ransomware payloads and cryptominers (like the one on billing-srv-01) directly at the server level.
Trade-offs: Active scanning could potentially impact the performance (CPU/IOPS) of heavy database servers like ehr-db-01.

***

Gap ID: GAP-005
Gap Title: End-of-Life MRI Workstation on Production Network
Risk Level: Critical

Treatment Strategy: Mitigate

Justification: We cannot Avoid the risk by turning off a $2.1M MRI machine needed for patient care, and we cannot upgrade the OS. We must mitigate the vulnerability using compensating controls to isolate the machine.
  - Proposed Control(s): Technical Preventive (Microsegmentation ACLs) and Physical Preventive (USB port locks).
  - Estimated Cost: $0-1K (Estimated ~$500 for physical locks and cables).
  - Implementation Effort: Short-term < 1 month
  - Expected Risk Reduction: Hides the unpatchable Windows XP system from the rest of the network, making lateral movement via EternalBlue or similar exploits mathematically impossible.
Trade-offs: Increases workflow complexity for radiology technicians who may need to alter their procedures for handling diagnostic files.

***

Gap ID: GAP-009
Gap Title: Unmanaged Shadow IT Storage in Clinical Wards (Dr. Patel's NAS)
Risk Level: High

Treatment Strategy: Avoid

Justification: Storing unencrypted PHI and clinical research on a personal, unmanaged NAS drive is a severe regulatory violation and poses a massive data breach risk. It cannot be accepted or transferred. The activity itself must be stopped.
  - Avoidance Action: Physically disconnect and confiscate the personal NAS, migrate the research data to the secure corporate file server, and ban personal network devices.
  - Business Impact: Dr. Patel may experience slower file access speeds on the corporate drive, causing frustration and slight delays in research workflows.
Trade-offs: Causes significant political friction and dissatisfaction among senior medical staff towards the IT department.

***

### Budget Summary
The total security budget is $120,000. Our risk treatment strategy heavily leverages internal labor and strategic outsourcing to stay well within this limit:

* GAP-011 (VPN MFA): ~$5,000
* GAP-002 (AWS Cloud Backups): ~$14,400 (Based on previous quote)
* GAP-004 (Sophos Server Antivirus): ~$5,000
* GAP-005 (MRI Physical Locks): ~$500
* GAP-001 (Network Segmentation): $0 (Internal IT labor)
* GAP-009 (Confiscate Shadow IT): $0 (Administrative action)
* GAP-003 (MDR/MSSP 24/7 Monitoring): ~$80,000 (Allocating the remainder of the budget to outsource monitoring instead of buying a raw SIEM license).

**Total Estimated Spend: $104,900**

This strategy successfully addresses all 7 critical/high gaps while leaving approximately $15,100 in reserve for unforeseen deployment costs or future training initiatives. By choosing to *Transfer* the logging requirement to an MSSP rather than buying a raw SIEM, we gain 24/7 human oversight without exceeding our budget constraints.
