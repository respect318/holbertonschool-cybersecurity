# The Encryption Levels

## Encryption Level Comparison

| Level | Scope | Performance Impact | Key Management | Use Case |
| :--- | :--- | :--- | :--- | :--- |
| **Full-disk (FDE)** | Entire physical or virtual disk (including OS and temp files) | Low (Hardware accelerated via AES-NI) | OS-level (TPM, Pre-boot authentication) | Best for laptops and physical servers vulnerable to physical theft. |
| **Partition** | One logical partition | Low | OS-level (Unlocked at mount time) | Best when separating a protected data partition from an unencrypted OS boot partition on the same drive. |
| **Volume** | Logical volume (may span multiple physical disks) | Low to Medium | Volume Manager level (e.g., LUKS, LVM) | Best for massive storage arrays like NAS or SANs where data spans across a RAID configuration. |
| **File** | Individual files or directories | Medium | User-level or Application-level | Best for protecting specific sensitive documents on shared file servers while leaving non-sensitive files accessible. |
| **Database** | Entire database or tablespace (TDE - Transparent Data Encryption) | Medium | DBMS-level (Managed by the database engine) | Best for securing a massive database at rest transparently without rewriting the application's SQL queries. |
| **Record** | Individual fields, columns, or records (e.g., SSN, Credit Card) | High (Breaks native indexing, sorting, and searching) | Application-level (Requires granular key mapping) | Best for ultra-sensitive data that must be hidden even from the Database Administrators (DBAs) with legitimate server access. |

## MedDefense Encryption Level Map

**1. Patient records in PostgreSQL (ehr-db-01)**
* **Recommended Level:** Database-level (Transparent Data Encryption - TDE).
* **Justification:** TDE encrypts the data at rest on the storage media while transparently decrypting it for authorized application queries, securing the 50,000 patient records without breaking the complex search and indexing functions the EHR software relies on.

**2. Backup data on NAS-01**
* **Recommended Level:** Volume-level.
* **Justification:** Since the Synology NAS utilizes a RAID array spanning multiple physical disks, volume encryption ensures that all backup dumps and archives written to the storage pool are automatically encrypted, regardless of the backup utility used.

**3. Financial records in MySQL (billing-srv-01)**
* **Recommended Level:** Record-level (Application-level).
* **Justification:** Financial tables contain highly sensitive PCI-DSS regulated data (like Credit Card PANs and SSNs) that neither the DBAs nor the general IT staff should ever see in plaintext; record-level encryption ensures this data remains encrypted even if an attacker or rogue insider runs a `SELECT *` query.

**4. Medical images on PACS (pacs-srv-01)**
* **Recommended Level:** Full-disk (FDE) or Volume-level.
* **Justification:** DICOM files are massive binary objects, and encrypting them individually at the file or record level would introduce severe latency for radiologists; full-disk encryption secures the physical storage against theft with minimal overhead.

**5. Email data in O365**
* **Recommended Level:** File/Mailbox-level (in addition to Microsoft's underlying FDE).
* **Justification:** In a multi-tenant cloud environment, file or mailbox-level encryption ensures that MedDefense's emails are cryptographically isolated from other Microsoft customers and requires MedDefense-specific keys to access the contents.

**6. Employee laptops**
* **Recommended Level:** Full-disk (BitLocker for Windows).
* **Justification:** Laptops are highly mobile and present the greatest risk of physical theft or loss; FDE ensures that the operating system, swap files, temporary caches, and all user data are completely inaccessible if the device is stolen.

**7. BD Alaris pump firmware/configuration**
* **Recommended Level:** File-level.
* **Justification:** Constrained medical IoT devices lack the computational power and storage architecture to support full-disk encryption; file-level encryption efficiently protects only the specific sensitive configuration files and cryptographic keys without overwhelming the device's limited CPU.
