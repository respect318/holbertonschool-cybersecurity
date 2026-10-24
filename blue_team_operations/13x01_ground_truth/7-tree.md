# 13x01 Ground Truth — Task 7: Reconstruct the Tree

FLAG_PARENT:  C:\Windows\System32\wscript.exe  (parentProcessGuid {bd691e28-1800-4e04-8f79-9ee12aeb3956})  executing  C:\Users\sdumont\Downloads\PORTWAY-DISPATCH-UPDATE.js
FLAG_PERSIST: HKCU\Software\Microsoft\Windows\CurrentVersion\Run\Tavistock9  ->  C:\Users\sdumont\AppData\Roaming\iblenor.exe
FLAG_PAYLOAD: C:\Users\sdumont\AppData\Roaming\iblenor.exe
FLAG_C2:      198.51.100.47  (cdn-halcyon-sync.example)  tcp/443

## Process tree (agent 001, PORTWAY-WS-114)

wscript.exe (pid 19308, {bd691e28-...})                           [delivery — UNRESOLVED]
  └─ C:\Users\sdumont\Downloads\PORTWAY-DISPATCH-UPDATE.js
     └─ powershell.exe (pid 19312, {a0e0be61-dffb-40af-9c7b-f0a6c40d4ea5})   [MALICIOUS]
        │   -nop -w hidden -enc ... , integrity Medium, user sdumont
        ├─ EID 11  writes  C:\Users\sdumont\AppData\Roaming\iblenor.exe
        └─ EID 13  sets    HKCU\...\Run\Tavistock9 -> iblenor.exe
           └─ iblenor.exe (pid 19332, {ec443170-b1e2-483e-9b49-c60d87f37252})  [MALICIOUS]
              └─ EID 3  tcp/443 -> 198.51.100.47 (cdn-halcyon-sync.example)

SEPARATE, BENIGN ADMINISTRATIVE (decoy — cleared):
nmdeploy-agent.exe (C:\Program Files\Northmoor\DeployAgent\, svc_nmdeploy, pid 1340)
  └─ powershell.exe (pid 19292, {5891c7e0-8bcc-40fb-96c2-d692884504ac})
         -ExecutionPolicy Bypass -EncodedCommand -> Northmoor\stage\pkg_7708.ps1, integrity High

## Timeline (host time, 2026-09-18)

07:55:03.212  EID 1   wscript.exe (pid 19308) -> powershell.exe (pid 19312)
07:55:1x      EID 11  powershell writes C:\Users\sdumont\AppData\Roaming\iblenor.exe
07:55:14.051  EID 13  powershell sets HKCU\...\Run\Tavistock9 -> iblenor.exe
15:40:12.331  EID 1   nmdeploy-agent.exe -> powershell (pid 19292)  [benign]
16:15:33.738  EID 3   iblenor.exe (pid 19332) -> 198.51.100.47:443

## Verdicts — one decisive artefact per node, each rubric factor tied to one telemetry item

### powershell.exe (pid 19312, {a0e0be61-...})  —  MALICIOUS  —  HIGH
Decisive artefact (one): EID 13 registry value-set by processGuid {a0e0be61-...} — targetObject HKCU\...\CurrentVersion\Run\Tavistock9, details C:\Users\sdumont\AppData\Roaming\iblenor.exe (utcTime 07:55:14.051).
- provenance: EID 1 Hashes MD5=121E1253E10DBE8D2D06AAE33EDBC859, Image …\WindowsPowerShell\v1.0\powershell.exe — identical to the admin's hash, so provenance alone decides nothing.
- lineage: EID 1 ParentImage C:\Windows\System32\wscript.exe (parentProcessGuid {bd691e28-...}) — spawned by a script host running a Downloads .js, not by a deployment service.
- behaviour: EID 1 CommandLine "powershell.exe -nop -w hidden -enc …" — hidden, encoded, no-profile.
- network: no EID 3 under {a0e0be61-...} itself; the outbound belongs to its dropped child (next node).

### iblenor.exe (pid 19332, {ec443170-...})  —  MALICIOUS  —  HIGH
Decisive artefact (one): EID 3 network connection by processGuid {ec443170-...} — destinationIp 198.51.100.47, destinationHostname cdn-halcyon-sync.example, tcp/443 (utcTime 16:15:33.738).
- provenance: Image C:\Users\sdumont\AppData\Roaming\iblenor.exe — unsigned binary in a user-writable path.
- lineage: it is the target of FLAG_PERSIST (EID 13 Run\Tavistock9 details == this image) — it runs because the Run key points at it.
- behaviour: EID 3 initiated:true outbound to a fixed external host.
- network: destinationIp 198.51.100.47 is public (non-RFC1918); hostname cdn-halcyon-sync.example.

### wscript.exe + PORTWAY-DISPATCH-UPDATE.js (delivery / initial access)  —  UNRESOLVED  —  LOW
Decisive artefact that WOULD settle it is absent: there is no EID 1 process-create for wscript.exe (pid 19308) in the telemetry (so its own parent is unknown), and no EID 11/EID 3 showing how PORTWAY-DISPATCH-UPDATE.js arrived.
- provenance: the file path C:\Users\sdumont\Downloads\PORTWAY-DISPATCH-UPDATE.js (from the pid-19312 parentCommandLine) — the file's origin is not in the four streams.
- lineage: parentProcessGuid {bd691e28-...} is referenced as a parent but never appears as a child in any EID 1 — the chain above wscript is not captured.
- behaviour: a .js under Downloads launching hidden PowerShell is consistent with a lure, but no delivery event (download/write/open) is recorded.
- network: no EID 3 tied to the .js arrival.
Verdict: the EXECUTION of the implant under wscript is certain; the DELIVERY vector is UNRESOLVED. What would resolve it: the wscript (pid 19308) creation event with its parent, or a file-create / download event for PORTWAY-DISPATCH-UPDATE.js.

### powershell.exe (pid 19292, {5891c7e0-...})  —  BENIGN ADMINISTRATIVE (cleared)  —  HIGH
Decisive artefact (one): EID 1 process-create by processGuid {5891c7e0-...} — ParentImage C:\Program Files\Northmoor\DeployAgent\nmdeploy-agent.exe, parentUser PORTWAY\svc_nmdeploy.
- provenance: EID 1 Hashes MD5=121E1253… (same powershell binary) + CommandLine decodes to Northmoor\stage\pkg_7708.ps1 (a signed deployment package).
- lineage: ParentImage nmdeploy-agent.exe (the legitimate Northmoor deployment service) — routine for this host.
- behaviour: EID 1 integrityLevel High; no EID 13 Run-key write exists under {5891c7e0-...}.
- network: no EID 3 under {5891c7e0-...} to 198.51.100.47 — internal-only, never beacons to the C2.

## The shared-tool trap
Both powershell nodes carry the same Image and the same MD5 (121E1253…). Tool and provenance are shared and decide nothing; lineage (script-host lure vs deployment service), behaviour (Run-key persistence vs none) and network (public C2 vs internal-only) are what separate them.

## C2 familiarity
cdn-halcyon-sync.example — the "halcyon" token and the cdn-*-sync.example pattern. If this matches infrastructure from a prior engagement/client, record the actor overlap ("Halcyon"); recognising the actor across two clients outweighs any single artefact here.
