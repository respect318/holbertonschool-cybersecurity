# Fetch Surface Inventory — Clarion Signal

Inventory of every URL-fetching feature in Clarion Signal, classified by
request origin (server-side vs client-side), based on Burp proxy history
review. Each classification is backed by the concrete observation that
settled it — reflection of a submitted URL in the response is explicitly
**not** treated as proof of a server-side fetch.

| Feature | Request Location (where in the UI) | Origin Classification | Decisive Observation |
|---|---|---|---|
| Link preview | Article composer, paste-a-URL preview card | Server-side | Canary (out-of-band) endpoint recorded an inbound hit from Clarion's server IP after submitting the preview URL; the request never appeared in my own Burp proxy history as originating from the browser. |
| Thumbnail import | Media library, "import from URL" | Server-side | Response returns a fetched/resized image asset even when the source URL is not publicly reachable from my machine (I could not resolve/reach it myself), meaning only the server could have retrieved it. |
| Webhook tester | Integrations settings, "Test webhook" | **Client-side** | The "test" request shows up directly in my own Burp proxy history as an outbound call from my browser (XHR/fetch to the target URL), and no corresponding server-originated interaction hit was recorded on the canary console. The app is only checking reachability from the browser, not fetching server-side. |
| Report generator | Reports module, "Generate branded report from URL" | Server-side | Canary console logged an interaction with a timestamp matching the report-generation request, well after my proxy history shows the client request to Clarion's own API — i.e., a second, server-originated fetch happened downstream. |
| Avatar import | Profile settings, "Import avatar from URL" | Server-side | Submitting a URL pointing to an internal-only address (unreachable from my browser) still resulted in an avatar being set, confirming the fetch happened from a network position I don't have (the server). |
| Article snapshot | Article view, "Snapshot this page" | Server-side | The snapshot image reflects page content behind an internal-only host I cannot reach directly, and the canary console shows a corresponding out-of-band hit at request time. |

## Isolated client-side feature

**Webhook tester** is the one feature whose outbound fetch is made by the
browser, not Clarion's server. It looks like an SSRF candidate because it
accepts an arbitrary URL and reports back reachability, but the request
itself never leaves my own proxy history — the app is simply performing a
client-side reachability check and rendering the result. Submitting an
internal-only or canary URL here produces no server-originated interaction
hit, which is what distinguishes it from every genuinely server-side
feature above.

## Note on reflection vs. proof

Several of these features also reflect the submitted URL back in the UI
(e.g., displaying "Fetching: <url>" or echoing the input in a confirmation
message). Reflection alone is not used anywhere above as evidence of a
server-side fetch — each classification instead rests on either (a) a
canary/interaction hit recorded on the server side, or (b) content being
returned that could only have been retrieved from a network position the
browser does not have. Webhook tester is the counter-example: it reflects
a result but produces no server-side interaction hit, which is exactly
why it's excluded from the server-side set.

## Usable for Task 2

The five server-side candidates above (link preview, thumbnail import,
report generator, avatar import, article snapshot) are carried forward as
genuine SSRF candidates for internal-service mapping in Task 2. Webhook
tester is excluded from that set.
