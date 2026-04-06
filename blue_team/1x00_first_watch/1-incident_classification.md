# Incident Classification Table

This table classifies each incident using the CIA Triad framework, identifying the primary impact, justification, and any secondary impact.

| Incident | Primary CIA Pillar | Justification | Secondary CIA Pillar | Secondary Explanation |
|----------|-------------------|--------------|----------------------|----------------------|
| Incident A | Availability | The ransomware attack made the billing server inaccessible, preventing the finance team from processing claims for 4 days. | Integrity | The encryption and outdated backup created a risk of data loss or corruption. |
| Incident B | Confidentiality | Patients were able to access other patients' lab results due to broken access control in the portal. | Integrity | The ability to manipulate URL parameters shows improper control over how data is accessed. |
| Incident C | Integrity | Medication dosages were incorrectly modified due to a faulty database update script. | Availability | The system could not provide reliable and correct data during the incident period. |
| Incident D | Integrity | The website was defaced, meaning its content was modified without authorization. | Availability | The legitimate website content was temporarily unavailable to users. |
| Incident E | Availability | The EHR system was unavailable for 9 hours during a failed database migration. | Integrity | The untested rollback procedure introduced a risk of inconsistent or corrupted data. |
| Incident F | Confidentiality | An unauthorized personal laptop had access to the internal network, exposing sensitive resources. | Integrity | The device could potentially modify or compromise internal data due to lack of control. |
