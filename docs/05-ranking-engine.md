# Ranking engine

## Ranking pipeline

1. Select finalized, eligible matches in one explicit scope.
2. Join one accepted prediction per user/match to its deterministic award.
3. Sum awarded points per participant.
4. Include eligible participants with zero points when product rules require them.
5. Assign positions with the selected tie policy.
6. Apply a separate stable display order.

Awarded points and **potential** points must use different names and visual treatment. Potential totals are projections based on unresolved matches or scenarios and cannot be mixed into official standings.

## Tie handling

The illustrative query uses `DENSE_RANK()`: totals `12, 12, 9` receive positions `1, 1, 2`. `RANK()` would produce `1, 1, 3`; `ROW_NUMBER()` would force distinct positions. PickPlay should choose one policy per competition and expose it in the UI. A stable secondary sort—such as display name and immutable user ID—orders equal rows without pretending the tie is broken.

## Reusable scopes

- **General:** all eligible finalized matches in a competition.
- **Matchday:** general filters plus one matchday.
- **Team/group:** matches or participants associated with the relevant competition grouping.
- **Relationship/private group:** general result set intersected with authorized membership.
- **Current user:** locate the authenticated user's row after the complete scoped ranking is calculated.

Filters must occur before ranking. Filtering a globally ranked result afterward yields positions from the wrong population.

## Nearby competitor / “threat” view

Calculate the complete authorized ranking, locate the current participant, then return a bounded position interval above and below. A “threat” is a comparison aid—not a behavioral assertion—and can display point gaps, remaining potential, and nearby position. Never expose a participant outside a private group the requester may view.

## Potential-score calculations

For unresolved matches, potential can mean either maximum achievable remaining points or points under a named scenario. The response must include the definition, rule version, included match IDs, and calculation time. Because competitors' potential values are correlated through shared outcomes, the UI should avoid claiming a guaranteed future rank unless the algorithm proves it.

## Query design

[`samples/ranking-query.sql`](../samples/ranking-query.sql) demonstrates CTEs, conditional aggregation, `DENSE_RANK()`, parameter placeholders, and stable ordering for MySQL 8+. Important indexes cover prediction uniqueness, match scope/status, and group membership. Validate the plan with `EXPLAIN ANALYZE` against representative sanitized distributions before deciding to materialize results.

## Refresh and correctness

Rankings may be computed on demand, cached, or materialized. On-demand calculations are simple but can become expensive. Cached or snapshot results need invalidation/versioning after official result, scoring-rule, prediction eligibility, or group-membership changes. Idempotent recomputation and a visible `calculated_at` value make stale data diagnosable.
