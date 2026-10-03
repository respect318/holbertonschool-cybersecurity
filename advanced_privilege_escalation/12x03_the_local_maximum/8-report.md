# Halcyon Freight — Engagement Report
# Spearpoint Security | Assessor: jdoe foothold | Engagement: 12x03_the_local_maximum

## Executive answer

An attacker who compromises a single user workstation on Halcyon's
network can read the pre-audit finance extract on the database host.
We demonstrated this end to end: starting from an unprivileged shell
on HAL-WS-07, a workstation on the user segment, we reached and read
the contents of the protected finance file on HAL-DB-01, a host on a
separate segment with no direct route from the user network.

The result means that Halcyon's network segmentation does not contain
a workstation compromise. Segmentation is designed to ensure that a
breach on one segment cannot reach assets on another without
additional, separately controlled steps. What we found is that the
segments are connected by a chain of trust relationships — an SSH
key on one host that opens a door to the next, an agent credential
that carries identity forward, an NFS share that honours whoever
claims to be root — and those relationships are not governed by the
segment boundaries at all. An attacker who follows the trust chain
does not need to break through the segmentation; they walk around it
on paths the infrastructure itself provides.

Fixing individual hosts will not correct this. Every one of the four
vulnerabilities we exploited could be patched, and a version of this
path would remain as long as the trust topology is unchanged. The
segmentation will contain a workstation compromise only when the
credentials and access grants that cross segment boundaries are
governed as carefully as the network controls themselves.

## The chain and the findings

### Hop 1 — User workstation to root on HAL-WS-07
A SUID binary at /usr/local/bin/ws-backup invokes tar by name without
a full path. Any user who can execute it and control the PATH
environment variable can substitute a malicious tar and have it run
as root. The trust here is the operating system's implicit grant to
the binary's owner: whatever ws-backup calls is called as root. The
finding is not that the binary has a vulnerability — it is that the
binary was given a trust it does not earn, because it does not verify
what it calls.

Remediation: replace the tar invocation with an absolute path
(/bin/tar). More broadly, audit every SUID binary on this host for
calls to external programs without absolute paths. SUID is a trust
grant that should be as narrow as possible.

### Hop 2 — HAL-WS-07 to HAL-JMP-01 (segment boundary: user to mgmt)
As root on HAL-WS-07 we read /home/dwalsh/.ssh/id_ed25519, a
passwordless SSH private key belonging to a user who has access to the
management segment. The key was stored on the workstation, readable
by root, with no passphrase protecting it. The trust is: whoever holds
this key is accepted as dwalsh on HAL-JMP-01. By becoming root on the
workstation we inherited that trust, and with it the ability to cross
a segment boundary that was supposed to separate the user network from
the management infrastructure.

Remediation: private keys that grant access to more privileged
segments must never be stored unencrypted on hosts in less privileged
segments. Require passphrases on all SSH keys used for inter-segment
access, and manage them through an agent that requires fresh
authentication at the start of each session. The segment boundary is
only as strong as the credentials that cross it.

### Hop 3 — HAL-JMP-01 to HAL-APP-01 (segment boundary: mgmt to app)
On HAL-JMP-01 as dwalsh, a deployment script at
/opt/deploy/health-check.sh was owned by dwalsh and executed every
fifteen seconds by a supervisor running as svc-deploy. We replaced
the script with one that planted a SUID bash copy, changed identity
to svc-deploy, and used svc-deploy's live forwarded SSH agent socket
to authenticate to HAL-APP-01 without ever possessing svc-deploy's
private key. The trust is threefold: dwalsh is trusted to write a
script that svc-deploy runs; svc-deploy's agent is forwarded to a
host where it can be used by anyone who becomes svc-deploy; and the
segment boundary accepts that identity without additional verification.

Remediation: deployment scripts executed by privileged accounts must
not be writable by less privileged accounts. SSH agent forwarding
should be disabled except where it is specifically required and its
socket permissions audited. The combination of a writable execution
target and a forwarded credential is a trust chain that bypasses every
network control between the two segments.

### Hop 4 — Code execution as root on HAL-APP-01
The netcheck service at /opt/halcyon/netcheck/netcheck.py runs as
root because the container entrypoint script does not apply the
unprivileged user specified in the service unit file. The service
accepts a host parameter over HTTP and interpolates it directly into
a shell command without sanitisation. We sent a crafted request that
appended a command after the intended ping invocation and confirmed
root execution. The trust is: the service trusts its input, and the
deployment trusts that someone else configured the runtime user.

