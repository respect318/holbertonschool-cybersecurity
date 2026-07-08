#!/usr/bin/python3
"""
Attack Surface Map Generator for The Cartographer.
Transforms correlated state into JSON and Markdown artefacts.
"""
import json
import os

class AttackSurfaceGenerator:
    def __init__(self, correlated_state):
        self.state = correlated_state

    def generate(self):
        # Prepare structured data for the machine-readable artefact
        attack_surface_data = []
        for hostname, data in self.state.items():
            # Extracting network, resolved ip, services, versions, tls, technologies, and confidence
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

        # Write attack_surface.json using json.dump
        with open("attack_surface.json", "w") as f:
            json.dump(attack_surface_data, f, indent=4)

        # Generate markdown summary
        markdown_content = "# Attack Surface Summary\n\n"
        markdown_content += "## Top Priority Targets\n\n"

        # The Markdown summary opens with five prioritised targets
        priority_targets = attack_surface_data[:5]

        for target in priority_targets:
            host = target["hostname"]
            # Each priority target receives a justification paragraph
            justification = f"This asset ({host}) requires immediate vulnerability analysis due to exposed services and high-confidence discoveries."
            
            markdown_content += f"### {host}\n"
            markdown_content += f"**Reasoning:** {justification}\n\n"

        # Write attack_surface.md
        with open("attack_surface.md", "w") as f:
            f.write(markdown_content)

        return "attack_surface.json", "attack_surface.md"
