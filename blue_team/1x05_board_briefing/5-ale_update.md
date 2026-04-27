# ALE Update: Recalculating Risk via Threat Intelligence

## Part 1 - Original vs. Updated ALE

### Original Ransomware ALE (from 1x03 T6)
* **Asset Value (AV):** $1,500,000 (Critical systems and patient data)
* **Exposure Factor (EF):** 0.8 (80% impact due to business interruption)
* **Single Loss Expectancy (SLE):** $1,200,000
* **Annual Rate of Occurrence (ARO):** 0.25 (1 attack every 4 years)
* **Original ALE:** **$300,000**

### Updated Ransomware ALE (Post-Advisory)
* **Asset Value (AV):** $1,500,000
* **Exposure Factor (EF):** 1.0 (Crimson Tide’s confirmed data exfiltration and double extortion model ensures total loss of confidentiality and availability)
* **Updated SLE:** **$1,500,000**
* **Updated ARO:** **2.0**
    * *Logic:* The advisory confirms 5 attacks in 10 days on hospitals of our exact size, with 3 in our immediate region. This indicates an extremely high immediate likelihood. Even conservatively, the probability of an attack within the year has shifted from "possible" to "multiple times per year" for the sector.
* **Updated ALE:** $1,500,000 × 2.0 = **$3,000,000**

**What changed and why?**
The **ARO** skyrocketed because the "Crimson Tide" campaign is a targeted, active cluster of activity specifically hitting our demographic and region right now. The **SLE** increased to 1.0 because the advisory confirms that exfiltration precedes encryption, making the financial impact of a breach (HIPAA fines, lawsuits) certain even if systems are restored.

---

## Part 2 - Budget Impact

### Control Justification Shift
The ten-fold increase in ALE ($300k to $3M) fundamentally changes the cost-benefit analysis for several controls previously deemed too expensive:
* **SIEM/SOC Monitoring:** Previously rejected due to high annual cost ($80k+). With a $3M risk, the ROI for detection is now clearly positive.
* **Data Loss Prevention (DLP):** Now justified as it is the only way to mitigate the Phase 4 exfiltration that leads to the increased SLE.

### FortiGate Support Contract ROI
* **Cost:** $2,400 (One-time emergency fee)
* **Risk Reduction:** Eliminates Phase 1 (Initial Access) for the current campaign.
* **ROI Calculation:** $(3,000,000 - 2,400) / 2,400 = 124,900\%$
* **Conclusion:** The ROI is **massive**. Spending $2,400 to mitigate a $3M risk is the most cost-effective decision in the current security strategy.

### Emergency Spending Recommendation
The Board should **approve emergency spending beyond the $120,000 budget.**
The original budget was built on a $300,000 annual risk profile. We are currently facing a $3,000,000 localized threat. Failing to spend an additional $10k-$20k tonight on patching, EDR trials, and backup isolation is equivalent to accepting a multi-million dollar loss that has a statistically high probability of occurring within the next 7 days.
