# Asymmetric Encryption Analysis

## Part 1 - RSA Key Generation and Encryption

**1. RSA Key Generation:**
`openssl genrsa -out rsa_private.pem 2048`
`openssl rsa -in rsa_private.pem -pubout -out rsa_public.pem`

**2. Encrypt and Decrypt a Small File:**
`openssl pkeyutl -encrypt -in patient_data.txt -pubin -inkey rsa_public.pem -out patient_data.rsa.enc`
`openssl pkeyutl -decrypt -in patient_data.rsa.enc -inkey rsa_private.pem -out patient_data.rsa.dec`

**3. Attempting to Encrypt a 100MB File:**
`openssl pkeyutl -encrypt -in testfile -pubin -inkey rsa_public.pem -out testfile.rsa.enc`

**Error Message:**
`00A2C99A01000000:error:0200006E:rsa routines:rsa_ossl_public_encrypt:data too large for key size:crypto/rsa/rsa_ossl.c:542:`

**Explanation:**
RSA encryption is mathematically limited by its key size; a 2048-bit key can only encrypt a maximum of 245 bytes of data at a time (when using standard PKCS#1 padding). It is incredibly slow and computationally expensive for bulk data. In real-world usage, this means RSA is never used to encrypt actual files or payloads, but rather used strictly for encrypting small, fixed-size data like symmetric session keys or cryptographic hashes.

## Part 2 - ECC Key Generation

**1. ECC Key Generation:**
`openssl ecparam -genkey -name prime256v1 -out ecc_private.pem`
`openssl ec -in ecc_private.pem -pubout -out ecc_public.pem`

**2. File Size Comparison and Explanation:**
An RSA-2048 private key file is approximately 1679 bytes, while an ECC P-256 private key is roughly 227 bytes, resulting in a size ratio of about 7.4 to 1. ECC achieves equivalent security with much smaller keys because it relies on the Elliptic Curve Discrete Logarithm Problem, a mathematical challenge that is fundamentally harder to crack per bit than RSA's integer factorization. For MedDefense's constrained environments, like BD Alaris pumps or Philips monitors, these smaller keys translate to significantly lower CPU usage, reduced memory consumption, and faster computation during secure handshakes without sacrificing security strength.

## Part 3 - The Hybrid Model

The hybrid model combines the secure key distribution capabilities of asymmetric cryptography with the high-speed performance of symmetric cryptography. In this model, two parties first use an asymmetric algorithm (like RSA or ECC) over an insecure channel to securely exchange or agree upon a temporary, shared symmetric "session key". Once this session key is established, both parties switch exclusively to a symmetric algorithm (like AES) to encrypt and decrypt the actual data payload. This combination is superior because it solves the complex problem of distributing a shared secret without suffering the extreme size limitations and slow processing speeds inherent to asymmetric encryption. For MedDefense's patient portal connecting via HTTPS, the asymmetric portion (RSA/ECC) handles the initial TLS handshake and session key exchange, while the symmetric portion (AES or ChaCha20) handles the bulk encryption of the HTML pages and medical records transmitted afterward.

## Part 4 - The Key Length Table

| Algorithm | Type | Key Lengths | Equivalent Security | Status | MedDefense Usage |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **AES** | Symmetric | 128, 192, 256-bit | High (Quantum-resistant at 256) | Approved | Bulk data encryption (Databases, VPN tunnels) |
| **RSA** | Asymmetric | 2048, 4096-bit | Moderate to High | Approved (2048+ only) | TLS certificates, Key exchange |
| **ECC** | Asymmetric | P-256, P-384 | High (P-256 = RSA-3072) | Approved | Modern TLS, IoT/Constrained medical devices |
| **ChaCha20-Poly1305** | Symmetric | 256-bit | High | Approved | TLS 1.3 bulk data encryption, mobile clients |
| **DES** | Symmetric | 56-bit | Very Low (Broken) | Not Approved | Legacy Kerberos (Finding 018) - Must disable |
| **3DES** | Symmetric | 112, 168-bit | Low (Deprecated) | Not Approved | Legacy systems - Must phase out |
| **RC4** | Symmetric | 40 to 2048-bit | Very Low (Broken) | Not Approved | Legacy Active Directory - Must disable |
