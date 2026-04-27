# 2. The CVSS Deconstruction

## Exercise 1: Deconstruction

**Vector String:** `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`
**Vulnerability:** CVE-2021-44790

### Component Breakdown

* **AV:N (Attack Vector = Network)**
    * **Meaning:** The vulnerability is exploitable remotely over a network (e.g., the Internet).
    * **Other Values:** Adjacent (A), Local (L), Physical (P). Moving down this list to a local or physical vector makes the attack harder, thus lowering the final CVSS score.
    * **Why Selected:** This is an Apache HTTP server vulnerability; an attacker can exploit it by sending a maliciously crafted request remotely without prior internal access.
* **AC:L (Attack Complexity = Low)**
    * **Meaning:** Exploiting the vulnerability does not require any special access conditions, race conditions, or extenuating circumstances.
    * **Other Values:** High (H). Changing to High would lower the score because the attacker would need specific and complex conditions to succeed.
    * **Why Selected:** Sending a crafted HTTP request is a highly repeatable and straightforward method of exploitation.
* **PR:N (Privileges Required = None)**
    * **Meaning:** The attacker does not need to be authenticated to the target system.
    * **Other Values:** Low (L), High (H). Higher privilege requirements lower the CVSS score because the barrier to entry is higher.
    * **Why Selected:** The attack targets the public-facing HTTP parsing process, which happens pre-authentication.
* **UI:N (User Interaction = None)**
    * **Meaning:** The exploit can be executed without any action from a legitimate user.
    * **Other Values:** Required (R). If required, the score drops because the attacker must trick a user into participating (e.g., clicking a link).
    * **Why Selected:** It is a server-side vulnerability triggered purely by the attacker's payload.
* **S:U (Scope = Unchanged)**
    * **Meaning:** The exploited vulnerability only affects resources managed by the vulnerable component itself.
    * **Other Values:** Changed (C). A Changed scope increases the score because the exploit cascades into a different security boundary.
    * **Why Selected:** The buffer overflow happens entirely within the Apache process environment.
* **C:H (Confidentiality = High)**
    * **Meaning:** Total loss of data confidentiality. All information is accessible to the attacker.
    * **Other Values:** Low (L), None (N).
    * **Why Selected:** Remote Code Execution (RCE) allows the attacker to read any file the Apache process has access to.
* **I:H (Integrity = High)**
    * **Meaning:** Total loss of data integrity. The attacker can modify or delete any files.
    * **Other Values:** Low (L), None (N).
    * **Why Selected:** RCE allows complete manipulation of the system.
* **A:H (Availability = High)**
    * **Meaning:** Total loss of system availability. The system is rendered unusable.
    * **Other Values:** Low (L), None (N).
    * **Why Selected:** The attacker can crash the server process or exhaust its resources entirely.

### Attack Vector Change Modification
* **New Vector:** `CVSS:3.1/AV:L/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`
* **New Score:** 8.4 (High)
* **Explanation:** Changing the Attack Vector from Network (N) to Local (L) drops the score from 9.8 (Critical) to 8.4 (High). A Local attack vector means the threat actor can no longer exploit the system directly over the open internet. They must first find another way to gain a local shell or terminal access to the operating system, which significantly reduces the likelihood and ease of the attack.

---

## Exercise 2: Construction

**Scenario Characteristics mapped to CVSS components:**
* Exploitable only from the local network -> **Attack Vector: AV:A (Adjacent)**
* Exploitation is complex -> **Attack Complexity: AC:H (High)**
* Attacker needs low-level privileges -> **Privileges Required: PR:L (Low)**
* No user interaction is needed -> **User Interaction: UI:N (None)**
* Scope unchanged -> **Scope: S:U (Unchanged)**
* Confidentiality completely compromised -> **Confidentiality: C:H (High)**
* No impact on integrity -> **Integrity: I:N (None)**
* No impact on availability -> **Availability: A:N (None)**

**Results from NIST Calculator:**
* **Vector String:** `CVSS:3.1/AV:A/AC:H/PR:L/UI:N/S:U/C:H/I:N/A:N`
* **Calculated Score:** 4.8
* **Severity Rating:** Medium

---

## Exercise 3: Comparison

**Selected Findings:**
* **Finding A (Score > 9.0):** Remote Code Execution (RCE)
  * Vector: `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`
  * Score: 9.8 (Critical)
* **Finding B (Score between 5.0 and 7.0):** Reflected Cross-Site Scripting (XSS)
  * Vector: `CVSS:3.1/AV:N/AC:L/PR:N/UI:R/S:U/C:L/I:L/A:N`
  * Score: 5.4 (Medium)

### Component Differences & Impact Analysis
When comparing these two vectors side-by-side, the specific components that explain the score difference are:

1. **Impact Metrics (C, I, A):** Finding A results in a total system compromise (High Confidentiality, High Integrity, High Availability loss). Finding B only allows partial data disclosure and modification (Low Confidentiality, Low Integrity) and does not disrupt system operations (None Availability). 
2. **User Interaction (UI):** Finding A requires no user interaction (UI:N). Finding B requires the victim to actively click a malicious link (UI:R), reducing the reliability of the attack.

**Which components have the biggest impact?**
The **Impact sub-score metrics (Confidentiality, Integrity, Availability)** have the most significant mathematical weight on the final CVSS score. While exploitability metrics (like UI) act as multipliers that adjust the likelihood of an attack, the actual "damage" dictated by the CIA triad forms the foundation of the base score. Dropping from total compromise (H/H/H) to partial compromise (L/L/N) is the primary reason the score drops drastically from a 9.8 down to a 5.4.
