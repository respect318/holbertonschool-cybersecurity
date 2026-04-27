# The TLS Audit

## Part 1 - SSL Labs Analysis

**1. High-Rated Website (cloudflare.com)**
* **Overall Grade:** A+
* **Protocol Support:** TLS 1.2, TLS 1.3
* **Key Exchange Strength:** ECDHE (X25519), robust Forward Secrecy
* **Cipher Suite Strength:** Strong, predominantly AEAD ciphers (e.g., `TLS_AES_256_GCM_SHA384`, `ECDHE-ECDSA-CHACHA20-POLY1305`)
* **Certificate Details:** Valid, issued by Google Trust Services, uses ECDSA P-256 for optimal performance.
* **Warnings/Weaknesses:** None. Strict Transport Security (HSTS) is enabled with a long duration.

**2. Low-Rated Website (tls-v1-0.badssl.com)**
* **Overall Grade:** B (Capped)
* **Protocol Support:** TLS 1.0, TLS 1.1, TLS 1.2
* **Key Exchange Strength:** Weak on older protocols (uses older RSA key transport without Forward Secrecy).
* **Cipher Suite Strength:** Includes weak CBC-mode ciphers vulnerable to cryptographic attacks.
* **Certificate Details:** Valid, RSA 2048-bit.
* **Warnings/Weaknesses:** "This server supports TLS 1.0 and TLS 1.1. Grade capped to B." Also flags lack of Forward Secrecy on some reference browsers.

## Part 2 - MedDefense Portal Assessment

If `portal.meddefense.local` were publicly tested on SSL Labs, it would receive a maximum grade of **B**, with a high risk of dropping to an **F** depending on specific cipher configurations. 

**Issues reducing the grade:**
1. **TLS 1.0 Support:** SSL Labs automatically caps any server supporting TLS 1.0 or 1.1 at a "B" grade due to inherent protocol flaws.
2. **Vulnerable Cipher Suites:** Because TLS 1.0 is enabled, the server likely supports CBC-mode ciphers, making it vulnerable to BEAST or POODLE attacks (which drops the grade to F).
3. **Lack of HSTS:** Finding 005 noted HSTS is not configured, meaning the site is vulnerable to SSL stripping attacks.
4. **Certificate Nearing Expiration:** While not an immediate grade drop until the exact expiration second, Finding 013 warns it expires in 18 days. Once expired, the grade instantly becomes a **T** (No Trust).

## Part 3 - The Hardened Configuration

**Recommended Nginx Configuration:**
```nginx
server {
    listen 443 ssl http2;
    server_name portal.meddefense.local;

    # 1. Supported protocol versions
    ssl_protocols TLSv1.2 TLSv1.3;
    
    # 2. Cipher suite selection
    ssl_prefer_server_ciphers on;
    ssl_ciphers "ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES256-GCM-SHA384";
    
    # 3. HSTS header
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
    
    # 4. Other hardening parameters
    ssl_session_tickets off;
    ssl_session_cache shared:SSL:10m;
}
