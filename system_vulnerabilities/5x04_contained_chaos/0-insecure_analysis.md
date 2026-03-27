# Dockerfile Security Analysis Report

This document identifies and explains the security vulnerabilities found in the provided Dockerfile for DevStream.

## 1. Use of Unpinned Base Image (ubuntu:latest)
* **Problem:** The Dockerfile uses `FROM ubuntu:latest` instead of a specific version tag or SHA256 hash.
* **Why it's Dangerous:** The `:latest` tag is non-reproducible and non-deterministic. It pulls the most recent version available, which might contain new vulnerabilities or breaking changes that haven't been tested.
* **Exploitation:** An attacker can exploit vulnerabilities present in a newer image version that was pulled automatically without the developer's review.

## 2. Sensitive Credentials in Image Layers (Hardcoded Secrets)
* **Problem:** The Dockerfile contains `RUN echo 'root:devstream123' | chpasswd` and hardcoded database credentials in `ENV` instructions.
* **Why it's Dangerous:** Docker image layers are persistent. Even if deleted in a later step, secrets in `RUN` or `ENV` commands are stored in the image metadata and history.
* **Exploitation:** Anyone with access to the Docker image can run `docker history --no-trunc` or `docker inspect` to extract the root password and database credentials in plain text.

## 3. Running as Root (No USER Directive)
* **Problem:** There is no `USER` instruction, meaning the application runs as the **root** user by default.
* **Why it's Dangerous:** This violates the Principle of Least Privilege. If the application (app.py) has a vulnerability like Remote Code Execution (RCE), the attacker immediately gains full administrative control over the container.
* **Exploitation:** A root user inside the container makes it significantly easier to perform a **container escape**, allowing the attacker to compromise the underlying host kernel.

## 4. Presence of Sudo and Unnecessary Packages
* **Problem:** The Dockerfile installs `sudo`, `gcc`, `make`, and networking tools like `curl`, `wget`, and `net-tools`.
* **Why it's Dangerous:** These tools drastically increase the attack surface. In a containerized environment, `sudo` is unnecessary and dangerous. Compilers and network tools are "Living off the Land" binaries.
* **Exploitation:** An attacker who gains a shell can use `gcc` to compile custom exploits or use `curl` and `net-tools` for internal network reconnaissance and data exfiltration.

## 5. Broad COPY Instruction Without .dockerignore
* **Problem:** The command `COPY . /app` is used without a `.dockerignore` file.
* **Why it's Dangerous:** This copies the entire directory, including sensitive files like `.git`, `.env`, private keys, or local configuration files.
* **Exploitation:** An attacker gaining access to the container filesystem can retrieve hidden configuration files or source code history to facilitate further attacks.

## 6. Pip Cache Persistence
* **Problem:** `pip3 install` is executed without the `--no-cache-dir` flag.
* **Why it's Dangerous:** This leaves unnecessary binary artifacts and caches in the image layers, increasing the image size and providing more tools/files for an attacker to analyze.

## 7. Missing HEALTHCHECK
* **Problem:** The Dockerfile lacks a `HEALTHCHECK` instruction.
* **Why it's Dangerous:** Without a healthcheck, the container orchestration system (like Kubernetes or Docker Swarm) cannot determine if the application is truly functioning or if it has been compromised and stalled.

## 8. Excessive Attack Surface
* **Problem:** Installing debugging tools like `vim` and `iputils-ping` in a production environment.
* **Why it's Dangerous:** Every additional package increases the probability of having a CVE (Common Vulnerabilities and Exposures) within the image.
* **Exploitation:** An attacker can use these pre-installed tools to facilitate lateral movement or modify configuration files within the container.
