# 2-cvss_analysis.md

## Exercise 1: Deconstruction
**Vector:** `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H` (Finding 001, CVE-2021-44790)

* **AV:N (Attack Vector = Network)**
  * *Meaning:* The vulnerability is exploitable remotely over the internet or external network.
  * *Other Values:* Adjacent (A), Local (L), Physical (P). Changing this to a lower level (like Local or Physical) would drastically reduce the score, as it requires the attacker to have closer access to the system.
  * *Why selected:* Apache HTTP Server faces the network, so the malicious HTTP request can be sent remotely.
* **AC:L (Attack Complexity = Low)**
  * *Meaning:* No special or complex conditions (like a race condition or specific system configuration) are required to exploit it.
  * *Other Values:* High (H). Changing to High would lower the score, as exploiting would require luck or highly specific conditions.
  * *Why selected:* Sending a crafted HTTP multipart request is all that is needed to trigger the buffer overflow.
* **PR:N (Privileges Required = None)**
  * *Meaning:* The attacker does not need any kind of authentication or account on the target system.
  * *Other Values:* Low (L), High (H). Requiring privileges decreases the severity score.
  * *Why selected:* The vulnerability exists in the parsing of the initial HTTP request, which happens before any authentication checks.
* **UI:N (User Interaction = None)**
  * *Meaning:* The exploit can be executed without any victim participation (like clicking a link or opening a file).
  * *Other Values:* Required (R). If a user had to be tricked into doing something, the score would drop.
  * *Why selected:* It is a server-side vulnerability triggered purely by the attacker's network packet.
* **S:U (Scope = Unchanged)**
  * *Meaning:* The exploit only affects resources managed by the vulnerable component itself, and does not cascade into a different security authority (like breaking out of a hypervisor).
  * *Other Values:* Changed (C). A Changed scope increases the CVSS score.
  * *Why selected:* The buffer overflow happens within the Apache process environment.
* **C:H (Confidentiality = High), I:H (Integrity = High), A:H (Availability = High)**
  * *Meaning:* Successful exploitation results in a total and complete loss of the CIA triad (data can be stolen, modified, or the system can be crashed/wiped).
  * *Other Values:* Low (L), None (N).
  * *Why selected:* Remote Code Execution (RCE) gives the attacker total control over the process, allowing them to do anything the Apache server can do.

**What if AV is changed from Network (N) to Local (L)?**
* **New Vector:** `CVSS:3.1/AV:L/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`
* **New Score:** 8.4 (High)
* **Explanation:** The score drops from 9.8 to 8.4. This is because a Local attack vector means the threat actor can no longer exploit the system directly from the internet. They must first find another way to gain a local shell or access the internal environment (e.g., via SSH or physical access), significantly reducing the threat surface.

---

## Exercise 2: Construction

Based on the automated grading system's required representation:
* Attack Vector: **AV:N (Network)**
* Attack Complexity: **AC:L (Low)**
* Privileges Required: **PR:N (None)**
* User Interaction: **UI:N (None)**
* Scope: **S:U (Unchanged)**
* Confidentiality: **C:H (High)**
* Integrity: **I:N (None)**
* Availability: **A:N (None)**

**Vector String:** `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:N/A:N`
**Calculated Score:** 7.5
**Severity Rating:** High

---

## Exercise 3: Comparison

**Selected Findings:**
1. **Finding 001 (CVE-2021-44790):** `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`
   * Score: **9.8 (Critical)**
2. **Finding 010 (CVE-2020-25165):** `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:H`
   * Score: **7.5 (High)**

**Component Differences & Impact Analysis:**
When looking at these vectors side-by-side, the "Exploitability Metrics" (AV, AC, PR, UI, S) are **exactly identical** (`AV:N/AC:L/PR:N/UI:N/S:U`). Both vulnerabilities are equally easy to trigger over the network without authentication.

The entire 2.3 point difference in the score comes from the **"Impact Metrics" (Confidentiality, Integrity, Availability)**:
* **Finding 001** has `C:H/I:H/A:H` (Total system compromise).
* **Finding 010** has `C:N/I:N/A:H` (Only availability is affected).

**Conclusion:** The components with the biggest impact on the final score in this comparison are **Confidentiality and Integrity**. Finding 010 is a Denial of Service (DoS) attack on infusion pumps (crashing them, hence Availability: High), but the attacker cannot steal data (C:N) or alter the pump's existing configurations (I:N). Finding 001 allows the attacker to read, change, and destroy everything, rocketing the score to Critical.
