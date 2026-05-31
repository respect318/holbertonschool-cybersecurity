#!/bin/bash

# Execute inline python3 for robust JSON and data parsing using native libraries
python3 - << 'EOF'
import json
import subprocess
import re
import os

cve_feed = {}
if os.path.exists('cve_feed.json'):
    with open('cve_feed.json', 'r') as f:
        cve_feed = json.load(f)

packages_data = []

# Get upgradable packages
try:
    apt_list = subprocess.check_output(['apt', 'list', '--upgradable'], stderr=subprocess.DEVNULL).decode('utf-8')
except Exception:
    apt_list = ""

for line in apt_list.splitlines():
    if '/' not in line or 'Listing' in line:
        continue
    
    parts = line.split()
    pkg = parts[0].split('/')[0]
    cand_ver = parts[1]
    
    # Check installed version
    try:
        dpkg_out = subprocess.check_output(['dpkg-query', '-W', '-f=${Version}', pkg], stderr=subprocess.DEVNULL).decode('utf-8')
        inst_ver = dpkg_out.strip()
    except:
        continue
        
    if not inst_ver:
        continue

    # Extract source pocket
    pocket = "unknown"
    try:
        policy = subprocess.check_output(['apt-cache', 'policy', pkg], stderr=subprocess.DEVNULL).decode('utf-8')
        for p_line in policy.splitlines():
            if 'http' in p_line and any(x in p_line for x in ['security', 'updates', 'backports']):
                m = re.search(r'([a-z0-9]+-\w+)', p_line)
                if m:
                    pocket = m.group(1)
                    break
    except:
        pass

    # Extract CVEs from changelog
    cves = []
    try:
        clog = subprocess.check_output(['apt-get', 'changelog', pkg], stderr=subprocess.DEVNULL).decode('utf-8', errors='ignore')
        cves = list(set(re.findall(r'CVE-\d{4}-\d+', clog)))
    except:
        pass

    if not cves:
        continue

    # Calculate max CVSS and KEV status
    max_cvss = 0.0
    in_cisa = False
    
    for cve in cves:
        if cve in cve_feed:
            score = float(cve_feed[cve].get('cvss', 0.0))
            if score > max_cvss: 
                max_cvss = score
            if cve_feed[cve].get('in_cisa_kev', False): 
                in_cisa = True
            
    # Determine severity
    if max_cvss == 0.0: severity = "unknown"
    elif max_cvss < 4.0: severity = "low"
    elif max_cvss < 7.0: severity = "medium"
    elif max_cvss < 9.0: severity = "high"
    else: severity = "critical"

    packages_data.append({
        "package": pkg,
        "installed_version": inst_ver,
        "candidate_version": cand_ver,
        "source_pocket": pocket,
        "cves": cves,
        "max_cvss": max_cvss,
        "severity": severity,
        "in_cisa_kev": in_cisa
    })

# Write output to JSON
with open('vulnerability_inventory.json', 'w') as f:
    json.dump({"packages": packages_data}, f, indent=2)

EOF
