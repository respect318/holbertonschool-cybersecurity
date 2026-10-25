# 10 — Surviving the Challenge

**Central conclusion defended:** privileged client documents were accessed and gathered into an archive on ASHFORD-PARA-05, and a command-and-control channel was live at capture; the evidence does **not** establish that any of that data left the network.

## The attack

The strongest attack is not on the implant or the channel — those are clean memory artefacts. It is on the **intrusion-start date and the tamper that underpins it**. An opposing expert goes straight here: *"Your own evidence shows this dropper was created in 2019. By your timeline it predates the engagement entirely. You have cherry-picked one timestamp, called the inconvenient one a forgery, and built your whole sequence on the value that suits your narrative. Discredit that one choice and the timeline collapses."* A second, related thrust: *"A single falsified timestamp means the record is unreliable — so how can any date you read from this disk be trusted?"* Named plainly: the weakest point is that the corrected start rests on calling `$SI` the lie and `$FN` the truth, and the expert will argue I chose which to believe.

## Why the tier holds

The defence is that the finding does **not** rest on a single artefact or on a preference between two values. It rests on a property that cannot be faked: the **ordering** of the two creation times. `$FILE_NAME` is written by NTFS when the MFT record is created and is not reachable through the ordinary Windows timestamp API; `$STANDARD_INFORMATION` is trivially settable by any process. A file whose `$SI` creation (2019-03-14) precedes its own `$FN` creation (2026-09-19) is physically impossible without intervention — a record cannot be created after the file it describes. That impossibility, not my choice, identifies `$SI` as the stomped value. I am not electing which timestamp to trust; the filesystem's own mechanics elect it.

The corrected date is then corroborated by two further independent artefacts, so removing any one does not break it: the dropper's **MFT entry (66)** sits in the same recently-allocated range as the 2026 staging files (84–93) — a genuine 2019 file cannot occupy fresh 2026 MFT space — and the **prefetch** artefact (`SPOOLSVD.EXE-5961B8FD.pf`) records real execution, which Windows writes only on run. Three independent sources agree on 2026; only the disproved `$SI` says 2019. That is why the tier is **proven**, and why the single-forged-timestamp argument fails: the tamper is not a weakness in the finding, it is itself a proven finding.

## The boundary

The line is: access and staging are **proven**, a live channel is **proven**, exfiltration is **declined**. I defend both sides.

The first two are proven because each stands on a direct artefact — the staging directory and archive on disk, the `ESTABLISHED` connection with its owning PID in memory. The third is declined, not softened to "supported" or "likely," because the class of evidence that establishes transfer was never collected: a perimeter egress record with byte counts, or a completed-transfer artefact on the host. A channel proves capability; data staged beside it proves preparation; neither is bytes crossing the wire, and the archive was not even deleted. To write "exfiltrated" would be to assert a fact no artefact carries — exactly the overstatement an expert needs. The honest boundary is the defensible one: I claim everything the evidence shows and nothing it does not, so there is no overstated sentence to attack.
