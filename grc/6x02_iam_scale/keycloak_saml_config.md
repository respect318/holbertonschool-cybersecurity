# MedDefense SAML SSO Configuration Reference

This document describes the SAML 2.0 SSO configuration for MedDefense Health Systems using
Keycloak as the Identity Provider (IdP). It is derived from the realm export, sample SAML
assertions, and supporting flow notes produced during the SSO integration analysis.

---

## Realm Configuration Summary

| Parameter | Value |
|---|---|
| Realm name | `meddefense` |
| Display name | `MedDefense Health Systems` |
| Enabled | `true` |
| SSO session idle timeout | 30 minutes (1800 seconds) |
| Brute force protection | Enabled |
| Max login failures before lockout | 5 failed attempts |

**Source — `keycloak_realm_export_meddefense.json` (abbreviated):**

```json
{
  "realm": "meddefense",
  "displayName": "MedDefense Health Systems",
  "enabled": true,
  "ssoSessionIdleTimeout": 1800,
  "bruteForceProtected": true,
  "failureFactor": 5
}
```

The realm `meddefense` acts as a security domain that isolates all MedDefense users and clients
from other realms on the same Keycloak instance. The 30-minute idle timeout means a clinician
who walks away from a workstation will have their SSO session invalidated after 30 minutes of
inactivity, reducing the risk of unauthorized access on unattended terminals. Brute force
protection with a threshold of 5 failed attempts automatically locks an account after 5
consecutive incorrect password entries, mitigating password-spray and brute-force attacks
against clinical staff credentials.

---

## Client Configuration Summary

| Parameter | Value |
|---|---|
| Client ID | `meddefense-portal` |
| Protocol | `saml` |
| Enabled | `true` |
| Assertion Consumer Service (ACS) URL | `http://localhost:5000/saml/acs` |
| Redirect URIs | `http://localhost:5000/*` |
| NameID format | `email` (forced) |
| Signed assertions | `true` |
| Signed documents (server signature) | `true` |

**Source — `keycloak_realm_export_meddefense.json` client block:**

```json
{
  "clientId": "meddefense-portal",
  "protocol": "saml",
  "enabled": true,
  "redirectUris": ["http://localhost:5000/*"],
  "attributes": {
    "saml_name_id_format": "email",
    "saml_force_name_id_format": "true",
    "saml.assertion.signature": "true",
    "saml.server.signature": "true",
    "saml_assertion_consumer_url_post": "http://localhost:5000/saml/acs"
  }
}
```

The Service Provider (SP) `meddefense-portal` receives SAML responses at the ACS URL via HTTP
POST binding. Forcing the email NameID format ensures that every assertion identifies the
subject by their organizational email address, providing a consistent identifier that maps
directly to the workforce directory. Both `saml.assertion.signature` and
`saml.server.signature` are set to `true`, meaning Keycloak signs the inner `<saml:Assertion>`
element as well as the outer `<samlp:Response>` envelope, providing two independent layers of
tamper protection.

### Protocol Mapper — MedDefenseRole

| Parameter | Value |
|---|---|
| Mapper name | `MedDefenseRole` |
| Protocol | `saml` |
| Mapper type | `saml-user-attribute-mapper` |
| User attribute | `MedDefenseRole` |
| SAML attribute name | `MedDefenseRole` |
| Attribute name format | `Basic` |

The `MedDefenseRole` mapper reads the custom user attribute `MedDefenseRole` from the
Keycloak user profile and injects it into every SAML assertion as an
`<saml:AttributeStatement>`. The SP uses this attribute to perform role-based authorization
(e.g., granting clinical staff access to Epic and the PACS, while granting IT security staff
access to audit tooling).

---

## Test Users and Role Attributes

| Username | Email | MedDefenseRole |
|---|---|---|
| `d.walsh` | `d.walsh@meddefense.internal` | `clinical_staff` |
| `r.kim` | `r.kim@meddefense.internal` | `it_security` |

Both accounts are enabled in the `meddefense` realm. `d.walsh` represents a clinical staff
member with access to patient-facing systems. `r.kim` represents an IT security analyst with
access to security tooling and audit logs. These two roles cover the primary authorization
boundaries MedDefense needs to enforce across connected applications.

---

## Annotated SAML Assertion: d.walsh

The following is the full SAML response for user `d.walsh`, with inline comments explaining
each element. The SP must validate every annotated element before granting access.

