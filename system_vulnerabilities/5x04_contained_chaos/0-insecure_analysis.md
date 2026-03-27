# Dockerfile Security Analysis: Project "Contained Chaos"

This document outlines the security vulnerabilities found in the DevStream production Dockerfile.

## 1. Use of Unpinned Base Image (ubuntu:latest)
* **The Problem:** The Dockerfile uses the `latest` tag for the base image.
* **Why it's Dangerous:** The `:latest` tag is non-deterministic and non-reproducible. Every time the image is built, it could pull a different version of Ubuntu, potentially introducing new bugs or breaking security patches.
* **Exploitation:** An attacker could exploit known vulnerabilities in a newer version of the base image that was automatically pulled without the developers' knowledge.

## 2. Package Bloat and Dangerous Tools (GCC, Make, Sudo)
* **The Problem:** The image installs unnecessary tools like `gcc`, `make`, `sudo`, `curl`, and `net-tools`.
* **Why it's Dangerous:** These tools significantly increase the attack surface. Specifically, `gcc` and `make` allow an attacker to compile exploits locally, and `sudo` has no place in a container environment as it provides a direct path for privilege escalation.
* **Exploitation:** If an attacker gains a shell, they can use `curl` to download malicious scripts, `gcc` to compile kernel exploits, and `sudo` to bypass restricted permissions.

## 3. Hardcoded Root Password
* **The Problem:** The instruction `RUN echo 'root:devstream123' | chpasswd` sets a static password.
* **Why it's Dangerous:** This secret is baked into the image layers. Even if deleted later, it remains in the image history.
* **Exploitation:** Anyone with access to the image can use `docker history` to find the root password and take full control of the container.

## 4. Sensitive Credentials in Environment Variables
* **The Problem:** Database credentials (`DB_PASSWORD`, `DB_USER`) are stored using the `ENV` instruction.
* **Why it's Dangerous:** Environment variables are not secure; they are visible to anyone who can run `docker inspect` or access the container's shell.
* **Exploitation:** An attacker who compromises the container or gains access to the Docker host can easily extract these plain-text credentials to access the production database.

## 5. Running as Root (Missing USER Directive)
* **The Problem:** The Dockerfile lacks a `USER` instruction, so the application runs as **root**.
* **Why it's Dangerous:** If the application is compromised (e.g., via RCE), the attacker immediately has administrative privileges within the container.
* **Exploitation:** A root user inside a container makes it much easier to perform a **container escape** to compromise the underlying host's kernel.

## 6. Broad COPY Without .dockerignore
* **The Problem:** `COPY . /app` copies the entire directory without a `.dockerignore` file.
* **Why it's Dangerous:** This often includes hidden files like `.env`, `.git` folders, or local configuration files containing secrets.
* **Exploitation:** An attacker can explore the `/app` folder to find sensitive source code history or hidden configuration files that were never meant to be in production.

## 7. Pip Cache Not Cleaned
* **The Problem:** `pip3 install` is used without `--no-cache-dir`.
* **Why it's Dangerous:** It leaves unnecessary binary artifacts and package caches in the image, increasing the image size and providing more files for an attacker to manipulate.

## 8. Missing Healthchecks
* **The Problem:** There is no `HEALTHCHECK` instruction.
* **Why it's Dangerous:** The container orchestration system cannot monitor if the application is actually healthy or if it has been stalled by a Denial of Service (DoS) attack.
