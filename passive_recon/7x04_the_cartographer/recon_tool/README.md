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
**Dependency setup:** Requires Python 3.9+ and nmap.
**Configuration:** No extra config files are needed.
Run the tool using the recon.py --domain command:
`./recon.py --domain cartograph.example`
**Output artefacts:** The tool produces both structured and Markdown output artefacts (`attack_surface.json` and `attack_surface.md`). Another engineer can run the tool from the documentation.

## Third-Party Transparency
The tools are not treated as black boxes.
- **nmap**: Used for TCP port scanning and service fingerprinting.
- **subfinder**: Used for subdomain enumeration via public APIs.
Integration was chosen over rebuilding because creating custom parsers and massive signature databases from scratch is inefficient and error-prone.
**Known failure or false-positive modes:** nmap might produce false positives on unrecognized service versions, and subfinder may return stale DNS records that no longer resolve.

## Limitations
What the tool does not do: It does not perform active exploitation or vulnerability scanning.
Residual operational risk remains because the tool depends on third-party guarantees. For instance, if an external API goes down or nmap output is malformed, the results will be incomplete. The tool is not perfect.
