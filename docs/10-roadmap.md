# Technical roadmap

This roadmap is a proposed sequence. Items below must not be read as currently implemented, scheduled, or promised. Advancement should depend on risk, product priorities, and measured evidence.

## Phase 1 — Establish correctness and safety

- Add automated characterization tests around critical prediction and result workflows.
- Build table-driven scoring unit tests covering precedence, configuration, invalid input, and wildcard multiplication.
- Review and strengthen foreign keys, unique constraints, checks, migrations, and transactional deadline behavior.
- Introduce structured, redacted application logging with correlation identifiers and documented retention.
- Define authorization and match-status transition matrices.

**Exit evidence:** repeatable local test commands, reviewed migrations, deadline concurrency tests, and actionable logs using synthetic data.

## Phase 2 — Clarify boundaries and measure behavior

- Refactor application/domain services behind stable interfaces, one workflow at a time.
- Define internal API boundaries and consistent validation/error contracts without prematurely splitting deployment.
- Improve observability for scoring/recalculation failures, slow ranking queries, and administrative actions.
- Profile representative ranking and prediction paths; review query plans before adding caches or indexes.
- Version scoring configuration and derived ranking calculations explicitly.

**Exit evidence:** dependency boundaries covered by tests, documented service contracts, useful traces/metrics, and profiling-backed optimization decisions.

## Phase 3 — Automate delivery and enable optional evolution

- Add CI/CD with required test, lint, link, secret, and static-analysis checks plus controlled deployment stages.
- Provide a containerized, documented development environment with pinned major dependencies and synthetic seed data.
- Enforce automated quality checks and migration verification on pull requests.
- Evaluate an API-first interface only where mobile clients, integrations, or independently evolving UI requirements justify it.
- Add safe rollback, backup/restore exercises, and release observability.

**Exit evidence:** reproducible clean-environment builds, gated releases, verified rollback/restore procedures, and an evidence-based API decision.

## Deliberate non-goals

A microservice rewrite, speculative distributed infrastructure, and performance claims without measurement are not roadmap goals. Architecture should become more complex only when concrete reliability, ownership, integration, or scaling needs require it.
