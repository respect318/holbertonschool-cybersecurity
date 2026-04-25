Gap ID: G-001
Gap Description: No endpoint protection or antivirus software is deployed on any Windows or Linux servers.
Category x Function Missing: Technical Preventive / Technical Detective
Affected Asset(s) or Zone: All MedDefense Servers (Central & Westside)
Risk if Unaddressed: Malware, such as ransomware or cryptominers, can execute and spread across critical servers without being blocked or flagged, compromising Availability and Integrity.
Evidence: Artifact 4 explicitly states that for Windows servers, the "server protection license not purchased," and Linux servers are "not supported."

Gap ID: G-002
Gap Description: Lack of centralized log management (SIEM) and automated security alerting.
Category x Function Missing: Technical Detective
Affected Asset(s) or Zone: Entire IT Infrastructure (Network, Servers, Active Directory)
Risk if Unaddressed: Attackers can breach the network, elevate privileges, and move laterally for months without anyone noticing, severely compromising Confidentiality and Integrity.
Evidence: Artifact 8 states "No centralized log management system exists" and "No automated alerting."

Gap ID: G-003
Gap Description: Backups are stored on a local NAS in the same physical rack and network segment as the servers, with no offsite or cloud replication.
Category x Function Missing: Technical Corrective
Affected Asset(s) or Zone: Organizational Data / Backup Archives
Risk if Unaddressed: A physical disaster (fire, flood) or a network-wide ransomware attack will destroy both the primary servers and the backups simultaneously, resulting in a total and permanent loss of Availability.
Evidence: Artifact 5 notes the backup destination is "NAS-01... same rack row" and Offsite/Cloud backup is listed as "None."

Gap ID: G-004
Gap Description: No egress filtering on the FortiGate firewall; all internal outbound traffic is allowed to the internet on any port.
Category x Function Missing: Technical Preventive
Affected Asset(s) or Zone: Internal
