# Digital Signatures Analysis

## Part 1 - Sign and Verify

**1. Create the file:**
`echo "Patient: John Smith | MRN: MED-10042 | Rx: Metoprolol 50mg | Prescriber: Dr. Patel" > prescription.txt`

**2. Sign the file:**
`openssl dgst -sha256 -sign rsa_private.pem -out prescription.sig prescription.txt`

**3. Verify the signature:**
`openssl dgst -sha256 -verify rsa_public.pem -signature prescription.sig prescription.txt`
*Output:* `Verified OK`

**4. Modify the file and verify again:**
`echo "Patient: John Smith | MRN: MED-10042 | Rx: Metoprolol 500mg | Prescriber: Dr. Patel" > prescription.txt`
`openssl dgst -sha256 -verify rsa_public.pem -signature prescription.sig prescription.txt`
*Output:* `Verification Failure`

**Explanation:**
If a pharmacist receives a digitally signed prescription and verification fails, the prescription is legally invalid and must be rejected immediately. The failure indicates either tampering in transit or a direct forgery attempt, prompting the pharmacist to contact the prescriber directly via a secure channel to prevent potentially lethal medication errors.

## Part 2 - The Three Properties

**Integrity:**
Integrity is provided by the hashing algorithm (SHA-256 in this case). The signature mathematically encrypts a fixed-size hash of the document; upon verification, the recipient calculates their own hash of the received document and compares it to the decrypted hash from the signature. If even a single bit of the document changes, the hashes will not match, proving the file was altered.

**Authentication:**
Authentication is provided by the asymmetric key pairing mechanism. Since only the sender legitimately possesses their unique private key, only they could have generated a signature that successfully decrypts with their widely distributed public key. An attacker would need to steal the sender's private key to forge a signature that successfully authenticates as them.

**Non-repudiation:**
Non-repudiation is provided by the cryptographic binding of both the unique document hash and the sender's exclusive private key. Because the signature is intrinsically tied to both the specific document content and the sender's identity, the sender cannot technically or legally deny having signed it. An attacker cannot detach the signature to reuse it on another document, nor can the sender claim someone else forged it without admitting they carelessly lost control of their private key.

## Part 3 - MedDefense Application

**1. Electronic Health Records (EHR) Entries:**
* **Data Signed:** Patient treatment notes, diagnoses, and database updates.
* **Signer:** The attending physician or nurse making the entry.
* **Verifier:** The EHR system (PostgreSQL), medical auditors, and subsequent medical staff.
* **Consequence:** A missing or invalid signature allows unauthorized alteration of patient histories, potentially leading to incorrect treatments, patient harm, and severe legal liabilities under HIPAA.

**2. VPN Site-to-Site Tunnels:**
* **Data Signed:** The initial IKEv2/IPSec key exchange messages.
* **Signer:** The central FortiGate firewall and the remote Westside/HQ routers.
* **Verifier:** The opposing VPN endpoint router or firewall.
* **Consequence:** A missing signature allows a man-in-the-middle attack (especially vulnerable on the consumer Nighthawk router), enabling an attacker to silently intercept and read all sensitive cross-site traffic.

**3. Medical Device Software Updates:**
* **Data Signed:** Firmware patches for DICOM/PACS servers and BD Alaris pumps.
* **Signer:** The original equipment manufacturer (OEM) or MedDefense IT Administrators.
* **Verifier:** The medical device itself prior to installing the update.
* **Consequence:** An invalid signature could allow a threat actor to deploy malicious firmware or ransomware directly onto life-critical medical devices, instantly compromising patient safety and network availability.
