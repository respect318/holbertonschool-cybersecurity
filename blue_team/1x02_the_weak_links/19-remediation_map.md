# 19-remediation_map.md

## Remediation Map

### Finding 001: Apache mod_lua Buffer Overflow
* **Response Type:** Patch
* **Patch Source:** Ubuntu Extended Security Maintenance (ESM) repository.
* **Prerequisites:** Acquire an Ubuntu Pro/ESM license (as 18.04 is EOL), test the `apache2` package update in a staging environment, schedule a 1-hour maintenance window, and take a full VM snapshot.
* **Rollback Plan:** Restore the VM snapshot or use `apt-get downgrade apache2`.
* **Operational Risk:** Upgrading the core web server package might introduce configuration incompatibilities that break the custom billing application.
* **Timeline:** Immediate
* **Owner:** IT
* **Cost Estimate:** $1-10K (ESM Licensing costs)

### Finding 031: Tomcat AJP Ghostcat
* **Response Type:** Configuration Change
* **Change Description:** Edit Tomcat's `server.xml` file. If the AJP connector (port 8009) is not actively used by a reverse proxy, comment out the connector completely. If it is used, set `secretRequired="true"` and configure a strong authentication secret.
* **Impact Assessment:** If the Apache/Nginx front-end relies on AJP to communicate with Tomcat and is not updated with the new secret simultaneously, the entire Electronic Health Records (EHR) web interface will go offline.
* **Timeline:** Immediate
* **Owner:** IT
* **Cost Estimate:** $0-1K

### Finding 004: Windows XP SMB / EternalBlue
* **Response Type:** Compensating Control
* **Control Description:** Implement strict VLAN isolation for the MRI workstation. Apply network ACLs to block all inbound and outbound SMB (Port 445) and RDP (Port 3389) traffic. Whitelist only specific DICOM traffic to the PACS imaging server.
* **Residual Risk:** The OS remains permanently vulnerable. If malware is introduced via a physical vector (e.g., a technician plugging an infected USB drive directly into the MRI computer), the system will still be compromised.
* **Timeline:** Immediate
* **Owner:** Security / Network Team
* **Cost Estimate:** $0-1K

### Finding 010: BD Alaris Pump Firmware
* **Response Type:** Patch
* **Patch Source:** BD Official Support Portal / Certified Field Technician engagement.
* **Prerequisites:** Coordinate heavily with clinical floor managers to schedule downtime for infusion pumps. Maintain a reserve pool of patched pumps to swap out vulnerable ones actively in use. Backup all device configurations.
* **Rollback Plan:** Reverting medical firmware requires vendor intervention. The fallback is to replace the malfunctioning unit with a spare from the clinical reserve pool.
* **Operational Risk:** Flashing firmware can occasionally "brick" medical devices. A failed mass-update could result in a critical shortage of life-saving infusion pumps on the intensive care floor.
* **Timeline:** 30 days
* **Owner:** Clinical Engineering / Vendor
* **Cost Estimate:** $10-50K (Vendor service engagement and potential downtime logistics)

### Finding 008: PrintNightmare
* **Response Type:** Patch
* **Patch Source:** Microsoft Windows Update (Relevant KB for Windows Server 2012 R2).
* **Prerequisites:** Test the patch in a development environment, backup the Print Server VM, and communicate potential temporary print service disruptions to hospital staff.
* **Rollback Plan:** Uninstall the specific Windows KB update via command line or revert to the pre-patch VM snapshot.
* **Operational Risk:** The Microsoft patch changes default "Point and Print" restrictions. This may prevent non-admin clinical staff from installing or updating valid network printers, generating a high volume of IT helpdesk tickets.
* **Timeline:** 7 days
* **Owner:** IT
* **Cost Estimate:** $0-1K

### Finding 003: PostgreSQL Unrestricted Access
* **Response Type:** Configuration Change
* **Change Description:** Modify `pg_hba.conf` to remove the `host all all 10.10.0.0/16 trust` entry. Replace it with a strict whitelist allowing connections ONLY from the EHR Application Server IP (`10.10.2.10`) using `md5` or `scram-sha-256` authentication.
* **Impact Assessment:** Any undocumented reporting scripts, IT backup jobs, or third-party integrations currently connecting to the database from outside the new whitelist will instantly fail.
* **Timeline:** Immediate
* **Owner:** IT (Database Administrator)
* **Cost Estimate:** $0-1K

### Finding 002: Apache Local PrivEsc
* **Response Type:** Patch
* **Patch Source:** Ubuntu ESM repository.
* **Prerequisites:** Deploy the patch to the staging environment. Since it affects the same service as Finding 001, they should be bundled into the same maintenance window.
* **Rollback Plan:** Restore the VM snapshot taken prior to the patching window.
* **Operational Risk:** Minimal, aside from the temporary dropping of active billing user sessions during the `systemctl restart apache2` command.
* **Timeline:** 7 days
* **Owner:** IT
* **Cost Estimate:** $0-1K (Assuming ESM license is covered under Finding 001)

### Finding 029: Grafana Path Traversal (Shadow IT)
* **Response Type:** Configuration Change
* **Change Description:** Do not attempt to patch the software. Administratively disable the network switch port connected to the undocumented Linux host, effectively quarantining it from the network. Decommission the server physically.
* **Impact Assessment:** The unknown department or employee who deployed this Shadow IT asset will lose access to their unofficial dashboard. This may cause internal political friction, but it eliminates an unauthorized attack vector.
* **Timeline:** Immediate
* **Owner:** Security
* **Cost Estimate:** $0-1K
