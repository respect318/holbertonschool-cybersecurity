1. Hardcoded Secrets in ENV and Layers
The Problem: The Dockerfile hardcodes the root password (chpasswd) and database credentials (DB_PASSWORD) directly in the instructions.

Why it's Dangerous: Docker image layers are additive and persistent. Even if a file is deleted in a later layer, the ENV variables and RUN commands are stored in the image metadata.

Exploitation: Anyone with access to the image can run docker history or docker inspect to reveal these plain-text secrets, granting them full access to the production database and the container's root account.

2. Running as Root (Lack of USER Directive)
The Problem: The Dockerfile lacks a USER instruction, meaning the application and all processes run as the root user by default.

Why it's Dangerous: This violates the principle of least privilege. If the Python application is compromised via a vulnerability like Remote Code Execution (RCE), the attacker immediately gains full administrative control inside the container.

Exploitation: An attacker can use root privileges to modify system libraries or, combined with kernel vulnerabilities, attempt a container escape to compromise the underlying host machine.

3. Inclusion of sudo
The Problem: The sudo package is installed inside the container environment.

Why it's Dangerous: Sudo is unnecessary in a container. Its presence provides a built-in mechanism for privilege escalation and bypasses security boundaries if misconfigured.

Exploitation: If an attacker gains access as a low-privileged user (if one were created), they could exploit known sudo vulnerabilities (like SudoEdit) or misconfigurations to regain root access.

4. Use of ubuntu:latest Tag
The Problem: Using the :latest tag instead of a specific, pinned version (e.g., ubuntu:22.04 or a SHA256 hash).

Why it's Dangerous: This leads to non-deterministic and non-reproducible builds. The "latest" image changes over time, potentially introducing new vulnerabilities or breaking security configurations without notice.

5. Unnecessary Tools (GCC, Make, and Network Tools)
The Problem: Installing build tools (gcc, make) and debugging tools (curl, net-tools, vim) in a production image.

Why it's Dangerous: These tools significantly increase the attack surface by providing "Living off the Land" binaries.

Exploitation: An attacker can use gcc to compile custom exploits for kernel vulnerabilities and use curl or net-tools to perform internal network reconnaissance and exfiltrate data.

6. Broad COPY without .dockerignore
The Problem: Using COPY . /app without a .dockerignore file.

Why it's Dangerous: This copies everything in the build context, including sensitive local files like .env, .git folders, or private SSH keys into the image.

Exploitation: An attacker exploring the container filesystem can find these accidentally included files to pivot to other systems or steal source code history.

7. Pip Cache Retention
The Problem: Running pip3 install without the --no-cache-dir flag.

Why it's Dangerous: It leaves behind temporary build artifacts and package caches, increasing the image size and leaving more files available for an attacker to analyze or manipulate.

8. Missing HEALTHCHECK
The Problem: There is no HEALTHCHECK instruction defined.

Why it's Dangerous: Without a healthcheck, the container orchestration system cannot determine if the application is truly healthy or if it has been frozen/deadlocked by a denial-of-service attack.
