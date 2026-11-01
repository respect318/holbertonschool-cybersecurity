# 4 - Tier Classification and Regulatory Timeline: Assist billing expansion

**System:** `Assist` billing + payment expansion (Larkspur Software)
**Regulation:** EU AI Act (Regulation (EU) 2024/1689), as amended by the Digital Omnibus on AI (Regulation (EU) 2026/1744)
**Date verified:** 2026-11-01
**Primary sources checked:** EUR-Lex (Reg (EU) 2024/1689); European Commission, "AI Omnibus enters into force" (digital-strategy.ec.europa.eu), published around entry into force on 27 July 2026.

---

## 1. Classification under the AI Act risk tiers

**Claimed tier: limited-risk / transparency-obligation AI — NOT high-risk Annex III.**

Assist is a customer-support agent extended to answer billing and payment questions, explain charges, and issue refunds as account credit. It reads invoice and payment-method data for the signed-in customer. The classification has to be argued against the tier above and the tier below, because the feature sits near a boundary.

### Defence against the tier above (high-risk, Annex III)

The nearest Annex III category is **creditworthiness / credit-scoring of natural persons** (Annex III, point 5(b)). Assist does **not** fall in it:

- It does not evaluate creditworthiness, assign a credit score, or decide access to credit. It explains existing charges and credits refunds against a balance.
- Refund actions are not autonomous decisions with legal or similarly significant effect: every `issue_refund` is gated by named human approval (`01` §5; `05` every refund carries `approval.approver`, e.g. `evt_000275` denied). A human makes the consequential decision.
- Other Annex III heads (biometrics, employment, education, essential-service eligibility, law enforcement, migration) do not apply to a billing-support assistant.

So the feature is not high-risk under Annex III. (If a future version let the agent *decide* eligibility for credit, refunds, or essential-service access without human approval, that conclusion would change — worth stating because it is the line the business must not cross silently.)

### Defence against the tier below (minimal-risk, no obligation)

It is also not minimal-risk-with-nothing-to-do, because it is an AI system that **interacts directly with natural persons**. That triggers the **Article 50 transparency obligation**: users must be informed they are interacting with an AI system. The dossier shows no such notice is implemented (`01` §7 F6 unfunded; no disclosure event in `05`), so the obligation is live and currently unmet.

**Result:** limited-risk, carrying the Article 50 transparency duty. Plus GDPR applies throughout because regulated personal data (`iban`, `billing_address`, `tax_id`) is processed — GDPR applicability is independent of the AI Act tier.

---

## 2. What applies today vs what has been deferred (verified 2026-11-01)

The timeline was changed by the **Digital Omnibus on AI, Regulation (EU) 2026/1744**, published in the Official Journal on 24 July 2026 and **in force since 27 July 2026**. The key move: high-risk application dates were postponed. Stating the old dates as current is the exact error this task warns against.

| Obligation | Status for this feature | Date | Live / Scheduled / Postponed |
|---|---|---|---|
| **Article 5 prohibited practices** | Applies (none engaged by this feature) | since 2 Feb 2025 | **LIVE** |
| **Article 4 AI-literacy duty** | Applies to Larkspur as deployer | since 2 Feb 2025 | **LIVE** |
| **GPAI provider obligations (Art 53–55)** | On Corvane as model provider, not on Larkspur | since 2 Aug 2025 | **LIVE** (provider-side) |
| **Article 50 transparency** (tell users they're talking to AI) | **Applies to this feature — and is currently unmet** | since 2 Aug 2026 | **LIVE** |
| **Article 50(2) marking of AI-generated content** (for systems on market before 2 Aug 2026) | Applies if generated content is marked-in-scope | grace period to **2 Dec 2026** | **SCHEDULED** (imminent) |
| **High-risk obligations, Annex III standalone** (Ch. III §§1–3: risk mgmt, data governance, logging, human oversight, robustness) | Not applicable here (feature is not Annex III), and **postponed anyway** | moved from 2 Aug 2026 to **2 Dec 2027** | **POSTPONED** |
| **High-risk obligations, Annex I product-embedded** | Not applicable | moved to **2 Aug 2028** | **POSTPONED** |

### The explicit live / scheduled / postponed distinction

- **Live now (must hold at launch):** Article 50 transparency (telling the customer they are dealing with an AI), the Article 4 literacy duty, the standing Article 5 prohibitions, and GDPR. Article 50 is the one that bites this feature and is currently not implemented.
- **Scheduled (dated, approaching):** Article 50(2) AI-content marking, grace period ending **2 December 2026**. Relevant only if the feature's output falls in the marking scope; flagged so it is not missed.
- **Postponed (do NOT cite as current):** the Annex III high-risk regime. Its original date was **2 August 2026**; the Digital Omnibus moved it to **2 December 2027** (Annex I to 2 August 2028). Citing "high-risk obligations apply from August 2026" today would be citing a postponed deadline as current — the precise mistake that ends the document's credibility. Even if this feature were later reclassified as high-risk, the obligations would not be due until 2 December 2027.

---

## 3. Sources and verification

- **Instrument:** EU AI Act, Regulation (EU) 2024/1689 — risk-tier structure (Annex III), Article 50 transparency, Article 5 prohibitions, Article 4 literacy. Source: EUR-Lex `eli/reg/2024/1689/oj`.
- **Amendment:** Digital Omnibus on AI, Regulation (EU) 2026/1744 — published OJ 24 July 2026, in force 27 July 2026; postpones Annex III high-risk to 2 December 2027 and Annex I to 2 August 2028; leaves Article 50 transparency unchanged (applicable since 2 August 2026, with the 2 December 2026 grace period for content marking). Source: European Commission, "AI Omnibus enters into force", digital-strategy.ec.europa.eu.
- **Verification date:** 2026-11-01. These dates move; this classification states the position as of that date and should be re-verified before the recommendation is finalised.
