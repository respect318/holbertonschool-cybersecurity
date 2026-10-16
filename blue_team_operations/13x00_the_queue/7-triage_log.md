# Halcyon Triage Log — Shift Handover

FLAG_TRUE_POSITIVES=KST{3689bd99d6295b88610569689e12ee62}
FLAG_FALSE_ALARM=KST{d8e134e1d9a6e6c7c596e37765980c1f}

Regulated-data discipline observed: all records referenced by identifier only; no personal, credential, or cardholder data reproduced.

| # | Alert | Verdict | Confidence | The one fact that decided it | What would change my mind |
|---|---|---|---|---|---|
| 1 | HAL-753699 | True positive | High | 34 auth failures + 3 successes from one external source (HAL-753699) | A vendor/partner record authorising 198.51.100.12 as an expected source |
| 2 | HAL-157752 | True positive | High | Logon succeeded from a country outside the 4 baseline countries (HAL-157752) | An approved remote-access record for that user from that source |
| 3 | HAL-214031 | True positive | High | Remote-gw02 reached from the same source/JA3 as the spray (HAL-214031) | A change record authorising that remote-service access |
| 4 | HAL-467427 | True positive | High | 22 directory queries in under 2 minutes, same actor/JA3 (HAL-467427) | Proof the queries were a sanctioned automated job |
| 5 | HAL-502452 | True positive | Medium | Service account reached crown-jewel txn-proc01 from a host absent from baseline (HAL-502452) | A change record adding legacy-jump03 as an approved batch source |
| 6 | HAL-242743 | True positive | High | software.authorised=False on the installed remote-access tool (HAL-242743) | An IT allowlist entry authorising that tool on the host |
| 7 | HAL-723401 | True positive | Medium | finding.acl=none with cardholder-format classification (HAL-723401) | Evidence of an isolated segment with compensating controls |
| 8 | HAL-999978 | False positive | High | Account creation carries change ticket CHG-6913 (HAL-999978) | N/A |
| 9 | HAL-943390 | False positive | High | Logon from the admin's normal internal workstation (HAL-943390) | N/A |
| 10 | HAL-918535 | False positive | High | export.scheduled=true, recurring monthly job (HAL-918535) | N/A |
| 11 | HAL-521013 | False positive | High | Failure reason field is password_expired (HAL-521013) | N/A |
| 12 | HAL-943972 | False positive | High | Failure reason field is password_expired (HAL-943972) | N/A |
| 13 | HAL-304298 | False positive | Medium | password_expired, user profile not fully reviewed (HAL-304298) | N/A |
| 14 | HAL-319641 | False positive | Medium | password_expired, user profile not fully reviewed (HAL-319641) | N/A |
| 15 | HAL-968414 | False positive | Medium | password_expired, user profile not fully reviewed (HAL-968414) | N/A |
| 16 | HAL-416486 | False positive | High | Events are port_probe/detected only, no successful connection (HAL-416486) | N/A |
| 17 | HAL-993022 | False positive | Medium | Port probe, detected only, no follow-on seen (HAL-993022) | N/A |
| 18 | HAL-928498 | False positive | Medium | Port probe, detected only, no follow-on seen (HAL-928498) | N/A |
| 19 | HAL-482068 | Noise | High | svc_backup failures from an internal backup source (HAL-482068) | N/A |
| 20 | HAL-369229 | Noise | Medium | Same svc_backup internal-source pattern (HAL-369229) | N/A |
| 21 | HAL-370342 | Noise | Medium | Same svc_backup internal-source pattern (HAL-370342) | N/A |
| 22 | HAL-283568 | Noise | Medium | Same svc_backup internal-source pattern (HAL-283568) | N/A |
| 23 | HAL-826555 | Noise | Medium | Same svc_backup internal-source pattern (HAL-826555) | N/A |
| 24 | HAL-347915 | Noise | Medium | Same svc_backup internal-source pattern (HAL-347915) | N/A |
| 25 | HAL-961124 | Noise | Medium | Same svc_backup internal-source pattern (HAL-961124) | N/A |
| 26 | HAL-281673 | Noise | Medium | Same svc_backup internal-source pattern (HAL-281673) | N/A |
| 27 | HAL-916029 | Noise | Medium | Same svc_backup internal-source pattern (HAL-916029) | N/A |
| 28 | HAL-699743 | Noise | Medium | Routine service_restart on an internal host (HAL-699743) | N/A |
| 29 | HAL-142604 | Noise | Medium | Routine service_restart on an internal host (HAL-142604) | N/A |
| 30 | HAL-840335 | Noise | Medium | Routine service_restart on an internal host (HAL-840335) | N/A |
| 31 | HAL-933816 | Noise | Medium | Routine service_restart on an internal host (HAL-933816) | N/A |
| 32 | HAL-313569 | Noise | Medium | Routine service_restart on an internal host (HAL-313569) | N/A |
| 33 | HAL-247933 | Noise | Medium | Routine service_restart on an internal host (HAL-247933) | N/A |
| 34 | HAL-773525 | Noise | High | software.authorised=True browser extension on a standard host (HAL-773525) | N/A |
| 35 | HAL-739411 | Noise | High | software.authorised=True browser extension on a standard host (HAL-739411) | N/A |
| 36 | HAL-399387 | Noise | Medium | Printer queue service restart, routine infra (HAL-399387) | N/A |
| 37 | HAL-414039 | Noise | Medium | Disk-usage threshold, routine infra (HAL-414039) | N/A |
| 38 | HAL-343667 | Noise | Low | TLS cert nearing expiry; verdict rests only on absence of further pattern (HAL-343667) | N/A |
| 39 | HAL-174079 | Noise | Low | Scheduled job failure; verdict rests only on absence of further pattern (HAL-174079) | N/A |
| 40 | HAL-971271 | Noise | Low | Firewall rule change; only evidence is "no further pattern in queue" (HAL-971271) | N/A |
| 41 | HAL-141423 | Noise | Low | New DNS record; only evidence is "no further pattern in queue" (HAL-141423) | N/A |
