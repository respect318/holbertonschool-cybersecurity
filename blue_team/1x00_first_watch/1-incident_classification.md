# Incident Classification Log

| Incident | Primary Pillar | Justification | Secondary Pillar | Connection |
| :--- | :--- | :--- | :--- | :--- |
| **Incident A** | Availability | The ransomware encrypted the billing server, rendering the system and its critical data completely inaccessible to the finance team for four days. | Integrity | The original data and system files were modified (encrypted) by an unauthorized ransomware payload, compromising their original state. |
| **Incident B** | Confidentiality | A broken access control allowed unauthorized users (patients) to view sensitive Protected Health Information (PHI) belonging to other patients. | None | N/A |
| **Incident C** | Integrity | A database update script bug unintentionally altered the medication dosage values without authorization, resulting in untrustworthy medical data across all sites. | None | N/A |
| **Incident D** | Integrity | The public-facing website was defaced, meaning its content was intentionally modified and replaced by an unauthorized actor. | Availability | The legitimate website and its intended informational services were inaccessible to the public for the two hours it took to restore. |
| **Incident E** | Availability | A failed database migration caused a 9-hour operational outage, making the critical EHR system and patient data inaccessible to physicians. | None | N/A |
| **Incident F** | Confidentiality | An unauthorized personal device running a file-sharing (torrent) client was on the internal network, creating a severe risk of unauthorized access to the HR file share. | None | N/A |
