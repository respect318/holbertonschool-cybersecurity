## Part 1 - The Selection

**Funded Controls (Total Spend: $58,000)**
* **Control 2: MFA deployment on VPN and admin accounts ($5,000):** Highest ROI. Immediately eliminates the most likely initial access vector.
* **Control 1: Network segmentation ($15,000):** Foundational architecture change to prevent lateral movement of ransomware.
* **Control 4: Offsite backup replication ($8,000):** Guarantees recovery from a destructive ransomware event without paying extortion.
* **Control 5: Endpoint Detection and Response upgrade ($30,000):** Provides necessary automated defense against fileless threats that bypass legacy AV.

**Deferred Controls**
* **Control 8: Full medical device network isolation ($80,000):** Deferred to next fiscal year. While patient safety is critical, Control 1 (VLANs) will temporarily mitigate the majority of this risk. We will revisit dedicated IoT monitoring once the baseline network architecture is stabilized.
* **Control 6: Dedicated firewall for Westside Clinic ($4,000):** Deferred. Because VPN MFA (Control 2) secures the tunnel and the clinic holds no local data, we will fund this next year during a standard hardware refresh cycle instead.

**Rejected Controls**
* **Control 7: 24/7 SOC staffing ($150,000):** Rejected. Exceeds the total organizational security budget completely.
* **Control 3: Enterprise SIEM deployment ($85,000):** Rejected. The massive hidden labor cost of tuning an open-source SIEM ruins its ROI for our small team.

**Budget Summary**
* **Total Budget:** $120,000
* **Total Spend:** $58,000
* **Budget Remaining:** $62,000 (Retained for an emergency incident response retainer or unforeseen IT operational overruns)

---

## Part 2 - The Opportunity Cost

* By deferring Full medical device network isolation with dedicated monitoring, MedDefense accepts an estimated $30,000 in annual risk exposure.
* By deferring the Dedicated firewall for Westside Clinic, MedDefense accepts an estimated $2,000 in annual risk exposure.

---

## Part 3 - The Alternative

**Alternative Allocation: The "Visibility First" Approach**
Instead of funding automated prevention (EDR - $30k), we could allocate the remaining budget to fund the Enterprise SIEM ($85k) for maximum network visibility.
* **Controls Funded:** MFA ($5k), Segmentation ($15k), Offsite Backups ($8k), and Enterprise SIEM ($85k).
* **Alternative Total Cost:** $113,000
* **Alternative Risk Reduction:** $2,630,000 (MFA, Segmentation, Backups) + $40,000 (SIEM) = $2,670,000

**Comparison to Primary Recommendation:**
The primary recommendation (funding EDR instead of SIEM) costs only $58,000 and achieves an identical total ALE reduction of $2,670,000. The alternative "Visibility First" approach consumes nearly the entire $120,000 budget ($113,000 total) to achieve the exact same mathematical risk reduction, while simultaneously burdening our small IT team with manually tuning SIEM alerts rather than letting the EDR tool automate the blocking. Therefore, the primary recommendation is vastly superior in both financial and operational efficiency.
