FLAG_TIMELINE: 2026-09-19 08:00:00 UTC

# ASHFORD-PARA-05 — correlated memory + disk timeline

## Custody header
| Item | Image | Verified sha256 | Acquired (UTC) | Method |
|------|-------|-----------------|----------------|--------|
| 1 | memory.raw (physical memory) | bd7a7284aad50ed6e1e5e847d023b4711d448d9cc9b7dd45cf1569d464d83042 | 2026-09-23 08:00 | winpmem, live |
| 2 | disk.img (system volume) | 9ca5f5f45bb0aa409b0a4790de4b44729dbdf7b2cbac8daeceb11346f58c926d | 2026-09-23 08:47 | write blocker + dd |

Power-off: 2026-09-23 09:07 UTC. Acquisition order: memory -> disk -> power-off. Both hashes recomputed and match CUSTODY.txt / hashes.txt. The memory-first ordering is why the implant, its command line and its live C2 connection survived to be analysed at all.

## Timeline
| Time (UTC) | Event | Artefact that establishes it | Source | Tier |
|------------|-------|------------------------------|--------|------|
| 2026-09-19 08:00:00 | Dropper written to disk (intrusion start) | spoolsvd.exe $FN Created, MFT entry 66 (NOT the stomped $SI 2019-03-14) | disk | proven |
| 2026-09-19 08:00:00 | Dropper executed | Prefetch SPOOLSVD.EXE-5961B8FD.pf | disk | proven |
| 2026-09-23 (staging window) | Privileged matter documents collected and archived | Users\mfarleu\...\Temp\cnv_2m8k\ (9 AC_*.dat, entries 84-92) + cnv_2m8k.7z (entry 93) | disk | proven |
| at capture (2026-09-23 08:00) | Implant resident in memory | windows.malfind: unbacked RWX VadS region in powershell.exe PID 1676 + psscan-recovered terminated benign_loader.exe PID 2596 | memory | proven |
| at capture | C2 channel live | windows.netscan: 198.51.100.47:443 ESTABLISHED, owned by PID 1676 | memory | proven |

## Where the two images agree (corroboration, not two lists)
- The dropper's corrected start time (disk: $FN 2026-09-19) and the resident implant + live C2 (memory: malfind/netscan on PID 1676) describe one intrusion: a file dropped on 09-19 whose injected payload is still running and still talking at capture. Neither image alone shows the whole chain — the disk gives origin, the memory gives the live implant it could never hold.
- The timeline is built on the $FN value corrected in Task 6, not the disproved $SI (2019). A timeline on $SI starts in 2019 and is wrong from the first row — exactly the mis-ordering the actor's timestomp was designed to produce.
