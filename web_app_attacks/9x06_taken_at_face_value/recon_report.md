# Reconnaissance Report: Northbridge Digital Bank

## 1. Scope and Rules of Engagement
This assessment is an **authorized, isolated assessment** of the fictional **Northbridge Digital Bank portal**. All testing is strictly limited to the provided **lab environment** and relies entirely on **fictional data**. 

**Controlled-Exploitation Boundary:**
Testing is governed by strict rules of engagement. All actions taken during this assessment will be **minimal and reversible**. When demonstrating impact, we will use only the **smallest lab amount** necessary to prove a point. There will be absolutely **no destructive activity** against the platform or its data, and no techniques or data discovered here will be used outside this isolated lab environment.

## 2. Asset-Criticality Model and Severity
Severity during this engagement will not be assigned abstractly. Every severity rating will be directly tied to this asset-criticality model and argued against its specific effect on money movement, customer authority, the confirmation step, privileged functions, and auditability.

**Crown-Jewel Flows:**
These are the high-risk flows that move money or change authority. They represent the core target of this assessment:
* Login and session management
* Account access
* Internal and external transfers
* Beneficiary management
* The transaction confirmation step
* Support and admin functions
* The audit and monitoring trail

**Peripheral Surfaces:**
Surfaces that do not handle core financial or authorization actions are categorized as lower-criticality. These include:
* Marketing pages
* User preferences
* Notification settings

## 3. Assessment Methodology
The engagement will be conducted following a structured, phased approach to ensure comprehensive coverage of the high-risk areas:

1. **Functional reconnaissance:** Mapping out the application's intended behavior, endpoints, and logic flows.
2. **Object and role mapping:** Identifying the resources available and the authorization roles governing them.
3. **Hypothesis-driven testing of high-risk flows:** Formulating and executing specific attack vectors against the crown-jewel assets.
4. **Controlled proof:** Demonstrating the impact of discovered vulnerabilities safely, strictly adhering to the controlled-exploitation boundary.
5. **Logging analysis:** Reviewing the audit and monitoring trail to determine if the platform successfully records malicious actions and attribution.
6. **Reporting:** Documenting the findings, evidence, and actionable remediation steps.
