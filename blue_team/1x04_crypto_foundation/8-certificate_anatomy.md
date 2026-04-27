# The Certificate Anatomy

## Part 1 - Inspect Three Real Certificates

**1. Let's Encrypt Certificate (example: letsencrypt.org)**
* **Subject:** `CN = lencr.org` (Domain Validation typically omits O, L, ST, C)
* **Issuer:** `CN = R3, O = Let's Encrypt, C = US`
* **Validity Period:** * Not Before: `Feb 15 00:00:00 2024 GMT`
  * Not After : `May 15 23:59:59 2024 GMT`
* **Serial Number:** `04:88:5a:06:91:df:49:12:8e:63:7a:5e:a3:20:8c:11:15:3e`
* **Signature Algorithm:** `sha256WithRSAEncryption`
* **Public Key Algorithm and Key Size:** `id-ecPublicKey` (ECDSA P-256)
* **Subject Alternative Names (SAN):** `DNS:lencr.org`, `DNS:www.lencr.org`
* **Key Usage:** `Digital Signature`
* **Extended Key Usage:** `TLS Web Server Authentication, TLS Web Client Authentication`
* **Authority Information Access:** * OCSP - URI:`http://r3.o.lencr.org`
  * CA Issuers - URI:`http://r3.i.lencr.org/`

**2. Commercial CA Certificate (example: github.com)**
* **Subject:** `CN = github.com, O = "GitHub, Inc.", L = San Francisco, ST = California, C = US`
* **Issuer:** `CN = DigiCert TLS Hybrid ECC SHA384 2020 CA1, O = DigiCert Inc, C = US`
* **Validity Period:**
  * Not Before: `Mar 07 00:00:00 2024 GMT`
  * Not After : `Mar 07 23:59:59 2025 GMT`
* **Serial Number:** `02:51:71:0d:5a:42:0a:c9:88:31:34:b3:f1:0c:e5:0c`
* **Signature Algorithm:** `sha384WithRSAEncryption`
* **Public Key Algorithm and Key Size:** `id-ecPublicKey` (ECDSA P-256)
* **Subject Alternative Names (SAN):** `DNS:github.com`, `DNS:www.github.com`
* **Key Usage:** `Digital Signature`
* **Extended Key Usage:** `TLS Web Server Authentication, TLS Web Client Authentication`
* **Authority Information Access:**
  * OCSP - URI:`http://ocsp.digicert.com`
  * CA Issuers - URI:`http://cacerts.digicert.com/DigiCertTLSHybridECCSHA3842020CA1-1.crt`

**3. Broken Certificate (expired.badssl.com)**
* **Subject:** `CN = *.badssl.com, O = BadSSL, L = San Francisco, ST = California, C = US`
* **Issuer:** `CN = COMODO RSA Domain Validation Secure Server CA, O = COMODO CA Limited, L = Salford, ST = Greater Manchester, C = GB`
* **Validity Period:**
  * Not Before: `Apr 09 00:00:00 2015 GMT`
  * Not After : `Apr 12 23:59:59 2015 GMT`
* **Serial Number:** `00:d0:d0:d0:d0:d0:d0:d0:d0:d0:d0:d0:d0:d0:d0:d0:d0`
* **Signature Algorithm:** `sha256WithRSAEncryption`
* **Public Key Algorithm and Key Size:** `rsaEncryption` (RSA 2048-bit)
* **Subject Alternative Names (SAN):** `DNS:*.badssl.com`, `DNS:badssl.com`
* **Key Usage:** `Digital Signature, Key Encipherment`
* **Extended Key Usage:** `TLS Web Server Authentication, TLS Web Client Authentication`
* **Authority Information Access:**
  * OCSP - URI:`http://ocsp.comodoca.com`

## Part 2 - The Broken Certificate

The `expired.badssl.com` certificate is invalid because its "Not After" date explicitly shows it expired in 2015. A modern web browser would immediately halt the connection and display an `ERR_CERT_DATE_INVALID` (or `SEC_ERROR_EXPIRED_CERTIFICATE`) error. This misconfiguration creates a massive security risk because the CA's validation of the domain ownership is decades out of date, and the private key has lived far past its intended cryptographic cryptoperiod, increasing the likelihood of key compromise. I would strongly advise a patient **never** to proceed to a medical portal displaying this error; instructing patients to click past certificate warnings trains them to ignore active Man-in-the-Middle (MITM) attacks, directly threatening their Protected Health Information (PHI).

## Part 3 - MedDefense Certificate Profile

* **Type:** Organization Validation (OV). While DV is cheaper and EV provides maximum visual trust, OV strikes the perfect balance for healthcare by cryptographically proving to the patient that the portal is genuinely owned by the legally registered "MedDefense" organization, deterring phishing attempts.
* **Issuing CA:** A reputable commercial CA like DigiCert, GlobalSign, or Sectigo. These CAs maintain stringent validation procedures for OV certificates, which aligns with healthcare compliance frameworks like HIPAA.
* **SAN Entries:** `DNS:portal.meddefense.com`, `DNS:www.meddefense.com`, `DNS:meddefense.com`.
* **Key Algorithm and Size:** `ECC P-256` (or `ECC P-384`). Elliptic Curve keys provide superior security (equivalent to RSA-3072) with significantly less computational overhead, ensuring fast, secure TLS handshakes for patients on mobile devices.
* **Validity Period:** 398 days (the maximum industry limit for commercial certificates), heavily paired with automated tracking to prevent the exact 18-day expiration crisis currently facing the portal. Alternatively, 90 days if strictly using automated ACME protocols.
* **Wildcard vs. Single-domain:** A strict **single-domain (with SANs)** certificate is appropriate. Wildcard certificates (`*.meddefense.com`) violate the principle of least privilege; if a single server using the wildcard key is compromised, the attacker can impersonate every subdomain on the network, including the highly sensitive patient portal.
