### 1. Risk Analysis
The Windows XP operating system on the MRI workstation has not received security updates since 2014, meaning it contains numerous publicly known, unpatchable vulnerabilities (such as those exploited by EternalBlue) that allow for trivial remote code execution. Because MedDefense currently operates a flat 10.10.0.0/16 network architecture, this highly vulnerable machine is directly exposed to every other workstation and device in the hospital. If a standard user downloads malware or falls for a phishing attack, the infection can effortlessly spread laterally across the flat network, compromise the MRI workstation, and use it as a persistent, unpatchable pivot point to maintain access to the entire MedDefense domain.

### 2. Compensating Control Strategy

Control 1: Network Isolation and Strict ACLs (Microsegmentation)
- Description: Move the MRI workstation to a dedicated, isolated VLAN behind an internal firewall, configuring Access Control Lists (ACLs) to allow communication ONLY over the specific ports required to reach the PACS server (`pacs-srv-01`). All other inbound and outbound traffic must be explicitly denied.
- Classification: Technical Preventive
- Risk Reduction: This drastically shrinks the attack surface by hiding the unpatchable OS from the rest of the hospital network, making it mathematically impossible for general malware on a nurse's workstation to reach and infect the MRI via lateral movement.
- Limitations/Residual Risk: If the PACS server itself is compromised, the attacker could still use that trusted connection to attack the MRI workstation.

Control 2: Physical Port Blockers and Strict Access Control
- Description: Install physical port locks on all USB ports and optical drives of the MRI workstation, and enforce strict badge-access controls to the MRI control room, allowing entry only to authorized radiology technicians.
- Classification: Physical Preventive
- Risk Reduction: Prevents malicious actors or negligent staff from bypassing the network isolation by plugging in infected USB drives or unauthorized hardware directly into the vulnerable machine.
- Limitations/Residual Risk: Physical locks can sometimes be forced, bypassed, or removed by determined insiders with physical access to the machine.

Control 3: Dedicated Network Intrusion Detection System (NIDS)
- Description: Deploy a NIDS specifically monitoring the traffic chokepoint between the MRI's isolated VLAN and the PACS server, configured with strict signature and anomaly detection rules tailored to Windows XP exploits.
- Classification: Technical Detective
- Risk Reduction: Provides immediate visibility and alerting if any anomalous traffic or exploitation attempt occurs across the only remaining network pathway, enabling rapid incident response before the device is fully compromised.
- Limitations/Residual Risk: This is a detective measure only; it will alert the security team to an attack but will not stop the attack from executing on the unpatchable system.

### 3. Implementation Priority
If MedDefense can only implement one control immediately, it must be Control 1: Network Isolation and Strict ACLs (Microsegmentation). 
The flat network is the primary enabler of the critical risk; as long as the MRI is on the 10.10.0.0/16 subnet, it is fully exposed to thousands of endpoints. Isolating the workstation instantly cuts off this massive attack surface, providing the highest and most immediate risk reduction for a zero-dollar software cost by utilizing the existing core network equipment to protect patient care operations.
