# The Cartographer - Passive Reconnaissance Tool

## Architecture
This section explains how state and control flow move through the tool:
- **module_base.py**: The abstract base class that enforces the interface for all modules.
- **state.py**: The central data structure where findings are stored and deduplicated.
- **orchestrator.py**: Registers modules, resolves dependencies, and executes the pipeline in order.
- **scope.py**: The guard that ensures the tool drops out-of-scope assets.
- **logger.py**: Provides standardized, timestamped logging across the tool.
- **Correlation logic**: Merges matching records across modules (by IP, hostname, or SAN) into one enriched asset.
- **Attack-surface output generator**: Consumes the correlated state to produce final structured and human-readable artifacts.

## Adding a New Module
The extension process is reproducible by following these actionable instructions for creating a new module:
1. Start by **inheriting module_base**.
2. Setup the module by **declaring name and dependencies**.
3. Write the core logic by **implementing run(state)** to write findings to the shared state.
4. Activate it by **registering the module with the orchestrator** in `recon.py`.

## Usage, Configuration, and Outputs
Another engineer can run the tool from the documentation alone using this reproducible setup path.
**Dependency setup:**
1. Install OS-level requirements for nmap: `sudo apt-get update && sudo apt-get install -y nmap`
2. Set up the Python environment: `python3 -m venv venv && source venv/bin/activate`
3. Install required Python libraries: `pip install cryptography dnspython requests`

**Configuration:**
Runtime settings require no special environment variables. Path assumptions strictly assume the tool is executed from the project root directory. Ensure the entry point is executable (`chmod +x recon.py`).

**Execution:**
Run the tool using the recon.py --domain command:
`./recon.py --domain cartograph.example`

**Output artefacts:**
The tool generates both structured and Markdown output artefacts in the root directory:
- `attack_surface.json`: The structured JSON artifact detailing the final correlated state.
- `attack_surface.md`: The Markdown artifact providing a human-readable summary.
Verify them using `cat attack_surface.json` and `cat attack_surface.md` after the run.

## Third-Party Transparency
The integrated tools are not treated as black boxes.
- **nmap**: Used for TCP port scanning and service fingerprinting. Integration was chosen over rebuilding because maintaining a massive, community-vetted service signature database and custom TCP stack is technically unfeasible. Known failure or false-positive modes: nmap might produce false positives on unrecognized service versions, or drop packets under rate limits.
- **subfinder**: Used for passive subdomain enumeration. Integration was chosen over rebuilding because maintaining scraping logic for dozens of third-party APIs is heavily error-prone. Known failure or false-positive modes: subfinder often returns stale DNS records that no longer resolve.
- **cryptography**: Used for parsing X.509 certificates to extract SANs. Integration was chosen over rebuilding because custom ASN.1 parsing is notoriously difficult and poses memory safety risks. Known failure modes: It may crash on non-compliant, malformed certificates.
- **dnspython**: Used for querying DNS records. Integration was chosen over rebuilding to avoid manually crafting UDP packets. Known failure modes: Upstream resolver timeouts.
- **requests**: Used for HTTP connections. Integration was chosen over rebuilding to avoid handling raw TCP sockets manually. Known failure modes: Hanging on infinite redirect loops.

## Limitations
What the tool does not do: It does not perform active exploitation, fuzzing, or credential brute-forcing. 
Residual operational risk remains because the tool depends on third-party guarantees. For instance, if an external API goes down, or if nmap XML output is malformed, the pipeline will produce an incomplete map. Avoid claiming the tool is perfect; it provides only a point-in-time snapshot.
