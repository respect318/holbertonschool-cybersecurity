CIS Control 1: Inventory and Control of Enterprise Assets
Score: Implemented
Evidence: 1x01 network scans confirm all enterprise connected assets match the official, actively maintained baseline inventory.

CIS Control 2: Inventory and Control of Software Assets
Score: Implemented
Evidence: 1x02 host analysis confirms an accurate software inventory and active prevention of unauthorized applications across endpoints.

CIS Control 3: Data Protection
Score: Partial
Evidence: 1x00 policies confirm data classification, but 1x02 endpoint reviews show full encryption on end-user devices handling ePHI is not yet universally deployed.

CIS Control 4: Secure Configuration of Enterprise Assets and Software
Score: Partial
Evidence: 1x01 scans show core servers are hardened, but some legacy endpoints still lack secure baseline configurations and automatic session locking.

CIS Control 5: Account Management
Score: Implemented
Evidence: 1x02 Active Directory audit verifies unique passwords, automated disabling of dormant accounts after 45 days, and dedicated admin accounts.

CIS Control 6: Access Control Management
Score: Partial
Evidence: 1x00 access policies enforce MFA for external networks, but 1x02 confirms MFA roll-out for internal administrative access is currently incomplete.

CIS Control 7: Continuous Vulnerability Management
Score: Partial
Evidence: 1x01 internal scans revealed automated OS patching is active, but third-party application patch management is still handled inconsistently.

CIS Control 8: Audit Log Management
Score: Implemented
Evidence: 1x02 system reviews confirm audit logs are actively collected and securely retained in centralized storage for adequate analysis.

CIS Control 9: Email and Web Browser Protections
Score: Implemented
Evidence: 1x00 policy and 1x02 endpoint configurations confirm the strict enforcement of supported browsers and active enterprise DNS filtering.

CIS Control 10: Malware Defenses
Score: Implemented
Evidence: 1x02 endpoint analysis confirms centrally managed anti-malware deployments with automated signature updates and disabled autorun features.

CIS Control 11: Data Recovery
Score: Partial
Evidence: 1x00 documentation confirms automated backups are performed, but 1x01 architecture mapping shows the isolated, offline instance of recovery data is still under construction.

CIS Control 12: Network Infrastructure Management
Score: Implemented
Evidence: 1x01 architecture mapping demonstrates up-to-date network infrastructure with secure management protocols and appropriate segmentation.

CIS Control 13: Network Monitoring and Defense
Score: Implemented
Evidence: 1x01 traffic analysis confirms centralized security event alerting and active network intrusion detection monitoring are in place.

CIS Control 14: Security Awareness and Skills Training
Score: Implemented
Evidence: 1x00 policy reviews verify a comprehensive security awareness program is established, including mandatory social engineering training.

CIS Control 15: Service Provider Management
Score: Implemented
Evidence: 1x00 vendor documentation confirms an established inventory and strict management policy for all authorized service providers.

CIS Control 16: Application Software Security
Score: Implemented
Evidence: 1x00 SDLC review confirmed a mature, secure application development process accompanied by formal developer training.

CIS Control 17: Incident Response Management
Score: Implemented
Evidence: 1x00 policy review indicates designated incident response personnel and a clearly established enterprise reporting process are operational.

CIS Control 18: Penetration Testing
Score: Implemented
Evidence: 1x00 compliance review confirmed periodic external penetration tests are actively scheduled and remediation processes are enforced.

### Scorecard Summary
* Implemented: 13
* Partial: 5
* Not Implemented: 0

### Top 5 Priority Controls
1. **CIS Control 7: Continuous Vulnerability Management**
   Standardizing automated application patch management will eliminate remaining critical CVEs and ensure consistent vulnerability remediation across the network.
2. **CIS Control 11: Data Recovery**
   Finalizing the isolated, offline instance of recovery data is essential for MedDefense to maintain operational continuity during a targeted ransomware attack.
3. **CIS Control 6: Access Control Management**
   Expanding Multi-Factor Authentication (MFA) to all internal administrative access points is critical to prevent lateral movement and privilege escalation.
4. **CIS Control 3: Data Protection**
   Universally enforcing device encryption ensures that highly regulated healthcare data (ePHI) remains secure even in the event of physical asset theft or loss.
5. **CIS Control 4: Secure Configuration of Enterprise Assets and Software**
   Applying standard secure baseline configurations to the remaining legacy endpoints will close common attack vectors and reduce the overall attack surface.
