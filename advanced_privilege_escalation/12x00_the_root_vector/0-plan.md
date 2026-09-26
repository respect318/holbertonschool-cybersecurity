The objective of this engagement is to establish a reasoned, composable path to root by analyzing and chaining isolated, intentionally configured privileges. Finding a single vector is not the goal; understanding the host's logic and building a systematic chain is.

**Initial Inventory and Order**
Since automated enumeration frameworks are out of scope, I will manually inventory the host's attack surface in a specific, prioritized order. First, I will establish my own baseline context using `id` and `sudo -l` to understand my initial access. Second, I will search for SUID and SGID binaries using `find / -type f -a \( -perm -4000 -o -perm -2000 \) 2>/dev/null`. Third, I will enumerate file capabilities with `getcap -r / 2>/dev/null`. Finally, I will inspect scheduled tasks by reviewing `/etc/crontab`, `/etc/cron.d/`, and systemd timers to identify background jobs running with higher privileges.

**Evaluating Primitives and Undocumented Binaries**
To determine what a primitive actually permits, I will not rely on its name, assumed function, or external documentation. For custom, undocumented binaries, I will inspect them safely using `strings` to find hardcoded file paths, and `strace` or `ltrace` (if permitted) to observe live system calls and file interactions. By strictly observing the required inputs and the resulting effective user or group IDs (euid/egid) during execution, I can concretely map the exact privilege boundaries rather than guessing.

**Handling Non-Root Primitives**
When a primitive grants a real privilege that is not root—such as read-only access to a specific folder or execution rights as a different non-root service account—I will not discard it as a failure. Instead, I will treat it as an intermediate stepping stone. I will use this new access to enumerate a fresh layer of the system. For example, a primitive granting read access might expose sensitive configuration files, logs, or credentials, which will then serve as the necessary input for a secondary primitive.

**Prohibited Actions**
One specific action I will absolutely not perform on this host is the execution of automated enumeration scripts like linpeas, pspy, or linux-exploit-suggester. Furthermore, I will strictly refrain from exfiltrating any clinical data off the machine, ensuring the environment remains fully functional and reversible.
