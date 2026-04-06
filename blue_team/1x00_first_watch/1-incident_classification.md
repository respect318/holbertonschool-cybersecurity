# Incident Classification Table

This table classifies each incident using the CIA Triad framework, clearly explaining how each incident impacts Confidentiality, Integrity, or Availability.

| Incident | Primary CIA Pillar | Justification | Secondary CIA Pillar | Secondary Explanation |
|----------|-------------------|--------------|----------------------|----------------------|
| Incident A | Availability | This incident impacts Availability because the ransomware made the billing server inaccessible, preventing users from accessing the system when needed. | Integrity | The encryption process may have altered or destroyed data, impacting its integrity. |
| Incident B | Confidentiality | This incident impacts Confidentiality because unauthorized patients were able to access sensitive lab results that they were not permitted to see. | Integrity | The ability to manipulate URL parameters indicates improper control over data access, which affects integrity. |
| Incident C | Integrity | This incident impacts Integrity because medication dosage data was modified incorrectly by a faulty script, resulting in inaccurate information. | Availability | The system could not reliably provide correct data during the incident, affecting its availability for safe use. |
| Incident D | Integrity | This incident impacts Integrity because the website content was modified without authorization, altering its original state. | Availability | The legitimate website content was temporarily unavailable to users during the defacement. |
| Incident E | Availability | This incident impacts Availability because the EHR system was inaccessible for 9 hours, preventing normal operations. | Integrity | The failed migration and untested rollback introduced a risk of inconsistent or corrupted data. |
| Incident F | Confidentiality | This incident impacts Confidentiality because an unauthorized personal device had access to internal network resources and potentially sensitive data. | Integrity | The presence of an uncontrolled device increases the risk of unauthorized data modification. |
