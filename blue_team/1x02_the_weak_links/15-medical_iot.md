# 15-medical_iot.md

## 1. BD Alaris Assessment (Finding 010)
* **Vulnerability Description:** BD Alaris systems running firmware 12.1.2 have documented critical vulnerabilities (such as CVE-2020-25165 and others referenced in ICS-CERT advisories). These vulnerabilities can allow an unauthenticated attacker on the network to hijack sessions, access the pump's configuration, or cause a Denial of Service (DoS) that crashes the communications module and drops the pump off the network.
* **Vendor Mitigation:** The manufacturer (BD) strongly recommends updating to the latest patched firmware version, utilizing strong wireless encryption, isolating the pumps on a dedicated segmented medical VLAN, and ensuring default credentials are changed.
* **MedDefense Implementation Status:** MedDefense has **not** implemented these recommendations. The pumps are still running the vulnerable 12.1.2 firmware, they are completely exposed on a flat network (10.10.0.0/16) without VLAN isolation, and the scan implies management interfaces are accessible, likely still utilizing default configurations.

## 2. Philips IntelliVue Assessment (Findings 016 & 024)
* **Data Flowing Through Interfaces:** The HL7 (Health Level Seven) protocol and unauthenticated web interfaces transmit real-time patient telemetry. This includes continuous vital signs (heart rate, blood pressure, oxygen saturation/SpO2), patient demographics, system alarms, and treatment parameters.
* **Attacker Capabilities:** An attacker with internal network access can intercept this unencrypted (cleartext) traffic to steal Protected Health Information (PHI). More dangerously, they could manipulate the HL7 traffic to spoof vital signs (triggering false alarms to cause "alarm fatigue" among nurses, or suppressing real critical alarms), or launch a DoS attack to blank the monitors entirely while a patient is in critical care.

## 3. Patient Safety Dimension
Medical device vulnerabilities fall into a completely different risk category because their compromise translates directly to kinetic, physical-world consequences. The worst-case scenario for a compromised standard IT workstation is data theft, ransomware lockouts, and financial loss for the hospital. In stark contrast, the worst-case scenario for a compromised infusion pump is an attacker altering the flow rate of critical, life-sustaining medications (like insulin, vasopressors, or fentanyl), resulting directly in patient overdose, injury, or death. Medical IoT bridges the cyber-physical gap where bytes dictate biological outcomes.

## 4. Remediation Challenge
Patching medical devices is exponentially harder than patching standard IT systems due to three specific factors:
1. **Regulatory Constraints:** Medical devices are heavily regulated by health authorities (e.g., FDA in the US). Any software change, even a simple security patch, must often go through a validation process to ensure the patch does not inadvertently alter the device's clinical efficacy or safety, delaying release.
2. **Operational Uptime & Logistics:** Devices like infusion pumps are highly mobile and in constant use for critical patient care across various hospital floors. Locating all the devices and taking them offline for a firmware update requires complex clinical coordination and scheduled downtime.
3. **Vendor Dependency:** IT administrators cannot simply deploy patches via automated tools like WSUS or SCCM. The software is closed and proprietary; updating often requires a certified field technician from the manufacturer to physically visit the hospital and manually flash the firmware on each individual device.
