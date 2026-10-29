# Forensic Report — ASHFORD-PARA-05

**Prepared for:** Ashford and Crane LLP
**Prepared by:** Kestrel Defense DFIR
**Incident:** KD-FF81C69
**Subject host:** ASHFORD-PARA-05 (paralegal workstation, privileged client matters)
**Evidence:** two images under custody — physical memory and system-volume disk

---

## 1. Custody and method

Kestrel received two images of ASHFORD-PARA-05, acquired on 2026-09-23 by responder IR-Kestrel5 and transferred under seal KD-FF81C69 on 2026-09-24. The chain-of-custody record documents the acquisition in a specific order: physical memory first (08:00 UTC, winpmem, host live), then the system volume (08:47 UTC, hardware write blocker and `dd` with verified read-back), then power-off (09:07 UTC).

Before any analysis, both images were verified against the custody record. The recorded SHA-256 values were recomputed from the mounted evidence and matched exactly:

- memory image (`/evidence/memory.raw`): `bd7a7284aad50ed6e1e5e847d023b4711d448d9cc9b7dd45cf1569d464d83042`
- disk image (`/evidence/disk.img`): `9ca5f5f45bb0aa409b0a4790de4b44729dbdf7b2cbac8daeceb11346f58c926d`

Both figures agree with `CUSTODY.txt` and `hashes.txt`, establishing that the evidence has not changed between acquisition and analysis. The evidence was mounted read-only throughout; no write to it is possible.

The acquisition order is not a formality — it is the reason this case can be answered. Memory, network connections and injected, non-persisted code do not survive power-off. Because memory was captured before the plug was pulled, the central artefact of this intrusion — an implant that never existed as a file on disk — was available for analysis. Had the responder powered the machine off first, the disk alone would have shown a dropper with no explanation and the live channel would have been gone.

Examination used Volatility 3 (2.28.2) against the memory image, with the kernel symbol pack resolving fully offline, and The Sleuth Kit against the NTFS system volume, including `$STANDARD_INFORMATION` / `$FILE_NAME` timestamp inspection. These tools fit the question: the memory image answers what was running and talking at capture; the disk answers what was created, executed and gathered, and whether any record was altered.

## 2. Findings

Every finding below carries a proof tier: **proven** (a direct artefact establishes it beyond dispute), **supported** (corroborated inference, strong but not certain), or **inferred** (consistent with the evidence but not established).

**F1 — Executable code was present in a process's private, unbacked memory. (proven)**
The direct artefact is a `PAGE_EXECUTE_READWRITE` private memory region (base `0x2068f4b0000`) inside `powershell.exe`, PID 1676, that is backed by no file on disk and contains executable bytes (`fc 48 83 e4 f0 e8 …`), recovered by `windows.malfind`. A private, executable, unbacked region in a process is injected code by definition — the proven claim is the region itself, not an interpretation of it. Corroboration (not part of the proven claim): `windows.psscan` recovers a terminated `benign_loader.exe` (PID 2596) consistent with having created it, which `windows.pslist` cannot see. This is the artefact a disk image could never have produced.

**F2 — A command-and-control channel was live at the moment of capture. (proven)**
`windows.netscan` recorded a TCP connection to `198.51.100.47:443` in state `ESTABLISHED`, owned by PID 1676 — the same process carrying the injected region. The connection is a direct memory artefact of a live channel at capture.

**F3 — The C2 destination matches an indicator seen at two prior engagements. (supported)**
The bounded, checkable fact is only this: the destination recovered in F2 (`198.51.100.47`) is the same address recorded at two earlier Kestrel engagements at other clients. That match is direct. The step from a matching indicator to "the same actor" is an inference, not a signature identification, so the finding is tiered **supported** rather than proven, and no named actor is asserted here.

