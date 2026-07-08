# 🗺️ The Cartographer

> **Automated, Scope-Safe Attack Surface Mapping Pipeline**

**The Cartographer** is a highly modular reconnaissance tool engineered for Red Team engagements. Built entirely in Python, it automates the asset discovery phase by orchestrating custom scanning modules and intelligent wrappers around industry-standard tools. 

The core philosophy of this project is **strict interface discipline and scope safety**—ensuring no out-of-bounds assets are ever touched during automated reconnaissance.

## ✨ Key Engineering Highlights

* **Modular Architecture:** Built with Python's `abc` module. Each scanning module operates independently and communicates solely through a unified `state.py` data engine.
* **Smart Orchestration:** A custom orchestrator dynamically resolves module dependencies, prevents circular logic, and handles module crashes gracefully without halting the entire pipeline.
* **Strict Scope Guard:** A robust pre-scan validation engine that strictly blocks wildcard traps, out-of-scope SAN entries, and suffix redirection tricks.
* **Hybrid Tooling:** 
  * *From Scratch:* Custom DNS enumeration and HTTP fingerprinting built directly in Python.
  * *Intelligent Wrappers:* Integrates `nmap` and `subfinder` via safe `subprocess` calls (avoiding `shell=True`), parsing their raw XML/JSON outputs directly into the shared state.
* **Data Correlation:** Automatically deduplicates and enriches findings across multiple modules to output a single, clean Attack-Surface Map.

## 🛠️ Tech Stack & Skills Demonstrated
* **Language:** Python 3.8+
* **Core Concepts:** OOP (Abstract Base Classes), Subprocess Management, Data Correlation, JSON Schema.
* **Security Domains:** External Reconnaissance, Attack Surface Management, OSINT, DNS/TLS Analysis, Safe Tool Automation.

## 🚀 Quick Start

```bash
git clone [https://github.com/respect318/the-cartographer.git](https://github.com/respect318/the-cartographer.git)
cd the-cartographer/recon_tool
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt

# Run the pipeline against an authorized target
./recon.py --domain example.com
