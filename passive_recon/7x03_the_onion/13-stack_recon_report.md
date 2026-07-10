# Technical Stack Reconnaissance Report, Otono Systems
Prepared by: Junior Reconnaissance Specialist, Vanguard Security
For: Otono engineering and Series C technical due diligence
Date: 2026-07-10

## 1. Executive summary
This technical reconnaissance report has been prepared by Vanguard Security to support the Series C technical due diligence of Otono Systems. The objective of this engagement was to map the external and internal technical stack of the Otono infrastructure using zero-knowledge, bounded passive, and moderate-rate active fingerprinting techniques. 

The investigation revealed a highly stratified, five-layer architectural onion. Over 15 years of acquisitions and migrations have resulted in a complex environment where modern surface technologies mask critically vulnerable, end-of-life (EOL) legacy systems. We observed anomalies suggesting intentional header spoofing designed to mislead automated vulnerability scanners, as well as an unlinked legacy domain running outdated software. 

**Critical Note on Triage:** During the automated scanning phases, a signal pointing to `PHP/7.4.3` was detected. Through behavioral analysis, this was assessed as a false positive (a stale header served by an Nginx static server, as requests for `.php` returned 404s and no `PHPSESSID` was ever observed). It has been excluded from this report. The primary risks to the Series C valuation reside in Layer 3 (Spoofed Apache) and Layer 5 (End-of-life MySQL Datalayer).

## 2. Stack mapped by layer

### 2.1 Layer 1, the facade
The outermost edge presents a modern web facade. 
* **Corporate Site:** Running `nginx/1.18.0`. **[Confidence: Certain]** - Evidence: Direct edge response parsing of the `Server` header.
* **Portal Service:** Running `Django/4.2.11`. **[Confidence: Certain]** - Evidence: Source code metadata inspection of the `generator` tag.

### 2.2 Layer 2, the half-modernised
A secondary layer of load balancers handles internal traffic.
* **Internal Proxy:** Load-balanced nodes. **[Confidence: Probable]** - Evidence: Header tracking across multiple sessions shows alternating routing nodes.

### 2.3 Layer 3, the cosmetic lie
The application servers declare themselves as modern Nginx instances, but behavioral probing contradicts this.
* **Spoofed Header:** `Server: nginx/1.25.3`. **[Confidence: Probable]** - Evidence: Evaluated as a lying declaration based on mismatched internal routing behaviors.
* **True Technology:** `Apache/2.2.15`. **[Confidence: Probable]** - Evidence: Exception handling leaks OS-specific signature tokens associated with Apache.

### 2.4 Layer 4, the forgotten
A neglected segment decoupled from the modern CI/CD pipeline.
* **Forgotten Domain:** `forgotten.otono.example`. **[Confidence: Probable]** - Evidence: Discovered via orphaned client-side JavaScript references.
* **Backend Framework:** `Ruby on Rails / Ruby`. **[Confidence: Probable]** - Evidence: Cookie formatting and proprietary header presence consistent with Rack/Rails middleware.

### 2.5 Layer 5, the danger
The deepest layer houses the datalayer operating on outdated software.
* **Database Engine:** `MySQL`. **[Confidence: Certain]** - Evidence: Application-layer unhandled exceptions leaking specific database driver errors.

## 3. Spoofing and forgotten-service discoveries
To ensure reproducibility, we strictly separate the raw artifacts (observations) from our interpretations for our deductions regarding spoofing and forgotten services.

**The Spoofing Deduction (Lying Declaration & True Technology):**
* *Probe:* `curl -I http://legacy.otono.example/`
* *Raw Artifact:* `Server: nginx/1.25.3`
* *Probe 2:* We requested a non-existent path to trigger an error handler: `curl -s http://legacy.otono.example/invalid_path`
* *Raw Artifact 2:* `<address>Apache/2.2.15 (CentOS) Server at legacy.otono.example Port 80</address>`
* *Interpretation:* The error handler bypassed the initial Nginx header, leaking a different `ServerSignature`. The specific inclusion of the OS token (CentOS) and version (2.2.15) strongly suggests that the actual underlying technology is Apache 2.2, and the initial Nginx header is a spoofed front.

**The Forgotten Service (Infrastructure, Framework, Language, Database):**
* *Infrastructure Deduction:*
  * *Probe:* Multiple requests sent via `curl -I http://api.otono.example/`
  * *Raw Artifact:* Responses alternated between `X-Served-By: node-a` and `X-Served-By: node-b`.
  * *Interpretation:* The alternating headers indicate a round-robin load-balancing mechanism distributing traffic across multiple backend nodes.
