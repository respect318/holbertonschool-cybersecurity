# Supply Chain Risk Assessment: MedDefense

## 1. Vendor: MedTech Solutions
* **Service:** EHR maintenance provider.
* **Access Type:** Network and Application access.
* **Access Scope:** Direct administrative access to the Electronic Health Record (EHR) server and its underlying database containing all patient medical histories.
* **Compromise Scenario:** If a MedTech Solutions technician’s credentials are stolen, the attacker can use the existing maintenance VPN to log directly into the EHR server. From there, they can exfiltrate the entire patient database or deploy ransomware directly onto MedDefense’s most critical asset.
* **Existing Controls:** Annual contract and Service Level Agreement (SLA); Access Control Policy (from 1x00).
* **Risk Assessment:** **Critical** - They have direct access to the "crown jewels" (patient data) and a compromise leads immediately to a Tier-1 breach.

## 2. Vendor: Microsoft
* **Service:** Office 365 E3 (Email, SharePoint, OneDrive, Entra ID).
* **Access Type:** Data and Application access (Identity Management).
* **Access Scope:** All corporate communications (Email), sensitive administrative documents (SharePoint/OneDrive), and user identities (Entra ID/Active Directory synchronization).
* **Compromise Scenario:** A compromise at Microsoft or a large-scale configuration exploit could lead to unauthorized access to all hospital emails and internal files. If Entra ID is compromised, attackers could gain control over all synchronized identities, leading to a total organizational lockout.
* **Existing Controls:** Contractual security obligations; O365 built-in security features.
* **Risk Assessment:** **High** - While Microsoft has high security, the scope of their access to MedDefense’s communication and identity layers makes them a massive single point of failure.

## 3. Vendor: Sophos
* **Service:** Endpoint protection and security management.
* **Access Type:** Application and Network access (System-level agent).
* **Access Scope:** Every managed endpoint (workstations and servers) in the MedDefense network has a Sophos agent installed with SYSTEM privileges.
* **Compromise Scenario:** A SolarWinds-style supply chain attack where a malicious update is pushed through the Sophos management console. This would automatically deploy malware to every single device in the hospital simultaneously, bypassing all other defenses.
* **Existing Controls:** Automatic updates; Endpoint security policy (from 1x00).
* **Risk Assessment:** **Critical** - The security software itself acts as a universal backdoor; if the provider is breached, the entire hospital is compromised instantly.

## 4. Vendor: Siemens
* **Service:** MRI scanner manufacturer and maintenance.
* **Access Type:** Physical and Network access (Legacy Workstation).
* **Access Scope:** Access to the MRI Windows XP workstation and the connected medical device network segment.
* **Compromise Scenario:** An attacker could compromise Siemens’ remote maintenance infrastructure to pivot into the unpatched Windows XP workstation. Given MedDefense’s flat network, the attacker could then move laterally from the legacy XP machine to the billing or EHR servers.
* **Existing Controls:** Periodic maintenance schedule; Hardware Asset Registry (from 1x00).
* **Risk Assessment:** **Medium** - The risk is concentrated on a specific clinical asset, but the use of EOL (End-of-Life) Windows XP makes it an attractive and easy pivot point for lateral movement.

## 5. Greenfield Building Management
* **Service:** HQ office building and network infrastructure provider.
* **Access Type:** Physical and Network access (VLAN management).
* **Access Scope:** MedDefense’s entire network traffic runs through Greenfield’s routers and switches; they manage the physical cabling and the VLAN configuration.
* **Compromise Scenario:** If Greenfield’s core network infrastructure is breached, the attacker could perform a "VLAN hopping" attack or sniff unencrypted internal traffic. They could also cause a total denial-of-service by shutting down the building's internet and internal connectivity.
* **Existing Controls:** VLAN isolation; Building access controls.
* **Risk Assessment:** **High** - They control the "pipes" that MedDefense’s data flows through. A breach here renders the hospital's internal network isolation useless.

## Supply Chain Risk Summary
The single vendor compromise that would cause the most catastrophic damage to MedDefense is **Sophos**. Because the Sophos agent resides on every managed device with highest-level system privileges, a poisoned update would lead to a 100% infection rate across all servers and workstations, including the EHR and billing systems, with no ability to stop the deployment. To reduce supply chain risk across all vendors, MedDefense should first implement **Network Segmentation**. By breaking the current flat network into isolated zones (e.g., separating medical devices from the EHR server and guest Wi-Fi), MedDefense can ensure that a breach of one vendor (like Siemens' MRI or Greenfield’s network) is contained within that specific zone, preventing lateral movement to the rest of the organization.
