# 20-priority_matrix.md

## The Priority Matrix

### Immediate (24-48 hours)
*Weaponized exploit + critical asset + active threat*
* **Finding 001:** Apache mod_lua RCE on billing | Action: Apply ESM patch/Snapshot rollback | Owner: IT | Cost: $1-10K
* **Finding 031:** Tomcat Ghostcat on EHR | Action: Require authentication for AJP connector | Owner: IT | Cost: $0-1K
* **Finding 003:** PostgreSQL Unrestricted | Action: Implement IP whitelist in pg_hba.conf | Owner: IT | Cost: $0-1K
* **Finding 004:** Windows XP SMB on MRI | Action: VLAN isolation & block SMB/RDP | Owner: Network/Sec | Cost: $0-1K
* **Finding 016:** Philips IntelliVue Web Exposure | Action: Network isolation to Medical VLAN | Owner: Network | Cost: $0-1K
* **Finding 024:** DICOM Cleartext | Action: Enforce TLS/IPsec encryption for PACS traffic | Owner: IT/Sec | Cost: $0-1K
* **Finding 008:** PrintNightmare | Action: Apply emergency Microsoft Windows patch | Owner: IT | Cost: $0-1K
* **Finding 028:** Shadow IT | Action: Physically disconnect unauthorized Linux host | Owner: Security | Cost: $0-1K
* **Finding 027:** Inactive Sophos | Action: Reactivate endpoint protection agents | Owner: IT | Cost: $0-1K
* **Finding 014:** Consumer Router VPN | Action: Replace with enterprise firewall | Owner: Network | Cost: $1-10K

### Short-term (7 days)
*Critical/High CVE with PoC + important asset*
* **Finding 002:** Apache Local PrivEsc | Action: Apply ESM patch alongside F001 | Owner: IT | Cost: $0-1K
* **Finding 009:** SSH Password Auth | Action: Disable password auth, enforce SSH keys | Owner: IT | Cost: $0-1K
* **Finding 006:** MySQL Unrestricted Binding | Action: Bind to localhost/app tier only | Owner: IT | Cost: $0-1K
* **Finding 029:** Grafana Path Traversal | Action: Decommission shadow host entirely | Owner: Security | Cost: $0-1K

### Medium-term (30 days)
*High/Medium CVE or significant misconfiguration*
* **Finding 010:** BD Alaris Firmware | Action: Coordinate vendor technician firmware flash | Owner: Clinical/Vendor | Cost: $10-50K
* **Finding 015:** Synology NAS Exposed | Action: Migrate NAS to restricted Mgmt VLAN | Owner: Network | Cost: $0-1K
* **Finding 023:** USB Mass Storage Allowed | Action: Implement GPO to block removable drives | Owner: IT | Cost: $0-1K
* **Finding 019:** Internal RDP Enabled | Action: Restrict RDP access via Windows Firewall | Owner: IT | Cost: $0-1K
* **Finding 018:** Weak Kerberos Encryption | Action: Disable RC4/DES via Group Policy | Owner: IT | Cost: $0-1K
* **Finding 013:** SSL Certificate Expiring | Action: Renew and deploy updated certificates | Owner: IT | Cost: $0-1K

### Long-term (90 days)
*Architecture changes, EOL migrations, systemic fixes*
* **Finding 011:** Ubuntu 18.04 EOL | Action: Migrate billing-srv-01 to Ubuntu 22.04/24.04 | Owner: IT | Cost: $10-50K
* **Finding 026:** Linux Kernel Outdated | Action: Remediated concurrently with F011 OS migration | Owner: IT | Cost: $0-1K
* **Finding 007:** LDAP Signing Missing | Action: Extensive testing, then enforce via GPO | Owner: IT | Cost: $0-1K

---

## Budget Summary

The total estimated cost to remediate all actionable findings ranges from **$22,000 to $120,000**, largely dependent on vendor service fees for medical device firmware flashing and IT consulting hours for the OS migration. MedDefense’s entire annual security budget (from 1x00) is **$120,000**. Executing all these remediations immediately would consume 18% to 100% of the entire yearly security budget within a single quarter, leaving nothing for incident response, new tools, or unexpected hardware failures. 

To remain financially viable, the $10-50K **Ubuntu 18.04 EOL Migration (Finding 011)** must be deferred to the next fiscal year's budget. In the interim, MedDefense will purchase a low-cost Canonical Ubuntu Pro (ESM) license ($500/year) as a compensating control to continue receiving security patches for the legacy server. This frees up the capital required to immediately fund the $10-50K vendor engagement to patch the **BD Alaris Pumps (Finding 010)**, prioritizing physical patient safety over IT modernization.
