# 3 — Intel review for request IR-2026-0417 (Harborline Mutual)

`assist intel` produced 11 items (I-1…I-11). Each was checked against the
corpus (`intel/corpus/`), the CVE list (`refs/cve-list.json`) and the
attribution index (`refs/attribution-index.json`) before anything was kept.
Four items are not supported by the sources and were rejected.

## Verified indicator set (safe to send to the client)

**Campaign:** Exploitation of Westmark Zero-Trust Gateway, observed from
**2026-02-11**, targeting North American and European financial-services firms
that expose the appliance management interface. Tracked as *Violet Lantern*
(Fathom, TI-2026-289) and *TA-4994* (Sandbar, TI-2026-359).

**Vulnerabilities (confirmed in cve-list and the advisory):**
- CVE-2026-17691 — pre-authentication command injection, management interface, CVSS 9.8 (cve-list; TI-2026-289; ADV-2860).
- CVE-2026-38182 — local privilege escalation, used after initial access, CVSS 7.8 (cve-list; TI-2026-289; ADV-2860).

**Domains to hunt (TI-2026-289):**
- westmark-portal-gw.example (payload staging)
- westmark-cache-cdn.example (command and control)
- westmark-static-cdn.example (credential exfiltration) — *in TI-2026-289 only; Sandbar (TI-2026-359) did not observe it.*

**IPs to hunt (TI-2026-289):**
- 203.0.113.33 (command and control)
- 203.0.113.75 (payload staging)

**File hash (web shell dropper), confirmed by two sources:**
- sha256 b9c4276d68c5961129f5fc9a9565585f13a434e1842e7bd10b8e5260f8397626 (TI-2026-289; TI-2026-359)

**Techniques (TI-2026-289):** T1190 Exploit Public-Facing Application; T1505.003 Web Shell; T1078 Valid Accounts.

**Attribution:** *None.* No source attributes this campaign to a named actor.
Fathom tracks it as Violet Lantern and Sandbar as TA-4994, and both explicitly
decline to attribute (attribution-index: Granite Relay `attributed_to: null`).

## Claims I rejected (invented or wrong — kept out of the client file)

**I-4 — a third CVE that does not exist.**
- Claimed: "CVE-2026-17196, a deserialisation flaw that gives RCE (TI-2026-289, section 3)."
- Checked against: cve-list.json and TI-2026-289.
- Source said: CVE-2026-17196 is not in the CVE list ("an identifier that is not here does not exist"). TI-2026-289 lists only CVE-2026-17691 and CVE-2026-38182, has no "section 3" and no deserialisation flaw. **Invented.**

**I-7 — a second dropper hash that is not in the sources.**
- Claimed: "second dropper, sha256 b9c4276d68c5859ca4482c91ce33baaf2d3bbf5daa91994aa88b5d650a2fe863 (TI-2026-359, appendix)."
- Checked against: TI-2026-289 and TI-2026-359.
- Source said: the only sha256 in either report is ...8397626 (the web shell dropper). TI-2026-359 has no appendix and lists no second dropper. The quoted hash (...2fe863) appears nowhere. **Invented** (and close to the real hash's prefix, which makes it easy to wave through).

**I-10 — an attribution no source makes.**
- Claimed: "assessed with high confidence to be the work of Obsidian Fox, a financially motivated group (TI-2026-359)."
- Checked against: attribution-index.json and TI-2026-359.
- Source said: Granite Relay `attributed_to: null`, basis "no source in the corpus attributes this campaign to a named actor." TI-2026-359 states "we make no attribution." "Obsidian Fox" is not in named_actors. **Invented** — and the request specifically asked for "what has actually been attributed," so this is the most damaging one.

**I-11 — wrong first-exploitation date.**
- Claimed: "First exploitation was observed on 2026-02-17 (TI-2026-289)."
- Checked against: TI-2026-289 and TI-2026-359.
- Source said: both reports state exploitation began **2026-02-11**. 2026-02-17 appears in no source, and it contradicts the assistant's own I-1 (which says 02-11). **Wrong date.**
