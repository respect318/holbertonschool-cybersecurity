# Technical Stack Reconnaissance Report, Otono Systems
Prepared by: Junior Reconnaissance Specialist, Vanguard Security
For: Otono engineering and Series C technical due diligence
Date: 2026-07-10

## 1. Executive summary
This technical reconnaissance report has been prepared by Vanguard Security to support the Series C technical due diligence of Otono Systems. The objective of this engagement was to map the external and internal technical stack of the Otono infrastructure using zero-knowledge, bounded passive, and moderate-rate active fingerprinting techniques. 

The investigation revealed a highly stratified, five-layer architectural onion. Over 15 years of acquisitions and migrations have resulted in a complex environment where modern surface technologies mask critically vulnerable, end-of-life (EOL) legacy systems. Notably, we discovered intentional header spoofing designed to mislead automated vulnerability scanners, as well as a completely forgotten legacy domain running heavily outdated software. 

**Critical Note on Triage:** During the automated scanning phases, a signal pointing to `PHP/7.4.3` was detected. Through rigorous behavioral analysis, this was definitively classified as a **false positive** (a stale header served by an Nginx static server with no actual PHP backend processing). It has been completely excluded from this report and our risk modeling. The primary threats to the Series C valuation reside in Layer 3 (Cosmetic Lie / Spoofed Apache) and Layer 5 (End-of-life MySQL Datalayer).

## 2. Stack mapped by layer

### 2.1 Layer 1, the facade
The outermost edge of the Otono infrastructure presents a modern, standard web facade. 
* **Corporate Site:** Running `nginx/1.18.0`. **[Confidence: Certain]** - Evidence: The `Server` header was read directly from the edge response.
* **Portal Service:** Running `Django/4.2.11`. **[Confidence: Certain]** - Evidence: The `generator` meta tag was read directly from the HTML source.
These components act as the entry point, handling initial TLS termination and routing.

### 2.2 Layer 2, the half-modernised
Behind the immediate facade lies a secondary layer of load balancers and reverse proxies handling internal traffic distribution.
* **Internal Proxy:** Load-balanced nodes. **[Confidence: Probable]** - Evidence: The `X-Served-By` headers alternate consistently between `node-a` and `node-b` upon repeated requests, indicating an active round-robin or least-connections balancing mechanism.

### 2.3 Layer 3, the cosmetic lie
This layer exposes intentional deception by the original engineering team. The application servers explicitly declare themselves as modern Nginx instances, but behavioral probing reveals otherwise.
* **Spoofed Header:** `Server: nginx/1.25.3`. **[Confidence: Probable]** - Evidence: This header is a deliberate lie. 
* **True Technology:** `Apache/2.2.15`. **[Confidence: Probable]** - Evidence: Forcing a 404 error returned a default `ServerSignature` containing specific OS tokens unique to Apache 2.2.x, combined with ETag format anomalies and DOCTYPE structures that converge exclusively on Apache architectures.

### 2.4 Layer 4, the forgotten
Our reconnaissance discovered a heavily neglected segment of the infrastructure, completely decoupled from the modern CI/CD pipeline.
* **Forgotten Domain:** `forgotten.otono.example`. **[Confidence: Probable]** - Evidence: Discovered via old JavaScript references pointing to legacy API endpoints, subsequently validated via active DNS resolution and live HTTP responses.
* **Backend Framework:** `Ruby on Rails / Ruby`. **[Confidence: Probable]** - Evidence: Behavioral signals including `_session_id` cookie formatting, `X-Runtime` header presence, and the specific stack trace format of a triggered Routing Error strongly converge on a legacy Rails environment.

### 2.5 Layer 5, the danger
The deepest layer of the architecture houses the datalayer, operating on critically outdated software.
* **Database Engine:** `MySQL`. **[Confidence: Certain]** - Evidence: Induced application errors returned the highly specific `Mysql2::Error 1054 (42S22)` exception, exclusively confirming the presence of a MySQL database engine processing backend queries.

## 3. Spoofing and forgotten-service discoveries
The most significant architectural debt discovered during this engagement involves the Layer 3 spoofing and the Layer 4 forgotten service. 

**The Spoofing Deduction:** The `nginx/1.25.3` header was immediately flagged as anomalous when compared against the underlying HTTP response structures. To deduce the true technology, we triggered a 404 Not Found exception. The resulting error page bypassed the spoofed header and leaked the true `ServerSignature`, revealing `Apache/2.2.15`. This indicates an attempt at "security by obscurity" rather than genuine system hardening.

**The Forgotten Service:** Content discovery tools identified a stale JavaScript file on the main portal referencing `forgotten.otono.example`. Resolving this subdomain revealed a live server. Further interaction with its routing endpoints leaked a `Ruby on Rails` default error template. This service represents a severe shadow IT risk, as it is likely unmonitored by current SecOps teams.

## 4. End-of-life inventory and prioritised attack surface
Using the internal EOL API mirror (`eol-api.otono.internal`), we cross-referenced all deduced true versions. 
* **Apache/2.2.15:** EOL Date 2017-12-31. Dangerously outdated.
* **MySQL 5.x:** Reaching EOL/Outdated depending on specific minor version (Error 1054 indicates old architecture).

**Highest-Priority Component:** `mysql:Layer5` (closely followed by `apache:Layer3`).
* **Composite Priority Justification:** The attack surface aggregation script computed exposure, criticality, EOL status, and recency. While Layer 3 (Apache) has higher external exposure, `mysql:Layer5` carries maximum criticality due to data residency. The combination of an EOL framework (Rails) in Layer 4 directly querying an EOL datalayer (MySQL) in Layer 5 creates the most defensible and critical attack path for the vulnerability analysis phase.

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
* **Black-Box Restrictions:** The assessment was conducted without internal authentication or shell access. Internal network segmentation, lateral movement controls, and outbound egress filtering could not be verified.
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
