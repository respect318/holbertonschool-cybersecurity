# Data Protection Map

| Data Categories | At Rest | In Transit | In Use |
| :--- | :--- | :--- | :--- |
| **Patient medical records (EHR data in PostgreSQL)** | Protection: None<br>Evidence: Audit notes<br>Status: Absent | Protection: Partial (ssl=on but hostnossl exists)<br>Evidence: Audit notes<br>Status: Weak | Protection: None<br>Evidence: Audit notes<br>Status: Absent |
| **Financial/billing data (MySQL on billing-srv-01)** | Protection: None<br>Evidence: 1x00 incident<br>Status: Absent | Protection: Plaintext MySQL<br>Evidence: Audit notes<br>Status: Weak | Protection: None<br>Evidence: Audit notes<br>Status: Absent |
| **Medical images (DICOM on PACS)** | Protection: None<br>Evidence: Audit notes<br>Status: Absent | Protection: None (Cleartext DICOM)<br>Evidence: Audit notes<br>Status: Absent | Protection: None<br>Evidence: Audit notes<br>Status: Absent |
| **Credentials (Active Directory, application passwords)** | Protection: NTHash (MD4), Kerberos RC4/DES<br>Evidence: Finding 018<br>Status: Weak | Protection: None (Cleartext LDAP)<br>Evidence: Finding 007<br>Status: Absent | Protection: None<br>Evidence: Audit notes<br>Status: Absent |
| **Backup data (NAS-01)** | Protection: None<br>Evidence: Audit notes<br>Status: Absent | Protection: None<br>Evidence: Finding 015<br>Status: Absent | Protection: None<br>Evidence: Audit notes<br>Status: Absent |
| **Email (O365)** | Protection: BitLocker + Per-mailbox<br>Evidence: Audit notes<br>Status: Adequate | Protection: TLS 1.2<br>Evidence: Audit notes<br>Status: Adequate | Protection: None (No S/MIME)<br>Evidence: Audit notes<br>Status: Absent |
| **VPN traffic (site-to-site tunnels)** | Protection: None<br>Evidence: Audit notes<br>Status: Absent | Protection: AES-256, SHA-256, IKEv2<br>Evidence: Audit notes<br>Status: Adequate | Protection: None<br>Evidence: Audit notes<br>Status: Absent |

## Gap Summary

* **How many of the 21 cells (7 × 3) have adequate protection?** 3
* **How many are weak?** 3
* **How many are absent?** 15
* **What is the overall crypto coverage percentage?** 14.28% (3 out of 21 cells)
