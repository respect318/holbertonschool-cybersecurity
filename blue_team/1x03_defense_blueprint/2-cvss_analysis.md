# 2. The CVSS Deconstruction

## Exercise 1: Deconstruction

**Vector String:** `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`
**Vulnerability:** CVE-2021-44790

### Component Breakdown

* **AV:N (Attack Vector: Network)**
    * **Meaning:** The vulnerability is exploitable remotely over a network (e.g., the Internet).
    * **Other Values:** Adjacent (A), Local (L), Physical (P). Moving down this list (towards P) makes the attack harder, thus lowering the final CVSS score.
    * **Why Selected:** This is an Apache HTTP server vulnerability; an attacker can exploit it by sending a maliciously crafted URI over the network without needing physical or local system access.
* **AC:L (Attack Complexity: Low)**
    * **Meaning:** Exploiting the vulnerability does not require any special access conditions or extenuating circumstances. It is easily repeatable.
    * **Other Values:** High (H). Changing to High would lower the score because the attacker would need specific conditions (like a race condition) to succeed.
    * **Why Selected:** Sending a crafted request is a straightforward, reliable method of exploitation.
* **PR:N (Privileges Required: None)**
    * **Meaning:** The attacker does not need to be authenticated to the system or have any prior privileges.
    * **Other Values:** Low (L), High (H). Higher privilege requirements lower the CVSS score because the attack barrier is higher.
    * **Why Selected:** The Apache server handles public HTTP requests; thus, the attack occurs pre-authentication.
* **UI:N (User Interaction: None)**
    * **Meaning:** The vulnerability can be exploited without any action from a legitimate user.
    * **Other Values:** Required (R). If required, the score drops because the attacker must trick a user (e.g., clicking a link).
    * **Why Selected:** The exploit is triggered directly by the attacker's payload reaching the server.
* **S:U (Scope: Unchanged)**
    * **Meaning:** The exploited vulnerability can only affect resources managed by the same security authority. It does not escape to compromise a different environment (like an OS from a VM).
    * **Other Values:** Changed (C). If Changed, the score typically increases due to the wider blast radius.
    * **Why Selected:** The buffer overflow affects the Apache process itself, not an external sandboxed environment.
* **C:H (Confidentiality: High)**
    * **Meaning:** Total loss of data confidentiality. All information is accessible to the attacker.
    * **Other Values:** Low (L), None (N). Lowering this decreases the score.
    * **Why Selected:** Remote Code Execution (RCE) allows the attacker to read any file the Apache process can access.
* **I:H (Integrity: High)**
    * **Meaning:** Total loss of data integrity. The attacker can modify or delete any files.
    * **Other Values:** Low (L), None (N).
    * **Why Selected:** RCE allows complete manipulation of the system's files.
* **A:H (Availability: High)**
    * **Meaning:** Total loss of system availability. The system is completely shut down or rendered unusable.
    * **Other Values:** Low (L), None (N).
    * **Why Selected:** The attacker can crash the server or use it for resource-exhaustion, denying service to legitimate users.

### Attack Vector Change Modification
* **New Vector:** `CVSS:3.1/AV:L/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`
* **New Score:** 8.4 (High)
* **Explanation:** The score drops from 9.8 (Critical) to 8.4 (High). This happens because a "Local" attack vector means the attacker must already possess local access to the target system (e.g., via a shell or terminal) to execute the exploit. It is inherently much more difficult to achieve local presence than it is to send a malicious packet over the open Internet (Network).

---

## Exercise 2: Construction

**Scenario Characteristics:**
* Exploitable only from local network -> **AV:A** (Adjacent)
* Exploitation is complex -> **AC:H** (High)
* Attacker needs low-level privileges -> **PR:L** (Low)
* No user interaction needed -> **UI:N** (None)
* Scope unchanged -> **S:U** (Unchanged)
* Confidentiality completely compromised -> **C:H** (High)
* No impact on integrity -> **I:N** (None)
* No impact on availability -> **A:N** (None)

**Constructed Vector String:**
`CVSS:3.1/AV:A/AC:H/PR:L/UI:N/S:U/C:H/I:N/A:N`

**NIST Calculator Results:**
* **Base Score:** 4.8
* **Severity Rating:** Medium

---

## Exercise 3: Comparison

**Finding 1 (Score > 9.0): Remote Code Execution (RCE)**
* **Vector:** `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`
* **Score:** 9.8 (Critical)

**Finding 2 (Score 5.0 - 7.0): Reflected Cross-Site Scripting (XSS)**
* **Vector:** `CVSS:3.1/AV:N/AC:L/PR:N/UI:R/S:U/C:L/I:L/A:N`
* **Score:** 5.4 (Medium)

### Component Differences and Impact Analysis
When placing these vectors side-by-side, the specific components that explain the score difference are:

1.  **Impact Metrics (C, I, A):** Finding 1 results in a total system compromise (High Confidentiality, High Integrity, High Availability loss). Finding 2 only allows partial data disclosure and modification (Low Confidentiality, Low Integrity) and does not disrupt system operations (None Availability). 
2.  **User Interaction (UI):** Finding 1 requires no user interaction (UI:N). Finding 2 requires the victim to click a malicious link (UI:R), reducing the reliability and ease of the attack.

**Biggest Impact on Final Score:**
The **Impact sub-score metrics (Confidentiality, Integrity, Availability)** have the most significant mathematical weight on the final CVSS score. While exploitability metrics (like UI, AV, or PR) act as multipliers that adjust the likelihood of an attack, the actual "damage" dictated by the CIA triad forms the foundation of the base score. Going from total compromise (H/H/H) to partial compromise (L/L/N) is what drops the score from a 9.8 down to a 5.4.
