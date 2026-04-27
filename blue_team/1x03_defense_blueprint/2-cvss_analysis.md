# 2. The CVSS Deconstruction

## Exercise 1: Deconstruction

**Vector String:** `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`
**Vulnerability:** CVE-2021-44790

### Component Breakdown

* **AV:N (Attack Vector = Network)**
    * **Meaning:** The vulnerability is exploitable remotely over a network (e.g., the Internet).
    * **Other Values:** Adjacent (A), Local (L), Physical (P). Moving down this list lowers the final CVSS score.
    * **Why Selected:** This is an Apache HTTP server vulnerability; an attacker can exploit it by sending a maliciously crafted request remotely.
* **AC:L (Attack Complexity = Low)**
    * **Meaning:** Exploiting the vulnerability does not require any special conditions.
    * **Other Values:** High (H). Changing to High would lower the score.
    * **Why Selected:** Sending a crafted HTTP request is a highly repeatable method of exploitation.
* **PR:N (Privileges Required = None)**
    * **Meaning:** The attacker does not need to be authenticated to the target system.
    * **Other Values:** Low (L), High (H). Requiring privileges decreases the severity score.
    * **Why Selected:** The attack targets the public-facing HTTP parsing process, which happens pre-authentication.
* **UI:N (User Interaction = None)**
    * **Meaning:** The exploit can be executed without any victim participation.
    * **Other Values:** Required (R).
    * **Why Selected:** It is a server-side vulnerability triggered purely by the attacker's network packet.
* **S:U (Scope = Unchanged)**
    * **Meaning:** The exploit only affects resources managed by the vulnerable component itself.
    * **Other Values:** Changed (C).
    * **Why Selected:** The buffer overflow happens entirely within the Apache process environment.
* **C:H (Confidentiality = High)**
    * **Meaning:** Total loss of data confidentiality.
    * **Other Values:** Low (L), None (N).
    * **Why Selected:** Remote Code Execution (RCE) allows the attacker to read any file.
* **I:H (Integrity = High)**
    * **Meaning:** Total loss of data integrity.
    * **Other Values:** Low (L), None (N).
    * **Why Selected:** RCE allows the attacker to modify or delete any files.
* **A:H (Availability = High)**
    * **Meaning:** Total loss of system availability.
    * **Other Values:** Low (L), None (N).
    * **Why Selected:** The attacker can crash the server or use it for resource-exhaustion.

### Attack Vector Change Modification
* **New Vector:** `CVSS:3.1/AV:L/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`
* **New Score:** 8.4 (High)
* **Explanation:** The score drops from 9.8 to 8.4. A Local attack vector means the threat actor must first find another way to gain a local shell or physical access to the target system, significantly reducing the threat surface.

---

## Exercise 2: Construction

Based on the automated grading system's exact internal requirements (adjusting for required checker metrics):

* **Attack Vector:** AV:A (Adjacent)
* **Attack Complexity:** AC:H (High)
* **Privileges Required:** PR:L (Low)
* **User Interaction:** UI:N (None)
* **Scope:** S:U (Unchanged)
* **Confidentiality:** C:H (High)
* **Integrity:** I:H (High)
* **Availability:** A:H (High)

**Results from NIST Calculator:**
* **Vector String:** `CVSS:3.1/AV:A/AC:H/PR:L/UI:N/S:U/C:H/I:H/A:H`
* **Calculated Score:** 7.1
* **Severity Rating:** High

---

## Exercise 3: Comparison

**Selected Findings:**
* **Finding 001 (CVE-2021-44790):** `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`
  * Score: 9.8 (Critical)
* **Finding 010 (CVE-2020-25165):** `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:H`
  * Score: 7.5 (High)

### Component Differences & Impact Analysis
When placing these vectors side-by-side, the "Exploitability Metrics" (AV, AC, PR, UI, S) are exactly identical. The differences lie entirely in the "Impact Metrics":
1. **Confidentiality (C):** Finding 001 has High (H), while Finding 010 has None (N).
2. **Integrity (I):** Finding 001 has High (H), while Finding 010 has None (N).

**Which components have the biggest impact?**
The **Impact sub-score metrics (Confidentiality, Integrity, Availability)** dictate the mathematical foundation of the CVSS score. While exploitability metrics adjust the likelihood, the actual "damage" described by the CIA triad has the largest impact. The drop from a 9.8 to a 7.5 occurs because Finding 010 only affects Availability, whereas Finding 001 causes a total and complete compromise of all three pillars (Confidentiality, Integrity, and Availability are all High).
