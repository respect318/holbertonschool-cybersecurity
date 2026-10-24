# 13x01 Ground Truth — Task 6: Author the Detection

## The rule

Wazuh custom rule (local_rules.xml), keyed on the persistence *action*, not the interpreter:

    <group name="sysmon,persistence,portway_custom,">
      <rule id="100900" level="12">
        <if_group>sysmon_event_13</if_group>
        <field name="win.eventdata.targetObject">CurrentVersion\\Run</field>
        <field name="win.eventdata.details">AppData|\\Temp\\|\\Downloads\\</field>
        <description>Persistence: autorun (Run key) set to a user-writable path -> $(win.eventdata.details)</description>
        <mitre><id>T1547.001</id></mitre>
      </rule>
    </group>

Equivalent hunt query used to test it against the telemetry:

    data.win.eventdata.targetObject:*CurrentVersion*Run* and (data.win.eventdata.details:*AppData* or data.win.eventdata.details:*Temp* or data.win.eventdata.details:*Downloads*)

## The behaviour it keys on, and why it survives the tool being shared

It keys on the *outcome*: an autorun entry (…\CurrentVersion\Run) whose value points at a user-writable location (AppData / Temp / Downloads) — "arrange for a dropped file to run again at logon."

This says nothing about PowerShell, so a shared interpreter is irrelevant. The administrator and the attacker both drive the host through powershell.exe with -EncodedCommand; only the attacker's chain registers autorun persistence that points back at a user-writable drop. The legitimate Northmoor deployment agent runs signed packages from C:\Program Files\Northmoor\ and never writes a Run key, so a rule on the persistence action cannot fire on it.

## Result of running it against the legitimate activity on this host

Run over the full telemetry window (agent 001, PORTWAY-WS-114):
- 1 match — HKCU\…\CurrentVersion\Run\Tavistock9 -> C:\Users\sdumont\AppData\Roaming\iblenor.exe (the intrusion).
- 0 matches on the legitimate admin chain (svc_nmdeploy / nmdeploy-agent.exe -> powershell), which sets no Run key.

=> Fires on the attack, silent on the admin. It passes the cry-wolf test.

## First attempt -> final

- First attempt keyed on the tool: powershell.exe with -EncodedCommand and a hidden window (-w hidden -enc). It caught the malicious PowerShell, but it also fired on the Northmoor deployment agent, which legitimately runs `powershell.exe -ExecutionPolicy Bypass -EncodedCommand` on every deployment. A rule that flags the IT department on every run is the rule the team learns to ignore.
- Change: moved the rule off the interpreter and onto the persistence behaviour — a Run-key value pointing at a user-writable path. The deployment chain never does that, so the final rule keeps the true positive (Tavistock9 -> iblenor.exe) and drops the false positive on the admin.
