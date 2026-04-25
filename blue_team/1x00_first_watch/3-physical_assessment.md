Observation 1:
  Vulnerability: Inadequate physical access controls (generic badge access) and complete lack of auditing (no cameras or visitor logs) for the primary server room.
  Threat: An unauthorized person (visitor or staff) enters the server room to physically steal hardware, plant a rogue device, or destroy infrastructure.
  Impact: Compromises Availability (systems destroyed), Integrity (hardware tampered with), and Confidentiality (physical theft of data drives).
  Severity: Critical - Physical access to the core server room allows an attacker to instantly bypass all digital security controls and completely destroy the organization's infrastructure.

Observation 2:
  Vulnerability: An unlocked network closet door combined with exposed administrative credentials taped directly to the wall.
  Threat: A malicious actor or curious employee walks in and uses the exposed credentials to log into the network switch management interface.
  Impact: Compromises Confidentiality (eavesdropping on network traffic), Integrity (altering routing tables), and Availability (shutting down network segments).
  Severity: High - This provides immediate, zero-effort administrative access to the network infrastructure, enabling an attacker to easily intercept or disrupt hospital communications.

Observation 3:
  Vulnerability: Missing automatic screen lock controls and a highly negligent operational policy that encourages abandoning active, logged-in sessions.
  Threat: A hospital visitor, patient, or unauthorized staff member walks up to the unattended workstation to view, steal, or alter patient medical records.
  Impact: Compromises Confidentiality (unauthorized exposure of PHI) and Integrity (unauthorized modification of patient medical data).
  Severity: High - This is a direct HIPAA violation that exposes sensitive health data and severely risks patient safety if medical records are maliciously altered.

Observation 4:
  Vulnerability: A life-critical medical IoT device running severely outdated firmware (from 2019) is deployed on an unsegmented, flat network alongside regular workstations.
  Threat: Automated malware (like the previous ransomware) or an attacker on the main network pivots to easily exploit known vulnerabilities in the outdated medical monitor.
  Impact: Compromises Integrity (altering patient vital signs data) and Availability (crashing or disabling the monitor).
  Severity: Critical - Exploiting unsegmented, life-critical medical devices goes beyond digital risk and directly endangers patient health and life safety.

Observation 5:
  Vulnerability: A propped-open fire door that intentionally bypasses the physical security boundary separating public waiting areas from restricted administrative zones.
  Threat: A malicious actor casually walks from the public area into the IT and executive wing to steal devices, access unlocked computers, or plant rogue network hardware.
  Impact: Compromises Confidentiality (theft of corporate or IT data) and Integrity (unauthorized physical tampering of administrative devices).
  Severity: High - Defeating the physical perimeter grants untracked, direct access to high-value operational targets like the IT department and executive leadership offices.
