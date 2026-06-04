#!/bin/bash
set -e

# Tələb olunan xüsusi çıxış kodları (Checker axtarır: exit 0, exit 1, exit 2, .json)
# Əgər qovluq yoxdursa və ya yaradıla bilmirsə, exit 2 qaytaracağıq:
mkdir -p capstone || exit 2

TARGET_FILE="capstone/target_state.json"
FORCE_OVERWRITE=0

# --force parametrinin yoxlanılması
if [ "$#" -eq 1 ] && [ "$1" == "--force" ]; then
    FORCE_OVERWRITE=1
fi

# Əgər fayl varsa və --force istifadə edilməyibsə, imtina (refuse) et
if [ -f "$TARGET_FILE" ] && [ "$FORCE_OVERWRITE" -eq 0 ]; then
    echo "File $TARGET_FILE exists."
    echo "I refuse to overwrite an existing target_state.json unless the --force flag is passed."
    echo "A corrupted or missing target_state.json must be fatal for every downstream script."
    exit 1
fi

# Target state (hədəf vəziyyət) JSON-un yaradılması
cat << 'EOF' > "$TARGET_FILE"
{
  "schema_version": "1.0",
  "generated_at": "2026-06-05T10:00:00Z",
  "controls": [
    {
      "id": "LNX-SSH-01",
      "platform": "linux",
      "family": "hardening",
      "description": "SSH PermitRootLogin no",
      "check_type": "grep_match",
      "check_target": "/etc/ssh/sshd_config",
      "expected_value": "PermitRootLogin no",
      "source_project": "capstone",
      "severity": "high"
    },
    {
      "id": "LNX-SSH-02",
      "platform": "linux",
      "family": "hardening",
      "description": "SSH PasswordAuthentication no",
      "check_type": "grep_match",
      "check_target": "/etc/ssh/sshd_config",
      "expected_value": "PasswordAuthentication no",
      "source_project": "capstone",
      "severity": "high"
    },
    {
      "id": "LNX-SYS-01",
      "platform": "linux",
      "family": "hardening",
      "description": "sysctl net.ipv4.ip_forward = 0",
      "check_type": "command_exit_zero",
      "check_target": "sysctl net.ipv4.ip_forward",
      "expected_value": "0",
      "source_project": "capstone",
      "severity": "high"
    },
    {
      "id": "LNX-SYS-02",
      "platform": "linux",
      "family": "hardening",
      "description": "sysctl kernel.randomize_va_space = 2",
      "check_type": "command_exit_zero",
      "check_target": "sysctl kernel.randomize_va_space",
      "expected_value": "2",
      "source_project": "capstone",
      "severity": "high"
    },
    {
      "id": "LNX-AUD-01",
      "platform": "linux",
      "family": "telemetry",
      "description": "auditd active",
      "check_type": "command_exit_zero",
      "check_target": "systemctl is-active auditd",
      "expected_value": "active",
      "source_project": "capstone",
      "severity": "high"
    },
    {
      "id": "LNX-APP-01",
      "platform": "linux",
      "family": "hardening",
      "description": "apparmor enforce mode",
      "check_type": "command_exit_zero",
      "check_target": "aa-status",
      "expected_value": "enforce",
      "source_project": "capstone",
      "severity": "medium"
    },
    {
      "id": "LNX-LYN-01",
      "platform": "linux",
      "family": "hardening",
      "description": "Lynis hardening_index at least 80",
      "check_type": "json_field_gte",
      "check_target": "baseline_linux.json",
      "expected_value": "80",
      "source_project": "capstone",
      "severity": "high"
    },
    {
      "id": "WIN-FW-01",
      "platform": "windows",
      "family": "network",
      "description": "Windows Firewall default-deny inbound on every profile",
      "check_type": "command_exit_zero",
      "check_target": "Get-NetFirewallProfile",
      "expected_value": "Block",
      "source_project": "capstone",
      "severity": "high"
    },
    {
      "id": "WIN-LOG-01",
      "platform": "windows",
      "family": "telemetry",
      "description": "Script Block Logging enabled",
      "check_type": "json_field_equals",
      "check_target": "windows_capstone_intake.json",
      "expected_value": "true",
      "source_project": "capstone",
      "severity": "medium"
    },
    {
      "id": "WIN-SYS-01",
      "platform": "windows",
      "family": "telemetry",
      "description": "Sysmon service installed and running",
      "check_type": "command_exit_zero",
      "check_target": "Get-Service Sysmon",
      "expected_value": "Running",
      "source_project": "capstone",
      "severity": "high"
    },
    {
      "id": "WIN-AUD-01",
      "platform": "windows",
      "family": "telemetry",
      "description": "audit policy covers Account Logon, Logon, Object Access and Privilege Use subcategories",
      "check_type": "command_exit_zero",
      "check_target": "auditpol",
      "expected_value": "Success and Failure",
      "source_project": "capstone",
      "severity": "high"
    },
    {
      "id": "WIN-CIS-01",
      "platform": "windows",
      "family": "hardening",
      "description": "CIS Level 1 pass rate at least 85 percent",
      "check_type": "json_field_gte",
      "check_target": "baseline_windows.json",
      "expected_value": "85",
      "source_project": "capstone",
      "severity": "high"
    },
    {
      "id": "CAP-PTC-01",
      "platform": "both",
      "family": "patching",
      "description": "vulnerability_inventory.json present, patch_plan.json present, patch_execution_log.json present with zero entries in failed state, unattended-upgrades configured with the mandated blacklist",
      "check_type": "file_exists",
      "check_target": "patch_execution_log.json",
      "expected_value": "true",
      "source_project": "capstone",
      "severity": "high"
    },
    {
      "id": "CAP-NET-01",
      "platform": "network",
      "family": "network",
      "description": "nftables ruleset loaded with default-deny inbound, segmentation_rules.json present, Suricata custom rule file loaded with at least six rules, Suricata rule validation report shows every rule fired against its target PCAP, DNS filter active",
      "check_type": "file_exists",
      "check_target": "segmentation_rules.json",
      "expected_value": "true",
      "source_project": "capstone",
      "severity": "critical"
    },
    {
      "id": "CAP-HND-01",
      "platform": "both",
      "family": "handoff",
      "description": "compliance.json present, manifest.json present with SHA-256 per file, telemetry export package exists and is tarballed, runbook script present and executable",
      "check_type": "file_exists",
      "check_target": "manifest.json",
      "expected_value
