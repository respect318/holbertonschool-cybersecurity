# Three Independent Roads to Root — FDS-ETL-02

## Road 1 — Raw block device access via `disk` group membership

**What it abused:** `svc-etl` is a member of the `disk` group
(`groups=1000(svc-etl),6(disk)`), and the host's root filesystem block
device `/dev/sda2` is group-owned by `disk` with read/write
permissions (`brw-rw---- 1 root disk`).

**Why it works:** Group membership on `/dev/sda*` grants direct access
to the raw filesystem, bypassing every file-level permission check
entirely. Standard Unix permissions on files like `/root/*` (mode 600,
owned by root) are never consulted, because this path never goes
through the filesystem's permission-checking code at all — it reads
the block device's bytes directly.

**Evidence:**
    $ debugfs -R "cat /root/root.flag" /dev/sda2
    FEN{8982c77ec6737fa536eb44cf2942c2b5}

**Remediation:** Remove `svc-etl` from the `disk` group. No service
account should hold membership in `disk`, `kmem`, or any group with
direct block-device access unless it genuinely needs raw I/O.

## Road 2 — SUID root shell at `/tmp/rootbash2`

**What it abused:** A world-executable binary at `/tmp/rootbash2`,
owned by `root:root` with the setuid bit set
(`-rwsr-xr-x 1 root root`), present in a world-writable directory.

**Why it works:** The setuid bit causes the binary to run with its
owner's privileges (root) regardless of which user invokes it. Run
with `-p` (preserve privileges, preventing bash from dropping the
effective UID on start), it hands back a root-privileged shell
directly.

**Evidence:**
    $ /tmp/rootbash2 -p
    rootbash2-5.2# id
    uid=1000(svc-etl) gid=1000(svc-etl) euid=0(root) groups=1000(svc-etl),6(disk)
    rootbash2-5.2# date -u
    Fri Oct  2 06:38:29 AM UTC 2026

**Remediation:** Remove this binary; it has no legitimate purpose in
`/tmp`. More broadly, mount `/tmp` with `nosuid` so that no setuid
binary placed there (by any process or user) can ever be honored by
the kernel at exec time, independent of whether this specific file is
found and removed.

## Road 3 — File capability on `fds-logcat` enabling arbitrary file write

**What it abused:** `/usr/local/bin/fds-logcat` carries the
`cap_dac_override=ep` file capability, and the binary appends
caller-supplied stdin content to any file path given as its argument
(`openat(..., "/etc/shadow", O_WRONLY|O_CREAT|O_APPEND, ...)`,
confirmed via `strace`), with no restriction on which path may be
targeted.

**Why it works:** `cap_dac_override` grants the process the ability to
bypass all discretionary file permission checks (read and write),
independent of the invoking user's UID. The tool itself performs no
path validation, so it can be pointed at any file on the filesystem,
including ones `svc-etl` could never normally write to.

**Evidence:**
    $ echo "backdoor::0:0:root:/root:/bin/bash" | /usr/local/bin/fds-logcat /etc/passwd
    $ tail -1 /etc/passwd
    backdoor::0:0:root:/root:/bin/bash
    $ su backdoor
    # id
    uid=0(root) gid=0(root) groups=0(root)
    # date -u
    Fri Oct  2 06:51:10 AM UTC 2026

**Remediation:** Remove the `cap_dac_override` capability from this
binary; a log-append tool should run with ambient file permissions, or
at most a narrowly scoped capability restricted to a specific log
directory, never unrestricted filesystem-wide override.

## Why these three are independent

Each road abuses a structurally different Linux privilege mechanism:
Road 1 is a POSIX group permission on a device node, Road 2 is the
setuid execution bit on a regular file, and Road 3 is a POSIX file
capability on a binary. Fixing any one of them — removing the group
membership, deleting the SUID binary, or stripping the capability —
has no effect on the other two; each depends on a completely separate
piece of host configuration, with no shared root cause.

## Ruled out

**LD_PRELOAD via sudo's `env_keep` setting.** `sudo -l` showed
`env_keep+=LD_PRELOAD` and a `NOPASSWD` rule for
`/usr/local/sbin/fds-7039-maintenance`, which looked like a classic
LD_PRELOAD hijack. This was set aside after confirming no C compiler
is available on the host:

    $ gcc
    Command 'gcc' not found
    $ dpkg -l | grep gcc
    ii  gcc-14-base:amd64 ...
    ii  libgcc-s1:amd64 ...

Only GCC's runtime support libraries are installed, not the compiler
itself, and no alternative compiler (`cc`, `clang`, `tcc`) is present
either. Without a way to build a malicious shared object on the host,
this lead does not produce a working path, regardless of how
permissive the sudo rule is.
