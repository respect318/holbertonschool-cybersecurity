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
**Dependency setup:** Requires Python 3.9+, dnspython, cryptography, requests, and nmap installed on the host.
**Configuration:** No extra config files are needed.
Run the tool using the recon.py --domain command:
`./recon.py --domain cartograph.example`
**Output artefacts:** The tool produces both structured and Markdown output artefacts (`attack_surface.json` and `attack_surface.md`). Another engineer can run the tool from the documentation.

## Third-Party Transparency
The tools are not treated as black boxes. Here is what nmap, subfinder, and every other integrated third-party component actually do, why integration was chosen over rebuilding, and the known failure or false-positive modes for each component:

- **nmap**: Used for TCP port scanning and service fingerprinting. Integration was chosen over rebuilding because writing a custom TCP stack and maintaining a massive, community-vetted service signature database from scratch is technically unfeasible. Known failure or false-positive modes: nmap might produce false positives on unrecognized, obscure service versions, or drop packets under rate limits.
- **subfinder**: Used for passive subdomain enumeration via public APIs. Integration was chosen over rebuilding because maintaining custom scraping logic for dozens of third-party DNS APIs is heavily error-prone. Known failure or false-positive modes: subfinder may return stale DNS records that no longer resolve.
- **cryptography (Python library)**: Used for parsing X.509 certificates to extract SANs. Integration was chosen over rebuilding because custom ASN.1 parsing is notoriously difficult and poses severe memory safety risks. Known failure modes: It may crash or fail to parse non-compliant, malformed certificates.
- **dnspython (Python library)**: Used for querying SOA, TXT, and SRV records. Integration was chosen over rebuilding to avoid manually crafting UDP packets and parsing raw DNS protocol bytes. Known failure modes: Upstream resolver timeouts or dropped UDP packets.
- **requests (Python library)**: Used for HTTP connections and header extraction. Integration was chosen over rebuilding to avoid handling raw TCP sockets and chunked transfer decoding manually. Known failure modes: Hanging on infinite redirect loops or timing out on tarpits.

## Limitations
What the tool does not do: It does not perform active exploitation, fuzzing, or vulnerability scanning.
Residual operational risk remains because the tool depends on third-party guarantees. For instance, if an external API goes down, if UDP packets are dropped, or if nmap XML output is malformed, the results will be incomplete. The tool is not perfect.
