# 13x01 Ground Truth — Task 7: Reconstruct the Tree

FLAG_PARENT:  C:\Windows\System32\wscript.exe  executing  C:\Users\sdumont\Downloads\PORTWAY-DISPATCH-UPDATE.js  (parentProcessGuid {bd691e28-1800-4e04-8f79-9ee12aeb3956}) — the "spawns-things-anyway" host the implant hid under
FLAG_PERSIST: HKCU\Software\Microsoft\Windows\CurrentVersion\Run\Tavistock9  ->  C:\Users\sdumont\AppData\Roaming\iblenor.exe
FLAG_PAYLOAD: C:\Users\sdumont\AppData\Roaming\iblenor.exe
FLAG_C2:      198.51.100.47  (cdn-halcyon-sync.example)  tcp/443

## Process tree (agent 001, PORTWAY-WS-114, user PORTWAY\sdumont)

wscript.exe (pid 19308)                                   [FLAG_PARENT — lure host]
  └─ C:\Users\sdumont\Downloads\PORTWAY-DISPATCH-UPDATE.js
     └─ powershell.exe (pid 19312, {a0e0be61-dffb-40af-9c7b-f0a6c40d4ea5})
        │   -nop -w hidden -enc ... , integrityLevel Medium
        ├─ writes  C:\Users\sdumont\AppData\Roaming\iblenor.exe           [FLAG_PAYLOAD]
        └─ sets    HKCU\...\CurrentVersion\Run\Tavistock9 -> iblenor.exe  [FLAG_PERSIST]
           └─ iblenor.exe (pid 19332)
              └─ outbound tcp/443 -> 198.51.100.47 (cdn-halcyon-sync.example)  [FLAG_C2]

SEPARATE, BENIGN (the decoy — cleared):
nmdeploy-agent.exe (C:\Program Files\Northmoor\DeployAgent\, svc_nmdeploy, pid 1340)
  └─ powershell.exe (pid 19292, {5891c7e0-8bcc-40fb-96c2-d692884504ac})
         -ExecutionPolicy Bypass -EncodedCommand -> Northmoor\stage\pkg_7708.ps1, integrity High

## Timeline (host time, 2026-09-18)

07:55:03  wscript.exe -> powershell.exe (pid 19312)  — implant executes under the script host
~07:55    powershell writes iblenor.exe to AppData\Roaming  — payload dropped
07:55:14  powershell sets Run\Tavistock9 -> iblenor.exe     — persistence established
15:40:12  nmdeploy-agent.exe -> powershell (pid 19292)       — BENIGN admin deployment (unrelated)
16:15:33  iblenor.exe -> 198.51.100.47:443                   — C2 beacon

## Verdicts (verdict / confidence / decisive artefact / rubric: provenance x lineage x behaviour x network)

### powershell.exe (pid 19312)  —  MALICIOUS  —  confidence HIGH
Decisive artefact: it wrote Run\Tavistock9 -> AppData\iblenor.exe (EID 13), and its drop beacons out (EID 3).
- provenance: signed Microsoft powershell.exe (MD5 121E1253...) — identical to the admin's, proves nothing
- lineage: spawned by wscript.exe running a .js from Downloads — NOT a deployment service; suspicious
- behaviour: -w hidden -enc, dropped a payload, wrote autorun persistence
- network: its child reaches an external C2

### iblenor.exe (pid 19332)  —  MALICIOUS  —  confidence HIGH
Decisive artefact: EID 3 beacon to 198.51.100.47 (cdn-halcyon-sync.example).
- provenance: unsigned binary dropped in a user-writable path (AppData\Roaming) — bad
- lineage: launched from the Run-key persistence
- behaviour: beacons on a schedule to a fixed external host
- network: destination is non-internal (public) C2

### wscript.exe + PORTWAY-DISPATCH-UPDATE.js (initial access)  —  MALICIOUS  —  confidence MEDIUM
Decisive artefact: it is the parent that spawned the hidden powershell (the implant hid under a script host that spawns things anyway); the .js sits in the user's Downloads and is named to blend with dispatch operations.
- This is the node that does NOT deserve high confidence: the telemetry shows wscript executing the .js, but how PORTWAY-DISPATCH-UPDATE.js arrived (download/email) and what spawned wscript are not established from the four streams. The execution is certain; the delivery vector is inferred.

### nmdeploy-agent.exe -> powershell (pid 19292)  —  BENIGN (cleared)  —  confidence HIGH
Decisive artefact: internal-only, no Run-key persistence, signed Northmoor agent parent.
- provenance: signed powershell running a signed Northmoor package from C:\Program Files\Northmoor\
- lineage: spawned by the legitimate Northmoor deployment service (svc_nmdeploy) — routine for this host
- behaviour: deployment file writes, integrity High, writes no autorun persistence
- network: internal-only; it never beacons to 198.51.100.47
Why it is not the attacker despite using the same interpreter: tool and provenance are shared, but lineage (deployment service vs script-host lure), behaviour (no persistence) and network (no C2) all separate it.

## The shared-tool trap, stated plainly
Both chains run powershell.exe with -EncodedCommand. The interpreter and its signature are identical and decide nothing. What separates them is lineage, behaviour and where they talked.

## C2 familiarity
The C2 hostname cdn-halcyon-sync.example carries the token "halcyon" and the cdn-*-sync.example pattern. If this matches infrastructure seen in a prior engagement/client, that actor overlap ("Halcyon") is worth more than any single artefact here — cross-reference it.
