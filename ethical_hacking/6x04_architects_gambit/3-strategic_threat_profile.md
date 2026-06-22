# Strategic Threat Profile, Nordstrøm Power Group

## Framework Choice and Rationale

This profile uses a MITRE ATT&CK and ATT&CK for ICS hybrid, structured through a PASTA-informed asset-threat mapping layer. MITRE ATT&CK covers the IT and corporate surfaces common across all five subsidiaries; ATT&CK for ICS addresses the operational technology exposure in Norway and the Netherlands where industrial control systems are material to business continuity. PASTA provides the risk-prioritisation logic that connects threat actors to business impact — essential for a group where board-grade output, not technical completeness, defines the engagement's success. A generic kill-chain model alone would flatten the IT/OT boundary and ignore the jurisdictional variance that makes Nordstrøm architecturally complex.

---

## Group-Level Profile

Nordstrøm Power Group operates across five national energy markets with essential-entity and important-entity classifications that vary by country, sector, and subsidiary size. At group level, the primary threat drivers are three: geopolitical exposure as a Scandinavian energy holding with offshore gas assets in a NATO-adjacent threat environment; IT/OT convergence risk as operational technology in Norway and the Netherlands is increasingly connected to corporate IT and cloud platforms; and integration risk concentrated in the German subsidiary, where an incomplete acquisition creates a transitional attack surface with unverified tooling, inconsistent access controls, and an open prior-audit gap.

The group's 3.8 billion EUR revenue and 4,200-employee footprint make it a high-value ransomware target. Its cross-border data flows and multi-jurisdictional NIS2 obligations create regulatory exposure if an incident triggers notification requirements in more than one country simultaneously. The 90-day board deadline and the competitor incident 18 months ago elevate reputational risk as a secondary driver.

---

## Subsidiary Sub-Profiles

### Norway — Offshore Gas

| Threat Actor | Asset Exposure | Technique Relevance | Severity | Regulatory Dimension |
|---|---|---|---|---|
| State-linked actors (Russia-nexus) | Offshore SCADA, wellhead control systems, corporate IT | T0800 Activate Firmware Update Mode, T0816 Device Restart/Shutdown, spearphishing of OT-adjacent engineers | Critical | Norwegian Security Act (sikkerhetsloven), NIS2 essential-entity equivalent; PST threat advisories apply |
| Ransomware groups (e.g. BlackCat-successors) | Corporate IT, VPN gateways, ERP systems | Initial access via phishing, lateral movement, data exfiltration before encryption | High | Mandatory incident notification to NSM within 72 hours |
| Insider threat | Physical and remote access to wellhead systems | Privilege abuse, credential sharing, sabotage of safety instrumented systems | High | Norwegian Petroleum Safety Authority oversight; safety-system compromise triggers dual regulatory response |

**Architectural note:** OT network segmentation and IT/OT boundary definition must be confirmed before scoping. Methodology requires ATT&CK for ICS overlay. Phase priority: high.

---

### Sweden — Hydro and Wind

| Threat Actor | Asset Exposure | Technique Relevance | Severity | Regulatory Dimension |
|---|---|---|---|---|
| Hacktivist groups (climate-motivated) | Wind farm SCADA, public-facing web assets, grid interconnects | DDoS, web defacement, opportunistic OT probing | Medium | Swedish NIS2 transposition (NIS2-lagen); NCSC-SE oversight |
| State-linked actors | Hydro dam control systems, generation forecasting platforms | T0831 Manipulation of Control, supply-chain compromise of industrial software vendors | High | Hydropower assets classified as critical infrastructure under Swedish Civil Contingencies Agency (MSB) framework |
| Ransomware groups | Corporate IT, SCADA historian servers | Phishing, RDP exploitation, double extortion | High | 72-hour notification to NCSC-SE; MSB may require parallel reporting |

**Architectural note:** Hydro assets carry physical safety implications. Severity elevates where generation disruption affects grid stability. Scope should explicitly address SCADA historian segregation.

---

### Denmark — Offshore Wind and Trading

| Threat Actor | Asset Exposure | Technique Relevance | Severity | Regulatory Dimension |
|---|---|---|---|---|
| State-linked actors | Energy trading platforms, market data feeds, offshore wind SCADA | T0814 Denial of Control, market manipulation via data integrity attacks | Critical | Danish NIS2 transposition; CFCS (Centre for Cyber Security) threat level for energy sector currently elevated |
| Financially motivated actors | Trading platform APIs, settlement systems | API abuse, credential stuffing, insider-assisted fraud | High | DFSA oversight for trading activity; NIS2 notification obligations separate from financial regulation |
| Supply-chain actors | Offshore wind turbine firmware, remote maintenance vendors | Compromise of vendor access paths, malicious firmware updates | High | Danish Energy Agency critical infrastructure designation |

**Architectural note:** Trading platform exposure combines cyber and financial risk. Scope architecture must decide whether trading systems fall under IT assessment or require a specialist financial-system review track.

---

### Netherlands — Gas and Hydrogen Infrastructure

| Threat Actor | Asset Exposure | Technique Relevance | Severity | Regulatory Dimension |
|---|---|---|---|---|
| State-linked actors (Russia-nexus, China-nexus) | Gas pipeline control systems, hydrogen electrolysis platforms, compressor station SCADA | T0806 Brute Force I/O, T0828 Loss of Safety, lateral movement from IT to OT via engineering workstations | Critical | Dutch NIS2 transposition (Cyberbeveiligingswet); NCTV oversight; hydrogen infrastructure under emerging EU hydrogen regulation |
| Ransomware groups | Corporate IT, remote access infrastructure, historian servers | Phishing, VPN exploitation, OT-adjacent encryption | High | NCSC-NL 72-hour notification; cross-border gas disruption may trigger EU Crisis Mechanism |
| Insider threat | Physical access to compressor stations, remote maintenance accounts | Sabotage, credential exfiltration, deliberate misconfiguration | High | NCTV may classify deliberate sabotage as national security incident |

**Architectural note:** Hydrogen infrastructure is newer and less security-mature than gas assets. Scope must differentiate legacy pipeline OT from hydrogen platform IT/OT hybrid environments. Cross-border gas disruption potential elevates this subsidiary to group-level priority.

---

### Germany — Utility-Scale Solar (Integration in Progress)

| Threat Actor | Asset Exposure | Technique Relevance | Severity | Regulatory Dimension |
|---|---|---|---|---|
| State-linked actors | Inherited IT environment (pre-acquisition tooling), solar inverter management platforms, cloud integration surfaces | T0862 Supply Chain Compromise, initial access via unpatched legacy systems, cloud misconfiguration exploitation | Critical | German NIS2 transposition (NIS2UmsuCG); BSI oversight; acquisition does not transfer regulatory compliance status automatically |
| Ransomware groups | Fragmented IT estate, unverified endpoint controls, incomplete IAM integration | Phishing of newly onboarded staff, exploitation of unpatched systems in integration gap | High | BSI incident reporting mandatory; integration-phase systems may fall outside current security baseline |
| Prior-audit residual risk | Systems reviewed by competitor firm — findings status unknown | Unknown remediation gaps, potential undisclosed vulnerabilities | High | If prior audit findings were not remediated, Nordstrøm Group may inherit material compliance gaps |

**Architectural note:** Germany is the highest-uncertainty subsidiary in the portfolio. Integration is incomplete, the prior competitor audit has not been formally closed, and the tooling baseline is unverified. This subsidiary warrants a standalone scoping decision — it should not be treated as operationally equivalent to the four established entities. Phase architecture recommendation: assess Germany separately with explicit integration-gap methodology before merging findings into the group report.
