# Hardware Security and Key Management

## Part 1 - Technology Comparison

| Technology | What It Is | What It Protects | Typical Cost | Typical Deployment |
| :--- | :--- | :--- | :--- | :--- |
| **TPM (Trusted Platform Module)** | A dedicated cryptographic coprocessor embedded directly on a computer's motherboard. | The boot process (Secure Boot) and Full-Disk Encryption keys (e.g., BitLocker). | Low (Included in the base cost of modern devices, ~$1-2 for OEMs). | Endpoints (Employee laptops) and physical servers. |
| **HSM (Hardware Security Module)** | A dedicated, tamper-resistant physical appliance or PCIe card built specifically for high-speed cryptographic operations. | High-value cryptographic Master Keys (e.g., Root CA keys, TDE master keys). | Very High ($10,000 - $50,000+ for hardware) or Cloud ($1-2/key/month). | Data centers, Certificate Authorities, and high-security enterprise environments. |
| **Secure Enclave** | An isolated, hardware-backed execution environment within the main CPU (e.g., ARM TrustZone, Intel SGX). | Data and keys actively "in use" (in memory) from the main OS and hypervisor. | Low (Included in modern CPUs and mobile SoCs). | Mobile phones (Biometrics), IoT devices, and Cloud Confidential Computing. |
| **KMS (Software-based)** | A centralized software or cloud service (e.g., HashiCorp Vault, AWS KMS) for managing cryptographic keys and secrets. | Application API keys, passwords, and symmetric encryption keys across the network. | Low to Medium (Software licensing or minor cloud API usage fees). | Distributed cloud applications and internal enterprise networks. |

## Part 2 - MedDefense Key Management Design

**Key Storage Locations & Access:**
* **Patient Database (TDE Master Key):** Stored centrally in a Secure KMS (or Cloud HSM). Accessed only by the primary database service account and the IT Director for emergency recovery.
* **Backup Storage (LUKS Key):** Stored in a physical offline safe (Key Escrow) and the secure KMS. Accessed strictly by the IT Director and authorized Disaster Recovery personnel.
* **Portal TLS Private Key:** Stored locally on `web-srv-01` (protected by tight filesystem permissions) or dynamically fetched from KMS. Accessed by the web server daemon (Apache/Nginx) and the IT Administrator.
* **VPN Tunnel Pre-Shared Keys / Certificates:** Stored in the FortiGate firewall's internal secure storage/TPM. Accessed by the Network Administrator.

**Rotation Policy:**
* **Frequency:** TLS certificates rotate every 90 to 398 days. VPN keys rotate every 90 days. Database and Backup Master keys rotate annually (or upon key custodian turnover).
* **Process:** Generate the new key, deploy it alongside the old key, migrate the active connections/re-encrypt the Master Key Encryption Key (KEK), verify successful operation, and permanently destroy the old key.

**Compromise Procedure (Revocation & Replacement):**
If a key is compromised, it is immediately revoked. For TLS, a new key pair is generated, a new certificate is issued, and the compromised certificate is sent to the CA's Revocation List (CRL/OCSP). For the database, the TDE master key is immediately rotated, which re-encrypts the internal Data Encryption Key (DEK) without requiring a full decryption/re-encryption of the 50,000 patient records. 

**Loss Procedure (Recovery & Escrow):**
If a TLS or VPN key is lost, no data is permanently lost; new keys are simply regenerated and deployed. However, if the Database or Backup LUKS key is lost, the data is permanently unrecoverable. Therefore, these high-impact symmetric keys are placed in **Key Escrow**—a physical, encrypted hard drive or paper copy stored in a tamper-evident envelope inside a bank safe deposit box, accessible only by the CEO and IT Director together.

## Part 3 - The HSM Decision

Based on the 1x03 Risk Register, a breach of the 50,000-record patient database due to key compromise carries a catastrophic impact (HIPAA fines, lawsuits, reputation loss) resulting in an Annualized Loss Expectancy (ALE) in the millions of dollars (e.g., $15,000,000 impact × 0.1 ARO = $1,500,000 ALE). 

By contrast, the cost of mitigating this risk using a Cloud-based HSM-as-a-Service is exceptionally low (approximately $1-2 per key per month, or a few hundred dollars annually for a dedicated partition). This investment is **overwhelmingly justified**. By moving the database master keys out of plaintext configuration files and into a dedicated, tamper-proof HSM, MedDefense completely neutralizes the threat of a software-level key exfiltration (like the 1x01 cryptominer or a directory traversal attack), providing a massive Return on Security Investment (ROSI).
