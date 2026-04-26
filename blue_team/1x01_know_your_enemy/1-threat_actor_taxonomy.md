Report A:
  Actor Type: Nation-state
  Internal/External: External - The initial compromise occurred through a vulnerability in the public-facing VPN appliance.
  Resources: High - The attackers utilized a zero-day vulnerability, custom-built malware, and a stolen code-signing certificate, requiring massive financial backing.
  Sophistication: High - Demonstrated by a 14-month dwell time without detection, custom remote access tools, and encrypted DNS tunneling.
  Primary Motivation: Espionage - Targeted specific, highly valuable intellectual property (Phase III trial data worth $2B).
  Confidence Level: High - Zero-day exploits, stolen certificates, and long-term undetected espionage are textbook signatures of an Advanced Persistent Threat (APT) / Nation-state.

Report B:
  Actor Type: Organized crime
  Internal/External: External - Initial access was gained via a phishing email originating from outside the organization.
  Resources: Medium - Utilized known vulnerabilities (Adobe Reader) and commercially available remote access trojans (RATs) rather than expensive custom zero-days.
  Sophistication: Medium - Successfully executed a well-known Ransomware-as-a-Service (RaaS) playbook, including lateral movement and a double-extortion scheme.
  Primary Motivation: Financial gain - Extorting the hospital for 40 Bitcoin ($1.6M) under the threat of data leakage.
  Confidence Level: High - The combination of phishing, commercial RATs, and double-extortion ransomware is the standard operational model for financially motivated cybercriminal syndicates.

Report C:
  Actor Type: Hacktivist
  Internal/External: External - Exploited a public-facing website without attempting to breach internal network segments.
  Resources: Low - Used standard, publicly known web exploitation techniques (SQL injection) without needing custom tools.
  Sophistication: Low - Only achieved basic website defacement and lacked the skill or desire to pivot to internal systems.
  Primary Motivation: Philosophical or political beliefs - The attack was a public protest against a corporate policy, complete with an activist logo.
  Confidence Level: High - Defacement combined with a political message and an activist logo clearly aligns with hacktivism.

Report D:
  Actor Type: Insider threat
  Internal/External: Internal - The attacker was a recently terminated employee who used authorized systems to conduct the attack.
  Resources: Low - No external exploits or funded tools were needed; the attacker simply abused existing administrative privileges.
  Sophistication: Medium - Demonstrated foresight by creating a hidden VPN account and disabling backups prior to termination.
  Primary Motivation: Revenge - Acted maliciously to destroy production data immediately following a disciplinary hearing.
  Confidence Level: High - The timeline (fired 2 days prior), the IP address, and the specific targeting of backups make this a classic malicious insider case.

Report E:
  Actor Type: Unskilled attacker
  Internal/External: External - The attack came from outside via an automated internet-wide scan targeting a known CVE.
  Resources: Low - Used publicly available automated exploit tools and standard Monero mining software.
  Sophistication: Low - Exploited a 6-month-old vulnerability with no attempt to move laterally, evade detection, or target specific data.
  Primary Motivation: Financial gain - Illicit cryptocurrency mining via mass automated exploitation.
  Confidence Level: High - The mass infection of 300+ organizations with the same automated script is a definitive indicator of opportunistic, low-skill threat actors.

Report F:
  Actor Type: Shadow IT
  Internal/External: Internal - The root cause was an internal employee connecting unauthorized hardware (Raspberry Pi) to the medical network.
  Resources: Low - Used an inexpensive, personal Raspberry Pi device.
  Sophistication: Low - The device ran an outdated OS with default credentials and was inadvertently exposed to the internet.
  Primary Motivation: Ethical motivations - The employee had no malicious intent and was simply monitoring network performance for a personal project, believing it was helpful or harmless.
  Confidence Level: High - The investigation confirmed the employee's identity and lack of malicious intent, making this a clear case of Shadow IT.

Report G:
  Actor Type: Insider threat
  Internal/External: Could be either - Access occurred through a legitimate account, but since the physician was out of the country, it could be another internal employee or an external attacker who compromised the credentials.
  Resources: Low - The attacker utilized legitimate credentials to log in and download data without needing advanced technical exploits.
  Sophistication: Medium - The attacker avoided detection for 6 weeks by operating exclusively during off-hours and specifically extracting high-value targets.
  Primary Motivation: Financial gain - Targeted patients with high-value insurance plans, strongly indicating preparation for medical identity theft or fraud.
  Confidence Level: Low - This report is deliberately ambiguous. While categorized distinctly as an Insider threat (assuming another employee abused the access), Organized crime could also fit if an external attacker stole the credentials. To distinguish between them, analysts need evidence such as authentication logs (is the IP an internal hospital address or an external VPN/Tor node?), MFA logs, and endpoint forensics on the physician's devices to check for malware.

Report H:
  Actor Type: Organized crime
  Internal/External: External - Analysis of the API logs confirmed unauthorized access originated from an external Tor exit node.
  Resources: Low - Exploited a standard broken authentication vulnerability that had already been discovered internally, requiring no custom tools.
  Sophistication: Medium - Demonstrated the ability to identify an API logic flaw, extract data as proof, and use the Tor network for operational security.
  Primary Motivation: Blackmail - Demanded $50,000 in cryptocurrency in exchange for not publishing the vulnerability details and stolen patient records.
  Confidence Level: High - Extorting a company by threatening to release a discovered vulnerability and authentic data samples is classic financially motivated cybercriminal behavior.
