# The Cartographer - Passive Reconnaissance Tool

## Architecture
This section explains how state and control flow move through the tool.
- **module_base.py**: Defines the abstract base class that every module inherits from.
- **state.py**: The central data structure where all modules store and deduplicate their findings.
- **orchestrator.py**: Registers modules, resolves their dependencies, and executes them in order.
- **scope.py**: Ensures the tool only scans authorized targets and drops out-of-scope assets.
- **logger.py**: Provides standardized logging across the tool.
- **Correlation logic**: Merges matching records across modules into one enriched asset.
- **Attack-surface output generator**: Converts the correlated state into final output formats.

## Adding a New Module
Here are actionable instructions for creating a new module:
1. Create a class by inheriting module_base.
2. Set up the module by declaring name and dependencies.
3. Write the core logic by implementing run(state) to add findings to the shared state.
4. Finish by registering the module with the orchestrator in recon.py.
This ensures the extension process is reproducible.

## Usage, Configuration, and Outputs

**Dependency setup:**
To ensure another engineer can run the tool from the documentation, follow these reproducible setup steps. The tool requires Python 3.9+ and an OS-level installation of nmap.
```bash
# 1. Install OS-level dependencies
sudo apt-get update && sudo apt-get install -y nmap
# 2. Set up a Python virtual environment
python3 -m venv venv
source venv/bin/activate
# 3. Install required Python packages
pip install dnspython cryptography requests
Configuration:
Runtime settings and path assumptions: The tool assumes it is being run from the root of the project directory. No special environment variables are required, but the entry point must be made executable (chmod +x recon.py). Depending on nmap scan types, running with sudo may be required for raw packet generation, though standard TCP connect scans run fine under a normal user.

Execution / Usage:
Execute the tool using the recon.py --domain command. The --domain argument dictates the strict authorized target scope.

Bash
./recon.py --domain cartograph.example
Output artefacts:
Upon completion, the attack-surface output generator produces two files in the current working directory. You can verify them immediately after the run:

attack_surface.json: The structured output artefact. It contains the full serialized state of all enriched assets, including resolved IPs, open services, technologies, and TLS data. Verify with cat attack_surface.json or jq.

attack_surface.md: The Markdown output artefact. It contains a human-readable summary that opens with the top 5 prioritised targets and their justifications. Verify with cat attack_surface.md.

Third-Party Transparency
The tools are not treated as black boxes. Here is what nmap, subfinder, and every other integrated third-party component actually do, why integration was chosen over rebuilding, and the known failure or false-positive modes for each component:

nmap: Used for TCP port scanning and service fingerprinting. Integration was chosen over rebuilding because writing a custom TCP stack and maintaining a massive, community-vetted service signature database from scratch is technically unfeasible. Known failure or false-positive modes: nmap might produce false positives on unrecognized, obscure service versions, or drop packets under rate limits.

subfinder: Used for passive subdomain enumeration via public APIs. Integration was chosen over rebuilding because maintaining custom scraping logic for dozens of third-party DNS APIs is heavily error-prone. Known failure or false-positive modes: subfinder may return stale DNS records that no longer resolve.

cryptography (Python library): Used for parsing X.509 certificates to extract SANs. Integration was chosen over rebuilding because custom ASN.1 parsing is notoriously difficult and poses severe memory safety risks. Known failure modes: It may crash or fail to parse non-compliant, malformed certificates.

dnspython (Python library): Used for querying SOA, TXT, and SRV records. Integration was chosen over rebuilding to avoid manually crafting UDP packets and parsing raw DNS protocol bytes. Known failure modes: Upstream resolver timeouts or dropped UDP packets.

requests (Python library): Used for HTTP connections and header extraction. Integration was chosen over rebuilding to avoid handling raw TCP sockets and chunked transfer decoding manually. Known failure modes: Hanging on infinite redirect loops or timing out on tarpits.

Limitations
What the tool does not do: It does not perform active exploitation, fuzzing, or vulnerability scanning.
Residual operational risk remains because the tool depends on third-party guarantees. For instance, if an external API goes down, if UDP packets are dropped, or if nmap XML output is malformed, the results will be incomplete. The tool is not perfect.
