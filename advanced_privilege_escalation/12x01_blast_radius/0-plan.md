The primary objective of this engagement is to determine whether an attacker with developer access can sign and ship an Ardent release, and to establish the full reach of a build infrastructure compromise. I have a four-day window, approximately thirty hours, to achieve this.

To serve this objective logically rather than just starting with what is convenient, I have allocated the four-day window across the following phases:
Phase 1: Source and Pipeline Enumeration (Day 1, 8 hours). I must start here because the objective centers on the build system. Understanding the pipeline definition is the necessary prerequisite for achieving command execution on the runner.
Phase 2: Environment Characterization and Escape (Day 2, 8 hours). Once execution on a runner is achieved, I will map the container's namespaces and attempt an escape to the underlying host.
Phase 3: Expanding Access and Proving the Objective (Day 3, 8 hours). I will locate the signing authority and determine the maximum extent of the compromise within the internal segment.
Phase 4: Consolidation and Reporting (Day 4, 6 hours). This ensures time to document limitations properly.

My strict stopping rule sets a specific time limit: I will give any single technical lead a maximum of four hours. The observable evidence that will trigger a reassessment is an explicit system response showing a blocked mitigation. For example, if I see an unresolvable compiler error when adapting an exploit, or diagnostic output showing a definitively blocked system call, I will abandon that lead. This evidence proves the environment lacks the prerequisite condition, so I will move to another lead and document the blocked path as a limitation.

Logging will begin immediately, starting before the first engagement action. I will maintain a continuous text log recording the timestamp, the command run, the raw output received, the technical decision made based on that output, and the results.