Remediation: the service unit user directive must be enforced at
the process level, not assumed from an entrypoint script. Input to
any service that constructs shell commands must be sanitised or the
command must be replaced with a library call that does not invoke a
shell at all. The gap between what a service says it runs as and what
it actually runs as is a deployment configuration review item, not
a code item alone.

### Hop 5 — HAL-APP-01 to HAL-DB-01 finance data (segment boundary: app to db)
As root on HAL-APP-01 we mounted the NFS export
/srv/nfs/dropbox from HAL-DB-01. The export is configured with
no_root_squash, meaning the server accepts uid=0 asserted by the
client at face value and grants root-level access to server storage.
We wrote a hook script to the export's hooks directory; HAL-DB-01's
own watcher executed it as root and wrote the output, including the
finance extract, back to the export's output directory, where we read
it. The trust is: HAL-DB-01 trusts that the host mounting its NFS
export and claiming to be root is actually authorised to act as root
on its storage. It is not.

Remediation: remove no_root_squash from the NFS export. No NFS
export that carries sensitive data should honour client-asserted root
identity. Additionally, the hook execution mechanism gives any writer
to the hooks directory arbitrary code execution on HAL-DB-01; the
hooks directory should not be world-writable, and the watcher should
validate hook scripts before running them.

## Severity

### Finding 1 — NFS no_root_squash on finance data export

CVSS:3.1/AV:A/AC:L/PR:H/UI:N/S:C/C:H/I:N/A:N
Score: 8.4 (High)

AV:A — the attacker must already be on the adjacent application
segment to reach the NFS port; the attack is not possible from the
internet directly.
AC:L — once on the app segment with root, mounting and exploiting the
export requires no special conditions; the no_root_squash
misconfiguration is consistently present.
PR:H — root on the application server is required to assert uid=0 to
the NFS server; an unprivileged user on that segment cannot exploit
this alone.
UI:N — no user interaction is needed; the mount and read are entirely
attacker-controlled.
S:C — the impact crosses from the application segment into the
database segment, which is a separate security scope; the scope
change is the definition of this finding's severity.
C:H — the finance pre-audit extract is read in its entirety; the
confidentiality impact is total for the data in scope.
I:N — we read but did not alter the file; the export was not used to
write to protected paths beyond our own proof files.
A:N — no availability impact was demonstrated or attempted.

### Finding 2 — SSH private key stored unencrypted on a lower-trust host

CVSS:3.1/AV:L/AC:L/PR:H/UI:N/S:C/C:H/I:H/A:N
Score: 8.2 (High)

AV:L — the key is read from local storage on HAL-WS-07; the attacker
must already have local access to that host.
AC:L — once root on the workstation the key is a plain file read; no
brute force or timing dependency is involved.
PR:H — root on the workstation is required to read the key from the
user's .ssh directory.
UI:N — no interaction from dwalsh or any other user is needed after
the key is read.
S:C — the key grants access to HAL-JMP-01 on the management segment,
crossing a segment boundary that the network is intended to enforce;
the scope of impact extends beyond the workstation.
C:H — all data accessible to dwalsh on the management segment and,
through the subsequent trust chain, on the application segment is
exposed.
I:H — the key grants write access to the management host and,
through the writable deployment script, to the application server;
we demonstrated write-level access at both hops.
A:N — availability was not impacted at either destination.

## Activity log

All times UTC. Source host and identity noted for each action.

2026-10-02 18:00 — KALI: initial SSH connection to HAL-WS-07 port
2222 as jdoe. Confirmed unprivileged shell, uid=1000.

2026-10-02 18:05 — HAL-WS-07 as jdoe: ran sudo -l (no sudo rights),
find for SUID binaries, located /usr/local/bin/ws-backup.

2026-10-02 18:08 — HAL-WS-07 as jdoe: ran strings on ws-backup,
confirmed unqualified tar call. Created ~/bin/tar payload. Set PATH
and executed ws-backup. Confirmed /tmp/.rootshell created with SUID
root.

2026-10-02 18:10 — HAL-WS-07 as root via /tmp/.rootshell: read
/home/dwalsh/.ssh/id_ed25519 and config. Read known_hosts (two
hashed entries). Read /root/flag_ws_root.txt. No files modified.

