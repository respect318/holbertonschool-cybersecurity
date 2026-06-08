#!/usr/bin/env python3
"""
playbook_credential_exposure.py - Credential Exposure Automation Playbook

Enriches the source IP, checks whether the involved account is privileged,
applies decision logic, and writes flagged hosts to an isolation queue
for human-authorized action.

Usage:
    python3 playbook_credential_exposure.py alerts/ALT-20260428-007.json
"""

import json
import sys
import os
import logging
from datetime import datetime, timezone

import enrich_ioc as enrich_ioc_module
import case_manager

# Configure audit log
logging.basicConfig(
    filename="playbook_audit.log",
    level=logging.INFO,
    format="%(message)s",
)
audit_logger = logging.getLogger("playbook_audit")

# MITRE ATT&CK technique descriptions
MITRE_TECHNIQUES = {
    "T1003.001": "OS Credential Dumping: LSASS Memory",
    "T1550.002": "Use Alternate Authentication Material: Pass the Hash",
    "T1021.002": "Remote Services: SMB/Windows Admin Shares",
    "T1059.001": "Command and Scripting Interpreter: PowerShell",
    "T1055": "Process Injection",
    "T1078": "Valid Accounts",
    "T1110": "Brute Force",
}

PRIVILEGED_ACCOUNTS_PATH = "privileged_accounts.json"
ISOLATION_QUEUE_PATH = "isolation_queue.json"


def _now() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def load_privileged_accounts(path: str = PRIVILEGED_ACCOUNTS_PATH) -> dict:
    """Load the privileged accounts inventory."""
    try:
        with open(path) as f:
            return json.load(f)
    except (OSError, json.JSONDecodeError) as e:
        print(f"[WARNING] Could not load privileged accounts: {e}", file=sys.stderr)
        return {"domain_admins": [], "server_admins": []}


def check_privilege(username: str, accounts: dict) -> tuple:
    """
    Check if a username is a domain admin or server admin.
    Returns (is_domain_admin: bool, is_server_admin: bool).
    """
    domain_admins = [u.lower() for u in accounts.get("domain_admins", [])]
    server_admins = [u.lower() for u in accounts.get("server_admins", [])]
    uname = username.lower()
    return (uname in domain_admins, uname in server_admins)


def queue_isolation(host: str, alert_id: str, case_id: str, reason: str,
                    path: str = ISOLATION_QUEUE_PATH) -> None:
    """
    Append a host to the isolation queue JSON file.
    Creates the file with an empty list if it does not exist.
    This is a human-authorization queue only — no actual isolation is performed.
    """
    # Load existing queue
    if os.path.exists(path):
        try:
            with open(path) as f:
                queue = json.load(f)
        except (OSError, json.JSONDecodeError):
            queue = []
    else:
        queue = []

    entry = {
        "queued_at": _now(),
        "host": host,
        "alert_id": alert_id,
        "case_id": case_id,
        "reason": reason,
        "action_required": "Analyst must authorize isolation via EDR console before execution",
        "status": "pending_authorization",
    }
    queue.append(entry)

    with open(path, "w") as f:
        json.dump(queue, f, indent=2)


