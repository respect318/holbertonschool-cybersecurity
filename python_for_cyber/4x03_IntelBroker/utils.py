#!/usr/bin/env python3
"""Utility functions for caching."""
import json
import os


def load_cache():
    """Loads the cache from cache.json."""
    if os.path.exists("cache.json"):
        try:
            with open("cache.json", "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            return {}
    return {}


def save_cache(cache):
    """Saves the current cache to cache.json."""
    with open("cache.json", "w", encoding="utf-8") as f:
        json.dump(cache, f, indent=2)
