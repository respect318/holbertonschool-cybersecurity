Architecture Plan, The Cartographer
Architecture
module_base.py defines the universal interface contract for all modules. state.py centralizes finding storage, preventing duplicate records using strict entity normalization (e.g., canonicalizing IPs and domains). orchestrator.py resolves module dependencies and executes them in a valid topological order. scope.py acts as the absolute gatekeeper, validating targets to ensure no module operates outside the authorized boundary. All third-party components are strictly constrained: they receive only scope-validated targets and controlled arguments, their behavior is understood rather than treated as a black box, and their outputs are carefully parsed into the internal finding model to contain any unexpected target expansion.

Build order
Shared foundations: module_base.py, state.py, and scope.py. This ensures the safe module contract, duplicate prevention, and strict scope enforcement exist before any network interaction occurs.

The pipeline: orchestrator.py, which depends on the base interfaces and state.

Operational modules (DNS, Subdomain, Port, HTTP, TLS). These are built last because they inherently depend on the foundational scope validations and state correlation to function safely.

Module decisions
DNS: from scratch ; Ensures precise protocol control and strict scoping without delegating unsafe sub-process calls.

Subdomain: hybrid ; Leverages Subfinder for mature passive capabilities, but relies on internal DNS validation to strictly filter false positives.

Port scan: nmap wrapper ; Nmap is exceptionally reliable; a wrapper allows us to enforce safe arguments and parse its XML output to prevent opaque execution.

HTTP fingerprint: from scratch ; Allows custom bounded timeouts and strict, in-scope-only redirect following.

TLS: from scratch ; Using Python's native ssl module provides full transparency when extracting SAN entries without black-box delegation.

Klaus's lesson
Applied: I will not treat third-party tools as black boxes; I will strictly understand their behavior, control their arguments, and validate their outputs to prevent out-of-scope expansion.
Not applied: I will not read every single line of source code for mature tools like Nmap. Instead, due to project time constraints, I will ensure safety through strict input/output containment and our scope boundary guard.
