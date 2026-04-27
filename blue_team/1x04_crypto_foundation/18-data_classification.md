# The Data Classification Matrix

## Part 1 - Data Type Inventory

* **Regulated (HIPAA/PHI):** Patient medical records, DICOM medical images, laboratory results, electronic prescriptions, treatment plans.
* **PII (Personally Identifiable Information):** Patient contact information, employee Social Security Numbers, dates of birth, home addresses.
* **Financial:** Patient billing records, credit card PANs (PCI-DSS), payroll databases, corporate banking details.
* **Intellectual Property:** Proprietary medical research data, custom internal clinical algorithms, custom software source code.
* **Legal:** Business Associate Agreements (BAAs), vendor contracts, compliance audit reports, ongoing litigation holds.
* **Operational:** Hospital visiting hours, staff directories, cafeteria menus, IT network topology diagrams, maintenance schedules.

## Part 2 - Classification Levels

**1. Public**
* **Access:** Anyone (general public via the internet).
* **Encryption Required:** None at rest; standard TLS in transit (primarily to ensure data integrity and prevent MITM tampering, rather than confidentiality).
* **Exposure Impact:** None. The data is explicitly intended for public consumption (e.g., hospital address, public PR announcements).

**2. Internal**
* **Access:** All authenticated MedDefense employees and contractors.
* **Encryption Required:** Full-Disk/Volume encryption at rest; TLS 1.2+ in transit.
* **Exposure Impact:** Low. Unauthorized exposure may cause minor organizational embarrassment, internal confusion, or a slight loss of competitive advantage, but no regulatory fines (e.g., staff meeting schedules).

**3. Confidential**
* **Access:** Specific departments (e.g., HR, Finance) based strictly on Role-Based Access Control (RBAC).
* **Encryption Required:** File-level or Database-level encryption at rest; TLS 1.2+ in transit.
* **Exposure Impact:** Medium to High. Unauthorized exposure results in measurable financial loss, breach of contract, legal penalties, or loss of business trust (e.g., vendor contracts, unreleased financial reports).

**4. Restricted**
* **Access:** Strictly limited to authorized clinical or IT staff with an immediate, documented need-to-know.
* **Encryption Required:** Record-level or Database-level (TDE) with AES-256 and strict Hardware Security Module (HSM) key management at rest; TLS 1.3 in transit.
* **Exposure Impact:** Catastrophic. Exposure results in severe HIPAA/PCI fines, immediate harm to patients, class-action lawsuits, and critical, permanent destruction of organizational reputation (e.g., patient EHR data, cryptographic master keys).

## Part 3 - The Classification Decision Tree

Follow this logic to classify any newly generated MedDefense data:

1. Does the data contain patient health information (PHI), diagnoses, medical images, or cryptographic master keys?
   * **YES** ➔ Classify as **Restricted**.
   * **NO** ➔ Proceed to Step 2.
2. Does the data contain credit card numbers, employee SSNs, payroll data, or sensitive legal contracts?
   * **YES** ➔ Classify as **Confidential**.
   * **NO** ➔ Proceed to Step 3.
3. Is the data intended exclusively for employee use, such as internal staff directories, network diagrams, or internal memos?
   * **YES** ➔ Classify as **Internal**.
   * **NO** ➔ Proceed to Step 4.
4. Has the data been explicitly approved by the Corporate Communications or Legal department for public release?
   * **YES** ➔ Classify as **Public**.
   * **NO** ➔ Default to **Internal** and consult the IT Security Director for clarification.

## Part 4 - Sovereignty and Geolocation

Data sovereignty is the principle that digital data is subject to the laws and legal frameworks of the geographic location where it is physically stored, which is critical for healthcare because foreign jurisdictions may have conflicting data privacy or lawful intercept laws. If MedDefense stores HIPAA-regulated backups in an international AWS region, it potentially subjects American patient data to foreign government access, fundamentally violating HIPAA's strict compliance and privacy mandates. While strong client-side encryption ensures the foreign entity cannot read the data, it does not legally mitigate the sovereignty violation, as HIPAA mandates strict geographical compliance and physical data control regardless of the cryptographic state.
