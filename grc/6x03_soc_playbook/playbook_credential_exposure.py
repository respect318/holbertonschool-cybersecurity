#!/usr/bin/env python3
"""
playbook_credential_exposure.py
MedDefense SOC — Credential Access & Lateral Movement Triage Playbook

Usage:
    python3 playbook_credential_exposure.py <alert_json_path>

Imports:
    enrich_ioc     — IOC enrichment (verdict, score, tags)
    case_manager   — Case creation and note management

Decision matrix (per credential_exposure_decision_logic.md):
    BLOCK   + any priv       → Critical, escalate, isolation queue
    INVEST  + DA             → Critical, escalate, isolation queue
    INVEST  + SA (not DA)    → High,     open,     no queue
    INVEST  + no priv        → High,     open,     no queue
    ALLOW   + DA             → High,     escalate, no queue
    ALLOW   + SA (not DA)    → Medium,   open,     no queue
    ALLOW   + no priv        → Medium,   open,     no queue
"""

import json
import logging
import os
import sys
from datetime import datetime, timezone

import enrich_ioc
import case_manager

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

PRIVILEGED_ACCOUNTS_FILE = "privileged_accounts.json"
ISOLATION_QUEUE_FILE = "isolation_queue.json"
AUDIT_LOG_FILE = "playbook_audit.log"

MITRE_TECHNIQUES = {
    "T1003.001": "OS Credential Dumping: LSASS Memory",
    "T1550.002": "Use Alternate Authentication Material: Pass the Hash",
    "T1021.002": "Remote Services: SMB/Windows Admin Shares",
    "T1059.001": "Command and Scripting Interpreter: PowerShell",
}

# ---------------------------------------------------------------------------
# Logging
# ---------------------------------------------------------------------------

logging.basicConfig(
    filename=AUDIT_LOG_FILE,
    level=logging.INFO,
    format="%(message)s",
)


def _now_ts() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


# ---------------------------------------------------------------------------
# Privileged account helpers
# ---------------------------------------------------------------------------

def _load_privileged_accounts() -> dict:
    if not os.path.exists(PRIVILEGED_ACCOUNTS_FILE):
        return {"domain_admins": [], "server_admins": []}
    with open(PRIVILEGED_ACCOUNTS_FILE) as f:
        return json.load(f)


def _check_privilege(username: str, accounts: dict) -> tuple[bool, bool]:
    """Return (is_domain_admin, is_server_admin)."""
    da = username.lower() in [u.lower() for u in accounts.get("domain_admins", [])]
    sa = username.lower() in [u.lower() for u in accounts.get("server_admins", [])]
    return da, sa


def _privilege_label(is_da: bool, is_sa: bool) -> str:
    if is_da:
        return "Domain Admin"
    if is_sa:
        return "Server Admin"
    return "Standard User"


# ---------------------------------------------------------------------------
# Decision logic
# ---------------------------------------------------------------------------

def _apply_decision(ip_verdict: str, is_da: bool, is_sa: bool) -> tuple[str, str, bool]:
    """
    Returns (severity, status, write_to_isolation_queue).
    """
    v = ip_verdict.upper()

    if v == "BLOCK":
        return "Critical", "escalated", True

    if v == "INVESTIGATE":
        if is_da:
            return "Critical", "escalated", True
        return "High", "open", False

    # ALLOW
    if is_da:
        return "High", "escalated", False
    if is_sa:
        return "Medium", "open", False
    return "Medium", "open", False


# ---------------------------------------------------------------------------
# Isolation queue
# ---------------------------------------------------------------------------

def _write_isolation_queue(host: str, alert_id: str, case_id: str, reason: str) -> None:
    queue = []
    if os.path.exists(ISOLATION_QUEUE_FILE):
        try:
            with open(ISOLATION_QUEUE_FILE) as f:
                queue = json.load(f)
        except (json.JSONDecodeError, IOError):
            queue = []

    entry = {
        "queued_at": _now_ts(),
        "host": host,
        "alert_id": alert_id,
        "case_id": case_id,
        "reason": reason,
        "action_required": "Analyst must authorize isolation via EDR console before execution",
        "status": "pending_authorization",
    }
    queue.append(entry)

    with open(ISOLATION_QUEUE_FILE, "w") as f:
        json.dump(queue, f, indent=2)


# ---------------------------------------------------------------------------
# Main playbook
# ---------------------------------------------------------------------------

