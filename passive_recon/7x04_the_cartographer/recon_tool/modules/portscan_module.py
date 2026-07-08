#!/usr/bin/python3
"""
Port Scan Module for The Cartographer.
Intelligent wrapper around nmap, parsing XML output into structured state.
"""
import subprocess
import tempfile
import os
import xml.etree.ElementTree as ET
from core.module_base import ModuleBase

class PortScanModule(ModuleBase):
    @property
    def name(self) -> str:
        return "portscan"

    @property
    def dependencies(self) -> list:
        # Declares dependencies on dns and subdomain modules
        return ["dns", "subdomain"]

    def run(self, state):
        # We target all discovered domains and IP addresses
        targets = list(state.domains) + list(state.hosts.keys())
        if not targets:
            return

        # Deduplicate targets before scanning
        unique_targets = list(set(targets))

        for target in unique_targets:
            # Create a temporary file to hold the XML output
            fd, temp_xml = tempfile.mkstemp(suffix=".xml")
            os.close(fd)

            try:
                # nmap invocation: full TCP range (-p-), moderate timing (-T3), service detection (-sV), XML output (-oX)
                subprocess.run(
                    ['nmap', '-p-', '-T3', '-sV', '-oX', temp_xml, target],
                    capture_output=True,
                    text=True,
                    timeout=300  # Prevent infinite hangs
                )

                # Parse the XML output
                tree = ET.parse(temp_xml)
                root = tree.getroot()

                for host_node in root.findall('.//host'):
                    for port_node in host_node.findall('.//port'):
                        state_node = port_node.find('state')
                        if state_node is None or state_node.get('state') != 'open':
                            continue

                        port = int(port_node.get('portid'))
                        service_node = port_node.find('service')
                        
                        service = "unknown"
                        version = "unknown"
                        product = "unknown"
                        banner = "none"
                        status = "suspected"

                        if service_node is not None:
                            service = service_node.get('name', 'unknown')
                            product = service_node.get('product', 'unknown')
                            version = service_node.get('version', 'unknown')
                            extrainfo = service_node.get('extrainfo', '')
                            if extrainfo:
                                banner = extrainfo

                            # Check the confidence of the service detection
                            confidence = int(service_node.get('conf', '0'))
                            if confidence >= 8:
                                status = "confirmed"
                            else:
                                status = "suspected"

                        # We merge and upsert findings into the deduplicated state
                        state.add_service(target, port, f"{service} ({status})")

                        # Print details
                        print(f"[*] Open port on {target}:{port} - {service}/{version} (Product: {product}, Banner: {banner}, Status: {status})")

                        # Flag logic for the intranet submission
                        if port in [2222, 54321, 8443, 9443] or "management" in service.lower():
                            print(f"[MANAGEMENT_FLAG] {target}:{port}")
                            
                        if "portal" in product.lower() or service == "http" or port in [80, 443, 8080]:
                            if version != "unknown":
                                print(f"[PORTAL_FLAG] {service}/{version}")

            except Exception:
                pass
            finally:
                # Clean up the temporary XML file
                if os.path.exists(temp_xml):
                    os.remove(temp_xml)
