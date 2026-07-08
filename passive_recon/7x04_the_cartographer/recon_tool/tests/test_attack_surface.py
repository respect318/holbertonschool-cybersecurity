#!/usr/bin/python3
"""
Tests for the Attack Surface Map Generator.
"""
import sys
import os
import json

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from output.attack_surface import AttackSurfaceGenerator

def test_generator():
    # Fabricate correlated state
    fabricated_state = {
        "cartograph.example": {
            "ips": ["127.40.0.10"],
            "services": ["http", "ssh"],
            "certificates": ["san: cartograph.example"],
            "technologies": ["nginx"]
        }
    }

    generator = AttackSurfaceGenerator(fabricated_state)
    json_file, md_file = generator.generate()

    # Validate json and attack_surface.md results
    assert os.path.exists(json_file)
    assert os.path.exists("attack_surface.md")

    # Read and assert JSON content
    with open(json_file, "r") as f:
        data = json.load(f)
        assert len(data) == 1
        assert data[0]["hostname"] == "cartograph.example"

    # Clean up test artefacts
    os.remove(json_file)
    os.remove("attack_surface.md")

    # Surface the flag for intranet
    print("FLAG-ATTACK-SURFACE-MAPPED")

if __name__ == "__main__":
    test_generator()
