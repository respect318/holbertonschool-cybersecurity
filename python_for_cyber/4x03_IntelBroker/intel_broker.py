#!/usr/bin/env python3
"""
Intelligence Broker module.
Contains functions to query external Threat Intelligence APIs.
"""
import requests


def query_virustotal(ip: str) -> dict:
    """
    Queries the mock VirusTotal API for reputation data on a given IP.

    Args:
        ip (str): The IP address to query.

    Returns:
        dict: The JSON payload returned by the API, or an error dictionary.
    """
    url = f"http://localhost:5000/virustotal/{ip}"
    
    try:
        response = requests.get(url, timeout=10)
        
        # Check if the HTTP status code is 200 (OK)
        if response.status_code == 200:
            return response.json()
        
        # Handle non-200 responses gracefully
        return {"error": f"Received HTTP {response.status_code}"}
        
    except requests.exceptions.ConnectionError:
        print(f"[ERROR] Could not connect to API server at {url}. Is mock_api.py running?")
        return {"error": "ConnectionError"}
    except Exception as e:
        print(f"[ERROR] An unexpected error occurred: {e}")
        return {"error": str(e)}


if __name__ == "__main__":
    # Test the function with a dummy IP
    print(query_virustotal("1.2.3.4"))
