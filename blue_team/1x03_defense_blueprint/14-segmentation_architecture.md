# MedDefense Health Systems: Network Segmentation Architecture

## Part 1 - Zone Definition

To dismantle the dangerously flat 10.10.0.0/16 network, MedDefense will implement the following Virtual Local Area Networks (VLANs). This Zero-Trust inspired baseline ensures that compromise in one segment does not cascade enterprise-wide.

**1. Server Zone (VLAN 10)**
* **IP Range:** 10.10.10.0/24
* **Systems Included:** EHR Server (ehr-srv-01), EHR Database (ehr-db-01), Billing Server (billing-srv-01), Active Directory Domain Controllers, File Servers.
* **Allowed Outbound:** DNS/NTP to the Internet; Reply traffic to established clinical sessions; Active Directory authentication traffic (Kerberos/LDAP) to internal endpoints.
* **Allowed Inbound:** HTTPS/SQL from the Clinical Zone; RDP/SSH exclusively from the Management Zone.

**2. Clinical Workstation Zone (VLAN 20)**
* **IP Range:** 10.10.20.0/24
* **Systems Included:** Nurse station desktops, physician laptops, mobile medical carts, pharmacy workstations.
* **Allowed Outbound:** HTTPS (TCP 443) to the Server Zone (for EHR access); Filtered HTTP/HTTPS to the Internet.
* **Allowed Inbound:** Active Directory Group Policy updates from the Server Zone; Remote assistance from the Management Zone. None from Guest or Medical Device zones.

**3. Medical Device Zone (VLAN 30)**
* **IP Range:** 10.10.30.0/24
* **Systems Included:** BD Alaris infusion pumps, patient cardiac monitors, MRI machines, PACS imaging systems.
* **Allowed Outbound:** Specific medical protocols (e.g., HL7, DICOM) to designated servers in the Server Zone only.
* **Allowed Inbound:** Only essential management traffic from the Management Zone. No internet access.

**4. Management Zone (VLAN 40)**
* **IP Range:** 10.10.40.0/24
* **Systems Included:** IT administrative workstations, jump servers, Wazuh SIEM collector, Sophos EDR management console, vulnerability scanners.
* **Allowed Outbound:** Administrative protocols (RDP, SSH, WinRM, HTTPS) to all internal zones; HTTPS to the Internet for vendor updates.
* **Allowed Inbound:** None.

**5. Guest / IoT Zone (VLAN 50)**
* **IP Range:** 10.10.50.0/24
* **Systems Included:** Visitor Wi-Fi devices, waiting room smart TVs, patient personal phones.
* **Allowed Outbound:** HTTP/HTTPS/DNS to the Internet ONLY.
* **Allowed Inbound:** None.

---

## Part 2 - Firewall Rules

The following critical rules will be applied at the core routing firewall (FortiGate) to enforce inter-VLAN segmentation. 

| Rule # | Source Zone | Destination Zone | Port / Protocol | Action | Explanation |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Rule 1** | Management_Zone | Server_Zone | TCP/3389, TCP/22 | **ALLOW** | Permits IT administrators to securely manage core servers via RDP and SSH. |
| **Rule 2** | Clinical_Zone | Server_Zone | TCP/443 | **ALLOW** | Allows doctors and nurses to access the web interface of the EHR system. |
| **Rule 3** | Medical_Zone | Server_Zone | TCP/2575, TCP/104 | **ALLOW** | Permits critical medical protocols (HL7 and DICOM) to transmit patient telemetry and imaging to the main databases. |
| **Rule 4** | Server_Zone (AD) | ANY_INTERNAL | TCP/UDP 88, 389 | **ALLOW** | Allows Active Directory to process Kerberos and LDAP authentication requests from endpoints. |
| **Rule 5** | Clinical_Zone | Internet | TCP/80, 443 | **ALLOW** | Provides necessary internet access for clinical staff, subject to enterprise DNS filtering. |
| **Rule 6** | Guest_Zone | ANY_INTERNAL | ANY | **DENY** | *Critical Deny:* Explicitly prevents unmanaged visitor devices or compromised smart TVs from scanning or accessing any internal hospital assets. |
| **Rule 7** | Clinical_Zone | Server_Zone | TCP/3389, TCP/445 | **DENY** | *Critical Deny:* Prevents clinical endpoints from using RDP or SMB to access servers. This instantly neutralizes lateral movement by ransomware attempting to jump from a compromised nurse's PC to the EHR database. |
| **Rule 8** | Medical_Zone | Internet | ANY | **DENY** | *Critical Deny:* Medical devices (like infusion pumps) have no legitimate business communicating with the internet. This prevents them from downloading malware or reaching out to Command and Control (C2) servers. |
| **Rule 9** | Clinical_Zone | Medical_Zone | ANY | **DENY** | *Critical Deny:* Prevents a malware infection on a standard workstation from bleeding over into the life-critical patient monitoring equipment. |
| **Rule 10** | ANY | ANY | ANY | **DENY** | *Implicit Deny:* The universal rule placed at the bottom of the ACL ensuring that any traffic not explicitly authorized by the rules above is dropped automatically. |

---

## Part 3 - Kill Chain Impact

### Disruption of Kill Chain #1 (Ransomware Syndicate)
In our original 1x01 analysis, the Ransomware kill chain proceeded as follows on the flat network: 
1. *Initial Access* via a phishing email opening on a clinical workstation.
2. *Execution* of the payload.
3. *Lateral Movement* using SMB (TCP 445) to pivot directly to the billing and EHR servers.
4. *Command & Control (C2)* beaconing.
5. *Impact* (Encryption of the entire enterprise database).

**How Segmentation Breaks This Chain:**
This new architecture shatters the ransomware kill chain at **Step 3 (Lateral Movement)**. If a nurse inadvertently triggers ransomware in the Clinical Zone (VLAN 20), the malware will attempt to scan and spread to the Server Zone (VLAN 10) using SMB or RDP. **Firewall Rule 7 explicitly denies this traffic.** The infection is contained entirely within the Clinical Zone. The EHR server, billing database, and Active Directory remain untouched, preventing a total catastrophic enterprise failure. 

Additionally, if the malware attempts to infect infusion pumps, **Firewall Rule 9** stops it cold, preventing a patient safety incident. 

**Estimated Global Impact:**
By strictly defining and containing lateral movement pathways, this segmentation architecture would confidently disrupt **80% to 90%** of our top 5 identified kill chains. Advanced Persistent Threats (APTs), Initial Access Brokers, and automated botnets all rely on the assumption of a flat network to escalate privileges and find valuable data. By isolating servers, restricting medical devices, and trapping guest traffic, the attacker's blast radius is drastically minimized.
