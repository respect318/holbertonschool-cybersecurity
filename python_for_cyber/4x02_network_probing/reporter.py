"""
Reporter module for NetProbe.
Handles saving output to files.
"""

import json


def save_to_json(data: list, output_file: str):
    """
    Saves scan results to a JSON file.

    Args:
        data (list): The list of results to save.
        output_file (str): The destination file path.
    """
    if output_file:
        with open(output_file, "w", encoding="utf-8") as json_file:
            json.dump(data, json_file, indent=2)
        print(f"Results saved to {output_file}")
