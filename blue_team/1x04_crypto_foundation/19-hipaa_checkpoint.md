# The HIPAA Crypto Checkpoint

## HIPAA Crypto Compliance Table

| HIPAA Requirement | Citation | Current MedDefense State | Compliant? | Gap / Remediation |
| :--- | :--- | :--- | :--- | :--- |
| **Encryption and Decryption (At Rest)** | §164.312(a)(2)(iv) | The primary PostgreSQL EHR database (`ehr-db-01`) and the NAS-01 backup storage containing ePHI are stored entirely in plaintext without any disk or database-level encryption. | **No** | **Gap:** Massive ePHI exposure at the storage layer.<br>**Remediation:** Implement Transparent Data Encryption (TDE) for the PostgreSQL database using AES-256 and Full-Disk/Volume Encryption (LUKS) for NAS backups. |
| **Transmission Security (Integrity)** | §164.312(e)(1) | Internal network traffic containing ePHI, specifically DICOM medical imaging traffic between workstations and the PACS server, is transmitted in cleartext without integrity checks. | **No** | **Gap:** High risk of internal MITM tampering or unauthorized network sniffing.<br>**Remediation:** Enforce DICOM TLS (PS3.15) for all internal imaging traffic to ensure transmission integrity. |
| **Encryption (In Transit)** | §164.312(e)(2)(ii) | The external patient portal (`web-srv-01`) supports broken, deprecated TLS 1.0. Internal EHR database connections allow non-SSL fallback (`hostnossl`). Staff routinely email PHI in plaintext. | **No** | **Gap:** Deprecated protocols and plaintext channels expose ePHI in transit.<br>**Remediation:** Disable TLS 1.0/1.1 and enforce TLS 1.2/1.3 on the portal. Remove `hostnossl` from `pg_hba.conf`. Enforce secure messaging for clinical staff. |
| **Person or Entity Authentication** | §164.312(d) | Active Directory authentication relies on broken cryptographic algorithms (DES, RC4) and stores credentials using NTHash. LDAP traffic is unencrypted (Finding 007). | **No** | **Gap:** Weak authentication cryptography allows trivial credential theft and unauthorized access to ePHI systems.<br>**Remediation:** Disable DES/RC4 via Group Policy, enforce AES-256 for Kerberos, and mandate LDAPS. |

## Audit Assessment

MedDefense would unequivocally fail a formal HIPAA security audit today. While the organization possesses numerous cryptographic flaws, an auditor would cite the **complete lack of encryption at rest for the core PostgreSQL Electronic Health Records (EHR) database and the NAS backup systems** as the most critical and negligent deficiency. The HIPAA Security Rule mandates that covered entities implement addressable encryption standards or highly equivalent alternatives; MedDefense has done neither, leaving 50,000 sensitive patient records completely exposed to physical theft, rogue internal access, or ransomware exfiltration without any cryptographic barrier.
