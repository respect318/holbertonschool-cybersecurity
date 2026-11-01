# Compliance Review

The false control is **C-09** (output validation): the self-assessment claims
"tool inputs are schema-validated before execution", but this is false.

Disproved by `01-architecture.md` (`tool_args_validation: none_passthrough`,
"there is no schema check at the gateway") and by `05-sample-logs.jsonl`
event `evt_000233`, where `billing_lookup` runs with `filter: "status='open' OR 1=1"`,
`validation: skipped`, and returns `status: ok`.
