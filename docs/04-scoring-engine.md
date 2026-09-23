# Scoring engine

## Why centralize the policy?

Prediction entry, consolidated results, rankings, simulation, and administration must produce identical scores. A centralized rules engine prevents controller-specific interpretations and makes policy versioning and tests practical.

## Example configuration

| Outcome | Points |
|---|---:|
| Exact score | 5 |
| Same goal difference | 3 |
| Correct winner | 2 |
| Correct draw | 2 |
| No match | 0 |
| Configured wildcard multiplier | × 1.5 |

These values are the requested portfolio example. A real implementation should load the immutable rule version assigned to the competition or match.

## Classification and precedence

Given predicted `(ph, pa)` and actual `(ah, aa)`:

1. Reject negative or otherwise invalid values before scoring.
2. If `ph = ah` and `pa = aa`, award **exact score**.
3. Else, if the actual result is not a draw and `ph - pa = ah - aa`, award **goal difference**.
4. Else, if both pairs are draws, award **correct draw**. Keeping draws out of the preceding branch makes this configured category reachable.
5. Else, if `sign(ph - pa) = sign(ah - aa)`, award **correct winner**.
6. Otherwise award **no match**.
7. Apply the wildcard multiplier once, after the base classification, only if eligible and configured.

The rule order and the definition of goal-difference eligibility must be part of the versioned configuration or contract.

## Numeric representation

A multiplier of 1.5 can produce fractional totals (for example, `5 × 1.5 = 7.5`). Avoid binary floating-point for persisted awards. The sample represents points in **half-point units**: five points becomes 10 units, and the multiplier transforms 10 into 15 units. Display formatting converts units back to points.

## Test matrix

| Prediction | Actual | Expected reason | Base points |
|---|---|---|---:|
| 2–1 | 2–1 | exact | 5 |
| 3–1 | 2–0 | goal difference | 3 |
| 2–0 | 3–2 | winner | 2 |
| 1–1 | 0–0 | draw | 2 |
| 1–2 | 2–0 | none | 0 |
| 2–1 wildcard | 2–1 | exact × 1.5 | 7.5 |

Boundary tests should also cover zero scores, invalid negatives, large accepted values, wildcard ineligibility, configuration errors, and deterministic repeat execution.

## Sample design

[`samples/scoring-engine.php`](../samples/scoring-engine.php) targets PHP 8.2+ and separates immutable values (`Score`, `ScoringRules`) from classification (`ScoringEngine`) and result reporting (`ScoreAward`). It has no database, clock, or session dependency, so unit tests can call it directly. Eligibility for a wildcard remains outside the calculator; the caller passes whether the already-authorized multiplier applies.
