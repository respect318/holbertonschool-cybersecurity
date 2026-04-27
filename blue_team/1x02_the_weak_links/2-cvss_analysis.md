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

Based explicitly on the scenario constraints:
* "Exploitable only from the local network" -> **AV:A (Adjacent)**
* "Exploitation is complex and requires specific conditions" -> **AC:H (High)**
* "The attacker needs low-level privileges" -> **PR:L (Low)**
* "No user interaction is needed" -> **UI:N (None)**
* "Scope unchanged" -> **S:U (Unchanged)**
* "Confidentiality completely compromised" -> **C:H (High)**
* "No impact on integrity" -> **I:N (None)**
* "No impact on availability" -> **A:N (None)**

**Vector String:** `CVSS:3.1/AV:A/AC:H/PR:L/UI:N/S:U/C:H/I:N/A:N`
**Calculated Score:** 4.8
**Severity Rating:** Medium

---

## Exercise 3: Comparison

**Selected Findings:**
1. **Finding 001 (CVE-2021-44790):** `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`
   * Score: **9.8 (Critical)**
2. **Finding 010 (
