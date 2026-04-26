Report A:
Actor Type: Nation-state
Internal/External: External - The initial compromise occurred through a zero-day vulnerability in the public-facing VPN.
Resources: High - Utilized a zero-day vulnerability, custom-built remote access tool, and stolen code-signing certificate, indicating significant funding.
Sophistication: High - Demonstrated by a 14-month undetected dwell time, custom tools, and encrypted DNS queries for command and control.
Primary Motivation: Espionage - Systematically copied proprietary Phase III drug trial data valued at $2 billion.
Confidence Level: High - The use of zero-days, stolen certificates, and targeting of highly valuable R&D data are textbook indicators of a Nation-state APT.

Report B:
Actor Type: Organized crime
Internal/External: External - The attack originated from an external phishing email campaign simulating a vendor invoice.
Resources: Medium - Relied on commercially available remote access trojans and known Adobe Reader vulnerabilities rather than custom zero-days.
Sophistication: Medium - Followed a standard Ransomware-as-a-Service playbook including lateral movement, exfiltration, and double extortion.
Primary Motivation: Financial gain - The attackers demanded a 40 Bitcoin ($1.6 million) ransom under threat of leaking patient records.
Confidence Level: High - Double-extortion ransomware deployed via phishing is the defining operational model of financially motivated cybercriminal groups.

Report C:
Actor Type: Hacktivist
Internal/External: External - The attacker exploited a public-facing website vulnerability without breaching internal networks.
Resources: Low - Used standard, publicly available SQL injection techniques without custom or expensive tools.
Sophistication: Low - Only achieved basic website defacement, making no attempt to pivot laterally or escalate privileges internally.
Primary Motivation: Philosophical or political beliefs - The defacement criticized the hospital's policy to close a free clinic and included an activist logo calling for protests.
Confidence Level: High - Defacement combined with a clear political message, an activist group logo, and no data theft perfectly aligns with hacktivism.

Report D:
Actor Type: Insider threat
Internal/External: Internal - The perpetrator was a recently terminated IT administrator abusing previously authorized access.
Resources: Low - Required no financial backing or advanced tools; the attacker simply abused administrative privileges they already had.
Sophistication: Medium - Demonstrated system knowledge by creating a hidden, unlinked VPN account and disabling automated database backups prior to being fired.
Primary Motivation: Revenge - Acted maliciously to destroy production database tables two days after a disciplinary termination hearing.
Confidence Level: High - The timing (post-termination), the IP address (attacker's home), and the specific sabotage of backups definitively point to a malicious insider.

Report E:
Actor Type: Unskilled attacker
Internal/External: External - The infection occurred via an automated internet-wide scan targeting a known vulnerability.
Resources: Low - Used publicly available automated exploit tools and a standard, free Monero cryptocurrency miner.
Sophistication: Low - Exploited a 6-month-old known CVE with no attempt to move laterally, access sensitive data, or establish deep persistence.
Primary Motivation: Financial gain - The sole objective was illicit cryptocurrency mining (cryptojacking) using the victim's computational resources.
Confidence Level: High - The use of an automated scan, a known vulnerability, and linkage to 300+ identical global infections indicate a low-skill, opportunistic attacker.

Report F:
Actor Type: Shadow IT
Internal/External: Internal - An employee connected a personal, unauthorized device (Raspberry Pi) to the internal medical device network.
Resources: Low - Utilized a cheap, personal Raspberry Pi running an outdated version of Raspbian.
Sophistication: Low - The device was configured with default credentials (pi/raspberry) and inadvertently exposed an internet-facing port.
Primary Motivation: Ethical motivations - The employee was motivated by a desire to monitor network performance for a personal project, with absolutely no malicious intent.
Confidence Level: High - The investigation definitively identified the employee and confirmed the lack of malicious intent, which is the exact definition of Shadow IT.

Report G:
Actor Type: Insider threat / Organized crime
Internal/External: Could be either - It is Internal if another hospital employee abused the absent physician's account. It is External if an outside organized crime group compromised the credentials via phishing or credential stuffing.
Resources: Low - The attacker only used legitimate account credentials to authenticate and download data, requiring no advanced or expensive exploits.
Sophistication: Medium - The attacker maintained operational security by extracting data slowly over 6 weeks, only during off-hours (11 PM - 4 AM), and selectively filtering for high-value targets to avoid alerting automated defenses.
Primary Motivation: Financial gain - The attacker specifically targeted and downloaded records of patients with high-value insurance plans, which is a clear precursor to medical identity theft or insurance fraud.
Confidence Level: Low - This incident is deliberately ambiguous. Multiple actor types fit: a malicious Insider threat (a coworker) or Organized crime (external cybercriminals). To definitively distinguish between them, analysts need specific evidence: 1) Authentication and network logs to determine if the access IP resolves to an internal hospital workstation or an external Tor/VPN node. 2) Endpoint forensics on the physician's devices to identify potential credential-harvesting malware. 3) MFA logs to see if secondary authentication was bypassed or completed by an unauthorized device.

Report H:
Actor Type: Organized crime
Internal/External: External - Access to the API was confirmed to originate from an external Tor exit node.
Resources: Low - Exploited a standard broken authentication flaw that was already known internally, requiring no specialized or funded exploit development.
Sophistication: Medium - The attacker successfully identified an API logic flaw, extracted a precise data sample as proof, and utilized the Tor network to maintain anonymity.
Primary Motivation: Blackmail - The attacker explicitly demanded $50,000 in cryptocurrency to prevent the publication of the vulnerability and the stolen patient records.
Confidence Level: High - Extorting a company by holding a discovered vulnerability and verified stolen data for ransom is standard behavior for financially motivated cybercriminals.
