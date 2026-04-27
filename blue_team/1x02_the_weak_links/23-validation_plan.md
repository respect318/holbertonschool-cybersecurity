# 23-validation_plan.md

## 1. Post-Patch Verification (Immediate Remediations)

For the three immediate actions identified in the Patch Briefing, the following verification steps must be executed:

* **Finding 031 (Tomcat Ghostcat):**
    * **Verification:** Attempt to connect to port 8009 using the `ghostcat.py` exploit script from a testing machine.
    * **Success Criteria:** The connection must be rejected or require authentication, and the script must fail to read the `web.xml` file.
* **Finding 001 (Apache mod_lua RCE):**
    * **Verification:** Run `apache2 -v` on the billing server to confirm the version string has been updated to the latest ESM-supported version.
    * **Success Criteria:** An authenticated vulnerability rescan of the host must show CVE-2021-44790 as "Remediated" or "Fixed."
* **Finding 008 (PrintNightmare):**
    * **Verification:** Check the Windows Update history for the specific KB (Knowledge Base) number. Use the PowerShell command `Get-Printer` to verify that non-admin users can no longer add new printers.
    * **Success Criteria:** Verification that the `RestrictDriverInstallationToAdministrators` registry key is set to `1`.

## 2. Compensating Control Validation

* **MRI Workstation Isolation (Windows XP):** * **Verification:** Perform an Nmap scan from a standard nurse workstation targeting the MRI IP (`10.10.1.70`).
    * **Success Criteria:** All ports (445, 3389) must show as `Filtered` or `Closed`. Only the PACS server should be able to reach the MRI on the specific DICOM port.
* **Medical IoT (Infusion Pumps):**
    * **Verification:** Attempt to access the management web interface of a random pump from the "Guest" or "Admin" office Wi-Fi.
    * **Success Criteria:** Connection timeout. Access must only be possible from the dedicated, restricted "Medical Device Management" VLAN.

## 3. Rescan Schedule

MedDefense must transition from annual/ad-hoc scanning to a **monthly authenticated scanning** cycle, with **weekly unauthenticated perimeter scans**. 
* **Justification:** In a clinical environment with high staff turnover and "Shadow IT" risks, a month is long enough for new unpatched devices to enter the network. Monthly scans provide a balance between visibility and operational impact on sensitive medical systems.

## 4. Continuous Intelligence Integration

* **CISA KEV Integration:** The Security Analyst must review the CISA Known Exploited Vulnerabilities catalog every Tuesday (Patch Tuesday). Any CVE listed that exists in the MedDefense environment must bypass standard 30-day triage and move to "Immediate" (48h) remediation.
* **Vendor Advisories:** Subscription to BD, Philips, and Microsoft security notifications is mandatory. These feeds must be funneled into a central security dashboard for daily review.

## 5. Vulnerability Management Lifecycle

MedDefense will follow this continuous loop:

1.  **Scan:** (Responsible: **Security Analyst**) - Monthly internal and weekly external scanning.
2.  **Triage:** (Responsible: **Security Analyst**) - Filter out noise and identify False Positives.
3.  **Prioritize:** (Responsible: **Security Manager**) - Contextualize findings based on Asset Criticality and CISA KEV status.
4.  **Remediate:** (Responsible: **IT Ops / Vendor**) - Apply patches, change configurations, or implement isolation.
5.  **Validate:** (Responsible: **Security Analyst**) - Re-test and rescan to prove the fix works.
6.  **Repeat:** (Responsible: **Management**) - Review metrics and audit the entire cycle every quarter.
