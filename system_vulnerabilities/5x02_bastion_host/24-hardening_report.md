1. Executive Summary
This report documents the security hardening of the Bastion-01 host. The objective was to minimize the attack surface and prevent unauthorized access or privilege escalation before exposing the host to external traffic. By applying CIS-based kernel parameters, filesystem restrictions, and service minimization, the system's security posture has been significantly improved.

2. Baseline Assessment
Prior to hardening, an initial audit was performed using Lynis.

Initial Hardening Index: 62

Initial Warnings: 18

Initial Suggestions: 45

Key Vulnerabilities Found: Open ICMP redirects, world-writable /tmp with execution allowed, unnecessary services (Bluetooth/Cups), and direct root login capability.

3. Hardening Measures Applied
A. Network & Kernel Hardening (Tasks 2-8)
IP Forwarding: Disabled for both IPv4 and IPv6 to prevent the host from acting as a router.

ICMP Protection: Disabled redirects and ignored broadcast pings to prevent Smurf attacks and Man-in-the-Middle redirection.

SYN Cookies: Enabled to mitigate TCP SYN Flood (DoS) attacks.

RP Filter: Enabled Strict Reverse Path filtering to prevent IP spoofing.

B. Filesystem Hardening (Tasks 17-19)
Temporary Directories: /tmp, /var/tmp, and /dev/shm were hardened with noexec, nosuid, and nodev mount options.

Result: Malware dropped in these directories cannot be executed, and SUID bits are ignored.

C. Account & Service Minimization (Tasks 9-11, 20-21)
Root Lockdown: The root account password was locked to enforce the use of sudo for accountability.

Compiler Removal: gcc, g++, and make were purged to prevent on-device exploit compilation.

Service Removal: Non-server services (Bluetooth, Avahi, CUPS) were masked and stopped.

Tool Restriction: Administrative tools like tcpdump and nmap were restricted to the root group (0750).

D. Access Control & Banners (Tasks 22)
Legal Banner: Configured /etc/issue.net to display a legal warning via SSH, establishing a legal basis for prosecution of unauthorized access.
