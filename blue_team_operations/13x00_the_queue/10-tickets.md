# Escalation Tickets — Halcyon, shift handover (3 of >3 beliefs escalated)

Budget spent on the three highest potential harm if real and unactioned. Left in the log (real but lower impact): HAL-242743 (unauthorised remote tool, but on a standard workstation) and the JA3 cluster's earlier stages, folded into Ticket 2.

---

## Ticket 1 — Service account on crown-jewel payments host from an unknown source
- Indicator: svc_txn_reconcile authenticated to txn-proc01 from legacy-jump03 (source host 10.30.90.138)
- Evidence: HAL-502452. Baseline for this account is batch-svc01/02 (10.30.40.x) at ~04:15-04:25 daily; legacy-jump03 appears in zero other events across all 14 days.
- Recommended action: disable/rotate the svc_txn_reconcile credential, isolate legacy-jump03, and pull all txn-proc01 sessions and transactions in the window around 2026-10-10 06:50 UTC for review.
- Severity: CRITICAL. Asset criticality = crown-jewel (txn-proc01, payment processing). Confidence = high (clear baseline deviation, host never seen before). Stage = valid-account access directly on the money-moving system. Crown-jewel + high confidence + access already achieved -> top urgency.

---

## Ticket 2 — External actor: VPN compromise and internal reconnaissance (one cluster)
- Indicator: client JA3 ja3:ea60867eab8e161a12a37de50c3c72fc from 198.51.100.12 (ASN AS64512, geo VN), account u.ferreira
- Evidence: HAL-753699 (34-attempt spray) -> HAL-157752 (successful off-hours VPN logon) -> HAL-214031 (remote-gw02 access) -> HAL-467427 (22 directory queries in ~90s). Also wrongly auto-closed as a sibling: HAL-751883 (stale AS64512 allowlist).
- Recommended action: force-reset u.ferreira, revoke active VPN/remote sessions from 198.51.100.12, block the IP at the VPN gateway, remove the stale AS64512 allowlist entry, and review directory queries at 03:31-03:32 to scope what was enumerated.
- Severity: HIGH. Asset criticality = elevated (remote-gw02, directory) and a valid workforce identity. Confidence = high (one actor tied by JA3 across all four events). Stage = Discovery (internal enumeration) after confirmed access; no lateral movement or data access evidenced. Active confirmed intrusion mid-recon -> high, below Ticket 1 only because it has not reached a crown-jewel asset.

---

## Ticket 3 — Cardholder-format data on an unrestricted share
- Indicator: \\filesvc02\legacy_exports has ACL = none and holds cardholder-format files
- Evidence: HAL-723401 (finding.acl=none, data_classification=cardholder_format_detected, 214 files on filesvc02).
- Recommended action: restrict the share ACL immediately, confirm whether the files are live cardholder data, and review access logs on filesvc02 for any reads in the 24h window (incl. by the Ticket 2 actor).
- Severity: HIGH. Asset criticality = elevated host holding regulated (cardholder-format) data -> PCI exposure. Confidence = medium (exposure confirmed; actual unauthorised access not yet evidenced). Stage = standing exposure / pre-incident, not an active breach. Serious latent harm for a payments processor, ranked below the two active findings.
