# 13x01 Ground Truth — Task 7: Reconstruct the Tree

FLAG_PARENT:  C:\Windows\System32\wscript.exe  (processGuid {bd691e28-1800-4e04-8f79-9ee12aeb3956})  spawned by C:\Windows\explorer.exe, running C:\Users\sdumont\Downloads\PORTWAY-DISPATCH-UPDATE.js
FLAG_PERSIST: HKCU\Software\Microsoft\Windows\CurrentVersion\Run\Tavistock9  ->  C:\Users\sdumont\AppData\Roaming\iblenor.exe
FLAG_PAYLOAD: C:\Users\sdumont\AppData\Roaming\iblenor.exe
FLAG_C2:      198.51.100.47  (cdn-halcyon-sync.example)  tcp/443

## Process tree (agent 001, PORTWAY-WS-114, grounded in EID 1/11/13/3)

explorer.exe (pid 17140, user sdumont)
  └─ EID 1  wscript.exe (pid 19308, {bd691e28-...})  running Downloads\PORTWAY-DISPATCH-UPDATE.js
     └─ EID 1  powershell.exe (pid 19312, {a0e0be61-dffb-40af-9c7b-f0a6c40d4ea5})  -nop -w hidden -enc, integrity Medium
        ├─ EID 11 writes C:\Users\sdumont\AppData\Roaming\iblenor.exe
        └─ EID 13 sets   HKCU\...\Run\Tavistock9 -> iblenor.exe
           └─ EID 1  iblenor.exe (pid 19332, {ec443170-b1e2-483e-9b49-c60d87f37252})
              └─ EID 3  tcp/443 -> 198.51.100.47 (cdn-halcyon-sync.example)

SEPARATE, BENIGN ADMINISTRATIVE (decoy — cleared):
nmdeploy-agent.exe (C:\Program Files\Northmoor\DeployAgent\, svc_nmdeploy, pid 1340)
  └─ EID 1  powershell.exe (pid 19292, {5891c7e0-8bcc-40fb-96c2-d692884504ac})  -EncodedCommand -> Northmoor\stage\pkg_7708.ps1, integrity High

## Timeline (host time, 2026-09-18)

07:55:00.000  EID 1   explorer.exe -> wscript.exe (pid 19308)   [user double-clicks the .js]
07:55:03.212  EID 1   wscript.exe -> powershell.exe (pid 19312)
~07:55        EID 11  powershell writes AppData\Roaming\iblenor.exe
07:55:14.051  EID 13  powershell sets Run\Tavistock9 -> iblenor.exe
15:40:12.331  EID 1   nmdeploy-agent.exe -> powershell (pid 19292)  [benign]
16:15:33.738  EID 3   iblenor.exe (pid 19332) -> 198.51.100.47:443

## Node verdicts (verdict / confidence; one decisive artefact; four factors, each tied to one telemetry item)

### wscript.exe (pid 19308, {bd691e28-...})  —  MALICIOUS  —  HIGH
Decisive artefact: EID 1 process-create of {bd691e28-...} — commandLine "WScript.exe …\Downloads\PORTWAY-DISPATCH-UPDATE.js" (utcTime 07:55:00).
provenance: Hashes MD5=1EAAD2B5FF351137BEAB8A84FAD734E3, Image …\System32\WScript.exe (signed script host — the cover).
lineage: parentImage C:\Windows\explorer.exe (parentProcessId 17140) — user double-clicked, not a service.
behaviour: executes a .js from the user's Downloads folder.
network: no EID 3 under {bd691e28-...}.

### powershell.exe (pid 19312, {a0e0be61-...})  —  MALICIOUS  —  HIGH
Decisive artefact: EID 13 value-set by {a0e0be61-...} — HKCU\...\Run\Tavistock9 -> C:\Users\sdumont\AppData\Roaming\iblenor.exe (07:55:14.051).
provenance: EID 1 Hashes MD5=121E1253E10DBE8D2D06AAE33EDBC859 — identical to the admin's; decides nothing.
lineage: EID 1 ParentImage C:\Windows\System32\wscript.exe ({bd691e28-...}) — script-host lure, not a service.
behaviour: EID 1 CommandLine "-nop -w hidden -enc".
network: no EID 3 under {a0e0be61-...}.

### iblenor.exe (pid 19332, {ec443170-...})  —  MALICIOUS  —  HIGH
Decisive artefact: EID 3 by {ec443170-...} — destinationIp 198.51.100.47 (cdn-halcyon-sync.example) tcp/443 (16:15:33.738).
provenance: Image C:\Users\sdumont\AppData\Roaming\iblenor.exe — unsigned, user-writable path.
lineage: it is the FLAG_PERSIST target (EID 13 Run\Tavistock9 details == this image).
behaviour: EID 3 initiated:true outbound to a fixed external host.
network: destinationIp 198.51.100.47 is public (non-RFC1918).

### Delivery vector of PORTWAY-DISPATCH-UPDATE.js  —  UNRESOLVED  —  LOW
Decisive artefact: EID 11 File Create of C:\Users\sdumont\Downloads\PORTWAY-DISPATCH-UPDATE.js — proves the lure landed, 2026-09-18.
provenance: the .js file exists (EID 11 targetFilename) but has no recorded signer/hash of a source — origin unverified.
lineage: the writing process of that EID 11 is not identified — the arrival channel is not in telemetry.
behaviour: the file was later executed (EID 1 wscript above), but the delivery action itself is not captured.
network: no EID 3 corresponds to a download of the .js.
Unresolved: landing and execution are proven; the arrival vector (web / mail / removable media) is not. Resolve with the EID 11 source image or an EID 3 download event.

### powershell.exe (pid 19292, {5891c7e0-...})  —  BENIGN ADMINISTRATIVE  —  HIGH
Decisive artefact: EID 1 process-create of {5891c7e0-...} — ParentImage C:\Program Files\Northmoor\DeployAgent\nmdeploy-agent.exe, parentUser PORTWAY\svc_nmdeploy.
provenance: Hashes MD5=121E1253… running the signed Northmoor pkg_7708.ps1.
lineage: ParentImage nmdeploy-agent.exe (legitimate deployment service) — routine for this host.
behaviour: EID 1 integrityLevel High; no EID 13 Run-key write under {5891c7e0-...}.
network: no EID 3 under {5891c7e0-...} to 198.51.100.47 — internal-only.

## Shared-tool trap
Both powershell nodes carry Image …\powershell.exe and MD5 121E1253…; tool and provenance are shared and decide nothing. Lineage, behaviour and network separate them.

## C2 familiarity
cdn-halcyon-sync.example — the "halcyon" token and the cdn-*-sync.example pattern. If this matches infrastructure from a prior engagement/client, record the actor overlap ("Halcyon").