**F4 — Privileged client documents were accessed and gathered on the host. (proven)**
`fls` enumerated a staging directory, `C:\Users\mfarleu\AppData\Local\Temp\cnv_2m8k\` (MFT entries 83–93), containing nine privileged matter documents — identifiers AC_2023_0904, AC_2023_1122, AC_2024_0208, AC_2024_0342, AC_2024_0417, AC_2024_0555, AC_2024_0631, AC_2024_0688, AC_2024_0771 — and an archive built from them, `cnv_2m8k.7z`. Access is corroborated by `$MFT` access times on the source matters. The documents are referenced by identifier only; no content is reproduced.

**F5 — The intrusion began on 2026-09-19 08:00:00 UTC. (proven)**
This is established by direct artefacts, not by reasoning over the tampered value. The dropper's `$FILE_NAME` creation time — written by NTFS at record creation and not reachable through the Windows timestamp API — records 2026-09-19 08:00:00 UTC; it is a direct filesystem artefact. The stomped `$SI` value (2019) is the disproved one and is not relied on for this date. The start time is independently corroborated by two further direct artefacts: the prefetch file `SPOOLSVD.EXE-5961B8FD.pf`, which Windows writes only on actual execution, and the dropper's MFT entry (66), which sits in the same recently-allocated range as the 2026 staging files (entries 84–93). The proven tier rests on these artefacts; the tampered `$SI` is evidence of forgery (see §3), not the basis of this finding.

## 3. The tampering

One artefact on this machine was deliberately falsified, and catching it is worth more to the firm than any single recovered value, because it tells them the actor expected an investigation and shaped the evidence against it.

The dropper is `C:\ProgramData\ConfigBroker\spoolsvd.exe` (MFT entry 66). Its name imitates the legitimate Windows print spooler (`spoolsv.exe`) under a fabricated `ConfigBroker` directory. Its file-system timestamps disagree with themselves in a way that is physically impossible without intervention:

- `$STANDARD_INFORMATION` created: **2019-03-14 04:12:07 UTC**
- `$FILE_NAME` created: **2026-09-19 08:00:00 UTC**

The `$SI` creation time precedes the `$FN` creation time. `$FN` is written by NTFS when the record is created and is not reachable through the ordinary Windows timestamp API; `$SI` is trivially settable by any process. A file cannot have been created in 2019 after its own record was created in 2026. The `$SI` value was back-dated; the `$FN` value was not. The proof is the *disagreement between the pair*, not either value alone — a submission that reported only the forged 2019 value would be reporting the actor's lie as a finding.

Had the record been trusted, it would have said the dropper was a years-old file predating the engagement — out of scope, unrelated — and every event ordered after it would have been mis-sequenced. The corrected creation time, **2026-09-19 08:00:00 UTC**, is the true intrusion start.

The tamper is corroborated by two independent, un-fakeable sources. First, MFT-entry adjacency: the dropper sits at entry 66, in the same recently-allocated range as the 2026 staging files at entries 84–93; a genuine 2019 file cannot occupy the same fresh MFT range as files created in 2026. Second, the prefetch artefact `SPOOLSVD.EXE-5961B8FD.pf` confirms the binary actually executed, which Windows records only on real execution.

## 4. Conclusion

The firm's question is narrow: was privileged client data accessed or taken, and can it be proven — specifically, can staging be told from exfiltration.

What the evidence proves: privileged client documents (nine matters, by identifier) were **accessed**, **collected** into a single directory, and **archived** on ASHFORD-PARA-05; an injected implant was **resident** in memory at capture; and a command-and-control channel to `198.51.100.47:443` was **live** at capture. The intrusion began on **2026-09-19**, once the forged timestamp is corrected.

What the evidence does **not** establish is that any of that data left the network. This is the honest boundary, and it is narrower than the headline the firm may be braced for. A command channel existing proves capability, not transfer. Data gathered and archived beside that channel proves staging, not sending — and the archive was not deleted, which is consistent with material prepared but not shown to leave. Three facts are proven; none of them is the movement of bytes.

To establish exfiltration, the evidence would have needed a record that was never collected: a perimeter egress record with byte counts (proxy, firewall or NetFlow), or a completed-transfer artefact on the host (a BITS transfer job, an upload log, a sent-bytes record). ASHFORD-PARA-05 is a workstation, and no such record exists in either image. Exfiltration is therefore **declined** — not as supported, not as inferred, but as outside what this evidence can carry.

The disclosure sentence the firm can rely on: *"Privileged client documents were accessed and gathered into an archive on the workstation, and an active command channel was present; the available evidence does not establish that any of that data was transmitted off the network."*

## 5. Scope — interesting, but set aside

The following were observed and are genuinely interesting, but do not answer the firm's question, and are named here as such rather than folded into the conclusion.

- A `WerFault.exe` (PID 1396) shows the implant process crashed roughly at capture time. This explains why PID 1676 was faulting but does not change what was accessed or whether it left; it is context, not a finding.
- Two benign-looking filesystem oddities (`appconfig.bak`, and a restore-related file) have unusual timestamps but show **no** `$SI`-before-`$FN` impossibility and resolve innocently. They are not the tamper; noting them is what lets us state that the dropper is the *only* genuine tamper.
- `System.evtx` and `Security.evtx` are present on disk, but the workstation's analyst toolset cannot parse them, so no claim is drawn from event-log content. Where a log-based corroboration cannot be made, none is asserted.

Padding a conclusion with adjacent findings invites an opposing expert to ask which of the central findings are padding too. They are listed here, and set aside, deliberately.
