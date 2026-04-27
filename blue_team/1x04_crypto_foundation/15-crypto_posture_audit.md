# The Crypto Posture Audit

## Crypto Findings

**Finding ID:** CRYPTO-001
**Data Category:** Patient medical records (EHR data in PostgreSQL)
**Data State:** At Rest
**Current Protection:** None
**Vulnerability Reference:** Audit notes
**Risk Reference:** RISK-001 (PHI Data Breach)
**Algorithm Assessment:** N/A (Currently None)
**Recommended Protection:** AES-256 (AES-GCM)
**Encryption Level:** Database-level (TDE)
**Key Management:** Master key stored in Secure KMS / Cloud HSM. Rotated annually.
**Implementation Priority:** Immediate

**Finding ID:** CRYPTO-002
**Data Category:** Patient medical records (EHR data in PostgreSQL)
**Data State:** In Transit
**Current Protection:** Partial (SSL=on, but non-SSL allowed)
**Vulnerability Reference:** Audit notes
**Risk Reference:** RISK-002 (Network Eavesdropping)
**Algorithm Assessment:** Inadequate (Allows plaintext fallback)
**Recommended Protection:** Enforce TLS 1.2/1.3 with ECDHE-RSA-AES256-GCM-SHA384. Disable `hostnossl` in `pg_hba.conf`.
**Encryption Level:** N/A (In Transit)
**Key Management:** Certificates managed via automated internal PKI.
**Implementation Priority:** Immediate

**Finding ID:** CRYPTO-003
**Data Category:** Financial/billing data (MySQL on billing-srv-01)
**Data State:** At Rest
**Current Protection:** None
**Vulnerability Reference:** 1x00 incident observation
**Risk Reference:** RISK-003 (PCI-DSS Violation / Financial Breach)
**Algorithm Assessment:** N/A (Currently None)
**Recommended Protection:** Tokenization for PANs, AES-256 for remaining PII.
**Encryption Level:** Record-level (Application-level)
**Key Management:** Token vault isolated in highly restricted VLAN; DEK managed by KMS.
**Implementation Priority:** Immediate

**Finding ID:** CRYPTO-004
**Data Category:** Financial/billing data (MySQL on billing-srv-01)
**Data State:** In Transit
**Current Protection:** Plaintext MySQL
**Vulnerability Reference:** Audit notes
**Risk Reference:** RISK-004 (MITM Credential Theft)
**Algorithm Assessment:** Inadequate (Cleartext)
**Recommended Protection:** Enforce TLS 1.2/1.3 for all MySQL connections.
**Encryption Level:** N/A (In Transit)
**Key Management:** TLS certificates managed via internal PKI.
**Implementation Priority:** Phase 1

**Finding ID:** CRYPTO-005
**Data Category:** Medical images (DICOM on PACS)
**Data State:** At Rest
**Current Protection:** None
**Vulnerability Reference:** Audit notes (PACS)
**Risk Reference:** RISK-005 (Image Tampering/Theft)
**Algorithm Assessment:** N/A (Currently None)
**Recommended Protection:** AES-256
**Encryption Level:** Full-disk (FDE) or Volume-level
**Key Management:** Key escrowed offline; automated unlock via secure OS-level keychain/TPM if applicable.
**Implementation Priority:** Phase 1

**Finding ID:** CRYPTO-006
**Data Category:** Medical images (DICOM on PACS)
**Data State:** In Transit
**Current Protection:** None (Cleartext DICOM)
**Vulnerability Reference:** Audit notes (PACS)
**Risk Reference:** RISK-006 (PHI Interception via Network)
**Algorithm Assessment:** Inadequate
**Recommended Protection:** DICOM TLS (as defined in DICOM PS3.15) using AES-256.
**Encryption Level:** N/A (In Transit)
**Key Management:** Internal PKI certificates deployed to modalities and PACS servers.
**Implementation Priority:** Phase 2

**Finding ID:** CRYPTO-007
**Data Category:** Credentials (Active Directory, application passwords)
**Data State:** At Rest
**Current Protection:** NTHash (MD4), Kerberos RC4/DES
**Vulnerability Reference:** Finding 018
**Risk Reference:** RISK-007 (Kerberoasting / Offline Cracking)
**Algorithm Assessment:** Broken (MD4, RC4, DES are deprecated and easily cracked).
**Recommended Protection:** Disable RC4/DES. Enforce AES-256 for Kerberos. Use Argon2id for custom portal applications.
**Encryption Level:** Application-level
**Key Management:** Enforce complex passwords and Windows LAPS for local admin rotation.
**Implementation Priority:** Immediate

**Finding ID:** CRYPTO-008
**Data Category:** Credentials (Active Directory)
**Data State:** In Transit
**Current Protection:** None (Cleartext LDAP)
**Vulnerability Reference:** Finding 007
**Risk Reference:** RISK-008 (Credential Harvesting)
**Algorithm Assessment:** Inadequate
**Recommended Protection:** Enforce LDAPS (LDAP over TLS) or LDAP Signing.
**Encryption Level:** N/A (In Transit)
**Key Management:** Domain Controller certificates managed by Enterprise CA.
**Implementation Priority:** Immediate

**Finding ID:** CRYPTO-009
**Data Category:** Backup data (NAS-01)
**Data State:** At Rest
**Current Protection:** None
**Vulnerability Reference:** Audit notes
**Risk Reference:** RISK-009 (Ransomware Extortion / Physical Theft)
**Algorithm Assessment:** N/A (Currently None)
**Recommended Protection:** AES-256 (LUKS)
**Encryption Level:** Volume-level
**Key Management:** Passphrase/Key kept entirely off the NAS, stored in physical safe (Key Escrow) and KMS.
**Implementation Priority:** Immediate

**Finding ID:** CRYPTO-010
**Data Category:** Patient Portal (web-srv-01)
**Data State:** In Transit
**Current Protection:** TLS 1.0, TLS 1.2
**Vulnerability Reference:** Finding 005 & Finding 013
**Risk Reference:** RISK-010 (Downgrade Attack / Connection Hijacking)
**Algorithm Assessment:** Deprecated/Broken (TLS 1.0 vulnerable to POODLE/BEAST).
**Recommended Protection:** Disable TLS 1.0/1.1. Enforce TLS 1.2/1.3 with ChaCha20-Poly1305 / AES-256-GCM. Enable HSTS.
**Encryption Level:** N/A (In Transit)
**Key Management:** Renew expiring certificate with ECC P-256 signed by commercial CA.
**Implementation Priority:** Immediate

---

## Posture Score
**100%** of MedDefense's evaluated data flows (21/21 cells identified in the T0 Data Protection Map) now have a documented, cryptographically sound, and compliance-aligned remediation path mapped to specific algorithms and key management strategies.

## Top 3 Crypto Risks
1. **Finding CRYPTO-007 (Active Directory Credentials at Rest):** The use of broken algorithms (DES, RC4, NTHash) for identity management is the highest risk. If an attacker extracts these hashes, the entire domain falls, rendering all other encryption controls moot.
2. **Finding CRYPTO-009 (Backup Data at Rest on NAS-01):** Unencrypted backups are the primary leverage point for ransomware gangs. Compromise of the NAS allows attackers to exfiltrate 100% of the patient and financial databases simultaneously.
3. **Finding CRYPTO-001 (Patient Records at Rest in PostgreSQL):** The core asset of the organization is completely unencrypted at the storage level. A host-level compromise instantly exposes 50,000 PHI records, triggering catastrophic HIPAA fines and reputation destruction.
