# Algorithm Landscape and Gap Analysis

## Algorithm Reference Table

| Algorithm | Type | Key/Output Size | Primary Use Case | Status | Why Deprecated/Broken | MedDefense Usage |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **AES-128** | Symmetric | 128-bit | Bulk data encryption | Current | N/A | General encryption (if performance constrained) |
| **AES-192** | Symmetric | 192-bit | Bulk data encryption | Current | N/A | Not standardly used |
| **AES-256** | Symmetric | 256-bit | High-security bulk encryption | Current | N/A | VPN Tunnels, Recommended for EHR/DB at rest |
| **DES** | Symmetric | 56-bit | Legacy encryption | Broken | Key space is too small; trivially brute-forced | Legacy Kerberos (Finding 018) - Must remove |
| **3DES** | Symmetric | 112 / 168-bit | Legacy encryption | Deprecated | 64-bit block size vulnerable to Sweet32 collision attacks | Legacy systems - Must phase out |
| **ChaCha20-Poly1305** | Symmetric | 256-bit | Stream + AEAD bulk encryption | Current | N/A | Recommended for TLS 1.3 and mobile clients |
| **RC4** | Symmetric | 40 to 2048-bit | Legacy stream encryption | Broken | Inherent biases in key stream (FMS/NOMORE attacks) | Legacy Kerberos (Finding 018) - Must remove |
| **Blowfish** | Symmetric | 32 to 448-bit | General encryption | Deprecated | 64-bit block size vulnerable to birthday attacks (Sweet32) | Legacy applications - Must phase out |
| **RSA-2048** | Asymmetric | 2048-bit | Key exchange / Digital Signatures | Current | N/A | Patient portal TLS certificates, Signature scripts |
| **RSA-4096** | Asymmetric | 4096-bit | High-security Asymmetric | Current | N/A | Root CAs, High-security certificates |
| **ECC P-256** | Asymmetric | 256-bit | Key exchange / Signatures (IoT) | Current | N/A | Recommended for constrained devices (BD Alaris, PACS) |
| **ECC P-384** | Asymmetric | 384-bit | High-security Asymmetric | Current | N/A | High-security modern TLS |
| **Diffie-Hellman** | Asymmetric | 2048+ bit | Key Agreement | Current | N/A | VPN IPSec Tunnels |
| **ECDHE** | Asymmetric | 256+ bit | Perfect Forward Secrecy | Current | N/A | Recommended for modern web portal TLS handshakes |
| **MD5** | Hash | 128-bit | Legacy checksums | Broken | Trivial to generate cryptographic collisions | NTHash in Active Directory - Must remove |
| **SHA-1** | Hash | 160-bit | Legacy integrity | Broken | Cryptographic collisions proven (SHAttered attack) | Legacy certificate signing - Must phase out |
| **SHA-256** | Hash | 256-bit | Data integrity / Signatures | Current | N/A | Prescription/Document signing, File integrity |
| **SHA-512** | Hash | 512-bit | High-security integrity | Current | N/A | Firmware update signatures |
| **SHA-3** | Hash | 256 / 512-bit | Future-proof integrity | Current | N/A | High-security environments requiring sponge functions |
| **PBKDF2** | KDF | Variable | Password hashing / Key stretching | Current | N/A | Application passwords |
| **bcrypt** | KDF | 184-bit hash | Password hashing | Current | N/A | Application passwords |
| **Argon2** | KDF | Variable | Memory-hard password hashing | Current | N/A | Recommended for MedDefense portal passwords |
| **scrypt** | KDF | Variable | Memory-hard password hashing | Current | N/A | Application passwords |

## MedDefense Crypto Gap Analysis

Based on the cryptographic inventory and vulnerability findings (1x02 / 1x00), MedDefense currently relies on several broken or deprecated cryptographic algorithms that introduce severe operational risks. Below are 4 specific cases and their recommended replacements:

**1. Active Directory Kerberos Tickets (Finding 018)**
* **Current Usage:** DES (Broken).
* **Vulnerability:** DES uses a 56-bit key that can be brute-forced in hours using modern hardware. Attackers can effortlessly decrypt intercepted Kerberos service tickets.
* **Recommendation:** Disable DES entirely via Group Policy and enforce **AES-256** encryption for Kerberos authentication.

**2. Active Directory RC4 Support (Finding 018)**
* **Current Usage:** RC4 (Broken).
* **Vulnerability:** RC4 relies on internal MD4/MD5 mechanisms and produces biased key streams. It leaves MedDefense highly vulnerable to Kerberoasting, allowing attackers to request RC4 tickets and crack them offline.
* **Recommendation:** Disable RC4 (Type 4) encryption in Active Directory and restrict Kerberos to **AES-128 and AES-256**.

**3. Patient Portal TLS Configuration (Finding 005)**
* **Current Usage:** TLS 1.0 (Deprecated/Broken).
* **Vulnerability:** TLS 1.0 relies on outdated cipher suites (like CBC modes vulnerable to BEAST/POODLE) and weak hashing (MD5/SHA-1) for key exchange. It is strictly prohibited by HIPAA and PCI-DSS.
* **Recommendation:** Disable TLS 1.0 and 1.1 on `web-srv-01` (Apache). Enforce **TLS 1.2 or TLS 1.3** using strong cipher suites like **ECDHE-RSA-AES256-GCM-SHA384** or **ChaCha20-Poly1305**.

**4. Active Directory Password Storage**
* **Current Usage:** NTHash / MD4 (Broken).
* **Vulnerability:** Windows Active Directory stores user passwords using NTHash, which is effectively an unsalted MD4 hash. This allows attackers to dump the NTDS.dit file and instantly recover passwords using rainbow tables or pass-the-hash attacks.
* **Recommendation:** While NTHash cannot be fully removed from AD architectures natively, MedDefense must enforce complex password policies, implement **Windows LAPS** for local admin accounts, and ensure any custom application portal passwords strictly use **Argon2id** for storage.
