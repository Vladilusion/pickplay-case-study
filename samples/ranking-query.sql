-- Illustrative MySQL 8.0+ query. CTEs and DENSE_RANK() require MySQL 8.
-- Named :parameters represent prepared-statement values; never interpolate them.
-- This example is a PRIVATE-GROUP ranking. Private-group membership chooses the
-- participant population; competition and optional matchday parameters choose
-- the finalized matches. Tournament groups contain teams and are not used here.
-- The caller must authorize :private_group_id before executing this query.

WITH eligible_users AS (
    SELECT pgm.user_id
    FROM private_group_memberships AS pgm
    JOIN private_groups AS pg ON pg.id = pgm.private_group_id
    WHERE pgm.private_group_id = :private_group_id
      AND pg.competition_id = :competition_id
),
scoped_awards AS (
    SELECT p.user_id, pd.awarded_units
    FROM predictions AS p
    JOIN prediction_details AS pd ON pd.prediction_id = p.id
    JOIN matches AS m
        ON m.id = p.match_id
       AND m.status = 'final'
    JOIN matchdays AS md
        ON md.id = m.matchday_id
       AND md.competition_id = :competition_id
       AND (:matchday_id IS NULL OR md.id = :matchday_id)
),
scoped_points AS (
    SELECT
        eu.user_id,
        COALESCE(SUM(sa.awarded_units), 0) AS total_units,
        COUNT(sa.awarded_units) AS scored_predictions
    FROM eligible_users AS eu
    LEFT JOIN scoped_awards AS sa ON sa.user_id = eu.user_id
    GROUP BY eu.user_id
),
positioned AS (
    SELECT
        np.user_id,
        np.total_units,
        np.scored_predictions,
        DENSE_RANK() OVER (ORDER BY np.total_units DESC) AS position_no
    FROM scoped_points AS np
)
SELECT
    p.position_no,
    p.user_id,
    u.display_name,
    p.total_units / 2.0 AS total_points,
    p.scored_predictions
FROM positioned AS p
JOIN users AS u ON u.id = p.user_id
ORDER BY p.position_no, u.display_name, p.user_id;
