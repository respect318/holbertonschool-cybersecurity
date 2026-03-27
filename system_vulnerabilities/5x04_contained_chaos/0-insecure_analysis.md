1. Running as Root (Default User)
The Problem: The Dockerfile does not specify a non-root user (e.g., USER appuser). By default, containers run as root.

Why it’s Dangerous: If an attacker compromises the application (e.g., via a Python RCE), they inherit root privileges within the container.

Exploitation: An attacker could modify system files, install persistent malware, or attempt a container breakout to access the host kernel or filesystem.

2. Hardcoded Secrets in Environment Variables
The Problem: The DB_PASSWORD and DB_USER are explicitly written in the ENV instructions.

Why it’s Dangerous: Environment variables are not secure. Anyone with access to the image, the running container, or the orchestration logs (like docker inspect) can see these credentials in plain text.

Exploitation: An attacker with read access to the Docker daemon or even a developer with the image could steal the production database credentials and exfiltrate data.

3. Hardcoded Root Password
The Problem: The line RUN echo 'root:devstream123' | chpasswd sets a known, static password for the root user.

Why it’s Dangerous: This violates the principle of "no hardcoded credentials." It also implies an SSH or TTY service might be reachable.

Exploitation: If the container is exposed via SSH or an attacker gains a shell, they can use su or log in as root using the leaked password to gain total control.

4. Use of ubuntu:latest (Mutable Tag)
The Problem: Using the latest tag instead of a specific version (e.g., ubuntu:22.04) or a checksum (SHA).

Why it’s Dangerous: "Latest" is a moving target. A new update could introduce breaking changes or, more critically, new vulnerabilities that haven't been vetted by the security team.

Exploitation: An attacker could wait for a vulnerable version of the base image to be pushed to the registry, knowing the CI/CD pipeline will automatically pull it.

5. Inclusion of sudo and Build Tools
The Problem: The image installs sudo, gcc, and make.

Why it’s Dangerous: These tools are rarely needed in a production runtime environment. They significantly increase the attack surface.

Exploitation: gcc and make allow an attacker who has gained limited shell access to compile custom exploits or "dirty pipe" variants directly inside the container without needing to download binaries.

6. Inclusion of Unnecessary Network Tools
The Problem: Installing curl, wget, net-tools, and iputils-ping.

Why it’s Dangerous: These are "living off the land" binaries for attackers.

Exploitation: An attacker can use curl or wget to download malicious payloads from their Command & Control (C2) server, and use net-tools to map the internal network (lateral movement) to find other vulnerable services.

7. Overly Permissive COPY . /app
The Problem: Copying the entire directory (.) into the image.

Why it’s Dangerous: Without a .dockerignore file, this likely copies .git folders, local environment files (.env), secrets, and sensitive documentation into the image layers.

Exploitation: An attacker who gains access to the image can extract the .git history to find previously deleted credentials or architectural secrets.

8. Insecure pip Installation (Missing Constraints)
The Problem: RUN pip3 install -r requirements.txt without version pinning or hash checking.

Why it’s Dangerous: This is susceptible to Dependency Confusion or Supply Chain Attacks. If a library is hijacked in the public repository, the Docker build will pull the malicious version.

Exploitation: An attacker could publish a malicious package with the same name as an internal DevStream dependency, causing the Docker build to automatically execute malicious code during the pip install phase.
