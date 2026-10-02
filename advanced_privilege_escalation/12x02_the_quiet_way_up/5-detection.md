# Fenwick SOC Analyst Reconstruction — FDS-ETL-02

## Collection and forwarding configuration (read before ranking anything)

    ls -la /etc/audit/plugins.d/
    cat /etc/audit/plugins.d/*.conf

Every audisp dispatcher plugin on this host is `active = no`:
`au-remote.conf` (remote audit forwarding), `syslog.conf`
(audisp-to-syslog bridge), `af_unix.conf`, and
`audispd-zos-remote.conf`. This means every auditd event — everything
collected under keys like `rawdisk`, `identity`, `priv_esc`, `etl_job`
— is written only to the local `/var/log/audit/audit.log` file and
goes nowhere else. There is no live console or SIEM feed fed by
auditd on this host as currently configured; an analyst only sees
these events by logging in and running `ausearch`/`aureport` directly,
after the fact.

Separately:

    systemctl status rsyslog
    ● rsyslog.service ... Active: active (running)

    cat /etc/rsyslog.conf
    auth,authpriv.*    /var/log/auth.log

    grep -E "forward|@@" /etc/rsyslog.conf /etc/rsyslog.d/*
    (no output)

rsyslog is running and does route `auth`/`authpriv` facility messages
(which is what PAM uses for `su`, `sudo`, login events) to
`/var/log/auth.log`, but there is no remote forwarding rule (`@` or
`@@` target) anywhere in its configuration. So rsyslog, too, only
writes locally.

**This changes what "visibility" means on this host.** Nothing
produced by either logging layer leaves this machine in real time,
and there is no evidence of a live-monitored console or alerting
pipeline at all — only two local, after-the-fact record stores:
`audit.log` (auditd) and `auth.log` (rsyslog, fed by PAM). The
distinction between the roads taken is therefore not "triggered an
alert vs. stayed silent" — it is "left a record in one or both of
these local stores, recoverable by an analyst who comes looking" vs.
"left no record in either."

## Reading the trail: what each road actually wrote

### Road 1 — disk group / raw block device read (debugfs)
    auditctl -l | grep rawdisk
    -w /dev/sda   -p rwa -k rawdisk
    -w /dev/sda2  -p rwa -k rawdisk
    -a always,exit -F arch=b64 -S all -F path=/usr/sbin/debugfs -F perm=x -F key=rawdisk

    ausearch -k rawdisk
    type=EXECVE ... a0="debugfs" a1="-R" a2=636174202F726F6F742F726F6F742E666C6167 a3="/dev/sda2"
    type=SYSCALL ... comm="debugfs" exe="/usr/sbin/debugfs" auid=1000 uid=1000 ... key="rawdisk"

Collected into `audit.log` via auditd, which — per the forwarding
check above — has no active dispatcher. This record exists, is
complete (full command line decoded, invoking auid tied to the
svc-etl login session), but reaches no console. An analyst recovers
it only by logging into this host and querying `ausearch -k rawdisk`
specifically; nothing about this event reaches rsyslog, auth.log, or
anywhere off-host.

### Road 2 — SUID root shell at /tmp/rootbash2
    auditctl -l | grep -i rootbash
    (no output — no rule references this path or any generic SUID/execve condition)

    ausearch -x /tmp/rootbash2
    (no output)

    grep -i rootbash /var/log/auth.log
    (no output)

Nothing, in either local store. There is no auditd rule watching `/tmp`
or matching a generic SUID-execution condition, and invoking a setuid
binary directly (`/tmp/rootbash2 -p`) never goes through `sudo` or
`su`, so PAM never fires either. This road is as unrecoverable from
this host's records as Road 4.

### Road 3 — cap_dac_override write to /etc/passwd, then su to the planted account
    grep backdoor /var/log/auth.log
    2026-10-02T06:50:53 FDS-ETL-02 su: pam_unix(su:auth): user [backdoor] has blank password; authenticated without it
    2026-10-02T06:50:53 FDS-ETL-02 su[1483]: (to backdoor) svc-etl on pts/0
    2026-10-02T06:50:53 FDS-ETL-02 su[1483]: pam_unix(su:session): session opened for user backdoor(uid=0) by svc-etl(uid=1000)

This record exists in `auth.log`, written by PAM via the
`auth,authpriv.*` rsyslog rule — a different collection path than
auditd entirely, and one that is independent of every auditd rule on
this host. The underlying `/etc/passwd` write is also independently
caught by auditd's `-w /etc/passwd -p wa -k identity` watch
(`ausearch -k identity` would show it), so this road leaves two
separate local records through two unrelated mechanisms, neither of
which is forwarded anywhere either — but an analyst with only
`auth.log` access (no auditd access at all) would still catch this
road, whereas they would never catch Road 1 through that file alone.

### Road 4 (the quiet one) — SUID binary + writable RUNPATH shared-library hijack
    auditctl -l | grep -E "plugins-1f9aa1|fds-etl-verify"
    (no output)

    ausearch -x /usr/local/bin/fds-etl-verify
    (no output)

    grep -i fds-etl-verify /var/log/auth.log
    (no output)

Nothing, in either local store. No auditd watch covers the RUNPATH
directory or the SUID binary, and no PAM event fires because the
privilege change never goes through `sudo` or `su` — the dynamic
linker loads the (replaced) shared library as part of a normal SUID
exec, which is ordinary process behavior neither collection mechanism
is configured to flag. Running the exact same escalation twice, at
different times, produced zero matching records in audit.log and zero
in auth.log.

## Ranking, most to least visible (via the records this host actually keeps)

1. **Road 3 (backdoor via cap_dac_override)** — most recoverable.
   Caught by PAM/rsyslog independently of any auditd rule, AND by a
   dedicated auditd `identity` watch — two unrelated mechanisms, so it
   survives even if an analyst only has access to one of the two local
   log stores.
2. **Road 1 (debugfs/rawdisk)** — fully recorded, but through a single
   mechanism only (auditd). An analyst without access to
   `/var/log/audit/audit.log`, or without knowing to query the
   `rawdisk` key specifically, would never see it; it never touches
   auth.log or any other file.
3. **Road 2 (SUID shell at /tmp/rootbash2) and Road 4 (RUNPATH
   shared-library hijack) — tied, least visible.** Neither leaves any
   record in either local store. Both bypass every collection
   mechanism this host has for the same underlying reason: neither
   goes through `sudo`/`su` (so PAM never fires), and neither matches
   any path, device, or binary an auditd rule names (so auditd never
   fires). The difference between them is not visibility but
   mechanism — Road 2 is a pre-existing setuid binary an analyst could
   still find by enumerating SUID files on disk, while Road 4 exploits
   a legitimate, correctly-configured SUID binary via a writable
   library search path, leaving no anomalous file for static
   enumeration to flag either. Road 4 is treated as the quieter of the
   two for the detection rule below, since Road 2's artifact (an
   unexplained SUID binary sitting in /tmp) is at least discoverable
   by a one-time filesystem sweep, whereas Road 4's weakness is a
   property of an otherwise-legitimate binary and only shows up by
   specifically checking library search paths for writability.

## Why the difference
No road on this host triggers anything in real time — that capability
does not exist here, since every audisp forwarding plugin is disabled
and rsyslog has no remote target. Visibility here is purely a function
of whether an action passes through one of the two mechanisms that
write locally at all: a matching auditd rule (keyed to a specific
path or binary), or a PAM-driven authentication event (keyed to the
`auth`/`authpriv` facility, independent of auditd entirely). Road 3
passes through both. Road 1 passes through only the first. Roads 2 and
4 pass through neither, because a direct setuid binary invocation and
a RUNPATH library load are not syscall classes, paths, or
authentication events either mechanism was built to watch.

## Proposed rule for the quiet road

The rule must not key on `/opt/fds/plugins-1f9aa1` or
`fds-etl-verify` by name — on a different host built from the same
template these would be different paths and a different binary, and a
filename-keyed rule would miss every other SUID binary sharing the
same underlying weakness.

Key it on the mechanism: a setuid/setgid root binary with a library
search path (RUNPATH/RPATH) pointing into a directory writable by a
non-root principal. Two complementary pieces, both necessary given
this host's existing configuration has no forwarding at all:

1. **Static, periodic check:** enumerate every SUID/SGID binary
   (`find / -perm -4000 -o -perm -2000`), resolve each one's
   RUNPATH/RPATH and library dependencies (`readelf -d`, `ldd`), and
   alert when a resolved library's containing directory is group- or
   world-writable by anyone other than root. This needs no new
   collection infrastructure — it finds the exposure itself, before
   exploitation, independent of whether auditd or rsyslog ever see
   anything.
2. **Runtime auditd watch, generated from the static scan:** add
   `-w <dir> -p wa -k suid_runpath_write` for each directory the scan
   flags, so a write to any currently-risky RUNPATH directory is
   caught the moment it happens — but only if Fenwick first enables
   the `au-remote` or `syslog` audisp plugin (currently `active = no`
   on this host), since otherwise this new rule would suffer the
   exact same forwarding gap as the `rawdisk` rule already does.

This keys on the condition — a privileged binary's library search path
resolving into a writable directory — not on today's filenames, so it
catches the same class of weakness on a different binary, in a
different directory, on a different host built from the same
template; and it does not repeat this host's existing mistake of
collecting an event locally with no path for an analyst to see it
without already knowing to look.