```xml
<samlp:Response
  xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol"
  xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion"
  xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
  ID="_resp-dwalsh-20260428"
  Version="2.0"
  IssueInstant="2026-04-28T09:15:00Z"
  Destination="http://localhost:5000/saml/acs">

  <!-- Issuer: identifies the IdP that generated this response.
       The SP must verify this matches the registered IdP entity ID
       (http://localhost:8080/realms/meddefense). Any other value
       must cause the SP to reject the response. -->
  <saml:Issuer>http://localhost:8080/realms/meddefense</saml:Issuer>

  <!-- Signature (outer / document-level): covers the entire Response envelope.
       The SP verifies this against Keycloak's public signing certificate.
       If the signature is absent or invalid, the entire response is rejected
       regardless of the contents of the inner assertion. -->
  <ds:Signature>
    <ds:SignedInfo>
      <ds:Reference URI="#_assert-dwalsh-001"/>
    </ds:SignedInfo>
    <ds:SignatureValue>SIMULATED_SIGNATURE_VALUE_FOR_LAB_ONLY</ds:SignatureValue>
  </ds:Signature>

  <saml:Assertion ID="_assert-dwalsh-001" Version="2.0"
                  IssueInstant="2026-04-28T09:15:00Z">

    <!-- Issuer (assertion-level): repeated inside the Assertion to allow
         the assertion to be extracted and verified independently of the
         outer Response. Must match the same IdP entity ID. -->
    <saml:Issuer>http://localhost:8080/realms/meddefense</saml:Issuer>

    <saml:Subject>
      <!-- NameID: the authenticated user's identity token passed to the SP.
           Format emailAddress means the SP receives the user's organizational
           email (d.walsh@meddefense.internal) as the subject identifier.
           The SP maps this to its own user record or provisions an account. -->
      <saml:NameID Format="urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress">
        d.walsh@meddefense.internal
      </saml:NameID>
      <saml:SubjectConfirmation Method="urn:oasis:names:tc:SAML:2.0:cm:bearer">
        <saml:SubjectConfirmationData
          NotOnOrAfter="2026-04-28T09:20:00Z"
          Recipient="http://localhost:5000/saml/acs"/>
      </saml:SubjectConfirmation>
    </saml:Subject>

    <!-- Conditions: the validity envelope of this assertion.
         NotBefore — the SP must not accept the assertion before this UTC
         timestamp (2026-04-28T09:14:55Z). A small skew (typically ±5 s) is
         allowed to compensate for clock drift between IdP and SP.
         NotOnOrAfter — the SP must reject the assertion at or after this UTC
         timestamp (2026-04-28T09:20:00Z). The 5-minute window limits the
         exposure time if an assertion is intercepted.
         AudienceRestriction — restricts the assertion to meddefense-portal;
         the SP must reject assertions intended for a different audience. -->
    <saml:Conditions
      NotBefore="2026-04-28T09:14:55Z"
      NotOnOrAfter="2026-04-28T09:20:00Z">
      <saml:AudienceRestriction>
        <saml:Audience>meddefense-portal</saml:Audience>
      </saml:AudienceRestriction>
    </saml:Conditions>

    <!-- AuthnStatement: records the authentication event that the IdP performed.
         AuthnInstant — when Keycloak authenticated the user (09:14:58Z).
         SessionIndex — a unique handle for the IdP session; used for
         single logout (SLO) so the IdP can invalidate the correct session.
         AuthnContextClassRef — PasswordProtectedTransport indicates the user
         authenticated with a password over a secure (TLS) channel. -->
    <saml:AuthnStatement
      AuthnInstant="2026-04-28T09:14:58Z"
      SessionIndex="_session-dwalsh-001">
      <saml:AuthnContext>
        <saml:AuthnContextClassRef>
          urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport
        </saml:AuthnContextClassRef>
      </saml:AuthnContext>
    </saml:AuthnStatement>

    <!-- AttributeStatement: carries user attributes from the IdP to the SP.
         MedDefenseRole — the RBAC role injected by the MedDefenseRole mapper;
         value "clinical_staff" grants access to patient-care systems.
         email — the user's email address, confirming the NameID value. -->
    <saml:AttributeStatement>
      <saml:Attribute Name="MedDefenseRole">
        <saml:AttributeValue>clinical_staff</saml:AttributeValue>
      </saml:Attribute>
      <saml:Attribute Name="email">
        <saml:AttributeValue>d.walsh@meddefense.internal</saml:AttributeValue>
      </saml:Attribute>
    </saml:AttributeStatement>

  </saml:Assertion>

</samlp:Response>
```

