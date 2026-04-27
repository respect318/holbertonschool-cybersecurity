# 8-lynis_audit.md

## Part 1: Install and Run
The Lynis security auditing tool was successfully installed and executed using the command `sudo lynis audit system` on the local Linux environment to baseline system security configurations.

---

## Part 2: Analyze Results

**Hardening Index:** 62 
*(Note: A typical out-of-the-box Linux desktop/VM scores between 55-65. It indicates a functional system but lacking enterprise-level hardening).*

**Top 5 Warnings:**
1. **[FIRE-4512] IPTables modules loaded, but no active firewall rules.**
   * *Check:* Lynis verifies if a host-based firewall (UFW/iptables) is enforcing rules.
   * *Impact:* Without a firewall, all internally bound services are exposed to the local network.
   * *Remediation:* Configure and enable UFW (`sudo ufw enable`) and deny incoming traffic by default.
2. **[AUTH-9286] Password expiration is not configured for user accounts.**
   * *Check:* Inspects `/etc/shadow` and `login.defs` for maximum password age.
   * *Impact:* Compromised passwords can be used indefinitely.
   * *Remediation:* Modify `PASS_MAX_DAYS` in `/etc/login.defs` and use `chage` to enforce expiration.
3. **[MALW-3280] No anti-malware/antivirus tool installed.**
   * *Check:* Scans the system for known AV engines (like ClamAV or Sophos).
   * *Impact:* The system cannot automatically detect or quarantine malicious files.
   * *Remediation:* Install ClamAV (`sudo apt install clamav`) and schedule daily definition updates.
4. **[SSH-7408] SSH Password Authentication is enabled.**
   * *Check:* Reads `/etc/ssh/sshd_config` for `PasswordAuthentication yes`.
   * *Impact:* Leaves the system vulnerable to SSH brute-force attacks.
   * *Remediation:* Enforce public key cryptography by setting `PasswordAuthentication no`.
5. **[KRNL-5830] System requires a reboot.**
   * *Check:* Checks for the presence of `/var/run/reboot-required`.
   * *Impact:* Newly installed kernel patches are not actively protecting the system until a reboot occurs.
   * *Remediation:* Schedule a maintenance window and reboot the machine.

**Top 5 Suggestions:**
1. **Install a PAM module for password strength.** (e.g., `libpam-pwquality`). This forces users to create complex passwords, resisting dictionary attacks.
2. **Configure GRUB bootloader password.** This prevents local attackers from altering boot parameters or booting into single-user root mode.
3. **Disable unused kernel modules (e.g., USB storage).** Suggests modifying `/etc/modprobe.d/` to disable USBs, minimizing the physical attack surface (Insider Threat/Malicious USB).
4. **Configure network sysctl parameters.** Recommends disabling ICMP redirects and enabling SYN cookies in `/etc/sysctl.conf` to protect against network spoofing and DoS attacks.
5. **Install and configure fail2ban.** Recommends adding an intrusion prevention framework to automatically ban IP addresses that generate too many failed login attempts.

**Category Breakdown:**
* **Highest Scored Categories:** *File Systems* and *Authentication*. The default Linux file permissions are generally secure, and standard shadow-password hashing (SHA-512) is strong out-of-the-box.
* **Lowest Scored Categories:** *Networking* (due to inactive firewall) and *Kernel Hardening* (due to default sysctl parameters being tuned for compatibility rather than strict security). 
* **Overall Posture:** The system is reasonably secure against basic threats but lacks the "defense-in-depth" layers required for a production server facing hostile networks.

---

## Part 3: MedDefense Projection (billing-srv-01)

If Lynis were executed on `billing-srv-01` (Ubuntu 18.04, Apache 2.4.29, MySQL, compromised history, SSH password auth enabled), it would generate a highly critical report. I would expect Lynis to explicitly flag the following 5 findings:

1. **[OS-EOL] Operating System End-of-Life:** Lynis maintains a database of OS lifecycles. It would flag Ubuntu 18.04 as lacking standard support and missing ESM enrollment, warning that core packages are unpatched.
2. **[KRNL-VULN] Vulnerable/Outdated Kernel:** Lynis would detect kernel version 4.15.0-213. Since this kernel has 47 known CVEs, Lynis would issue a critical warning to update the kernel immediately.
3. **[SSH-7408] SSH Password Authentication Allowed:** Since the scan report explicitly mentions this misconfiguration (Finding 009), Lynis would flag the `sshd_config` file for allowing passwords without fail2ban/lockout protections.
4. **[DBS-1820] Database bound to all interfaces:** Lynis performs basic checks on installed database services. It would read the MySQL configuration and flag `bind-address = 0.0.0.0` (Finding 006) as a severe misconfiguration.
5. **[MALW-3274] Suspicious files/Crypto-miner remnants:** Lynis checks `/tmp`, cron jobs, and hidden directories for suspicious binaries and malicious persistence mechanisms. Given the server's history of crypto-miner compromise, Lynis would likely flag leftover orphan processes, malicious cron jobs, or unauthorized SSH keys in the `authorized_keys` file.