def run_playbook(alert_path: str) -> None:
    ts = _now_ts()

    # Load alert
    with open(alert_path) as f:
        alert = json.load(f)

    alert_id = alert.get("alert_id", "UNKNOWN")
    rule_name = alert.get("rule_name", "unknown")
    raw_log = alert.get("raw_log", {})

    # Extract required fields
    source_ip = raw_log.get("source_ip", "")
    username = raw_log.get("username", "")
    host = raw_log.get("host", "")
    mitre_technique = raw_log.get("mitre_technique", "")

    technique_name = MITRE_TECHNIQUES.get(mitre_technique, "Unknown Technique")

    # Enrich source IP
    ip_result = enrich_ioc.enrich_ioc(source_ip, ioc_type="ipv4")
    ip_verdict = ip_result["verdict"]
    ip_score = ip_result["score"]
    ip_category = ip_result["category"]
    ip_tags = ip_result.get("tags", [])

    # Check privilege
    accounts = _load_privileged_accounts()
    is_da, is_sa = _check_privilege(username, accounts)
    priv_label = _privilege_label(is_da, is_sa)

    # Apply decision matrix
    severity, status, queue_host = _apply_decision(ip_verdict, is_da, is_sa)

    # Build action description
    if queue_host:
        action = f"Host written to {ISOLATION_QUEUE_FILE} for analyst authorization"
    elif status == "escalated":
        action = "Escalated: privileged account anomaly from internal IP — manual review required"
    else:
        action = "Manual review required — assign to on-call analyst"

    # Build isolation reason
    isolation_reason = (
        f"{mitre_technique} ({technique_name}) from "
        f"{'known C2 IP ' if ip_verdict == 'BLOCK' else 'IP '}{source_ip} "
        f"(verdict={ip_verdict}) by {priv_label} {username}"
    )

    # Create case
    case_title = f"Credential Access: {technique_name} — {host} [{severity}]"
    ioc_entry = {
        "ioc_value": source_ip,
        "ioc_type": "ipv4",
        "verdict": ip_verdict,
        "score": ip_score,
        "category": ip_category,
        "tags": ip_tags,
    }
    case = case_manager.create_case(
        alert_id=alert_id,
        severity=severity,
        title=case_title,
        status=status,
        iocs=[ioc_entry],
    )
    case_id = case["case_id"]

    # Add enrichment note
    enrichment_note = (
        f"Playbook: credential_exposure | Alert: {alert_id} | "
        f"Rule: {rule_name} | Host: {host} | User: {username} ({priv_label}) | "
        f"Source IP: {source_ip} verdict={ip_verdict} score={ip_score} tags={ip_tags} | "
        f"MITRE: {mitre_technique} ({technique_name}) | "
        f"Decision: severity={severity} status={status} isolation_queue={'yes' if queue_host else 'no'} | "
        f"Reasoning: IP verdict is {ip_verdict}; username '{username}' is {priv_label}. "
        f"{'BLOCK verdict alone triggers Critical escalation and isolation queue.' if ip_verdict == 'BLOCK' else ''}"
        f"{'Domain Admin involvement from INVESTIGATE IP triggers Critical escalation and isolation queue.' if ip_verdict == 'INVESTIGATE' and is_da else ''}"
        f"{'Domain Admin anomaly from ALLOW/internal IP triggers High escalation.' if ip_verdict == 'ALLOW' and is_da else ''}"
    )
    case_manager.add_note(case_id, enrichment_note)

    # Write to isolation queue if required
    if queue_host:
        _write_isolation_queue(host, alert_id, case_id, isolation_reason)

    # Audit log
    isolation_flag = "yes" if queue_host else "no"
    log_line = (
        f"{ts} | CREDENTIAL_EXPOSURE | {alert_id} | "
        f"Host:{host} | User:{username} | IPVerdict:{ip_verdict} | "
        f"Privilege:{priv_label} | Case:{case_id} | "
        f"Severity:{severity} | IsolationQueued:{isolation_flag}"
    )
    logging.info(log_line)

    # Stdout summary
    print(f"[{ts}] CREDENTIAL EXPOSURE PLAYBOOK")
    print(f"Alert      : {alert_id}")
    print(f"Rule       : {rule_name}")
    print(f"Host       : {host}")
    print(f"User       : {username}  Privilege: {priv_label}")
    print(f"Source IP  : {source_ip}  Verdict: {ip_verdict}  Score: {ip_score}")
    if ip_tags:
        print(f"IP Tags    : {', '.join(ip_tags)}")
    print(f"MITRE      : {mitre_technique} {technique_name}")
    print(f"Case       : {case_id}  Severity: {severity}  Status: {status}")
    print(f"Action     : {action}")
    if queue_host:
        print(f"IsoQueue   : {ISOLATION_QUEUE_FILE} — pending analyst authorization")
    print()


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 playbook_credential_exposure.py <alert_json_path>")
        sys.exit(1)

    alert_file = sys.argv[1]
    if not os.path.exists(alert_file):
        print(f"ERROR: Alert file not found: {alert_file}")
        sys.exit(1)

    run_playbook(alert_file)
