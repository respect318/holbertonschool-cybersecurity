# Board Recommendation: Assist Billing Expansion

**To:** Deployment committee · **From:** Security governance · **Date:** 2026-11-01
**Decision requested:** approve launch, subject to conditions.

## Recommendation: GO, with conditions

Launch Assist's billing expansion on the fixed date, **only if all six conditions below are met first**. These are not aspirations; each is written so a director can ask "is this done, yes or no?"

1. **Injection protection is in place.** The system today passes user and tool text through without validation, and the logs already show one crafted input running against billing data. A guard that validates tool inputs must be live before launch. *Done = the red-team test shows the known bad inputs are now blocked.*
2. **Cross-account access is tested, not assumed.** Confirm by test that one customer cannot reach another's billing data. *Done = a signed test report, not a design claim.*
3. **A spend/rate cap sits on the billing tools.** Human approval alone is not a limit on financial action. *Done = a per-session cap is configured and enforced.*
4. **Refund approvers are trained.** The refund safeguard is only as good as the staff who approve. *Done = named approvers have completed training.*
5. **Customers are told they are talking to an AI.** This is legally required now, not optional. *Done = the notice is shown in the billing chat.*
6. **A kill switch and incident runbook exist.** *Done = Assist can be stopped in one step and there is a written response plan.*

## Watched after launch, with reconsideration triggers

Four controls are deferred to stay inside budget: a reply-side data filter, a vendor zero-retention addendum, an automated red-team suite in CI, and a monitoring dashboard. **Reconsider the launch decision immediately if any of these occurs:** a regulated field appears in a customer reply; injection or cross-account findings reappear in production; or the volume of provider-retained "flagged" billing conversations climbs. Each has a defined signal in the audit log.

## The compliance gap the board must know about

The internal compliance self-assessment marks tool-input validation as **"in place." It is not.** The architecture is configured for no validation, and the logs show an unvalidated input executing. The board is currently relying on a protection that does not exist. Condition 1 closes it; until then, every other assurance in that form sits on top of a control nobody has. This is the single most important line in this document.

## The residual

**Larkspur is knowingly accepting that, during the post-launch monitoring window, a customer's `card_last4` and invoice totals could appear in an AI-generated reply — reachable by a user prompting the agent to repeat their billing details, costing a bounded data-exposure incident (the regulated fields `iban`/`tax_id` are already withheld from the model, so the exposure is limited to card_last4 and amounts) — because the reply-side filter (F2, 2 engineering-weeks) was deferred to hold the launch date.**