def run_playbook(alert_path: str) -> int:
    """
    Run the credential exposure playbook against a single alert file.
    Returns 0 on success, 1 on unrecoverable error.
    """
    # Load alert
    try:
        with open(alert_path) as f:
            alert = json.load(f)
    except (json.JSONDecodeError, OSError) as e:
        print(f"[ERROR] Could not load alert file '{alert_path}': {e}", file=sys.stderr)
        return 1

    alert_id = alert.get("alert_id", "UNKNOWN")
    rule_name = alert.get("rule_name", "unknown")
    ts = _now()
    raw_log = alert.get("raw_log", {})

    # Extract fields
    source_ip = raw_log.get("source_ip")
    username = raw_log.get("username", "")
    host = raw_log.get("host", "")
    mitre_technique = raw_log.get("mitre_technique", "")
    technique_name = MITRE_TECHNIQUES.get(mitre_technique, mitre_technique)

    if not source_ip:
        print(f"[ERROR] Missing required field 'source_ip' in alert {alert_id}", file=sys.stderr)
        return 1

    # Enrich source IP
    try:
        ip_result = enrich_ioc_module.enrich_ioc(source_ip)
    except Exception as e:
        print(f"[WARNING] Enrichment failed for {source_ip}: {e}", file=sys.stderr)
        ip_result = {
            "ioc": source_ip, "type": "ipv4", "verdict": "INVESTIGATE",
            "score": 30, "feed_result": {"in_malicious_feed": False, "in_benign_list": False},
        }

    ip_verdict = ip_result.get("verdict", "INVESTIGATE")
    ip_score = ip_result.get("score", 0)
    ip_class = ip_result.get("ip_class", "")

    # Load privileged accounts
    accounts = load_privileged_accounts()
    is_da, is_sa = check_privilege(username, accounts)

    privilege_label = "Domain Admin" if is_da else ("Server Admin" if is_sa else "Standard User")

    # Apply decision logic
    write_isolation = False
    escalate = False

    if ip_verdict == "BLOCK":
        case_severity = "Critical"
        case_status = "escalated"
        write_isolation = True
        escalate = True
        action_label = "escalated"
    elif ip_verdict == "INVESTIGATE":
        if is_da:
            case_severity = "Critical"
            case_status = "escalated"
            write_isolation = True
            escalate = True
            action_label = "escalated"
        else:
            case_severity = "High"
            case_status = "open"
            action_label = "manual review"
    else:  # ALLOW
        if is_da:
            case_severity = "High"
            case_status = "escalated"
            escalate = True
            action_label = "escalated (privileged account anomaly)"
        elif is_sa:
            case_severity = "Medium"
            case_status = "open"
            action_label = "manual review"
        else:
            case_severity = "Medium"
            case_status = "open"
            action_label = "manual review"

    # IOCs for case
    iocs_for_case = [
        {
            "ioc_value": ip_result.get("ioc", source_ip),
            "ioc_type": ip_result.get("type", "ipv4"),
            "verdict": ip_verdict,
            "score": ip_score,
        }
    ]

    # Case title and description
    case_title = (
        f"Credential Exposure: {mitre_technique} on {host} by {username}"
    )
    case_description = (
        f"Alert {alert_id}: {technique_name} detected on {host}. "
        f"Source IP: {source_ip} (verdict: {ip_verdict}). "
        f"User: {username} ({privilege_label}). "
        f"MITRE: {mitre_technique} - {technique_name}."
    )

    # Create case
    try:
        case_id = case_manager.create_case(
            alert_id=alert_id,
            severity=case_severity,
            title=case_title,
            description=case_description,
            iocs=iocs_for_case,
        )
    except Exception as e:
        print(f"[ERROR] Database write failure: {e}", file=sys.stderr)
        return 1

    # Update status
    case_manager.update_case_status(case_id, case_status)

    # Add enrichment note
    feed_result = ip_result.get("feed_result", {})
    tags = feed_result.get("tags", [])
    cat = feed_result.get("category", "")
    tag_str = ", ".join(tags) if tags else cat
    note = (
        f"Playbook verdict: {case_severity}/{case_status}. "
        f"Source IP: {source_ip} verdict={ip_verdict} score={ip_score}"
        + (f" ({tag_str})" if tag_str else "") + ". "
        f"User: {username} ({privilege_label}). "
        f"MITRE: {mitre_technique} - {technique_name}. "
        f"Host: {host}. "
        f"Reasoning: IP verdict={ip_verdict}, is_DA={is_da}, is_SA={is_sa} → {case_severity} {action_label}."
    )
    case_manager.add_case_note(case_id, note)

    # Isolation queue
    if write_isolation:
        reason = (
            f"{technique_name} from {'known C2 IP ' if ip_verdict == 'BLOCK' else ''}"
            f"{source_ip} by {privilege_label} {username}"
        )
        queue_isolation(host, alert_id, case_id, reason)

    # Audit log
    isolation_flag = "yes" if write_isolation else "no"
    audit_line = (
        f"{ts} | CREDENTIAL_EXPOSURE | {alert_id} | "
        f"Host:{host} | User:{username} | IPVerdict:{ip_verdict} | "
        f"Privilege:{privilege_label} | Case:{case_id} | "
        f"Severity:{case_severity} | IsolationQueued:{isolation_flag}"
    )
    audit_logger.info(audit_line)

    # Stdout summary
    print(f"[{ts}] CREDENTIAL EXPOSURE PLAYBOOK")
    print(f"Alert      : {alert_id}")
    print(f"Rule       : {rule_name}")
    print(f"Host       : {host}")
    print(f"MITRE      : {mitre_technique} - {technique_name}")
    print(f"Source IP  : {source_ip}  Class: {ip_class}  Verdict: {ip_verdict}  Score: {ip_score}")
    if tag_str:
        print(f"  Feed tags: {tag_str}")
    print(f"Username   : {username}  ({privilege_label})")
    print(f"Verdict    : {case_severity} / {case_status}")
    if write_isolation:
        print(f"Isolation  : {host} queued in {ISOLATION_QUEUE_PATH} (pending analyst authorization)")
    print(f"Case       : {case_id}  Severity: {case_severity}  Status: {case_status}")
    if "escalat" in action_label:
        print(f"Action     : Escalated — {action_label}")
    else:
        print(f"Action     : {action_label.title()}")

    return 0


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 playbook_credential_exposure.py <alert_file.json>")
        sys.exit(1)

    alert_path = sys.argv[1]
    sys.exit(run_playbook(alert_path))


if __name__ == "__main__":
    main()
