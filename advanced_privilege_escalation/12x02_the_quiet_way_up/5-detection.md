# Fenwick SOC Analyst Reconstruction — FDS-ETL-02

## Reading the trail: what each road actually wrote

### Road 1 — disk group / raw block device read (debugfs)
    auditctl -l | grep rawdisk
    -w /dev/sda   -p rwa -k rawdisk
    -w /dev/sda2  -p rwa -k rawdisk
    -a always,exit -F arch=b64 -S all -F path=/usr/sbin/debugfs -F perm=x -F key=rawdisk

    ausearch -k rawdisk
    type=EXECVE ... a0="debugfs" a1="-R" a2=636174202F726F6F742F726F6F742E666C6167 a3="/dev/sda2"
    type=SYSCALL ... comm="debugfs" exe="/usr/sbin/debugfs" auid=1000 uid=1000 ... key="rawdisk"

This is complete: the raw block-device watch fires on open, and a
dedicated execve rule fires on invoking `/usr/sbin/debugfs`, capturing
the full command line (hex-decoded, this is `cat /root/root.flag`),
the invoking UID, and the audit login ID (auid=1000, tying it to the
svc-etl session that logged in, even through the later privilege
change). An analyst watching this host's `ausearch -k rawdisk` feed,
or any SIEM ingesting this key, would see this the moment it happened.

### Road 3 — cap_dac_override write to /etc/passwd, then su to the planted account
    grep backdoor /var/log/auth.log
    2026-10-02T06:50:53 FDS-ETL-02 su: pam_unix(su:auth): user [backdoor] has blank password; authenticated without it
    2026-10-02T06:50:53 FDS-ETL-02 su[1483]: (to backdoor) svc-etl on pts/0
    2026-10-02T06:50:53 FDS-ETL-02 su[1483]: pam_unix(su:session): session opened for user backdoor(uid=0) by svc-etl(uid=1000)

PAM logs every `su` attempt and outcome to auth.log by default,
independent of any auditd rule Fenwick wrote specifically for this
host. The "blank password" line is a standing anomaly signature on its
own — this account should never have existed, and PAM flags the
authentication method it used (none) in the same line. The actual
`/etc/passwd` write that created the account is additionally caught
by the dedicated `-w /etc/passwd -p wa -k identity` watch, so this
road leaves two independent records, not one.

### Road 4 (the quiet one) — SUID binary + writable RUNPATH shared-library hijack
    auditctl -l | grep -E "plugins-1f9aa1|fds-etl-verify"
    (no output)

    ausearch -x /usr/local/bin/fds-etl-verify
    (no output)

    grep -i fds-etl-verify /var/log/auth.log
    (no output)

Nothing. There is no watch on the RUNPATH directory
(`/opt/fds/plugins-1f9aa1`), and no execve rule on the SUID binary
itself. The privilege escalation happens inside the dynamic linker's
normal library resolution at process start — not a syscall class or a
file path this host's ruleset was built to watch. Running the exact
same escalation twice, at different times, produced zero matching
records in any of the three places the other two roads showed up in.

## Ranking, most to least visible

1. **Road 1 (debugfs/rawdisk)** — loudest. Two independent audit
   mechanisms (a file/device watch AND a dedicated execve rule) both
   fire, and the execve rule logs the full command line in cleartext.
   An analyst does not need to correlate anything; one `ausearch -k
   rawdisk` query reconstructs the entire action.
2. **Road 3 (backdoor via cap_dac_override)** — loud, but through a
   different mechanism: PAM's own authentication logging, not a
   custom auditd rule. Still trivially visible (plain grep of
   auth.log), but an analyst relying only on `auditctl -l` output to
   know what's watched would miss that this road is covered too,
   since the coverage comes from PAM rather than from a rule Fenwick
   wrote for this host specifically. The underlying write to
   /etc/passwd is independently caught by the `identity` watch,
   making this road doubly redundant in coverage.
3. **Road 4 (RUNPATH shared-library hijack)** — invisible. No file
   watch, no execve rule, and no PAM event, because the privileged
   action never goes through sudo, su, or a watched path — it happens
   inside a normal SUID exec and a normal library load, both of which
   are expected, everyday behavior on this host.

## Why the difference
Fenwick's ruleset is built around specific **paths** (`/dev/sda2`,
`/etc/passwd`, `/usr/sbin/debugfs`) and one specific **binary**
(`sudo`). PAM adds a second, independent layer that covers
authentication events regardless of auditd rules. Neither layer
watches **library resolution behavior** — a SUID binary loading a
shared object from a writable RUNPATH directory is indistinguishable,
to this ruleset, from any other legitimate dynamic linking happening
constantly on the system. Visibility here tracks what specific
objects a rule names, not how "exotic" the underlying technique is;
Road 4 is not technically obscure, it is simply outside every object
this host's rules currently name.

## Proposed rule for the quiet road

The rule must not key on `/opt/fds/plugins-1f9aa1` or
`fds-etl-verify` by name — on the next host those will be different
paths and a different binary, and a filename-keyed rule would miss
every other SUID binary with the same underlying weakness.

Key it on the mechanism instead: a setuid/setgid root binary loading
a shared library from a directory writable by a non-root user. This
is detectable in two complementary ways:

1. **Static, periodic check (cheapest, catches it before exploitation):**
   enumerate every SUID/SGID binary on the host (`find / -perm -4000
   -o -perm -2000`), resolve each one's RUNPATH/RPATH and its full
   library dependency tree (`readelf -d`, `ldd`), and alert on any
   case where a resolved library path's containing directory is
   group- or world-writable by a non-root principal. This needs no
   runtime instrumentation, just periodic re-scanning, since the
   writable-directory condition is what creates the vulnerability
   regardless of whether it has been exploited yet.

2. **Runtime audit rule (catches active exploitation):** add an
   auditd watch on write access (`-p wa`) to any directory that
   currently appears as a RUNPATH/RPATH target of a SUID/SGID binary,
   generated dynamically from the static scan above rather than
   hardcoded, so it tracks whichever directories are actually at
   risk on this host at any given time rather than one instance's
   specific path.

Either approach keys on the condition — "writable directory in a
privileged binary's library search path" — not on today's filenames,
so it would catch the same class of weakness on a different binary,
in a different directory, on a different host built from the same
template.
