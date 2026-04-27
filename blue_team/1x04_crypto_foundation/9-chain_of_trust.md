# The Chain of Trust Analysis

## Part 1 - Capture the Full Chain

**Capture Command:**
`openssl s_client -showcerts -connect github.com:443 </dev/null`

**Chain Analysis:**
There are typically 2 certificates provided in the chain by the server (the root is rarely sent as the client already has it).
1.  **Certificate 0 (Leaf Certificate):**
    * **Role:** End-entity/Leaf certificate for the actual website.
    * **Subject:** `CN = github.com, O = "GitHub, Inc.", L = San Francisco, ST = California, C = US`
    * **Issuer:** `CN = DigiCert TLS Hybrid ECC SHA384 2020 CA1, O = DigiCert Inc, C = US`
2.  **Certificate 1 (Intermediate Certificate):**
    * **Role:** Intermediate CA that bridges the trust between the Root CA and the Leaf.
    * **Subject:** `CN = DigiCert TLS Hybrid ECC SHA384 2020 CA1, O = DigiCert Inc, C = US`
    * **Issuer:** `CN = DigiCert Global Root CA, OU = www.digicert.com, O = DigiCert Inc, C = US`

*(Note how the Subject of the Intermediate perfectly matches the Issuer of the Leaf, establishing the cryptographic link).*

## Part 2 - Manual Chain Verification

**1. Verification with full chain:**
`openssl verify -untrusted intermediate.pem leaf.pem`
*Output:* `leaf.pem: OK`

**2. Verification without intermediate:**
`openssl verify leaf.pem`
*Output:* `error 20 at 0 depth lookup: unable to get local issuer certificate`

**Explanation:**
This demonstrates that browsers do not possess every possible intermediate certificate in the world; they only store the offline Root CAs. The server must send its full certificate chain (the leaf plus any intermediates) during the TLS handshake so the client can mathematically walk the path of trust back from the unknown leaf to a Root CA it already trusts. If the server fails to send the intermediate, the browser cannot bridge the gap, resulting in a broken trust chain and a blocked connection.

## Part 3 - Revocation Mechanisms

**CRL (Certificate Revocation List):**
A CRL is a digitally signed file published periodically by a CA containing a list of serial numbers for certificates that have been revoked prior to their expiration date. The client downloads this list and checks if the server's certificate is on it. Its main limitation is that the list can grow to massive sizes (megabytes), wasting bandwidth, and because it is updated periodically (e.g., daily), a client might trust a compromised certificate between update cycles.

**OCSP (Online Certificate Status Protocol):**
OCSP allows the client browser to query the CA directly in real-time about the specific status of a single certificate, rather than downloading a massive list. OCSP Stapling improves this by having the web server periodically query the CA itself and "staple" a time-stamped, CA-signed OCSP response directly to the TLS handshake. This eliminates the need for the client's browser to make a separate DNS/network call to the CA, improving privacy and handshake speed.

**MedDefense Key Compromise Sequence:**
If the portal's private key were exposed in a Git repository, the exact sequence to recover is:
1.  Immediately generate a brand-new RSA/ECC private key and a new Certificate Signing Request (CSR) on a secure system.
2.  Submit the CSR to the commercial CA to issue a replacement certificate.
3.  Install the new private key and new certificate on the `web-srv-01` Apache server and restart the service to restore secure connections.
4.  Log into the CA's management portal and explicitly submit a revocation request for the old, compromised certificate, selecting "Key Compromise" as the reason so it gets immediately pushed to OCSP responders and CRLs.

## Part 4 - Trust Store Exploration

**System Trust Store:**
* Location: `/etc/ssl/certs/`
* Command to count: `ls -1 /etc/ssl/certs/*.pem | wc -l`
* Result: My Linux system trusts approximately **137** root CAs.

**Root Certificate Inspection:**
* Command: `openssl x509 -in /etc/ssl/certs/DigiCert_Global_Root_CA.pem -text -noout`
* Validity Period:
    * Not Before: `Nov 10 00:00:00 2006 GMT`
    * Not After : `Nov 10 00:00:00 2031 GMT`
* **Surprise factor:** The validity period is massive—25 years. This makes sense, as deploying Root CAs to the operating systems and browsers of billions of devices is incredibly difficult. Because Root private keys are kept offline in physical vaults and used solely to sign intermediate CAs (not daily TLS traffic), they can safely maintain a much longer cryptographic lifespan compared to a standard 1-year leaf certificate.x
