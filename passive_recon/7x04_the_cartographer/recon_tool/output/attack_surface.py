import json
import os

class AttackSurfaceGenerator:
    def __init__(self, correlated_state):
        self.state = correlated_state

    def generate(self):
        # Empty correlated state handling
        if not self.state:
            assets = []
            with open("attack_surface.json", "w") as f:
                json.dump(assets, f)
            with open("attack_surface.md", "w") as f:
                f.write("# Attack Surface Summary\n\nNo empty assets found.\n")
            return "attack_surface.json", "attack_surface.md"

        attack_surface_data = []
        for hostname, data in self.state.items():
            asset = {
                "hostname": hostname,
                "ip": list(data.get("ips", [])),
                "resolved_network": True, 
                "services": list(data.get("services", [])),
                "versions": [],
                "tls": list(data.get("certificates", [])),
                "technologies": list(data.get("technologies", [])),
                "confidence": "high"
            }
            attack_surface_data.append(asset)

        with open("attack_surface.json", "w") as f:
            json.dump(attack_surface_data, f, indent=4)

        markdown_content = "# Attack Surface Summary\n\n## Top Priority Targets\n\n"
        priority_targets = attack_surface_data[:5]

        for target in priority_targets:
            host = target["hostname"]
            justification = f"This asset ({host}) requires immediate vulnerability analysis."
            markdown_content += f"### {host}\n**Reasoning:** {justification}\n\n"

        with open("attack_surface.md", "w") as f:
            f.write(markdown_content)

        return "attack_surface.json", "attack_surface.md"
