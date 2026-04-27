CIS Control 1: Inventory and Control of Enterprise Assets
Score: Partial
Evidence: 1x01 network scans identified undocumented enterprise assets operating outside the official baseline inventory.

CIS Control 2: Inventory and Control of Software Assets
Score: Partial
Evidence: 1x02 host analysis revealed unauthorized and legacy software applications deployed across multiple clinical endpoints.

CIS Control 3: Data Protection
Score: Partial
Evidence: 1x00 documentation confirms data classification exists, but 1x02 endpoint reviews show missing encryption on end-user devices handling ePHI.

CIS Control 4: Secure Configuration of Enterprise Assets and Software
Score: Not Implemented
Evidence: 1x01 vulnerability scans highlighted default credentials and unhardened baseline configurations on internal application servers.

CIS Control 5: Account Management
Score: Partial
Evidence: 1x02 Active Directory audit discovered dormant accounts exceeding 45 days and a lack of dedicated privilege separation for administrators.

CIS Control 6: Access Control Management
Score: Partial
Evidence: 1x00 access policies enforce MFA for external networks, but 1x02 confirms MFA is absent for internal administrative access.

CIS Control 7: Continuous Vulnerability Management
Score: Not Implemented
Evidence: 1x01 internal scans revealed critical CVEs without an automated or continuous OS/application patch management process in place.

CIS Control 8: Audit Log Management
Score: Partial
Evidence: 1x02 system reviews indicate local event logging is active, but lacks a centralized audit log storage and management architecture.

CIS Control 9: Email and Web Browser Protections
Score: Implemented
Evidence: 1x00 policy and 1x02 endpoint configurations confirm the enforcement of fully supported browsers and active enterprise DNS filtering.

CIS Control 10: Malware Defenses
Score: Implemented
Evidence: 1x02 endpoint analysis confirms centrally managed anti-malware deployments with automated signature updates and disabled autorun features.

CIS Control 11: Data Recovery
Score: Partial
Evidence: 1x00 documentation confirms automated backups are performed, but 1x01 architecture mapping shows no isolated, offline instance of recovery data.

CIS Control 12: Network Infrastructure Management
Score: Partial
Evidence: 1x01 architecture mapping demonstrates flat network topologies lacking secure, centralized authentication and segmentation for administrative functions.

CIS Control 13: Network Monitoring and Defense
Score: Not Implemented
Evidence: 1x01 traffic analysis confirms the absolute absence of centralized security event alerting and network intrusion detection systems (NIDS).

CIS Control 14: Security Awareness and Skills Training
Score: Not Implemented
Evidence: 1x00 policy reviews found no formal, documented security awareness training program for the workforce regarding social engineering or data handling.

CIS Control 15: Service Provider Management
Score: Not Implemented
Evidence: 1x00 vendor documentation review yielded no established service provider management policy or formal third-party inventory.

CIS Control 16: Application Software Security
Score: Not Implemented
Evidence: 1x00 SDLC review confirmed internal development teams lack formal application security training and secure coding guidelines.

CIS Control 17: Incident Response Management
Score: Not Implemented
Evidence: 1x00 policy review indicates no designated incident response personnel, contact information, or enterprise reporting processes.

CIS Control 18: Penetration Testing
Score: Not Implemented
Evidence: 1x00 compliance review confirmed no historical or scheduled periodic external penetration tests have been conducted.

### Scorecard Summary
* Implemented: 2
* Partial: 8
* Not Implemented: 8

### Top 5 Priority Controls
1. **CIS Control 7: Continuous Vulnerability Management**
   Implementing automated patch management will rapidly eliminate the critical CVEs discovered during network scans and immediately reduce the external attack surface.
2. **CIS Control 11: Data Recovery**
   Establishing an isolated, offline instance of recovery data ensures MedDefense can maintain operational continuity and data integrity in the event of a targeted ransomware attack.
3. **CIS Control 6: Access Control Management**
   Enforcing Multi-Factor Authentication (MFA) across all internal administrative access points is critical to preventing lateral movement and credential-based privilege escalation.
4. **CIS Control 4: Secure Configuration of Enterprise Assets and Software**
   Standardizing secure configurations and removing default credentials from internal servers provides the foundational hardening necessary to defend against automated exploits.
5. **CIS Control 3: Data Protection**
   Deploying universally enforced device encryption ensures that highly regulated healthcare data remains secure and compliant even in the event of physical asset theft or loss.
