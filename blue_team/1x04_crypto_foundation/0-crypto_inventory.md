# MedDefense Data Protection Map

| Data Category | At Rest | In Transit | In Use |
| :--- | :--- | :--- | :--- |
| **Patient medical records** | **Protection:** None<br>**Evidence:** Audit notes<br>**Status:** Absent | **Protection:** Partial (SSL=on, non-SSL allowed)<br>**Evidence:** Audit notes<br>**Status:** Weak | **Protection:** None<br>**Evidence:** Audit notes<br>**Status:** Absent |
| **Financial/billing data** | **Protection:** None<br>**Evidence:** 1x00 observation<br>**Status:** Absent | **Protection:** Plaintext MySQL<br>**Evidence:** Audit notes<br>**Status:** Weak | **Protection:** None<br>**Evidence:** Audit notes inference<br>**Status:** Absent |
| **Medical images** | **Protection:** None<br>**Evidence:** Audit notes (PACS)<br>**Status:** Absent | **Protection:** None (Cleartext DICOM)<br>**Evidence:** Audit notes (PACS)<br>**Status:** Absent | **Protection:** None<br>**Evidence:** Audit notes (PACS)<br>**Status:** Absent |
| **Credentials** | **Protection:** NTHash (MD4), Kerberos RC4/DES<br>**Evidence:** Finding 018<br>**Status:** Weak | **Protection:** None (Cleartext LDAP)<br>**Evidence:** Finding 007<br>**Status:** Absent | **Protection:** None<br>**Evidence:** Audit notes inference<br>**Status:** Absent |
| **Backup data** | **Protection:** None<br>**Evidence:** Audit notes<br>**Status:** Absent | **Protection:** None<br>**Evidence:** Finding 015<br>**Status:** Absent | **Protection:** None<br>**Evidence:** Audit notes<br>**Status:** Absent |
| **Email** | **Protection:** BitLocker + Per-mailbox encryption<br>**Evidence:** Audit notes (O365)<br>**Status:** Adequate | **Protection:** TLS 1.2<br>**Evidence:** Audit notes (O365)<br>**Status:** Adequate | **Protection:** None (No S/MIME/OME)<br>**Evidence:** Audit notes (O365)<br>**Status:** Absent |
| **VPN traffic** | **Protection:** N/A<br>**Evidence:** Audit notes<br>**Status:** Absent | **Protection:** AES-256, SHA-256, IKEv2<br>**Evidence:** Audit notes<br>**Status:** Adequate | **Protection:** N/A<br>**Evidence:** Audit notes<br>**Status:** Absent |

## Gap Summary

* **Total Cells Evaluated:** 21 (7 categories × 3 states)
* **Adequate Protection:** 3 cells
* **Weak Protection:** 3 cells
* **Absent Protection:** 15 cells (including N/A states for tunnel endpoints)

**Overall Crypto Coverage Percentage:**
* **Fully Adequate Coverage:** 14.28% (3 out of 21 cells)
* **Partial/Weak Coverage Included:** 28.57% (6 out of 21 cells)
