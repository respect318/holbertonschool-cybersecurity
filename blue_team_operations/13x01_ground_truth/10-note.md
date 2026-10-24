# Investigation Note — PORTWAY-WS-114

**Endpoint:** PORTWAY-WS-114 (Wazuh agent ID `001`, enrolled, Active)
**Analyst:** F. Mirzazada · **For:** Dana (IR lead) · **Date:** 2026-09-18 (telemetry window)
**Compromised user context:** `PORTWAY\sdumont`

## What happened

A user-initiated script delivery turned into a persistent, beaconing implant on a single
workstation. The chain, in order:

**1. Entry (execution by the user).** The host ran
`C:\Windows\System32\wscript.exe "C:\Users\sdumont\Downloads\PORTWAY-DISPATCH-UPDATE.js"`
(ProcessGuid `{bd691e28-1800-4e04-8f79-9ee12aeb3956}`). The lure arrived in `sdumont`'s
Downloads folder with a name that imitates a Portway dispatch update, and was opened by the
user — classic user-execution (MITRE **T1204.002**). `wscript.exe` is the true parent of
everything that follows; `explorer.exe`, `nmdeploy-agent.exe` and the intermediate
`powershell.exe` are decoys in the tree, not the origin.

**2. Execution (scripted stage).** `wscript` spawned
`powershell.exe -nop -w hidden -enc …` (ProcessGuid `{a0e0be61-dffb-40af-9c7b-f0a6c40d4ea5}`) —
no-profile, hidden window, Base64-encoded command (MITRE **T1059.001**). This PowerShell stage
is the writer: it dropped the payload and wrote persistence in the same burst.

**3. Payload drop.** EID 11 (file-create) recorded
`C:\Users\sdumont\AppData\Roaming\iblenor.exe`,
SHA-256 `d13e0265140f33bc79de76e6c31708138443510e9d44184f5acd44ea7a88c6b2`,
written into a user-writable path (no admin needed).

**4. Persistence.** EID 13 (registry-value-set) recorded
`HKCU\Software\Microsoft\Windows\CurrentVersion\Run\Tavistock9`, pointing at the dropped EXE
(MITRE **T1547.001**). This guarantees the implant re-runs at `sdumont`'s next logon — survival
without touching HKLM or needing elevation.

**5. Callback.** At logon the Run key launched `iblenor.exe`, which opened EID 3 network
connections to `198.51.100.47` (`cdn-halcyon-sync.example`) over tcp/443 on a steady ~60-second
interval — low-and-slow web C2 (MITRE **T1071.001**). The regular cadence to one external host
is the beacon.

So: a Downloads `.js` opened by the user → hidden encoded PowerShell → EXE in `AppData\Roaming`
→ HKCU Run-key persistence → logon-triggered implant beaconing to an external C2 on 443.

## The node I had to work for

One node would not fall to a quick read: `nmdeploy-agent.exe → powershell.exe` instance
**pkg_7714** (run ~12:59, ProcessGuid `{49fb0168-6c51-42f0-96fe-e45280d8b907}`). It looked
exactly like Portway's legitimate Northmoor deployment work — same signed `powershell.exe`
interpreter, launched under the service chain, writing into the Northmoor logging tree. On
provenance and tool alone I could not call it; my prior sat at **~50/50**.

I wrote the prediction before looking: if MALICIOUS, it would show an **EID 3 to the external
C2**; if BENIGN, its connections would be **internal-only**, like the genuine Northmoor stages.
What actually settled it was a single artefact — one EID 3 at **2026-09-18T13:00:01** from that
ProcessGuid to **198.51.100.47:443**, the same C2 as the main chain. That one connection broke
the "legitimate deployment" cover. Verdict: **MALICIOUS**. The tool never settled it; where it
talked did.

## What I cleared

The administrative chain that sat in the tree "looking guilty" the whole time is **benign**,
and I am clearing it explicitly rather than leaving it for someone to re-check. It is the
**Northmoor Deploy Agent** chain: `nmdeploy-agent.exe` (instances pkg_7702/7711/7708) →
`powershell.exe` under the service account `PORTWAY\svc_nmdeploy`, running the signed Northmoor
stage `pkg_7708.ps1`. Two factors clear it — and neither is the interpreter:

- **Provenance:** a signed Northmoor service binary under
  `C:\Program Files\Northmoor\DeployAgent\` launched it (not a user-opened Downloads `.js`),
  running as a service account at High integrity with a signed manifest. It never dropped to
  `AppData\Roaming` and never wrote a Run key.
- **Network:** its EID 3 connections are internal-only, to Portway hosts on `10.42.8.0/24`; it
  never touched `198.51.100.47` or any external address.

Falsifiable test for anyone who disagrees: pull these ProcessGuids' EID 1 parents and EID 3
destinations — signed `nmdeploy-agent.exe` parent and internal-only destinations mean benign.
The one change that would have flipped this call: a single EID 3 from this chain to the external
C2 — exactly what separated the benign stages from pkg_7714.

## Containment — three actions

**1. Sinkhole the C2 egress to `198.51.100.47:443` at the perimeter.** Stops: live tasking and
any exfil over the beacon. Business cost: effectively none (destination is malicious). Visibility
cost: low if sinkholed rather than null-routed — redirecting to an internal collector keeps the
beacon attempts visible while ending real reach, so I lose the *content* of tasking but keep the
*signal*.

**2. Network-isolate PORTWAY-WS-114 via the agent/EDR (management traffic only).** Stops: any
lateral movement or secondary C2 path from this host. Business cost: `sdumont`'s workstation goes
offline — one person's work stops tonight. Visibility cost: host telemetry still flows to Wazuh,
but the attacker may read the connectivity loss as "we've been seen."

**3. Preserve, then remove persistence.** Capture a memory image and the on-disk `iblenor.exe`
(verify SHA-256 `d13e0265…c6b2`) **first**, then delete
`HKCU\…\Run\Tavistock9` and quarantine the binary. Stops: re-execution at next logon. Business
cost: minimal. Visibility cost: this is the loudest host action, so it runs only after capture —
removing persistence before imaging would destroy evidence and still tip the attacker.

**The fourth, and why it lost: kill `iblenor.exe` on the spot.** With a fourth slot I'd have
terminated the running implant immediately. It loses because, once the host is isolated (#2) and
the C2 sinkholed (#1), the live process is already severed — killing it adds almost nothing, yet
it is the single clearest "we are here" signal to the operator, and on its own it does not remove
persistence (the Run key simply relaunches at logon). Highest tip-off, lowest marginal value —
cut.

## Cut now or watch

**Cut now.** The scope is understood: one workstation, one user context, a known payload by
hash, known persistence, and one external C2. Watching buys intelligence on a commodity 60-second
beacon I can largely characterise already, while every minute of watching is a minute of live
exposure on a production host. The sinkhole in action #1 is what makes "cut now" defensible
without being blind — I end the real exposure immediately but still log beacon attempts, so I am
not trading all visibility for safety. I accept the one real loss: I will not see what fresh
tasking the operator would have sent, and if they have a second foothold elsewhere, cutting here
may push them to go quiet. That risk is better handled by scoping the rest of the estate for the
same IOCs (`iblenor.exe` hash, `Tavistock9`, destination `198.51.100.47`) than by leaving a known
implant beaconing out of a live host. Watching would be defensible only if I had reason to believe
this host were one of many and the beacon were my only thread to the others — here it is not.
