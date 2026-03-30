## Insecure Dockerfile Analysis

This document identifies security issues in the provided Dockerfile and explains their risks and exploitation scenarios.

---

### 1. Using `ubuntu:latest`

**Problem:**  
The Dockerfile uses `ubuntu:latest` as the base image.

**Why it's dangerous:**  
- The `latest` tag is not fixed, making builds non-reproducible. Future builds may silently introduce vulnerabilities.
- Ubuntu is a large, general-purpose image, which increases the attack surface compared to minimal images like Alpine.

**Exploitation:**  
An attacker can exploit newly introduced vulnerabilities in updated base images without developers being aware of the change.

---

### 2. Installing unnecessary packages

**Problem:**  
The container installs many tools that are not required in production:
`vim`, `net-tools`, `iputils-ping`, `gcc`, `make`, `sudo`.

**Why it's dangerous:**  
- These tools significantly increase the attack surface.
- Compilers (`gcc`, `make`) allow attackers to compile and run malicious code inside the container.
- Network tools (`ping`, `net-tools`) help attackers perform internal reconnaissance.
- `sudo` is unnecessary in containers and may allow privilege escalation paths.

**Exploitation:**  
If an attacker gains access, they can:
- Compile exploits using `gcc`
- Scan internal networks using `ping` or `net-tools`
- Abuse `sudo` misconfigurations to gain higher privileges

---

### 3. No package cleanup

**Problem:**  
`apt-get` is used without cleaning cache.

**Why it's dangerous:**  
Leaves unnecessary metadata and increases image size.

**Exploitation:**  
Attackers may analyze leftover package data for insights about the system.

---

### 4. Hardcoded root password

**Problem:**  
Root password is set to `devstream123`.

**Why it's dangerous:**  
Static credentials are easily guessable.

**Exploitation:**  
Attackers can log in as root if access is obtained.

---

### 5. Secrets in environment variables

**Problem:**  
Database credentials are stored in ENV variables.

**Why it's dangerous:**  
They can be exposed via `docker inspect` or logs.

**Exploitation:**  
Attackers can extract credentials and access the database.

---

### 6. Running as root

**Problem:**  
Container runs as root.

**Why it's dangerous:**  
Violates least privilege principle.

**Exploitation:**  
Full control of the container if compromised.

---

### 7. Copying entire context

**Problem:**  
`COPY . /app` copies everything.

**Why it's dangerous:**  
Sensitive files may be included.

**Exploitation:**  
Attackers can access secrets or internal files.

---

### 8. Unpinned dependencies

**Problem:**  
Python dependencies are not version-pinned.

**Why it's dangerous:**  
May introduce vulnerable or malicious packages.

**Exploitation:**  
Compromised dependencies could execute arbitrary code.

---

## Conclusion

The Dockerfile is insecure due to poor base image selection, unnecessary tools, excessive privileges, and exposed secrets. These issues significantly increase the risk of compromise and must be fixed before production use.
