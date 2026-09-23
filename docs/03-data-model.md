# Conceptual data model

> The entities and names below are a portfolio-oriented conceptualization. They are not asserted to match the production schema.

## Relationship overview

```mermaid
erDiagram
    USERS ||--o{ PREDICTIONS : submits
    COMPETITIONS ||--o{ MATCHDAYS : contains
    COMPETITIONS ||--o{ TEAMS : registers
    COMPETITIONS ||--o{ COMPETITION_GROUPS : organizes
    COMPETITION_GROUPS ||--o{ TEAM_GROUP_MEMBERSHIPS : contains
    TEAMS ||--o{ TEAM_GROUP_MEMBERSHIPS : assigned_to
    COMPETITIONS ||--o{ PRIVATE_GROUPS : scopes
    USERS ||--o{ PRIVATE_GROUPS : owns
    PRIVATE_GROUPS ||--o{ PRIVATE_GROUP_MEMBERSHIPS : contains
    USERS ||--o{ PRIVATE_GROUP_MEMBERSHIPS : joins
    MATCHDAYS ||--o{ MATCHES : schedules
    TEAMS ||--o{ MATCHES : plays
    MATCHES ||--o{ PREDICTIONS : receives
    PREDICTIONS ||--|| PREDICTION_DETAILS : contains
    COMPETITIONS ||--o{ SCORING_RULES : versions
    USERS ||--o{ RANKINGS : appears_in
    COMPETITIONS ||--o{ RANKINGS : scopes
    COMPETITION_GROUPS ||--o{ RANKINGS : may_scope
    PRIVATE_GROUPS ||--o{ RANKINGS : may_scope
```

The model deliberately separates two meanings of “group”:

- `competition_groups` organize **teams** inside a tournament (for example, Group A). `team_group_memberships` is the team-to-group junction.
- `private_groups` organize **participants** who compare private standings. `private_group_memberships` is the user-to-group junction.

Neither concept substitutes for the other: a tournament-group ranking scopes matches by participating teams, while a private-group ranking scopes the participant population by membership.

## Entity catalog

| Entity | Primary key | Important relationships and fields |
|---|---|---|
| `users` | `id` | unique normalized email; status; password hash; audit timestamps |
| `competitions` | `id` | unique slug; name; timezone/display configuration; lifecycle timestamps |
| `teams` | `id` | FK `competition_id`; unique `(competition_id, code)` |
| `competition_groups` | `id` | FK `competition_id`; unique tournament-group name within a competition |
| `team_group_memberships` | `(competition_group_id, team_id)` | FKs to tournament group and team; assigns teams to competition groups |
| `private_groups` | `id` | FKs `competition_id`, `owner_user_id`; private participant-ranking scope |
| `private_group_memberships` | `(private_group_id, user_id)` | FKs to private group and user; records participant membership |
| `matchdays` | `id` | FK `competition_id`; unique sequence within competition; start/end instants |
| `matches` | `id` | FKs to matchday, home team, away team; kickoff, close, status, official scores |
| `predictions` | `id` | FKs `user_id`, `match_id`; unique pair; submitted/updated timestamps |
| `prediction_details` | `prediction_id` | PK and FK to `predictions.id`; predicted scores, wildcard choice, and awarded values in a 1:1 relationship |
| `scoring_rules` | `id` | FK `competition_id`; version and effective interval; point configuration |
| `rankings` | `id` | optional materialized snapshot keyed by scope, user, and calculation version |

Rankings can instead remain a query/read model. If snapshots are stored, they are derived data and need a source version or `calculated_at` timestamp; they must never become the source of truth for predictions or results.

## Keys, constraints, and temporal fields

- Use non-null foreign keys where absence has no domain meaning and restrict deletion of referenced competition history.
- Enforce `home_team_id <> away_team_id`, non-negative scores, and valid status values with application checks plus database `CHECK` constraints where supported.
- Enforce one prediction with `UNIQUE (user_id, match_id)`; use an upsert only after authorization and deadline validation.
- Make team codes and matchday numbers unique **within** a competition, not globally.
- Ensure team/group relationships remain in one competition. Composite foreign keys can enforce this in a fuller schema; the sample calls out the transaction-level check explicitly.
- Keep tournament team membership and private participant membership in separate junction tables with composite primary keys that prevent duplicates.
- Store `kickoff_at`, `closes_at`, `submitted_at`, `updated_at`, `finalized_at`, and `calculated_at` as UTC instants. Preserve the user-facing timezone in competition configuration.
- Version scoring rules rather than silently editing policy after awards exist. Prevent overlapping effective ranges by transaction/application checks if the database cannot express them directly.
- Audit administrator changes with actor, action, resource, before/after representation or diff, and timestamp, subject to privacy and retention policy.

## Recommended indexes

| Index | Query supported |
|---|---|
| `matches (matchday_id, status, kickoff_at)` | matchday schedule and finalization scans |
| `matches (competition_id, closes_at, status)` | open/closing views (if competition ID is denormalized safely) |
| `predictions (match_id, user_id)` unique | eligibility lookup and duplicate prevention |
| `predictions (user_id, match_id)` | participant history; the unique index may already cover this order |
| `matchdays (competition_id, sequence_no)` unique | ordered competition navigation |
| `scoring_rules (competition_id, effective_from, effective_to)` | effective-rule selection |
| `team_group_memberships (competition_group_id, team_id)` primary and reverse `(team_id, competition_group_id)` | tournament-group match filtering |
| `private_group_memberships (private_group_id, user_id)` primary and reverse `(user_id, private_group_id)` | private ranking scope and authorization |

Indexes should be confirmed with realistic query plans and representative, sanitized data; extra indexes increase write and storage cost.

## Integrity workflow

Prediction acceptance should lock or consistently read the match row, compare the database/application authoritative time with `closes_at`, and insert/update in the same transaction. Finalization should validate match status and scores, persist the official result, calculate or enqueue derived awards, and publish ranking changes atomically or through an idempotent, versioned follow-up process.

See the [illustrative schema](../samples/database-schema.sql).
