# MedDefense Backup Architecture

## Strategy Overview
The MedDefense backup architecture is designed around the industry-standard **3-2-1 backup methodology**: maintaining at least 3 copies of clinical and operational data, stored on 2 different media types, with at least 1 copy located off-site in a geographically separate cloud environment. This ensures resilience against localized hardware failures, primary data center loss, and ransomware encryption events.

Furthermore, this architecture utilizes a **dependency-aware sequencing** design. Restoring systems alphabetically or simultaneously leads to catastrophic failure if prerequisites (like Network routing or Active Directory DNS) are unavailable. The design enforces foundational infrastructure recovery first, followed by identity services, and finally Tier 1 and Tier 2 clinical applications, ensuring that dependent systems can authenticate and route traffic the moment they come online.

## RPO Compliance Verification
To prevent mathematical contradictions where promised recovery points are impossible, the backup architecture must show the math. The Maximum Possible Data Loss is calculated as:
**Backup Frequency + Backup Execution Time = Maximum Data Loss**

To be compliant, the Maximum Data Loss must be strictly less than or equal to (<=) the Declared RPO. The table below proves this mathematical compliance for all Tier 1 and Tier 2 systems.

| System | Declared RPO | Backup Frequency | Execution Time | Math (Freq + Exec = Max Loss) | Compliance Check |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Network Core | 15 mins | 5 mins | 1 min | 5m + 1m = 6 mins | 6 mins <= 15 mins (PASS) |
| Epic EHR | 15 mins | 5 mins | 2 mins | 5m + 2m = 7 mins | 7 mins <= 15 mins (PASS) |
| Backup and DR Infrastructure | 60 mins (1h) | 30 mins | 10 mins | 30m + 10m = 40 mins | 40 mins <= 60 mins (PASS) |
| Active Directory | 60 mins (1h) | 30 mins | 15 mins | 30m + 15m = 45 mins | 45 mins <= 60 mins (PASS) |
| PACS/RIS | 60 mins (1h) | 30 mins | 20 mins | 30m + 20m = 50 mins | 50 mins <= 60 mins (PASS) |
| Laboratory Information System | 60 mins (1h) | 30 mins | 15 mins | 30m + 15m = 45 mins | 45 mins <= 60 mins (PASS) |
| Pharmacy Dispensing System | 60 mins (1h) | 30 mins | 15 mins | 30m + 15m = 45 mins | 45 mins <= 60 mins (PASS) |
| Medical Device Integration Gateway| 120 mins (2h) | 60 mins | 10 mins | 60m + 10m = 70 mins | 70 mins <= 120 mins (PASS) |
| Security Operations Platform | 240 mins (4h) | 60 mins | 10 mins | 60m + 10m = 70 mins | 70 mins <= 240 mins (PASS) |

## Per-System Backup Specifications

### 1. Network Core (Tier 1)
* **Backup type**: Automated configuration snapshot.
* **Schedule**: Every 5 minutes.
* **Retention**: 30 days recent, 12 months archive.
* **Primary destination**: On-site secure configuration repository.
* **Secondary destination**: Off-site AWS S3 cloud bucket.
* **Encryption at rest**: AES-256 via KMS.
* **Encryption in transit**: TLS 1.2+ for management APIs.
* **Integrity verification**: Nightly SHA-256 hash validation and automated syntax restore-test.
* **Restoration sequence**: Deploy bare-metal switch, apply golden image firmware, push latest config snapshot.
* **Responsible role**: Network Engineer (executes), Infrastructure Manager (verifies).

### 2. Epic EHR (Tier 1)
* **Backup type**: Full database backup with continuous transaction log shipping.
* **Schedule**: Full daily, transaction logs every 5 minutes.
* **Retention**: 30 days recent, 10 years compliance archive.
* **Primary destination**: On-site NVMe backup array.
* **Secondary destination**: Off-site cloud availability zone.
* **Encryption at rest**: AES-256 with strict key separation.
* **Encryption in transit**: TLS 1.2+.
* **Integrity verification**: Daily automated restore-test into a non-production validation container with DB consistency checks.
* **Restoration sequence**: Mount storage, initialize DB engine, replay transaction logs to the exact crash point.
* **Responsible role**: Lead Database Administrator (executes), CISO (verifies).

### 3. Backup and DR Infrastructure (Tier 1)
* **Backup type**: Backup catalog and metadata replication.
* **Schedule**: Incremental every 30 minutes.
* **Retention**: 90 days recent, 3 years archive.
* **Primary destination**: Dedicated on-site hardened storage appliance.
* **Secondary destination**: Geographically isolated cloud vault.
* **Encryption at rest**: AES-256.
* **Encryption in transit**: TLS 1.2+ over dedicated VPN.
* **Integrity verification**: Automated checksum validation upon catalog write.
* **Restoration sequence**: Rebuild DR management server, import latest catalog from cloud vault, initialize arrays.
* **Responsible role**: Storage Administrator (executes), DR Coordinator (verifies).

### 4. Active Directory (Tier 1)
* **Backup type**: System State and Active Directory Database (NTDS.dit) backup.
* **Schedule**: Full daily, delta sync every 30 minutes.
* **Retention**: 60 days to prevent tombstone lifetime issues.
* **Primary destination**: On-site immutable backup SAN.
* **Secondary destination**: Off-site cloud repository.
* **Encryption at rest**: AES-256.
* **Encryption in transit**: TLS 1.2+.
* **Integrity verification**: Weekly automated restore-test into an isolated sandbox domain.
* **Restoration sequence**: Authoritative restore from latest 30-min delta, verify DNS resolution.
* **Responsible role**: Identity Access Administrator (executes), Security Lead (verifies).

