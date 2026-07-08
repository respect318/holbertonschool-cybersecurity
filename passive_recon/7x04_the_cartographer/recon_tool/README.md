# The Cartographer - Passive Reconnaissance Tool

## Architecture & Core Components
The Cartographer is a modular passive reconnaissance pipeline designed to build a correlated attack-surface map. The control flow moves through several core components before generating artifacts:
* **`core/module_base.py`**: The abstract base class that enforces the interface (name, dependencies, run method) for all modules.
* **`core/state.py`**: The centralized, deduplicated data store where all modules write their findings (domains, IPs, open ports).
* **`core/orchestrator.py`**: The engine that registers modules, resolves dependencies, and executes them in the correct sequential order while handling timeouts.
* **`core/scope.py`**: The boundary enforcer that ensures the tool never interacts with or stores data outside the authorized target domain.
* **`core/logger.py`**: Provides standardized, timestamped logging across all modules and core systems.
* **`core/correlation.py`**: The logic that runs post-pipeline to merge disparate findings (hostname, resolved IP, certificate SAN) into a single enriched asset record.
* **`output/attack_surface.py`**: The output generator that transforms the correlated state into a machine-readable `attack_surface.json` and a human-readable `attack_surface.md` summary.

## How to Add a New Module
The module system is highly extensible. To add a new module, an engineer must:
1.  Create a new file in `modules/` and inherit from `ModuleBase` (e.g., `class CustomModule(ModuleBase):`).
2.  Define the `name` property (e.g., `return "custom_recon"`).
3.  Declare upstream dependencies in the `dependencies` property (e.g., `return ["dns"]`).
4.  Implement the `run(self, state)` method to execute the recon logic and write findings to `state` (e.g., `state.add_domain()`).
5.  Register the module in `recon.py` by calling `orchestrator.register(CustomModule())`.

## Usage & Configuration
**Dependency Setup:**
The tool requires Python 3.9+, `nmap` installed on the host system, and standard libraries.
```bash
sudo apt install nmap
pip install requests cryptography dnspython
