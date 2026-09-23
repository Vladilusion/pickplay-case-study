# Security and data integrity

## Status of this document

This is a target control model for a public case study. Unless supported by production evidence outside this repository, controls below are **recommendations**, not claims about what is deployed. The sample code implements only the behavior visible in each sample.

## Request controls

- **Authentication and sessions:** use a mature session mechanism; rotate identifiers after login/privilege changes; set `Secure`, `HttpOnly`, and appropriate `SameSite` cookie attributes; expire idle and absolute sessions; store password hashes using a current password-hashing API.
- **Authorization:** enforce ownership, competition membership, private-group membership, and administrator capability server-side on every operation. A hidden button is not authorization.
- **Validation and normalization:** define accepted types, ranges, Unicode/email normalization, identifier formats, and unknown-field behavior. Resolve IDs to authorized domain objects; do not accept client-supplied ownership or awarded points.
- **CSRF:** protect state-changing browser requests with framework-supported tokens and suitable cookie policy; validate request origin where appropriate.
- **XSS:** contextually encode dynamic HTML, attributes, URLs, and JavaScript values; prefer text APIs over HTML injection; add a restrictive Content Security Policy as defense in depth.
- **SQL injection:** use parameterized prepared statements for values. Map requested sort/filter names through allowlists because placeholders do not protect SQL identifiers.

Client-side validation is progressive feedback only. [`prediction-validation.js`](../samples/prediction-validation.js) explicitly preserves the server as the trust boundary.

## Transactions and temporal integrity

A naive “check close time, then write” sequence can cross the deadline or race another update. Within one short transaction:

1. Load and lock the relevant match (or use an equivalent atomic conditional write).
2. Compare `closes_at` with an authoritative server/database UTC time using a documented rule: submissions at exactly close are rejected.
3. Verify match status, participant authorization, and score ranges.
4. Insert/update under `UNIQUE (user_id, match_id)`.
5. Commit and return the persisted representation.

The database should enforce uniqueness, foreign keys, non-negative scores, legal states, and distinct opponents where feasible. Transactions protect official-result finalization and associated outbox/recalculation work. Long scoring computations should use idempotent jobs and source versions rather than holding locks indefinitely.

## Secrets and least privilege

Load secrets from an approved runtime secret store or deployment environment—not source, samples, images, logs, or client bundles. Separate database roles by required capability; the web role should not administer schemas or read unrelated datasets. Rotate credentials, restrict network access, and audit exceptional administrative access. No production credentials or data belong in this repository.

## Audit and observability

Record actor ID, action, target, timestamp, request/correlation ID, and outcome for sensitive changes. Capture before/after data only when necessary and redact tokens, password material, session IDs, and excessive personal data. Protect audit logs from alteration, define retention, and monitor repeated authentication, authorization, deadline, and validation failures without leaking details to users.

## Operational hardening checklist

- Patch supported runtimes and dependencies; generate and review dependency inventories.
- Use TLS, security headers, generic external errors, and detailed protected server logs.
- Back up encrypted data and test restoration; document retention and deletion.
- Review asynchronous endpoints under the same authorization model as full-page requests.
- Threat-model copy-prediction, newsletters, exports, file handling, and administrator actions.
- Test replay, duplicate requests, concurrent deadline submissions, and idempotency.
- Run secret scanning and static analysis in automated quality checks when CI is introduced.

For reporting guidance, see [`SECURITY.md`](../SECURITY.md).
