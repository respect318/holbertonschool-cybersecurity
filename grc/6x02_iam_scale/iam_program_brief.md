# Identity Program Brief for Dr. Morales

**Prepared for:** Board Risk Committee
**Date:** June 8, 2025

---

## Identity Posture Summary

After the breach, we asked a simple question: who has access to our systems, and should they? The answer revealed 3 Critical and 4 High-severity gaps — seven conditions that increased our exposure to attack. Three of those gaps directly enabled the breach. Today, two have been fixed. The remaining five have assigned owners and firm deadlines. For the first time, we have a complete and auditable picture of our identity risk.

---

## Connection to the Incident

The breach worked because one stolen password opened nearly every door. Our review found three specific conditions that made this possible — all of which were still present after the incident:

- **Finding IAM-006:** Patient health records held in backup storage were readable by anyone on the internet — no account or password needed. This was the direct path to data exposure.
- **Finding IAM-007:** A third-party vendor account carried the same administrative rights as our most senior internal staff, with no limits on which systems it could reach. This is what allowed the attacker to move from one system to another once inside.
- **Finding IAM-001:** The single account with master control over all our cloud systems had no second sign-in step, and its access credentials had not been changed since March 2022. Holding those credentials meant holding everything.

Two of these three conditions have been corrected since the review began. The third (IAM-001) has a completion date of June 15, 2025.

---

## What Has Been Completed

- **corrected IAM policies** — The backup system's permissions were narrowed to exactly what it needs and nothing more, closing the access path exploited during the incident.
- **SSO and user access review** — A full review of sign-on records found active accounts belonging to former employees. Those accounts have been submitted for immediate removal.
- **Vault dynamic credentials** — High-privilege system accounts no longer use permanent passwords. Access credentials now expire automatically, removing a technique the attacker used to maintain hidden access.
- **Ongoing audit process** — The manual, one-time review that preceded this brief has been replaced with an automated process that runs on a regular schedule and flags new gaps as they appear.

---

## What Must Be Completed Before the Next Board Meeting

| Action | Owner | Deadline |
|---|---|---|
| Remove standing master account credentials; require second sign-in step (IAM-001, Critical) | Cloud Infrastructure Lead | June 15, 2025 |
| Remove public access to patient backup storage; engage Privacy Officer for legal exposure review (IAM-006, Critical) | Cloud Security Lead | June 15, 2025 |
| Reduce three over-privileged accounts to minimum required access (IAM-007, High) | IAM Administrator | June 30, 2025 |

---

## What Requires Board Authorization or Budget

Two improvements are validated and ready to deploy, but exceed current team capacity and budget:

1. **Full deployment of automatic credential expiry (Vault)** — Tested and confirmed to work. Expanding it to all privileged accounts eliminates the class of persistent access that sustained the breach. Without board funding, this remains a proof of concept. Estimated cost: **$180,000–$240,000**.

2. **Preventive account controls (SSO and cloud guardrails)** — Today, nothing prevents a misconfiguration from recreating the public-access condition that exposed patient data. A one-time structural change to our cloud environment would make that class of error technically impossible going forward. Estimated effort: **two to three weeks** with outside specialist support.

Deferring either item leaves a known breach path recoverable by a single mistake or insider action.

---

## Board Resolution Requested

The Board Risk Committee authorizes the CISO to engage a vendor and fund full deployment of the automatic credential expiry system at a cost not to exceed $240,000, and directs the technology team to implement preventive cloud account controls by September 30, 2025, with written progress reports submitted to the Risk Committee at each monthly meeting until both items are confirmed closed.
