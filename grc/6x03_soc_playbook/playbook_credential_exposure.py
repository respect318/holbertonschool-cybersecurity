#!/usr/bin/env python3
"""
Credential Exposure and Lateral Movement Playbook
MedDefense SOC Automation - Task 4
"""

import sys
import json
import os
from datetime import datetime, timezone

import enrich_ioc
import case_manager

# ---------------------------------------------------------------------------
# MITRE ATT&CK technique reference
# ---------------------------------------------------------------------------
MITRE_TECHNIQUES = {
    "T1003.001": "OS Credential Dumping: LSASS Memory",
    "T1550.002": "Use Alternate Authentication Material: Pass the Hash",
    "T1021.002": "Remote Services: SMB/Windows Admin Shares",
    "T1059.001": "Command and Scripting Interpreter: PowerShell",
}

PRIVILEGED_ACCOUNTS_FILE = "privileged_accounts.json"
ISOLATION_QUEUE_FILE = "isolation_queue.json"
AUDIT_LOG_FILE = "playbook_audit.log"


def load_privileged_accounts():
    with open(PRIVILEGED_ACCOUNTS_FILE, "r") as f:
        return json.load(f)


def check_privilege(username, privileged_accounts):
    """Return ('Domain Admin', True, False) / ('Server Admin', False, True) / ('None', False, False)"""
    da = [u.lower() for u in privileged_accounts.get("domain_admins", [])]
    sa = [u.lower() for u in privileged_accounts.get("server_admins", [])]
    uname = username.lower()
    is_da = uname in da
    is_sa = uname in sa
    if is_da:
        label = "Domain Admin"
    elif is_sa:
        label = "Server Admin"
    else:
        label = "Standard User"
    return label, is_da, is_sa


def decide(ip_verdict, is_da, is_sa):
    """
    Returns (severity, case_status, queue_isolation)
    per credential_exposure_decision_logic.md
    """
    if ip_verdict == "BLOCK":
        return "Critical", "escalated", True
    elif ip_verdict == "INVESTIGATE":
        if is_da:
            return "Critical", "escalated", True
        else:
            return "High", "open", False
    else:  # ALLOW
        if is_da:
            return "High", "escalated", False
        elif is_sa:
            return "Medium", "open", False
        else:
            return "Medium", "open", False


def write_isolation_queue(host, alert_id, case_id, reason):
    entry = {
        "queued_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "host": host,
        "alert_id": alert_id,
        "case_id": case_id,
        "reason": reason,
        "action_required": "Analyst must authorize isolation via EDR console before execution",
        "status": "pending_authorization",
    }
    queue = []
    if os.path.exists(ISOLATION_QUEUE_FILE):
        with open(ISOLATION_QUEUE_FILE, "r") as f:
            try:
                queue = json.load(f)
            except json.JSONDecodeError:
                queue = []
    queue.append(entry)
    with open(ISOLATION_QUEUE_FILE, "w") as f:
        json.dump(queue, f, indent=2)
    return entry


def write_audit_log(ts, alert_id, host, username, ip_verdict, priv_label, case_id, severity, queued):
    line = (
        f"{ts} | CREDENTIAL_EXPOSURE | {alert_id} | Host:{host} | User:{username} | "
        f"IPVerdict:{ip_verdict} | Privilege:{priv_label} | Case:{case_id} | "
        f"Severity:{severity} | IsolationQueued:{'yes' if queued else 'no'}\n"
    )
    with open(AUDIT_LOG_FILE, "a") as f:
        f.write(line)


