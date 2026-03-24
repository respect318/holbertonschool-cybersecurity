#!/usr/bin/env python3
"""Dossier model for intelligence data."""
from datetime import datetime


class TargetDossier:
    """Represents a target dossier with aggregated intelligence."""
    def __init__(self, ip=""):
        self.ip = ip
        self.vt_data = {}
        self.abuse_data = {}
        self.shodan_data = {}
        self.nmap_ports = []

    def to_dict(self):
        """Returns a structured dictionary for JSON export."""
        return {
            "target": self.ip,
            "timestamp": datetime.now().isoformat(),
            "intelligence": {
                "virustotal": self.vt_data,
                "abuseipdb": self.abuse_data,
                "shodan": self.shodan_data,
                "nmap_open_ports": self.nmap_ports
            }
        }