### 5. PACS/RIS (Tier 1)
* **Backup type**: Incremental block-level storage backup.
* **Schedule**: Full weekly, incremental every 30 minutes.
* **Retention**: 30 days recent, 7 years compliance archive.
* **Primary destination**: On-site high-capacity NAS.
* **Secondary destination**: Cloud glacier storage (geographically separate).
* **Encryption at rest**: AES-256.
* **Encryption in transit**: TLS 1.2+.
* **Integrity verification**: DICOM header hash verification and monthly sample image restore-test.
* **Restoration sequence**: Provision block storage, restore database, map DICOM archive paths.
* **Responsible role**: Radiology IT Specialist (executes), Clinical Operations (verifies).

### 6. Laboratory Information System (Tier 1)
* **Backup type**: VM snapshot and SQL backup.
* **Schedule**: Full daily, incremental every 30 minutes.
* **Retention**: 30 days recent, 7 years compliance archive.
* **Primary destination**: On-site backup SAN.
* **Secondary destination**: Cloud backup vault.
* **Encryption at rest**: AES-256.
* **Encryption in transit**: TLS 1.2+.
* **Integrity verification**: Automated script checking SQL table readability post-restore.
* **Restoration sequence**: Restore application VM, inject 30-min SQL differential, verify AD connectivity.
* **Responsible role**: Clinical Application Engineer (executes), Lab Director (verifies).

### 7. Pharmacy Dispensing System (Tier 2)
* **Backup type**: Application state and database backup.
* **Schedule**: Full daily, incremental every 30 minutes.
* **Retention**: 30 days recent, 5 years archive.
* **Primary destination**: On-site backup SAN.
* **Secondary destination**: Off-site cloud storage.
* **Encryption at rest**: AES-256.
* **Encryption in transit**: TLS 1.2+.
* **Integrity verification**: Hash-based checksums combined with weekly sandbox boot-tests.
* **Restoration sequence**: Restore application server, sync DB, reconnect to Epic EHR API.
* **Responsible role**: Pharmacy IT Admin (executes), Lead Pharmacist (verifies).

### 8. Medical Device Integration Gateway (Tier 2)
* **Backup type**: Virtual machine configuration snapshot.
* **Schedule**: Incremental every 60 minutes.
* **Retention**: 14 days recent.
* **Primary destination**: On-site backup SAN.
* **Secondary destination**: Cloud storage.
* **Encryption at rest**: AES-256.
* **Encryption in transit**: TLS 1.2+.
* **Integrity verification**: Monthly automated VM boot test in sandbox.
* **Restoration sequence**: Deploy VM snapshot, test HL7 routing to Epic EHR.
* **Responsible role**: Biomedical IT Engineer (executes), Nursing Lead (verifies).

### 9. Security Operations Platform (Tier 2)
* **Backup type**: Log snapshot and SIEM configuration backup.
* **Schedule**: Incremental every 60 minutes.
* **Retention**: 1 year hot search, 3 years cold archive.
* **Primary destination**: On-site secure log server.
* **Secondary destination**: Off-site cloud log vault.
* **Encryption at rest**: AES-256.
* **Encryption in transit**: TLS 1.2+.
* **Integrity verification**: WORM (Write Once Read Many) lock validation and hash matching.
* **Restoration sequence**: Rebuild SIEM core, import configuration, attach to cold storage.
* **Responsible role**: SOC Analyst (executes), Security Manager (verifies).

## Full Data Center Loss: Restoration Sequence
In the event of a catastrophic primary data center failure, systems must be restored in the following strict order to respect logical dependencies:

1. **Network Core**: Establishes VLANs, subnets, and routing. Without this, no nodes can communicate or download backup images.
2. **Backup and DR Infrastructure**: Recovered next to provide access to the backup payloads required for all subsequent steps.
3. **Active Directory**: Provides DNS resolution, service accounts, and identity authentication required by databases and clinical applications.
4. **PACS/RIS**: Restored simultaneously with AD to allow emergency standalone stroke/trauma imaging without needing full EHR integration.
5. **Epic EHR**: The core clinical database. Needs Network and AD running to function.
6. **Laboratory Information System**: Depends on Epic EHR to process stat lab orders.
7. **Pharmacy Dispensing System**: Depends on Epic EHR for valid e-prescriptions.
8. **Security Operations Platform**: Brought online to monitor the newly restored environment for secondary attacks.
9. **Medical Device Integration Gateway**: Restored last to resume automated vitals flow into the already-running Epic EHR.

## Dependency Restore Constraints
Restoration sequences are strictly gated by dependency prerequisites. 
- **Identity Constraint:** Active Directory must achieve full DNS resolution and authentication capability before the database engines for Epic EHR, LIS, or Pharmacy are spun up. 
- **Application Constraint:** Peripheral clinical systems (LIS, Pharmacy, Device Gateway) cannot be restored until Epic EHR is fully functional, as they rely on Epic's APIs for patient data reconciliation. Restoring them out of order would result in clinical data corruption and immediate application crashes.
