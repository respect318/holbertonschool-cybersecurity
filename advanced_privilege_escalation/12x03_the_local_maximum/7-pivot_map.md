# Pivot Map — Halcyon Freight Engagement

## Nodes

- KALI — attack box, user segment (10.0.2.15)
- HAL-WS-07 — entry host, user segment (10.0.2.5)
- HAL-JMP-01 — jump host, bridges user segment and app segment
- HAL-APP-01 — application server, app segment
- HAL-DB-01 — database host, db segment (NFS server, objective host)

## Graph

KALI (user segment)
  |
  | edge 1: password credential jdoe/v37WqqtPCGQ5sz — MATERIAL ONLY
  | [same segment, no boundary crossing]
  v
HAL-WS-07 as jdoe (user segment)
  |
  | edge 2: SUID binary /usr/local/bin/ws-backup calls tar without full
  |         path; PATH hijack plants malicious tar; binary runs as root
  |         and executes payload — PRIVILEGE REQUIRED
  | [local escalation, no boundary crossing]
  v
HAL-WS-07 as root (user segment)
  |
  | edge 3: passwordless SSH private key /home/dwalsh/.ssh/id_ed25519
  |         readable only as root; SSH config alias resolves hal-jmp01 — MATERIAL ONLY
  | [SEGMENT BOUNDARY: user segment -> mgmt/app segment]
  v
HAL-JMP-01 as dwalsh (mgmt/app segment)
  |
  | edge 4: /opt/deploy/health-check.sh writable by dwalsh, executed
  |         every 15s as svc-deploy; SUID bash planted; svc-deploy
  |         identity used to access live forwarded agent socket
  |         /run/svc-deploy/agent.sock — PRIVILEGE REQUIRED
  | [SEGMENT BOUNDARY: mgmt segment -> app segment]
  v
HAL-APP-01 as svc-deploy (app segment)
  |
  | edge 5: netcheck.py runs as root due to deployment gap (entrypoint.sh
  |         ignores service unit user); unsanitised host parameter passed
  |         to shell; command injection achieves root RCE — PRIVILEGE REQUIRED
  | [local escalation, no boundary crossing]
  v
HAL-APP-01 as root (app segment)
  |
  | edge 6: NFS export /srv/nfs/dropbox on HAL-DB-01 configured with
  |         no_root_squash; server honours client-asserted uid=0;
  |         root on HAL-APP-01 is accepted as root on server storage — MATERIAL ONLY
  | [SEGMENT BOUNDARY: app segment -> db segment]
  v
HAL-DB-01 storage as root via NFS (db segment)
  |
  | edge 7: write access to /srv/nfs/dropbox/hooks/ used to plant hook
  |         script; HAL-DB-01 watcher executes hooks as root and writes
  |         output to /srv/nfs/dropbox/out/; output read back via NFS — MATERIAL ONLY
  | [no boundary crossing; access to objective file on db segment]
  v
/var/lib/halcyon/exports/preaudit_extract.csv — OBJECTIVE FILE READ

## Segment Boundaries Crossed

1. user segment -> mgmt/app segment: edge 3 (passwordless SSH key)
2. mgmt segment -> app segment: edge 4 (forwarded SSH agent socket)
3. app segment -> db segment: edge 6 (NFS no_root_squash)

## Edge Classification Count

Privilege-required edges: 3 (edges 2, 4, 5)
Material-only edges: 4 (edges 1, 3, 6, 7)

## What the Map Corrects

Halcyon's assumption: privilege is what spreads.
What the graph shows: of seven hops from attack box to objective file,
only three required obtaining privilege on a host. The remaining four
crossed host and segment boundaries using nothing more than possession
of a credential, a private key, an agent socket, or a writable directory.
Fixing the three privilege escalations alone does not close the path:
an attacker who recovers dwalsh's key from HAL-WS-07 as root can still
cross every subsequent segment boundary on material alone, because the
segment boundaries are secured by trust in possession rather than by
verified identity.