def run_playbook(alert_path):
    # -----------------------------------------------------------------------
    # Load alert
    # -----------------------------------------------------------------------
    with open(alert_path, "r") as f:
        alert = json.load(f)

    alert_id = alert.get("alert_id", "UNKNOWN")
    alert_ts = alert.get("timestamp", datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"))
    rule_name = alert.get("rule_name", "")
    raw_log = alert.get("raw_log", {})

    source_ip = raw_log.get("source_ip", "")
    username = raw_log.get("username", "")
    host = raw_log.get("host", "")
    mitre_technique = raw_log.get("mitre_technique", "")

    now_ts = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

    # -----------------------------------------------------------------------
    # Enrich source IP
    # -----------------------------------------------------------------------
    enrichment = enrich_ioc.enrich_ioc(source_ip, "ipv4")
    ip_verdict = enrichment.get("verdict", "ALLOW")
    ip_score = enrichment.get("score", 0)
    ip_tags = enrichment.get("tags", [])

    # -----------------------------------------------------------------------
    # Check privilege
    # -----------------------------------------------------------------------
    privileged_accounts = load_privileged_accounts()
    priv_label, is_da, is_sa = check_privilege(username, privileged_accounts)

    # -----------------------------------------------------------------------
    # Decision logic
    # -----------------------------------------------------------------------
    severity, case_status, queue_isolation = decide(ip_verdict, is_da, is_sa)

    # MITRE description
    technique_name = MITRE_TECHNIQUES.get(mitre_technique, mitre_technique)

    # -----------------------------------------------------------------------
    # Create case
    # -----------------------------------------------------------------------
    title = f"Credential Exposure: {rule_name} on {host}"
    case = case_manager.create_case(
        alert_id=alert_id,
        severity=severity,
        title=title,
        status=case_status,
    )
    case_id = case["case_id"]

    # -----------------------------------------------------------------------
    # Isolation queue
    # -----------------------------------------------------------------------
    isolation_entry = None
    if queue_isolation:
        reason = (
            f"{mitre_technique} ({technique_name}) from "
            f"{'known C2 IP ' if ip_verdict == 'BLOCK' else 'IP '}{source_ip} "
            f"by {priv_label} {username} on {host}"
        )
        isolation_entry = write_isolation_queue(host, alert_id, case_id, reason)

    # -----------------------------------------------------------------------
    # Case note
    # -----------------------------------------------------------------------
    note_lines = [
        f"=== CREDENTIAL EXPOSURE PLAYBOOK ENRICHMENT ===",
        f"Alert ID  : {alert_id}",
        f"Host      : {host}",
        f"User      : {username}  Privilege: {priv_label}",
        f"Source IP : {source_ip}  Verdict: {ip_verdict}  Score: {ip_score}",
        f"IP Tags   : {', '.join(ip_tags) if ip_tags else 'none'}",
        f"MITRE     : {mitre_technique} {technique_name}",
        f"Severity  : {severity}",
        f"Status    : {case_status}",
    ]
    if queue_isolation and isolation_entry:
        note_lines.append(f"Isolation : Host written to isolation_queue.json — {isolation_entry['reason']}")
        note_lines.append("Action    : Analyst must authorize isolation via EDR console before execution")

    # Verdict reasoning
    if ip_verdict == "BLOCK":
        note_lines.append(
            f"Reasoning : Source IP {source_ip} is a known C2/malicious IP (score {ip_score}). "
            f"Any BLOCK-IP credential alert is automatically Critical and queued for isolation regardless of account privilege."
        )
    elif ip_verdict == "INVESTIGATE" and is_da:
        note_lines.append(
            f"Reasoning : Source IP flagged for investigation and username {username} holds Domain Admin rights. "
            f"Combined, this matches the prior lateral movement attack path. Escalated Critical."
        )
    elif ip_verdict == "ALLOW" and is_da:
        note_lines.append(
            f"Reasoning : Source IP is internal/allowed but {username} is a Domain Admin. "
            f"Privileged account anomaly from internal IP — escalated as High."
        )
    else:
        note_lines.append(
            f"Reasoning : Source IP verdict {ip_verdict}, non-Domain-Admin account. Flagged for manual review."
        )

    case_manager.add_case_note(case_id, "\n".join(note_lines))

    # -----------------------------------------------------------------------
    # Audit log
    # -----------------------------------------------------------------------
    write_audit_log(now_ts, alert_id, host, username, ip_verdict, priv_label, case_id, severity, queue_isolation)

    # -----------------------------------------------------------------------
    # Stdout summary
    # -----------------------------------------------------------------------
    action_line = (
        "Host written to isolation_queue.json for analyst authorization"
        if queue_isolation
        else f"Manual review required — case {case_id} created"
        if case_status == "open"
        else f"Escalated — SOC notification queued for on-call analyst"
    )

    print(f"[{now_ts}] CREDENTIAL EXPOSURE PLAYBOOK")
    print(f"Alert      : {alert_id}")
    print(f"Host       : {host}")
    print(f"User       : {username}  Privilege: {priv_label}")
    print(f"Source IP  : {source_ip}  Verdict: {ip_verdict}  Score: {ip_score}")
    print(f"MITRE      : {mitre_technique} {technique_name}")
    print(f"Case       : {case_id}  Severity: {severity}  Status: {case_status}")
    print(f"Action     : {action_line}")

    if severity in ("Critical", "High") and "escalat" in case_status:
        print(f"[ESCALATE] {severity} alert — on-call analyst notified")
    elif severity in ("High", "Medium") and case_status == "open":
        print(f"[MANUAL REVIEW] {severity} alert queued for analyst review")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 playbook_credential_exposure.py <alert_file.json>")
        sys.exit(1)
    run_playbook(sys.argv[1])