2026-10-02 18:14 — HAL-WS-07 as root: SSH to dwalsh@hal-jmp01 using
recovered key. Confirmed connection to HAL-JMP-01, uid dwalsh.

2026-10-02 18:16 — HAL-JMP-01 as dwalsh: enumerated interfaces,
routes, /etc/hosts. Located /run/svc-deploy/agent.sock,
/opt/deploy/health-check.sh (writable). Confirmed supervisor loop
in /entrypoint.sh executing health-check.sh as svc-deploy every 15s.

2026-10-02 18:18 — HAL-JMP-01 as dwalsh: replaced health-check.sh
with SUID bash payload. Waited 20 seconds. Confirmed
/tmp/.svcshell created.

2026-10-02 18:19 — HAL-JMP-01 as svc-deploy via /tmp/.svcshell:
used SSH_AUTH_SOCK=/run/svc-deploy/agent.sock to connect to
svc-deploy@hal-app01. Confirmed connection to HAL-APP-01.

2026-10-02 18:22 — HAL-APP-01 as svc-deploy: enumerated running
processes, located netcheck.py running as root on port 8080. Read
source and entrypoint.sh. Confirmed command injection and runtime
user gap.

2026-10-02 18:24 — HAL-APP-01: sent HTTP request with injected
command via curl to localhost:8080. Confirmed root RCE (id output
returned). Created /tmp/.approot SUID bash. No service interrupted.

2026-10-02 18:26 — HAL-APP-01 as root via RCE: ran showmount -e
hal-db01. Confirmed /srv/nfs/dropbox export open to all hosts.

2026-10-02 18:28 — HAL-APP-01 as root via RCE: mkdir
/mnt/halcyon-exports, mounted hal-db01:/srv/nfs/dropbox with NFS
vers=3,nolock. Mount succeeded. Listed export contents: hooks/,
out/, processed/.

2026-10-02 18:29 — HAL-APP-01 as root via RCE: created proof file
/mnt/halcyon-exports/prooftest. Confirmed file appeared as root:root
on server storage, proving no_root_squash.

2026-10-02 18:30 — HAL-APP-01 as root via RCE: wrote hook script
to /mnt/halcyon-exports/hooks/exfil.sh. Waited 8 seconds for watcher
to execute. Read output from /mnt/halcyon-exports/out/loot.txt.
Finance extract and FLAG_OBJECTIVE retrieved. No file on hal-db01
was altered.

2026-10-02 18:35 — Engagement actions complete. /tmp/.rootshell,
/tmp/.svcshell, /tmp/.approot left in place for verification;
health-check.sh payload removed and original script restored on
HAL-JMP-01. Proof files in NFS export left for deconfliction and
then to be removed by Halcyon on reset.

## Limitations

We did not test lateral movement to other workstations in the user
segment from KALI or from HAL-WS-07. The engagement scope placed
a single workstation as the starting point; whether other workstations
carry the same dwalsh SSH key or similar credentials was not
investigated. If dwalsh's key is distributed across multiple
workstations, the hop-2 finding is wider than demonstrated here.

We did not verify the two hashed entries in dwalsh's known_hosts on
HAL-WS-07 beyond confirming that hal-jmp01 was one of them. The
second entry is likely hal-app01 based on network topology, but we
did not recover it with ssh-keygen -F to confirm. This was set aside
because we reached HAL-APP-01 through the agent forwarding path
without needing to resolve the second entry.

We did not test whether the NFS export could be used to write to
protected paths on HAL-DB-01 beyond the designated dropbox
directories. The hooks directory executed scripts as root, and we
used that to read the objective file; we did not attempt to write to
/var/lib/halcyon/exports/ or other protected paths directly. Whether
root on the NFS client can overwrite arbitrary files on HAL-DB-01
through the export depends on the export options in full, which we
read through showmount but did not test exhaustively.

We did not attempt to recover or crack the credentials of other
accounts visible in /etc/passwd on any host. The engagement path was
closed without needing additional accounts, and testing account
credentials was out of scope for this assessment.

The first NFS mount attempt failed with mount.nfs: failed to apply
fstab options when attempted from a SUID-copy bash shell (real uid
not equal to effective uid). This is a known constraint of mount(2)
under that condition. We resolved it by routing the mount through
the netcheck command injection, which spawned a process with real
uid=0. The failure mode and resolution are documented here for
Halcyon's awareness; no NFS client software was modified.