---

## Assertion Expiration and Replay Prevention

Every SAML assertion carries two UTC timestamps inside `<saml:Conditions>`: `NotBefore` and
`NotOnOrAfter`. Together they define a narrow validity window — in this configuration, exactly
five minutes (09:14:55Z to 09:20:00Z for the d.walsh example). The SP is required to check the
current time against both values on every assertion it receives. If the current time is before
`NotBefore`, the assertion is not yet valid (possibly a clock-skew attack or a replayed
future-dated token) and must be rejected. If the current time equals or exceeds
`NotOnOrAfter`, the assertion has expired and must be rejected even if the signature is
cryptographically valid.

Expiration alone does not prevent replay within the validity window. An attacker who
intercepts a signed assertion can re-submit it to the ACS URL multiple times before
`NotOnOrAfter` is reached, gaining repeated unauthorized sessions. To close this window, the
SP must maintain an assertion ID cache: when a valid assertion arrives, the SP records its
unique `ID` attribute (e.g., `_assert-dwalsh-001`) with a TTL equal to `NotOnOrAfter`. If a
second request arrives carrying the same assertion ID before that TTL expires, the SP must
reject it as a replay. Keycloak assigns a unique ID to every assertion it issues, making the
ID a reliable replay-detection key.

In a clinical environment like MedDefense, replay attacks are especially dangerous because a
replayed `clinical_staff` assertion could allow a departed employee or an attacker who
intercepted a legitimate session to access Epic, the PACS, or the pharmacy system without
re-authenticating. The combination of short expiration windows and server-side assertion ID
tracking eliminates this threat.

---

## Assertion Signing Risk Explanation

In the current configuration both `saml.assertion.signature` and `saml.server.signature` are
set to `true` in the Keycloak client, meaning Keycloak uses its private key to sign both the
inner `<saml:Assertion>` block and the outer `<samlp:Response>` envelope. The SP verifies
these signatures against Keycloak's public certificate before trusting any content in the
message.

If assertion signing were disabled — by setting `saml.assertion.signature` to `false` — the
SP would receive an unsigned assertion and would have no cryptographic way to verify that the
`NameID`, `AttributeStatement`, or `Conditions` elements were produced by the legitimate IdP
and were not modified in transit. An attacker positioned between the browser and the SP (e.g.,
via a TLS-terminating proxy, a compromised browser extension, or an HTTP interception where
TLS is not enforced) could intercept the SAML response and rewrite the `NameID` to impersonate
any user, change `MedDefenseRole` from `clinical_staff` to a more privileged value, or extend
`NotOnOrAfter` to extend a stolen assertion's lifetime.

In the MedDefense context this risk is critical. The assertion carries the `MedDefenseRole`
attribute that controls access to patient data in Epic and the PACS. An unsigned assertion
allows privilege escalation to any role simply by editing one XML attribute value. Signing must
remain enabled on all SAML clients, and the SP must be configured to reject any assertion that
lacks a valid signature or whose signature cannot be verified against the registered IdP
certificate. Rotating the Keycloak signing certificate on a scheduled basis (annually at
minimum) further limits the impact of a key compromise.

---

## Off-Boarding and Centralized Identity Impact

During the MedDefense security incident, two Epic accounts belonging to departed employees
remained active because the off-boarding process required manual account disablement in each
system independently — Epic, PACS, the pharmacy platform, and the clinical communication
tool each maintained their own credential stores. A centralized IdP eliminates this risk.

When all connected applications delegate authentication to the `meddefense` Keycloak realm
via SAML, disabling a user account in Keycloak is the single action required to revoke access
across every integrated system simultaneously. The IdP will refuse to issue a new SAML
assertion for a disabled account; without a valid assertion, the SP cannot establish a session.
Existing SP sessions may persist until their own idle timeout or until a Single Logout (SLO)
request is sent, so HR and IT workflows should also trigger an SLO request on off-boarding to
invalidate any live sessions immediately.

The `meddefense` realm's brute force lockout (5 failed attempts) and 30-minute idle session
timeout further reduce the window of exposure if off-boarding is delayed. Centralized identity
management also provides a single audit log: every authentication event, failed login, and
session across all connected systems is recorded in Keycloak, giving the security team a
unified view for incident response and compliance reporting.
