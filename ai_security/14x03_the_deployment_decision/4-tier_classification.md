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

**The threshold.** Annex III makes an AI system high-risk only if it falls within a listed use-case. The one adjacent to Assist is **point 5(b): AI systems intended to be used to evaluate the creditworthiness of natural persons or establish their credit score**, and point 5 more broadly, systems used to decide eligibility for **essential private services**. The legal test is whether the system *evaluates or decides* a person's access to such a service.

**Assist against that threshold.** Assist does not meet it:

- It performs no creditworthiness evaluation and produces no credit score. It reads existing invoice and payment-method data and explains charges — a lookup-and-explain function, not an assessment of a person's financial standing.
- Its one consequential action, `issue_refund`, is **not an autonomous decision with legal or similarly significant effect**: every call is gated by named human approval (`01` §5 `human_required_all_amounts`; `05` every refund carries `approval.approver`, e.g. `evt_000275` denied). Annex III point 5(b) targets the system *making or materially driving* the decision; here a human makes it, so the system sits below the threshold.
- No other Annex III head (biometrics, employment, education, essential public services, law enforcement, migration, justice) matches a billing-support assistant.

So Assist is below the Annex III threshold. (If a future version let the agent *decide* credit eligibility, refunds, or essential-service access without human approval, it would cross into point 5(b) — the line the business must not cross silently.)

### Defence against the tier below (minimal-risk, no obligation)

**The threshold.** The minimal-risk tier is the residual category for AI systems that trigger *no* specific AI-Act obligation. The relevant boundary here is **Article 50(1): providers must ensure that AI systems intended to interact directly with natural persons inform those persons that they are interacting with an AI**. The legal test is whether the system is *intended to interact directly with natural persons*.

**Assist against that threshold.** Assist meets it, so it is **not** minimal-risk:

- It is a customer-facing conversational agent: signed-in customers converse with it directly about their billing (`01` §1 — Assist is the customer-support agent extended to billing Q&A). That is exactly the "intended to interact directly with natural persons" trigger in Article 50(1).
- The transparency duty is therefore engaged, and the dossier shows it is unmet (`01` §7 F6 unfunded; no disclosure event in `05`).

So Assist is above the minimal-risk floor (Article 50 applies) and below the Annex III ceiling (point 5(b) does not), which places it squarely in the **limited-risk / transparency-obligation** tier.

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

- **Instrument:** EU AI Act, Regulation (EU) 2024/1689 — risk-tier structure (Annex III point 5(b)), Article 50 transparency, Article 5 prohibitions, Article 4 literacy. Source: EUR-Lex `eli/reg/2024/1689/oj`.
- **Amendment:** Digital Omnibus on AI, Regulation (EU) 2026/1744 — published OJ 24 July 2026, in force 27 July 2026; postpones Annex III high-risk to 2 December 2027 and Annex I to 2 August 2028; leaves Article 50 transparency unchanged (applicable since 2 August 2026, with the 2 December 2026 grace period for content marking). Source: European Commission, "AI Omnibus enters into force", digital-strategy.ec.europa.eu.
- **Verification date:** 2026-11-01. These dates move; this classification states the position as of that date and should be re-verified before the recommendation is finalised.
