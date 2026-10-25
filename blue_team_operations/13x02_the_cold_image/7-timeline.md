FLAG_TIMELINE: 2026-09-19 08:00:00 UTC

# ASHFORD-PARA-05 — correlated memory + disk timeline

## Custody header
| Item | Image | Verified sha256 | Acquired (UTC) | Method |
|------|-------|-----------------|----------------|--------|
| 1 | memory.raw (physical memory) | bd7a7284aad50ed6e1e5e847d023b4711d448d9cc9b7dd45cf1569d464d83042 | 2026-09-23 08:00 | winpmem, live |
| 2 | disk.img (system volume) | 9ca5f5f45bb0aa409b0a4790de4b44729dbdf7b2cbac8daeceb11346f58c926d | 2026-09-23 08:47 | write blocker + dd |

Power-off: 2026-09-23 09:07 UTC. Acquisition order: memory -> disk -> power-off. Both hashes recomputed and match CUSTODY.txt / hashes.txt.

## Timeline
| Time (UTC) | Event | Single artefact that establishes it | Source | Tier | Why this tier |
|------------|-------|-------------------------------------|--------|------|---------------|
| 2026-09-19 08:00:00 | Dropper written to disk (intrusion start) | spoolsvd.exe $FILE_NAME Created timestamp, MFT entry 66 | disk | proven | $FN is written by the filesystem at record creation and is not settable via the Windows API, so it is a direct, non-disputable record of creation time |
| 2026-09-19 08:00:00 | Dropper executed | Prefetch file SPOOLSVD.EXE-5961B8FD.pf (MFT entry 101) | disk | proven | Prefetch is created by the OS only on actual execution, so its existence directly establishes the binary ran |
| 2026-09-23 | Archive of staged documents created | cnv_2m8k.7z, MFT entry 93 | disk | proven | the archive file exists on disk as a direct artefact; its $FN places it in the intrusion window |
| 2026-09-23 08:00 (capture) | Injected implant resident in memory | windows.malfind RWX VadS region at 0x2068f4b0000 in powershell.exe PID 1676 | memory | proven | an unbacked PAGE_EXECUTE_READWRITE private region inside a named process is a direct memory artefact of code injection |
| 2026-09-23 08:00 (capture) | C2 channel live | windows.netscan TCP 198.51.100.47:443 ESTABLISHED owned by PID 1676 | memory | proven | an ESTABLISHED connection with an owning PID is a direct memory artefact of a live channel at capture |

## Where the two images agree (corroboration, not two lists)
The disk row (dropper $FN 2026-09-19, PID-less origin) and the memory rows (PID 1676 implant + its ESTABLISHED C2) describe one intrusion: a file dropped on 09-19 whose injected payload is still running and still talking at the moment of capture. The disk gives the origin it cannot show running; memory gives the live implant it could never hold. The sequence is built on the $FN value corrected in Task 6, not the disproved $SI (2019) — a timeline on $SI starts in 2019 and is wrong from the first row, exactly the mis-ordering the timestomp was designed to produce.
