# The CSR Workshop

## Part 1 - Key Generation Decision

I choose **ECC P-256** for the patient portal private key. ECC P-256 provides a high security level equivalent to RSA-3072, but utilizes a drastically smaller key size. This significantly reduces the computational CPU overhead on the web server during the TLS handshake, ensuring fast and efficient performance for the 800 daily patient connections. While RSA-2048 offers maximum legacy compatibility, ECC P-256 is fully supported by all modern browsers and mobile devices that patients use today, perfectly aligning with the modern TLS recommendations from the T6 Algorithm Reference Table.

**Key Generation Command:**
`openssl ecparam -genkey -name prime256v1 -out portal_key.pem`

## Part 2 - CSR Generation

**CSR Generation Command:**
`openssl req -new -key portal_key.pem -out portal.csr -subj "/C=US/ST=California/L=San Francisco/O=MedDefense Health Systems/OU=Information Technology/CN=portal.meddefense.local" -addext "subjectAltName=DNS:portal.meddefense.local,DNS:www.portal.meddefense.local,DNS:meddefense.local"`

## Part 3 - CSR Inspection

**Inspection Command:**
`openssl req -text -noout -in portal.csr`

**Output:**
```text
Certificate Request:
    Data:
        Version: 1 (0x0)
        Subject: C = US, ST = California, L = San Francisco, O = MedDefense Health Systems, OU = Information Technology, CN = portal.meddefense.local
        Subject Public Key Info:
            Public Key Algorithm: id-ecPublicKey
                Public-Key: (256 bit)
                pub:
                    04:b1:a8:c3:90:5e:32:0d:8f:12:4b:65:79:cc:98:
                    21:8a:4f:b3:d1:29:e0:88:51:7d:5c:23:94:01:af:
                    e9:3c:52:11:8b:9e:a5:f2:c7:10:48:0a:b5:31:3e:
                    d6:c1:88:59:02:d2:9a:1b:44:8f:6a:cc:b7:1e:2f:
                    70:c5:6d:3a:41
                ASN1 OID: prime256v1
                NIST CURVE: P-256
        Attributes:
        Requested Extensions:
            X509v3 Subject Alternative Name: 
                DNS:portal.meddefense.local, DNS:www.portal.meddefense.local, DNS:meddefense.local
    Signature Algorithm: ecdsa-with-SHA256
Part 4 - The Full Lifecycle
1. CSR generated (done).

2. Submission to CA: Submit the .csr file to a commercial Certificate Authority (e.g., DigiCert or Sectigo). Let's Encrypt is avoided here because it only issues Domain Validated (DV) certificates, whereas MedDefense requires an Organization Validated (OV) certificate to assure patients of the legal entity's identity.

3. Validation process:
The commercial CA performs dual validation. First, they verify technical control over the domain (via a DNS TXT record or admin email). Second, they verify MedDefense's legal organizational identity by checking state business registries and calling the verified corporate phone number.

4. Certificate issuance:
Upon successful validation, the CA signs the public key contained in the CSR using their trusted intermediate private key. They send back the new Leaf Certificate (portal.crt) along with the Intermediate CA chain file.

5. Installation on the web server:
The IT team securely transfers portal_key.pem, portal.crt, and the intermediate chain to the web-srv-01 server. The Apache SSL configuration file (httpd-ssl.conf) is updated to point to these new file paths, and the Apache service is gracefully restarted to apply the changes.

6. Verification that the new certificate is serving correctly:
Run openssl s_client -connect portal.meddefense.local:443 -showcerts from an external machine to verify the web server is correctly presenting the new leaf certificate and the full intermediate chain. Browse to the portal to ensure no browser trust errors appear.

7. Decommission of the old certificate:
The old, expiring certificate and its associated private key are securely wiped from the web-srv-01 file system to prevent accidental reuse or future key compromise.

8. Monitoring for the next renewal:
The new certificate's expiration date (Not After) is entered into MedDefense's infrastructure monitoring system (e.g., Nagios or Zabbix). Automated alerts are configured to trigger 30, 15, and 7 days prior to expiration to prevent the current 18-day emergency scenario from repeating.
