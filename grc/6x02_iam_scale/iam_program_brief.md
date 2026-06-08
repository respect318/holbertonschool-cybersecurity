# Identity Program Brief for Dr. Morales

**To:** Dr. Morales, Chief Information Security Officer
**Date:** 2025-06-08
**For:** Board Risk Committee — Identity Posture Update

---

## Identity Posture Summary

Following the breach, MedDefense commissioned a full review of who has access to what — and whether those access rights are appropriate. The review covered every user account, administrative role, and cloud storage configuration.

The results were serious. We found **3 Critical gaps** and **4 High-severity gaps**. Three of them directly recreated the conditions that made the breach possible. Two have been fully corrected. The remaining five have owners, plans, and deadlines — three of which close before the next board meeting.

We now know exactly where we stand. We did not know that before.

---

## Connection to the Incident

The breach succeeded because an attacker obtained one set of credentials and faced no meaningful barriers after that. Our review confirmed three specific conditions that made this possible — and that still existed after the incident:

- A patient data backup was stored in a location accessible to anyone on the internet, with no login required (finding IAM-006). This is the condition most directly responsible for data exposure.
- A vendor account had the same level of access as our most senior administrators, with no restrictions on what systems it could reach (IAM-007). This is how lateral movement across systems occurred.
- The master account controlling all of our cloud systems had no second verification step and carried keys that had not been changed since 2022 (IAM-001). Whoever held those keys held everything.

What is different now: the vendor-equivalent access has been removed. The backup role has been corrected. The other two items have committed remediation dates of June 15, 2025.

---

## What Has Been Completed

- **corrected IAM policies** — The backup system's access was narrowed from "everything in the account" to the single storage location it actually needs. This directly closes the path used in the incident.
- **SSO and user access review** — A review of all user sign-on records identified accounts belonging to former employees that still had active access. Those accounts have been submitted for removal.
- **Vault dynamic credentials** — Privileged system accounts no longer use permanent passwords. Credentials now expire automatically after each use, eliminating a key persistence technique used in the attack.
- **Automated audit capability** — The manual review process that allowed these gaps to go undetected has been replaced with a repeatable audit script that can be scheduled and reviewed regularly.

---

## What Must Be Completed Before the Next Board Meeting

| Action | Owner | Deadline |
|---|---|---|
| Remove master account keys; add second-factor verification (IAM-001, Critical) | Cloud Infrastructure Lead | June 15, 2025 |
| Close public access to patient backup storage; engage Privacy Officer for breach risk review (IAM-006, Critical) | Cloud Security Lead | June 15, 2025 |
| Reduce three over-privileged administrator accounts to minimum required access (IAM-007, High) | IAM Administrator | June 30, 2025 |

---

## What Requires Board Authorization or Budget

Two items exceed what the current team can deliver within existing resources:

1. **Permanent rollout of the automatic credential system** — The solution has been tested and works. Deploying it to all privileged accounts requires dedicated project funding. Without it, some accounts will continue using permanent passwords — the same weakness exploited in the breach. Estimated investment: **$180,000–$240,000**.

2. **Account-level controls to prevent future misconfigurations** — Currently, nothing prevents an administrator from accidentally or intentionally recreating the public-access storage condition that caused the breach. A one-time configuration change to our cloud account structure would make that technically impossible. This requires outside architecture support and legal review. Estimated effort: **two to three weeks**.

Deferring either item leaves a known breach path open.

---

## Board Resolution Requested

> The Board Risk Committee authorizes the CISO to fund deployment of an automated privileged credential management system, budget not to exceed $240,000, and directs completion of preventive cloud account controls by September 30, 2025, with written status updates to the Risk Committee each month until both are closed.
