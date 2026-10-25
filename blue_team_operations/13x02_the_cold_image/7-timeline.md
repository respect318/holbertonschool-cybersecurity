FLAG_TIMELINE: 2026-09-19 08:00:00 UTC

# ASHFORD-PARA-05 — correlated memory + disk timeline

## Custody header
| Item | Image | Verified sha256 | Acquired (UTC) | Method |
|------|-------|-----------------|----------------|--------|
| 1 | memory.raw (physical memory) | bd7a7284aad50ed6e1e5e847d023b4711d448d9cc9b7dd45cf1569d464d83042 | 2026-09-23 08:00 | winpmem, live |
| 2 | disk.img (system volume) | 9ca5f5f45bb0aa409b0a4790de4b44729dbdf7b2cbac8daeceb11346f58c926d | 2026-09-23 08:47 | write blocker + dd |

Power-off: 2026-09-23 09:07 UTC. Order: memory -> disk -> power-off. Both hashes recomputed and match CUSTODY.txt / hashes.txt.

## Timeline (one row = one event, one artefact)
| Time (UTC) | Event | Single artefact | Source | Tier | Why the artefact supports exactly this tier (and its limit) |
|------------|-------|-----------------|--------|------|-------------------------------------------------------------|
| 2026-09-19 08:00:00 | Dropper created on disk | spoolsvd.exe $FILE_NAME Created, MFT entry 66 | disk | proven | $FN is set by NTFS at record creation and cannot be altered through the Windows timestamp API, so it fixes creation time directly; limit — it dates the record's creation, not who placed it |
| 2026-09-19 08:00:00 | Dropper executed at least once | Prefetch SPOOLSVD.EXE-5961B8FD.pf, MFT entry 101 | disk | proven | Windows writes a prefetch file only after a binary actually runs, so the file's existence proves execution; limit — proves "ran", not what it did |
| 2026-09-23 | Collected documents archived | cnv_2m8k.7z $FILE_NAME Created, MFT entry 93 | disk | proven | the archive's own $FN fixes when the container was created in the intrusion window; limit — proves the archive was built, not that it was sent |
| 2026-09-23 08:00 | Injected code resident in a process | windows.malfind RWX VadS region 0x2068f4b0000 in powershell.exe PID 1676 | memory | proven | an unbacked PAGE_EXECUTE_READWRITE private region in a named process is a direct artefact of injection; limit — proves injected code present at capture, not its full function |
| 2026-09-23 08:00 | C2 connection open | windows.netscan 198.51.100.47:443 ESTABLISHED, owning PID 1676 | memory | proven | an ESTABLISHED entry with an owning PID directly records a live socket at capture; limit — proves a channel existed, not that data crossed it |

## Correlation (one claim)
One event ties the two images: the disk's dropper ($FN 2026-09-19, entry 66) and the memory's PID-1676 implant + its ESTABLISHED C2 are the same intrusion — the 09-19 drop is the payload still resident and connected at capture. Disk gives the origin; memory gives the running implant the disk cannot hold. The order uses the Task-6 $FN correction, not the disproved $SI (2019).
