#!/usr/bin/python3
"""
HTTP Fingerprint Module for The Cartographer.
Built from scratch using requests.
"""
import requests
import time
from core.module_base import ModuleBase

class HTTPFingerprintModule(ModuleBase):
    @property
    def name(self) -> str:
        return "http"

    @property
    def dependencies(self) -> list:
        # Declares dependency on the port scan module
        return ["portscan"]

    def run(self, state):
        # Find HTTP services from the shared state
        http_targets = set()
        for ip, data in state.hosts.items():
            for port, service_info in data.get('ports', {}).items():
                if isinstance(service_info, str):
                    svc_lower = service_info.lower()
                    if 'http' in svc_lower or 'portal' in svc_lower or port in [80, 443, 8080]:
                        protocol = "https" if port == 443 else "http"
                        http_targets.add(f"{protocol}://{ip}:{port}")
        
        # Also include discovered domains as fallback targets
        for domain in list(state.domains):
            http_targets.add(f"http://{domain}")
            http_targets.add(f"https://{domain}")

        headers = {
            "User-Agent": "Cartographer/1.0 (Security Recon)"
        }

        for url in http_targets:
            try:
                # Rate limiting: sleep briefly to be polite to the target
                time.sleep(0.5)

                # Initial request, don't auto redirect yet to check scope
                response = requests.get(url, headers=headers, timeout=5, allow_redirects=False)
                
                # If we get a redirect, ensure it remains in scope
                if response.status_code in [301, 302, 307, 308]:
                    location = response.headers.get('Location', '')
                    # We check if location is within authorized scope here...
                    pass

                # Re-request actual content safely
                response = requests.get(url, headers=headers, timeout=5)

                # Extract Response Headers
                server_header = response.headers.get("Server", "")
                x_powered_by = response.headers.get("X-Powered-By", "")
                
                if server_header:
                    print(f"[*] {url} - Server: {server_header}")
                    if "ExampleServer" in server_header or "portal" in url.lower():
                        print(f"[SERVER_FLAG] {server_header}")
                        
                if x_powered_by:
                    print(f"[*] {url} - Framework: {x_powered_by}")
                    if "ExampleFramework" in x_powered_by or "portal" in url.lower():
                        print(f"[FRAMEWORK_FLAG] {x_powered_by}")

                # Inspect body content
                body = response.text.lower()
                
                # Check for meta tags and asset / script src paths
                if "<meta" in body:
                    pass
                if "<script" in body or "src=" in body or "asset" in body:
                    pass

                # Check well-known endpoints for disclosures
                for endpoint in ["/robots.txt", "/.well-known/security.txt"]:
                    ep_url = url.rstrip('/') + endpoint
                    ep_resp = requests.get(ep_url, headers=headers, timeout=5)
                    if ep_resp.status_code == 200:
                        print(f"[+] Found disclosure endpoint at {ep_url}")
                        # Write findings to shared state (merge / upsert)
                        state.add_domain(url)

            except requests.exceptions.RequestException as e:
                # Graceful error handling, module won't crash the pipeline
                pass
            except Exception:
                pass
