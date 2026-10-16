Task 0 — What an Agent Sees 

EDR evolution — AV → EPP → EDR → XDR:

Antivirus (AV): matches files against signatures of known malware. Blind to novel or fileless threats — if it hasn’t seen the signature, it misses it.
Endpoint Protection Platform (EPP): prevention-focused. AV plus host firewall, device control, and some behavioural blocking. Still fundamentally “stop known-bad before it runs.”
Endpoint Detection and Response (EDR): continuously records endpoint activity so you can detect, investigate, and respond after execution. Built on the assumption that prevention will sometimes fail, so you need the evidence to reconstruct what happened.
Extended Detection and Response (XDR): folds endpoint telemetry together with network and identity (and more) into one correlated view, so an actor is tracked across layers instead of one host at a time.

The four telemetry streams and what each answers:

Stream	Sysmon EID	What it’s good for
Process	1	What ran — parent/child lineage, command line, hashes. The backbone that answers “who launched what.”
File	11	What was written to disk — dropped payloads, staged files.
Registry	13	Registry value sets — persistence (Run keys), configuration changes.
Network	3	Outbound connections — C2 beacons, exfiltration destinations.

Key idea: no single stream proves an intrusion. Process shows lineage, file shows the dropped payload, registry shows persistence, network shows the C2 — you confirm a chain only by correlating across all four
