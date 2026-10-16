# Halcyon Triage Log — Shift Handover

FLAG_TRUE_POSITIVES=KST{3689bd99d6295b88610569689e12ee62}
FLAG_FALSE_ALARM=KST{d8e134e1d9a6e6c7c596e37765980c1f}

Regulated-data discipline observed: every record is referenced by identifier only; no personal, credential, or cardholder data is reproduced in this file.

| Alert | Verdict | Confidence | The one fact that decided it | What would change my mind |
|---|---|---|---|---|
| HAL-753699 | True positive | High | 34 auth failures + 3 successes from one external source 198.51.100.12, JA3 ea60867 (HAL-753699) | A vendor/partner authorisation record covering 198.51.100.12 as an expected source |
| HAL-157752 | True positive | High | u.ferreira logon succeeded from VN 198.51.100.12, outside the 4 baseline countries (HAL-157752) | Evidence u.ferreira legitimately travelled/used that source, e.g. an approved remote-access record |
| HAL-214031 | True positive | High | u.ferreira reached remote-gw02 from the same 198.51.100.12 / JA3 as the spray (HAL-214031) | A change/approval record authorising that remote-service access from that source |
| HAL-467427 | True positive | High | 22 directory queries in under 2 minutes from the same actor/JA3 (HAL-467427) | Proof the queries were a sanctioned automated job, not interactive enumeration |
| HAL-502452 | True positive | High | svc_txn_reconcile authenticated to crown-jewel txn-proc01 from legacy-jump03, a host absent from all 14 days of baseline (HAL-502452) | A change record adding legacy-jump03 as an approved batch source for svc_txn_reconcile |
| HAL-242743 | True positive | High | software.authorised=False on the QuickAssist Remote (unmanaged) install (HAL-242743) | An IT approval/allowlist entry authorising that remote-access tool on ws-6250 |
| HAL-723401 | True positive | Medium | finding.acl=none with data_classification=cardholder_format_detected on \\filesvc02\legacy_exports (HAL-723401) | Evidence the share is on an isolated segment with compensating controls, or the files are not truly cardholder data |
| HAL-999978 | False positive | High | Account creation carries change ticket CHG-6913, performed from internal admws-910 (HAL-999978) | N/A |
| HAL-943390 | False positive | High | adm.h.lindqvist logon from internal admws-910 / 10.30.9.177, his normal profile (HAL-943390) | N/A |
| HAL-918535 | False positive | High | export.scheduled=true, recurring monthly EXPORT-FINANCE-MONTHLY job (HAL-918535) | N/A |
| HAL-521013 | False positive | High | Failure reason is password_expired, q.berger profile normal FR/business-hours (HAL-521013) | N/A |
| HAL-943972 | False positive | High | password_expired for s.castillo, no other anomaly (HAL-943972) | N/A |
| HAL-304298 | False positive | High | password_expired for j.kowalski, no other anomaly (HAL-304298) | N/A |
| HAL-319641 | False positive | High | password_expired for u.tanaka, no other anomaly (HAL-319641) | N/A |
| HAL-968414 | False positive | High | password_expired for q.adekunle, no other anomaly (HAL-968414) | N/A |
| HAL-416486 | False positive | Medium | 203.0.113.84 events are port_probe/detected only, no successful connection (HAL-416486) | N/A |
| HAL-993022 | False positive | Medium | 203.0.113.84 probe, detected only, no follow-on access (HAL-993022) | N/A |
| HAL-928498 | False positive | Medium | 203.0.113.84 probe, detected only, no follow-on access (HAL-928498) | N/A |
| HAL-482068 | Noise | High | svc_backup failures from internal 10.34.3.59, backup service misconfig (HAL-482068) | N/A |
| HAL-369229 | Noise | High | svc_backup failures from internal 10.34.3.59 (HAL-369229) | N/A |
| HAL-370342 | Noise | High | svc_backup failures from internal 10.34.3.59 (HAL-370342) | N/A |
| HAL-283568 | Noise | High | svc_backup failures from internal 10.34.3.59 (HAL-283568) | N/A |
| HAL-826555 | Noise | High | svc_backup failures from internal 10.34.3.59 (HAL-826555) | N/A |
| HAL-347915 | Noise | High | svc_backup failures from internal 10.34.3.59 (HAL-347915) | N/A |
| HAL-961124 | Noise | High | svc_backup failures from internal 10.34.3.59 (HAL-961124) | N/A |
| HAL-281673 | Noise | High | svc_backup failures from internal 10.34.3.59 (HAL-281673) | N/A |
| HAL-916029 | Noise | High | svc_backup failures from internal 10.34.3.59 (HAL-916029) | N/A |
| HAL-699743 | Noise | High | service_restart on txn-proc06, routine, no corroborating event (HAL-699743) | N/A |
| HAL-142604 | Noise | High | service_restart on dhcp01, routine (HAL-142604) | N/A |
| HAL-840335 | Noise | High | service_restart on jumpbox02, routine (HAL-840335) | N/A |
| HAL-933816 | Noise | High | service_restart on print-mgmt01, routine (HAL-933816) | N/A |
| HAL-313569 | Noise | High | service_restart on admin-console01, routine (HAL-313569) | N/A |
| HAL-247933 | Noise | High | service_restart on dev-build02, routine (HAL-247933) | N/A |
| HAL-773525 | Noise | High | software.authorised=True browser extension, standard host (HAL-773525) | N/A |
| HAL-739411 | Noise | High | software.authorised=True browser extension, standard host (HAL-739411) | N/A |
| HAL-399387 | Noise | High | Printer queue service crashed/restarted, routine infra (HAL-399387) | N/A |
| HAL-414039 | Noise | High | Disk usage threshold, routine infra, no further pattern (HAL-414039) | N/A |
| HAL-343667 | Noise | Medium | TLS cert nearing expiry, routine infra (HAL-343667) | N/A |
| HAL-174079 | Noise | High | Scheduled nightly index rebuild failed, routine application (HAL-174079) | N/A |
| HAL-971271 | Noise | Medium | Firewall rule change, synthetic routine, no further pattern in queue (HAL-971271) | N/A |
| HAL-141423 | Noise | Medium | New DNS record, synthetic routine, no corroborating event (HAL-141423) | N/A |
