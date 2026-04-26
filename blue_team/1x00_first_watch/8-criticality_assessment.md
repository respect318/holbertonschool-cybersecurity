# Asset Criticality Matrix

| Asset Category | Confidentiality | Integrity | Availability | Overall Criticality | Justification |
|---|---|---|---|---|---|
| EHR System | Critical | Critical | Critical | Critical | Contains comprehensive PHI for all active patients; a breach triggers massive regulatory fines and litigation, while downtime forces a blind clinical response that directly risks patient life. |
| PACS/Imaging | Critical | Critical | High | Critical | Holds massive volumes of sensitive diagnostic imagery; altered or corrupted images lead to fatal surgical misdiagnoses, and exposure causes severe HIPAA penalties. |
| Medical IoT | Low | Critical | Critical | Critical | Directly interfaces with human biology; unauthorized modification of infusion pump dosages or vital monitor data immediately threatens patient life and physical safety. |
| Network Core | High | Critical | Critical | Critical | Serves as the digital backbone; a complete network halt disconnects all life-critical IoT, severs cross-site VPNs, and totally paralyzes the hospital's digital clinical care capabilities. |
| Billing Infrastructure | High | High | High | High | Processes all organizational revenue and insurance claims; extended downtime paralyzes cash flow, while data exposure causes identity theft and financial regulatory action. |
| Backup & Storage | High | Critical | Critical | Critical | The sole mechanism for organizational recovery; compromised integrity or availability of the NAS permanently prevents recovery from a ransomware event, leading to total operational failure. |
| Endpoints Clinical | High | High | High | High | Direct interfaces for ward staff; a compromise exposes active patient sessions and disrupts immediate floor-level care, causing severe operational bottlenecks. |
| Endpoints Administrative | High | Medium | Medium | High | Stores corporate, legal, and HR records; a breach causes significant reputational and financial damage, but does not directly halt emergency life-support operations. |
| Physical Security Systems | Low | Medium | High | High | Controls access to the facility; failure or tampering allows unauthorized individuals physical entry to critical infrastructure (like the server room) and restricted patient wards. |

# Top 5 Most Critical Assets

1. ehr-db-01 (EHR Database)
This PostgreSQL database is the centralized brain of MedDefense's clinical operations. If it goes down or is maliciously altered, physicians lose immediate access to critical patient histories, active allergies, and current medication lists, leading directly to life-threatening medical errors and total clinical paralysis.

2. PUMP-ICU / PUMP-ER (BD Alaris Infusion Pumps)
These connected medical IoT devices are responsible for directly administering medication into patient bloodstreams. Because they sit on an exposed, flat network with known unpatched firmware vulnerabilities (CVEs), an attacker could remotely alter infusion rates or drug dosages, instantly turning a cyber breach into a lethal event.

3. Core Network Switch / FortiGate Firewall
These routing devices are the absolute foundation of the hospital's digital existence. Without the core routing infrastructure, the entire 10.10.0.0/16 flat network collapses. Life-critical IoT devices lose their central monitoring, the Westside clinic is severed from the main hospital, and all clinical applications become unreachable.

4. WS-RAD-01 (MRI Control Workstation)
This highly vulnerable, unpatchable Windows XP system processes multi-million dollar diagnostic data and represents the single greatest infiltration risk. It serves as a permanent, open backdoor into the flat network, risking not only the hospital's primary diagnostic capability but also providing attackers a persistent pivot point to compromise the entire domain.

5. NAS-01 (Backup Storage System)
As the sole repository for organizational disaster recovery, this system is the ultimate fail-safe. Because it sits on the same flat network as the production servers and lacks offsite or cloud replication, a network-wide ransomware attack could easily encrypt it alongside primary systems, guaranteeing a permanent and unrecoverable loss of all hospital data.
