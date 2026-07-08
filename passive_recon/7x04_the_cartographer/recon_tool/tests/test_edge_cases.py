import sys
import os
import subprocess

def test_edge_cases():
    recon_script = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "recon.py"))
    
    # Test nonexistent domain
    result = subprocess.run(
        ["python3", recon_script, "--domain", "does-not-exist.invalid"],
        capture_output=True,
        text=True
    )
    
    # Verify graceful handling without traceback
    assert "Traceback" not in result.stderr
    
    # Check returncode and stderr / stdout
    assert result.returncode != 0
    
    print("FLAG-EDGE-CASES-HANDLED")

if __name__ == "__main__":
    test_edge_cases()
