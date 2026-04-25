# Root Cause Analysis: billing-srv-01 Performance Degradation

### 1. Identify the Process
The process named `./kworker` running under the `www-data` user is malicious. While legitimate Linux kernel threads are named `[kworker]` and run as root, this process is an executable hidden in `/var/www/html/.cache/`. The connection to `stratum+tcp://pool.monero.org:4443` reveals that it is using the Stratum mining protocol to connect to a Monero cryptocurrency mining pool. The sole purpose of this process is **cryptojacking (cryptocurrency mining)**, exploiting the server's CPU resources to generate profit for the attacker.

### 2. Classify the Real Compromise
While the visible symptom is performance degradation (an impact on **Availability**), the actual compromise occurred earlier, violating two other CIA pillars:
* **Confidentiality:** The attacker bypassed system access controls and gained unauthorized access to the server's internal environment, most likely by exploiting an unpatched vulnerability in the Apache web service (since the process runs as `www-data`).
* **Integrity:** The system's state was modified without authorization. The attacker created hidden directories (`.cache`), wrote malicious files (`kworker` and `config.json`), and executed unauthorized code on the server.

### 3. Explain Why the Sysadmin's Solution Fails
The sysadmin's recommendation to upgrade the server hardware (adding more RAM and vCPUs) will completely fail to solve the security problem. Adding more hardware only treats the symptom (CPU saturation) without addressing the root cause (malware infection and unpatched vulnerability). If the server is migrated to a more powerful VM, the crypto-miner will simply scale up its operations to consume the newly added CPU resources, and the server will remain compromised and vulnerable to further attacks.

### 4. Connect to the January Incident
The presence of both a ransomware payload in January and a crypto-miner now on the exact same server suggests a severe failure in MedDefense's Incident Response and Vulnerability Management processes. It indicates that when the server was rebuilt after the ransomware attack, the original entry point (the unpatched Apache vulnerability) was ignored and left open, allowing a second attacker to easily compromise the rebuilt server. 

The critical question we must ask is: **"Why are compromised servers being rebuilt and redeployed using the exact same vulnerable configurations without identifying and patching the initial attack vector?"**
