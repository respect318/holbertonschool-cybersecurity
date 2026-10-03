# Pivot Map — Halcyon Freight Engagement

## Segments and Nodes

USER SEGMENT:
  - KALI (attack box, 10.0.2.15)
  - HAL-WS-07 (entry host, 10.0.2.5)

MGMT SEGMENT:
  - HAL-JMP-01 (jump host)

APP SEGMENT:
  - HAL-APP-01 (application server)

DB SEGMENT:
  - HAL-DB-01 (database host, NFS server, objective host)

## Graph

KALI [USER SEGMENT]
  |
  | edge 1: password credential jdoe/v37WqqtPCGQ5sz — MATERIAL ONLY
  | (no segment boundary — same segment)
  v
HAL-WS-07 as jdoe [USER SEGMENT]
  |
  | edge 2: SUID binary /usr/local/bin/ws-backup calls tar without full
  |         path; PATH hijack executes malicious tar as root — PRIVILEGE REQUIRED
  | (no segment boundary — local escalation)
  v
HAL-WS-07 as root [USER SEGMENT]
  |
  | === SEGMENT BOUNDARY: USER SEGMENT -> MGMT SEGMENT ===
  | edge 3: passwordless SSH private key /home/dwalsh/.ssh/id_ed25519
  |         readable only as root; key authenticates to HAL-JMP-01 — MATERIAL ONLY
  v
HAL-JMP-01 as dwalsh [MGMT SEGMENT]
  |
  | === SEGMENT BOUNDARY: MGMT SEGMENT -> APP SEGMENT ===
  | edge 4: /opt/deploy/health-check.sh writable by dwalsh, executed
  |         every 15s as svc-deploy; SUID bash planted; svc-deploy
  |         forwarded agent socket /run/svc-deploy/agent.sock used
  |         to authenticate to HAL-APP-01 without private key — PRIVILEGE REQUIRED
  v
HAL-APP-01 as svc-deploy [APP SEGMENT]
  |
  | edge 5: netcheck.py runs as root due to deployment gap;
  |         unsanitised host parameter passed to shell;
  |         command injection gives root RCE — PRIVILEGE REQUIRED
  | (no segment boundary — local escalation)
  v
HAL-APP-01 as root [APP SEGMENT]
  |
  | === SEGMENT BOUNDARY: APP SEGMENT -> DB SEGMENT ===
  | edge 6: NFS export /srv/nfs/dropbox on HAL-DB-01 configured with
  |         no_root_squash; server honours client-asserted uid=0;
  |         root on HAL-APP-01 accepted as root on HAL-DB-01 storage — MATERIAL ONLY
  v
HAL-DB-01 storage as root via NFS [DB SEGMENT]
  |
  | edge 7: write access to /srv/nfs/dropbox/hooks/ used to plant hook
  |         script; HAL-DB-01 watcher executes hooks as root and writes
  |         output to /srv/nfs/dropbox/out/; output read back via NFS — MATERIAL ONLY
  | (no segment boundary — access to objective file within db segment)
  v
/var/lib/halcyon/exports/preaudit_extract.csv [DB SEGMENT] — OBJECTIVE FILE READ

## Segment Boundaries Crossed

1. USER SEGMENT -> MGMT SEGMENT: edge 3 — passwordless SSH private key
2. MGMT SEGMENT -> APP SEGMENT:  edge 4 — forwarded SSH agent socket
3. APP SEGMENT  -> DB SEGMENT:   edge 6 — NFS no_root_squash

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
