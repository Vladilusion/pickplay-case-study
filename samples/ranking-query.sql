-- Illustrative MySQL 8.0+ query. CTEs and DENSE_RANK() require MySQL 8.
-- Named :parameters represent prepared-statement values; never interpolate them.
-- This example ranks eligible members of one competition group for a matchday.

WITH eligible_users AS (
    SELECT gm.user_id
    FROM group_memberships AS gm
    JOIN competition_groups AS cg ON cg.id = gm.group_id
    WHERE gm.group_id = :group_id
      AND cg.competition_id = :competition_id
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
