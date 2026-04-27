# Quantitative Risk Analysis: MedDefense Health Systems

## SCENARIO 1: Ransomware Attack on Billing Server

* **Asset Value (AV): $473,000**
    * *Reasoning:* In cyber risk, the AV of a business process is the total cost of a worst-case disruption. 
        * Lost Revenue: 18 days downtime * $16,000/day = $288,000
        * Recovery Cost: $85,000
        * HIPAA Penalty (Mid-range): $100,000
        * *Total:* $288,000 + $85,000 + $100,000 = $473,000
* **Exposure Factor (EF): 100% (1.0)**
    * *Reasoning:* A successful ransomware encryption event results in the full realization of the downtime and recovery costs calculated in the AV.
* **Single Loss Expectancy (SLE): $473,000**
    * *Calculation:* $473,000 (AV) × 1.0 (EF)
* **Annualized Rate of Occurrence (ARO): 0.33**
    * *Reasoning:* Sector data indicates 1 attack every 3-4 years. Using 1 in 3 years (1/3 = 0.33) provides a conservative estimate for a high-risk hospital.
* **Annualized Loss Expectancy (ALE): $156,090**
    * *Calculation:* $473,000 (SLE) × 0.33 (ARO)
* **Confidence Level:** Medium
    * *Assumption that changes the number:* The 18-day average downtime is the biggest variable. If MedDefense establishes immutable backups (CIS Control 11) and reduces downtime to 3 days, the lost revenue drops from $288k to $48k, drastically lowering the ALE.

---

## SCENARIO 2: Patient Data Breach via EHR System

* **Asset Value (AV): $9,075,000**
    * *Reasoning:* The asset value is the aggregate cost of a total data compromise.
        * Breached Records: 50,000 records * $165/record = $8,250,000
        * HIPAA Notification: $25,000
        * Litigation Exposure: $200,000
        * Reputational/Revenue Loss: $600,000
        * *Total:* $9,075,000
* **Exposure Factor (EF): 100% (1.0)**
    * *Reasoning:* In a full database exfiltration scenario, 100% of the patient records are compromised, triggering the full Ponemon cost metric.
* **Single Loss Expectancy (SLE): $9,075,000**
    * *Calculation:* $9,075,000 (AV) × 1.0 (EF)
* **Annualized Rate of Occurrence (ARO): 0.33**
    * *Reasoning:* 1 breach in 3 years, given the lack of SIEM, flat network, and unpatched systems heavily documented in 1x01 and 1x02.
* **Annualized Loss Expectancy (ALE): $2,994,750**
    * *Calculation:* $9,075,000 (SLE) × 0.33 (ARO)
* **Confidence Level:** High
    * *Assumption that changes the number:* The Ponemon $165/record cost drives 90% of this figure. If MedDefense's actual patient demographic results in lower litigation/attrition costs than the industry average, this ALE could be inflated. However, for budgeting purposes, relying on standard sector metrics is safest.

---

## SCENARIO 3: Insider Data Theft (Negligent)

* **Asset Value (AV): $120,000**
    * *Reasoning:* The total aggregate cost of investigation ($30k) + containment ($25k) + remediation ($40k) + reporting ($25k) per incident.
* **Exposure Factor (EF): 100% (1.0)**
    * *Reasoning:* A negligent insider incident results in the full realization of these baseline response costs.
* **Single Loss Expectancy (SLE): $120,000**
    * *Calculation:* $120,000 (AV) × 1.0 (EF)
* **Annualized Rate of Occurrence (ARO): 2.5**
    * *Reasoning:* With 2,000 staff, shared accounts, and zero DLP/USB controls, estimating 2 to 3 incidents per year is highly realistic. The average is 2.5.
* **Annualized Loss Expectancy (ALE): $300,000**
    * *Calculation:* $120,000 (SLE) × 2.5 (ARO)
* **Confidence Level:** High
    * *Assumption that changes the number:* This assumes the current total lack of technical controls (no DLP, no USB restrictions). Implementing basic endpoint security would immediately drop the ARO to < 1.

---

## SCENARIO 4: Medical Device Compromise

*This scenario is split into two impact vectors: Operational (DoS) and Safety.*

**Vector A: Denial of Service (Device Quarantine)**
* **SLE:** $100,000 (5 days of operational disruption @ $20k/day)
* **ARO:** 0.1 (1 in 10 years)
* **ALE (DoS):** $10,000

**Vector B: Patient Safety Incident**
* **SLE:** $2,900,000 (Avg Liability of $2.75M + FDA Investigation $150k)
* **ARO:** 0.02 (1 in 50 years)
* **ALE (Safety):** $58,000

* **Combined Annualized Loss Expectancy (ALE): $68,000**
* **Confidence Level:** Low
    * *Assumption that changes the number:* Patient safety liability is extremely volatile. A wrongful death lawsuit resulting from an altered infusion pump could easily exceed the $5M maximum estimate, causing the SLE (and resulting ALE) to spike unpredictably.

---

## SCENARIO 5: VPN Compromise Leading to Full Network Access

* **Asset Value (AV): $9,548,000**
    * *Reasoning:* The FortiGate VPN is the single point of failure (gateway). A total compromise allows an attacker to execute Kill Chain #1 (Ransomware) AND Kill Chain #2 (Data Exfiltration). Therefore, the AV is the aggregate of Scenario 1 ($473,000) + Scenario 2 ($9,075,000).
* **Exposure Factor (EF): 100% (1.0)**
    * *Reasoning:* Because the network is completely flat (10.10.0.0/16), a VPN breach guarantees full access to all subnets, maximizing exposure.
* **Single Loss Expectancy (SLE): $9,548,000**
    * *Calculation:* $9,548,000 (AV) × 1.0 (EF)
* **Annualized Rate of Occurrence (ARO): 0.3**
    * *Reasoning:* VPNs are the #1 entry vector for healthcare ransomware. Given the history of FortiOS CVEs and unknown patching cadence, 1 attack every ~3 years is a realistic probability.
* **Annualized Loss Expectancy (ALE): $2,864,400**
    * *Calculation:* $9,548,000 (SLE) × 0.3 (ARO)
* **Confidence Level:** Medium
    * *Assumption that changes the number:* This assumes a worst-case scenario where the attacker achieves *both* total data exfiltration and total ransomware encryption. If MedDefense implements network segmentation (CIS Control 12), the blast radius of a VPN compromise shrinks drastically, lowering the EF from 100% to a fraction of the network.
