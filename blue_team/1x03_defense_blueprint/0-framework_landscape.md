# 0. The Framework Landscape

## Part 1 - Three-Framework Summary

### **NIST CSF 2.0 (Cybersecurity Framework)**
The NIST Cybersecurity Framework 2.0 is a voluntary guidance published by the National Institute of Standards and Technology (NIST) to help organizations manage and reduce cybersecurity risk. It is designed to provide a common language for both internal and external communication regarding security posture. The framework is structured around six core functions: **Govern, Identify, Protect, Detect, Respond, and Recover**. Organizations of all sizes use NIST CSF to align their technical security activities with their business requirements and risk appetite.

### **CIS Controls v8**
Published by the Center for Internet Security (CIS), the CIS Controls v8 is a prioritized set of 18 critical safeguards designed to mitigate the most common and impactful cyber-attacks. Its primary purpose is to provide "essential cyber hygiene" through actionable, technical steps rather than high-level policy. The controls are structured into three **Implementation Groups (IGs)** based on an organization's resource profile and risk exposure. It is typically used by technical teams and system administrators who need a practical, "how-to" checklist to secure their environment immediately.

### **ISO/IEC 27001**
ISO 27001 is an international standard published by the International Organization for Standardization (ISO) that specifies requirements for establishing, implementing, and maintaining an Information Security Management System (ISMS). Its primary purpose is to provide a formal framework for managing information risk through a process-driven approach. The standard is structured into 11 main clauses focused on management requirements and **Annex A**, which contains 93 security controls. It is most commonly used by organizations that need to demonstrate their security maturity to global partners or regulators through a formal certification process.

---

## Part 2 - Relationship Map

These three frameworks are complementary tools that function as a cohesive ecosystem rather than competitors. A useful mental model to understand their relationship is to see **NIST CSF** as the strategic brain that answers **"What should we do?"** to manage risk. **CIS Controls** serves as the technical hands, answering **"How should we do it?"** with specific, prioritized safeguards. Finally, **ISO 27001** acts as the formal witness, answering **"Can we prove we are doing it?"** by providing the management structure and audit requirements for certification. By using them together, an organization can plan strategically (NIST), implement effectively (CIS), and verify officially (ISO).

---

## Part 3 - MedDefense Framework Selection

### **Recommendation: NIST CSF 2.0 (Strategy) + CIS Controls v8 IG1 (Execution)**

**Justification:**
For a regional hospital like MedDefense with a limited security staff (one analyst and one deputy CISO), a combined approach is the most efficient path forward:

* **Practicality over Complexity:** With a small team, pursuing ISO 27001 certification immediately would be overwhelming due to its heavy documentation and administrative requirements. Instead, **CIS Controls v8 Implementation Group 1 (IG1)** provides a "safe harbor" of technical steps that can be implemented quickly to protect patient data and critical systems.
* **Strategic Communication:** The **NIST CSF 2.0** should be used as the high-level backbone to report progress to the Board and regulators. Its "Govern" and "Identify" functions will help the deputy CISO justify budget and resource needs in a language the Board understands.
* **Compliance Alignment:** While MedDefense is not a federal agency, using NIST CSF ensures the hospital is following industry best practices. This provides a strong defensive position if audited by health regulators, as it demonstrates a structured approach to risk management that can eventually evolve into a full ISO certification if needed in the future.
