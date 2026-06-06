# Security Quick Reference: IT Staff
<!-- MedDefense Health Systems | Information Security -->
**Version:** 1.0 | **Date:** 2026-06-06 | **Audience:** Helpdesk, sysadmins, SOC analysts, endpoint engineers

---

## Your biggest threats

- **Vendor requests for broad admin access.** A vendor calls or emails asking for Domain Admin or local admin rights to "get the job done faster." The 6x02 audit found `svc_helpdesk` sitting at Domain Admin because someone approved a vendor request and never scoped it back. Every vendor privilege grant needs a ticket, a scope, and an end date — or it becomes a permanent attack surface. Signal to watch for: any vendor or contractor asking for elevated access without a change ticket reference.

- **Dormant and over-privileged service accounts being activated.** The audit found `svc_epic_int` with Domain Admin and zero recent documented activity, `admin.legacy` with no MFA and dormant since a migration project, and `b.carter` still in privileged groups after the account was disabled. An attacker who finds these accounts does not need to compromise a live user. Signal to watch for: service account activity outside business hours with no corresponding ticket, or interactive logins on accounts that should only be running scheduled tasks.

- **Insider threat indicators you are positioned to see before tooling does.** After the March 2026 incident, `j.yamamoto` retained IT-level privileges after moving to Finance. Role transfers without access reviews create insider risk whether or not intent is present. Signal to watch for: a user accessing systems inconsistent with their current role, privilege changes without a ticket, or a peer running admin actions outside their documented scope.

---

## What to do right now

- **Pull up your service accounts this week and verify each one has an owner, a documented purpose, and a current ticket or project reference.** If you find a service account — especially one with Domain Admin or backup rights — with no active owner and no recent expected activity, flag it for review immediately. Start with `svc_epic_int`, `svc_helpdesk`, `svc_backup`, and `admin.legacy` if they have not already been remediated from the 6x02 findings.

- **Do not approve admin actions from personal email, personal devices, or untracked sessions.** If you are off-shift and someone contacts you asking you to make a privilege change, tell them to submit a ticket. No exceptions. Admin actions taken outside tracked change management are invisible to the SOC and impossible to audit after an incident.

- **Verify any user access that has not been reviewed after a role change.** Check whether `j.yamamoto` and any other staff who transferred roles in the past 12 months still hold access groups from their previous positions. If they do, remove or scope the access and document it. Managers will not always report these — this one lands on IT.

---

## When something looks wrong

**Report to SOC and document it.** If you see anomalous privileged account activity, an account active at unexpected hours, or a user accessing systems outside their role — log what you observed (account, time, action, system) and send it to security@meddefense.org or call ext. 4-SECURITY. You are reporting observable facts, not accusing anyone.

---

## What not to do

- **Do not grant vendor access without a scoped ticket and an end date.** "Temporary" access that has no removal date is permanent access. Every grant needs: ticket reference, scope, duration, and a calendar reminder to revoke it.

- **Do not leave privileged sessions open when you step away** — not on shared terminals, not on your primary workstation. An unlocked admin session is a fully open door. Lock it every time.

- **Do not use personal email or personal cloud accounts for anything touching IAM, endpoint management, or security tooling.** Personal accounts are outside MedDefense logging, outside MFA enforcement, and outside SOC visibility. If a personal account gets compromised, those admin credentials go with it.

---

**Security team:** ext. 4-SECURITY | security@meddefense.org
**Report a suspicious email:** phishing report button in Outlook toolbar (flag icon)
