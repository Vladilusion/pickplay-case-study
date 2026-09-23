# Engineering decisions

These concise ADR-style records describe the portfolio architecture. Status for each is **proposed case-study direction**, not proof of production deployment.

## ADR-001 — Retain the pragmatic PHP/MySQL stack

**Context.** PickPlay is a server-oriented full-stack application with relational workflows and a PHP/MySQL foundation.

**Decision.** Improve boundaries and tests within PHP/MySQL before considering platform replacement.

**Rationale.** The stack maps well to request/response workflows, transactional data, broad hosting support, and existing engineering knowledge.

**Trade-offs.** Discipline is needed to prevent page-level coupling; long-running or high-concurrency work may later require queues or specialized components.

## ADR-002 — Centralize scoring rules

**Context.** Entry, results, rankings, and simulation must agree on points.

**Decision.** Use one deterministic, version-aware scoring component with configuration supplied explicitly.

**Rationale.** A pure calculation is testable, auditable, and reusable.

**Trade-offs.** Rule schema/version migration adds design work, and callers must resolve the correct version.

## ADR-003 — Use database-backed ranking calculations

**Context.** Rankings aggregate relational predictions, matches, memberships, and awards.

**Decision.** Use scoped SQL aggregation and MySQL 8 window functions initially, behind a query boundary.

**Rationale.** The database can filter and aggregate close to indexed data while expressing tie policy clearly.

**Trade-offs.** Complex queries need plan analysis; growth may justify caching or materialized projections with explicit invalidation.

## ADR-004 — Make closing controls authoritative on the server

**Context.** Browser time and disabled controls cannot prevent late or concurrent writes.

**Decision.** Store UTC closing instants and recheck `now < closes_at` transactionally on every write.

**Rationale.** One authoritative rule closes client-clock and race windows.

**Trade-offs.** Locking/atomic-write design and timezone presentation require careful testing.

## ADR-005 — Isolate simulations from official data

**Context.** Scenario analysis changes results hypothetically but must not affect standings.

**Decision.** Overlay hypothetical results on a read-only official snapshot in memory or dedicated scenario storage.

**Rationale.** Structural separation reduces accidental mutation and makes simulation retryable.

**Trade-offs.** Large scenarios repeat calculation; saved scenarios need lifecycle, ownership, and source-version handling.

## ADR-006 — Build a responsive, progressively enhanced interface

**Context.** Prediction entry is time-sensitive and used across viewport/input conditions.

**Decision.** Start with semantic server-capable HTML, responsive CSS, then add JavaScript/AJAX feedback.

**Rationale.** Core workflows remain accessible and resilient while enhanced interactions reduce friction.

**Trade-offs.** Both enhanced and fallback paths require validation and testing.

## ADR-007 — Modernize incrementally rather than rewrite

**Context.** Rewrites delay user value and can discard encoded domain knowledge.

**Decision.** Introduce tests, service seams, query boundaries, and observability in measured slices.

**Rationale.** Each change is reviewable, reversible, and tied to a demonstrated constraint.

**Trade-offs.** Transitional patterns coexist, consistency takes time, and refactoring must be prioritized deliberately.
