# Obfuscation Toolkit Analysis

## Part 1 - Technique Comparison

| Technique | What it does to the data | Recoverability | Healthcare Use Case |
| :--- | :--- | :--- | :--- |
| **Encryption** | Scrambles data using mathematical algorithms and cryptographic keys. | Recoverable by authorized parties possessing the correct decryption key. | Protecting the PostgreSQL Electronic Health Records (EHR) database at rest. |
| **Hashing** | Converts data into a fixed-size, one-way mathematical string (digest). | Non-recoverable (computationally infeasible to reverse). | Securely storing user passwords for the MedDefense patient portal. |
| **Tokenization** | Replaces sensitive data with a randomly generated, non-sensitive substitute (token) that has no intrinsic value. | Recoverable only by the secure system holding the central token vault mapping. | Processing patient credit card payments without storing the actual card numbers in the billing database. |
| **Data Masking** | Obscures specific parts of the data while preserving the overall format (e.g., replacing characters with asterisks). | Non-recoverable from the masked output alone. | Displaying SSNs on a customer service screen as `***-**-1234`. |
| **Steganography** | Hides the existence of sensitive data by embedding it within other seemingly innocuous files (like images or audio). | Recoverable only by the person who embedded it or possesses the specific extraction tool. | (Malicious Use Case): An insider hiding exfiltrated PHI inside legitimate DICOM X-ray files. |

## Part 2 - MedDefense Tokenization Design

* **What data is tokenized:** Full Credit Card Primary Account Numbers (PANs). The token format preserves the length and structure to integrate smoothly with the legacy billing application (e.g., a 16-digit alphanumeric string keeping the last 4 digits for identity verification: `XXXX-XXXX-XXXX-4567`).
* **Vault storage and protection:** The token-to-real-data vault is stored on a dedicated, logically isolated server in a highly restricted VLAN. The vault database itself is encrypted at rest using AES-256, protected by strict Role-Based Access Control (RBAC), and requires Multi-Factor Authentication (MFA) for any administrative access.
* **Compromise impact:** If the token vault is compromised, the attacker gains the direct mapping of tokens to actual credit card numbers, effectively turning the useless tokens back into sensitive PANs and causing a massive PCI-DSS breach.
* **Tokenization vs. Encryption:** Tokenization significantly reduces MedDefense's PCI compliance scope because the main billing application server never processes or stores the actual encrypted PAN or decryption keys, only the valueless token. Encryption, by contrast, requires the application server to handle ciphertext and cryptographic keys, keeping the entire application infrastructure fully in-scope for rigorous PCI-DSS audits.

## Part 3 - Data Masking Examples

| Data Field | Full Value | Nurse (clinical) | Billing Clerk | Reception |
| :--- | :--- | :--- | :--- | :--- |
| **SSN** | 987-65-4321 | `***-**-4321` | `987-65-4321` | `***-**-4321` |
| **Patient Name**| Maria Gonzalez | `Maria Gonzalez` | `Maria Gonzalez` | `Maria Gonzalez` |
| **Diagnosis** | Type 2 Diabetes | `Type 2 Diabetes` | `Type 2 Diabetes` (or ICD-10 code) | `[REDACTED]` |

**Justifications:**
* **Nurse (clinical):** Needs full access to the Name and Diagnosis for direct patient care, but only requires the last 4 digits of the SSN for identity verification, not the full SSN.
* **Billing Clerk:** Needs the Full SSN for Medicare/insurance claims, the Full Name for account records, and the Diagnosis (or ICD-10 code) to justify the medical billing codes.
* **Reception:** Needs the Full Name to greet the patient and the last 4 digits of the SSN to verify identity at check-in, but has absolutely no clinical need-to-know regarding the patient's Diagnosis.

## Part 4 - Steganography as Threat Vector

Steganography represents a severe threat to MedDefense's Data Loss Prevention (DLP) program because it hides the very existence of stolen data, making it invisible to standard keyword scanners or regex filters. A malicious insider could use steganography tools to embed thousands of text-based patient records into the least significant bits of a single, large DICOM medical image file. Because DICOM files are massive binary objects routinely and legitimately transferred between hospitals, the exfiltration traffic would blend seamlessly into normal network operations without triggering data volume alerts. This makes it significantly harder to detect than traditional exfiltration, as the file extension, structure, and visual appearance of the image remain perfectly intact. To counter this, MedDefense must rely on the strict egress filtering (restricting outbound traffic to authorized destinations) and anomaly detection controls outlined in the 1x03 strategy, which would flag the unauthorized external transfer regardless of the file's contents.
