# The Cryptographic Attack Surface

**Attack:** TLS Downgrade
**Mechanism:** An attacker intercepts the initial client-server handshake and manipulates the supported protocols list to strip modern TLS support. This forces the server to fall back to an older, vulnerable protocol like TLS 1.0, allowing the attacker to exploit known legacy flaws (like POODLE) to decrypt the traffic.
**MedDefense Vulnerability:** Patient Portal (`web-srv-01`).
**Evidence:** Finding 005 (TLS 1.0 enabled alongside TLS 1.2).
**Viable Today:** Yes, because the web server actively accepts TLS 1.0 connections and lacks HTTP Strict Transport Security (HSTS) to force modern encryption.
**Mitigation:** Completely disable TLS 1.0 and 1.1 in the Apache/Nginx configuration and enable HSTS with a long max-age and the `preload` directive.

**Attack:** Collision Attack
**Mechanism:** A collision attack occurs when an attacker mathematically finds two completely different input strings that produce the exact same cryptographic hash output. If an authentication system relies on a weak hash, an attacker can forge a valid certificate or authentication ticket by feeding the system a malicious payload that hashes to the same value as a legitimate one.
**MedDefense Vulnerability:** Active Directory / Kerberos authentication.
**Evidence:** Finding 018 (Kerberos weak encryption enabled, relying internally on MD4/MD5).
**Viable Today:** Yes, algorithms relying on MD4 and MD5 have proven, trivially exploitable cryptographic collisions that can be generated in seconds on modern hardware.
**Mitigation:** Disable RC4 and legacy NTLM authentication entirely; enforce AES-256 for all Kerberos operations.

**Attack:** Birthday Attack
**Mechanism:** Based on the birthday paradox, this attack exploits the mathematical probability that finding *any* collision in a set of hashes is much faster than finding a specific one. Because of this probability curve, an algorithm is vulnerable if its output block size is too small; for example, a 64-bit block cipher effectively only offers 32 bits of collision resistance before identical ciphertext blocks start appearing (Sweet32 vulnerability).
**MedDefense Vulnerability:** Legacy symmetric algorithms (like DES and 3DES) used within Active Directory.
**Evidence:** Finding 018 (DES enabled) and T6 analysis (64-bit block size vulnerabilities).
**Viable Today:** Yes, if DES is actively used for bulk data or continuous authentication streams, an attacker can capture enough ciphertext to force a collision and recover the plaintext.
**Mitigation:** Phase out all legacy algorithms with 64-bit block sizes (DES, 3DES, Blowfish) and replace them with AES-GCM or ChaCha20.

**Attack:** Kerberoasting
**Mechanism:** An authenticated user requests a Kerberos Service Ticket (TGS) for a target service account from the domain controller. The domain controller provides the ticket encrypted with the service account's password hash; the attacker then extracts this ticket from memory and uses offline brute-force or rainbow tables to crack the weak RC4 hash to obtain the plaintext password.
**MedDefense Vulnerability:** Active Directory Service Accounts.
**Evidence:** Finding 018 (RC4 enabled).
**Viable Today:** Yes, any compromised standard user account in the flat network can request an RC4-encrypted ticket for any service account and crack it rapidly offline using GPU acceleration.
**Mitigation:** Disable RC4 (Type 4 encryption) via Group Policy, enforce AES-128/256 for Kerberos, and implement complex, randomly generated 25+ character passwords for all Service Principal Names (SPNs).

**Attack:** On-path/MITM on unencrypted channels
**Mechanism:** An attacker positions themselves logically between two communicating nodes on a network (e.g., via ARP spoofing) to silently intercept, read, or modify data in transit. Because the traffic is unencrypted, the attacker does not need to break any cryptography; they simply capture the raw packets using tools like Wireshark.
**MedDefense Vulnerability:** Internal PACS imaging traffic and internal billing database queries.
**Evidence:** T0 / T15 Audit (Cleartext DICOM on ports 4242/11112; Plaintext MySQL).
**Viable Today:** Yes, the flat network architecture (identified in 1x01 kill chains) means any compromised internal host or rogue device plugged into a clinic wall port can sniff cleartext patient images and financial records.
**Mitigation:** Implement DICOM TLS for all PACS traffic and enforce strict SSL/TLS encryption for all internal MySQL database connections.

**Attack:** Key Recovery from Memory
**Mechanism:** When an application encrypts or decrypts data, the plaintext encryption key must temporarily reside in the system's Random Access Memory (RAM). An attacker with administrative or root privileges can dump the system memory and scan it to extract the raw cryptographic keys used by the application.
**MedDefense Vulnerability:** Database servers (`ehr-db-01`, `billing-srv-01`) relying on software-level encryption without hardware protection.
**Evidence:** 1x00 incident (Crypto-miner obtained root access on `billing-srv-01`).
**Viable Today:** Yes, if MedDefense implements software-based database encryption, an attacker gaining root access (as already demonstrated by the crypto-miner incident) can simply dump the RAM and steal the master decryption key.
**Mitigation:** Utilize a Hardware Security Module (HSM) so the master keys never reside in the application server's RAM, and enforce strict EDR monitoring to block memory-dumping utilities.