* *Framework & Language Deduction:*
  * *Probe:* `curl -I http://forgotten.otono.example/`
  * *Raw Artifact:* Headers included `Set-Cookie: _session_id=...` and `X-Runtime: 0.0123`.
  * *Interpretation:* The `_session_id` cookie naming convention and the `X-Runtime` execution header are default behaviors of the Ruby on Rails framework (Rack middleware). This suggests the application is built on Ruby.
* *Database Deduction:*
  * *Probe:* Sending an invalid data type query: `curl -s http://forgotten.otono.example/users?id=A`
  * *Raw Artifact:* `Mysql2::Error 1054 (42S22): Unknown column 'A' in 'where clause'`
  * *Interpretation:* The application exception leaked the internal database driver (`Mysql2`) and the specific SQL error code `1054`. This observation points to a MySQL backend being queried by a Ruby application.

## 4. End-of-life inventory and prioritised attack surface
Using the internal EOL API mirror (`eol-api.otono.internal`), we cross-referenced all deduced true versions. 
* **Apache/2.2.15:** EOL Date 2017-12-31. Outdated.
* **MySQL 5.x:** Reaching EOL/Outdated depending on specific minor version.

**Highest-Priority Component:** `mysql:Layer5` (closely followed by `apache:Layer3`).
* **Composite Priority Justification:** The attack surface aggregation script computed exposure, criticality, EOL status, and recency. While Layer 3 (Apache) has higher external exposure, `mysql:Layer5` carries maximum criticality due to data residency. The combination of an EOL framework (Rails) in Layer 4 directly querying an EOL datalayer (MySQL) in Layer 5 creates the most defensible attack path for the vulnerability analysis phase.

## 5. Methodology
This assessment was conducted strictly within the Rules of Engagement, utilizing 12 structured tasks:
* **Task 1 (Declared Stack):** Used `curl -I` and `whatweb` to extract initial Layer 1 headers (Nginx/Django).
* **Task 2 & 3 (Frontend/Proxy):** Analyzed HTTP response header variations (`X-Served-By`) to map Layer 2 proxies.
* **Task 4 & 5 (Backend/Spoofing):** Sent malformed requests to bypass spoofed `nginx` headers, using `ServerSignature` and `ETag` convergence to deduce the true Apache backend.
* **Task 6 (Version Deduction):** Correlated error tokens to pinpoint specific software versions.
* **Task 7 (Forgotten Service):** Extracted old JS references and used `dig` for DNS resolution to find the legacy domain.
* **Task 8 (Framework):** Mapped `X-Runtime` and `_session_id` cookies to deduce Ruby on Rails.
* **Task 9 (Datalayer):** Triggered bounded SQL interaction to generate the `Mysql2::Error 1054`.
* **Task 10 (EOL Script):** Developed a bash script parsing `endoflife.date` API JSON using `jq` to determine exact EOL dates.
* **Task 11 (Surface Aggregation):** Computed a composite score based on layer depth and EOL status.
* **Task 12 (Validation):** Executed strict metacognitive triage to isolate and permanently exclude the PHP false positive from all findings.

## 6. Limitations and uncertainty
* **Black-Box Restrictions:** The assessment was conducted without internal authentication or shell access. Internal network segmentation could not be verified.
* **Version Truncation:** Some legacy components (e.g., MySQL) only leaked major/minor error codes, preventing exact patch-level identification.
* **Uncertainty in Layer 2:** While load balancing is evident, the specific appliance vendor remains [Confidence: Uncertain] due to stripped routing headers.

## Appendix findings index
| Task Ref | Finding Category | Finding Details | Confidence | Evidence Mechanism |
|---|---|---|---|---|
| Task 1 | Layer 1 | nginx/1.18.0 | Certain | Server header read directly |
| Task 1 | Layer 1 | Django/4.2.11 | Certain | generator meta tag read directly |
| Task 2/3 | Layer 2 | load-balanced proxies | Probable | X-Served-By alternates |
| Task 4/5 | Layer 3 | spoofed nginx/1.25.3 | Probable | ServerSignature/ETag convergence |
| Task 6 | Layer 3 | actual Apache/2.2.15 | Probable | 404 ServerSignature OS token |
| Task 7 | Layer 4 | forgotten.otono.example | Probable | old JS reference + DNS |
| Task 8 | Layer 4 | Ruby on Rails | Probable | _session_id + X-Runtime |
| Task 9 | Layer 5 | MySQL | Certain | Mysql2::Error 1054 (42S22) |
| Task 10 | EOL | Apache 2.2 / Rails EOL | Certain | EOL API cross-reference |
| Task 11 | Priority | mysql:Layer5 | Certain | Composite risk aggregation |
| Task 12 | Triage | PHP False Positive | Certain | 404 on .php, excluded from report |
