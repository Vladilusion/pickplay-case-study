# Product overview

## Product boundary

PickPlay is a full-stack sports prediction and competition-management application. This portfolio model describes the domain and engineering approach without reproducing production source, configuration, data, or exact schemas.

## Problem and users

A prediction competition needs more than a score form. Participants require a clear open/locked state, fast updates, standings they can understand, and ways to compare or explore outcomes. Administrators need controlled competition setup, schedules, official results, teams, tournament groups, closing instants, and communications. Every view must resolve to the same scoring policy and competition scope.

## Conceptual capabilities

### Participant experience

- Authenticate and maintain a secure session.
- Confirm participation and create or update predictions while a match is open.
- Copy eligible predictions as a deliberate, authorized action.
- Review match status, consolidated results, awarded points, and current position.
- Compare general, matchday, tournament-group, relationship/private-group, and nearby-player standings.
- Explore projected results without changing official records.
- Receive competition communications or newsletters according to consent preferences.

### Administration

- Configure competitions, matchdays, teams, tournament groups, scoring-rule versions, and closing times.
- Manage match status transitions and record official results.
- Control roles and access to operational actions.
- Reconcile participation, scoring, and ranking outputs through audit-friendly records.

Administration is a responsibility area within the application, not evidence of a separate service.

## Domain invariants

1. A prediction belongs to one participant and one match in the same competition context.
2. At most one active prediction exists per participant and match.
3. A prediction cannot be accepted at or after the authoritative close time.
4. Only valid final results are scoreable.
5. The scoring-rule version used for an award must be identifiable.
6. Hypothetical results cannot overwrite official results or awarded points.
7. Rankings expose their scope, tie semantics, and last evaluated data.

## UX structure

The responsive interface should emphasize the next actionable matches, explicit deadlines, inline validation, save confirmation, and a visible locked state. JavaScript and asynchronous requests can reduce friction, while semantic HTML and server-rendered fallbacks preserve accessibility and resilience. Administrative operations should favor review/confirmation over compact but ambiguous controls.

## Success criteria without invented metrics

Quality can be assessed through behavior: deterministic scoring tests pass; duplicate and late submissions are rejected; ranking queries return stable positions; scenario operations leave official data unchanged; and sensitive values never enter logs or this repository. No usage, revenue, performance, or conversion claims are made here.

## Related documents

- [System architecture](02-system-architecture.md)
- [Data model](03-data-model.md)
- [Security and data integrity](07-security-and-data-integrity.md)
