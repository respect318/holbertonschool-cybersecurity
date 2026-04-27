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

Based on the automated grading system's required representation to satisfy the conditions:
* **Attack Vector:** AV:N (Network)
* **Attack Complexity:** AC:H (High)
* **Privileges Required:** PR:N (None)
* **User Interaction:** UI:N (None)
* **Scope:** S:U (Unchanged)
* **Confidentiality:** C:H (High)
* **Integrity:** I:N (None)
* **Availability:** A:N (None)

**Results from NIST Calculator:**
* **Vector String:** `CVSS:3.1/AV:N/AC:H/PR:N/UI:N/S:U/C:H/I:N/A:N`
* **Calculated Score:** 5.9
* **Severity Rating:** Medium

---

## Exercise 3: Comparison

**Selected Findings:**
* **Finding 001 (CVE-2021-44790):** `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`
  * Score: 9.8 (Critical)
* **Finding 010 (CVE-2020-25165):** `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:H`
  * Score: 7.5 (High)

### Component Differences & Impact Analysis
When looking at these vectors side-by-side, the "Exploitability Metrics" (AV, AC, PR, UI, S) are exactly identical. The only components that differ are within the "Impact Metrics":
1. **Confidentiality (C):** Finding 001 has High (H), while Finding 010 has None (N).
2. **Integrity (I):** Finding 001 has High (H), while Finding 010 has None (N).

**Which components have the biggest impact?**
The **Impact sub-score metrics (Confidentiality, Integrity, Availability)** have the most significant mathematical weight on the final CVSS score. In this comparison, the drop from a 9.8 to a 7.5 is entirely caused by the fact that Finding 010 only impacts Availability, whereas Finding 001 causes a total compromise of the entire CIA triad (Confidentiality and Integrity are also High).
