The primary objective of this engagement is to determine if an attacker with developer access can sign and ship a release, and to establish the full reach of a build infrastructure compromise.

To achieve this, the four-day (thirty-hour) window is explicitly allocated across the following phases:
Phase 1: Source and Pipeline Enumeration (Day 1, 8 hours). I will start here because the objective centers on the build system. Gaining command execution via the pipeline definition is the necessary prerequisite for any further lateral movement.
Phase 2: Environment Characterization and Boundary Crossing (Day 2, 8 hours). Once execution on a runner is achieved, I will map the container's namespaces and plan an escape to the underlying host.
Phase 3: Expanding Access and Proving the Objective (Day 3, 8 hours). I will locate the signing authority and determine the maximum extent of the compromise within the internal segment.
Phase 4: Consolidation and Reporting (Day 4, 6 hours).

A strict stopping rule will govern this allocation. I will give any single technical lead a maximum of four hours. The concrete evidence that triggers this stopping rule will be explicit system responses showing a blocked mitigation—such as a specific missing kernel capability, an unresolvable compiler error when adapting a public exploit, or a blocked system call identified via diagnostic output. If the environment definitively lacks the prerequisite condition, I will abandon the lead, document it as a hard boundary limitation, and pivot to a new approach.

Logging will commence immediately, starting before the first engagement action or command is executed. I will maintain a continuous operator log in a structured text file. Every entry will record the exact timestamp, the command run, the raw output received, the technical decision made based on that output, and the results. This ensures the client can definitively deconflict their monitoring alerts against my exact activity.
