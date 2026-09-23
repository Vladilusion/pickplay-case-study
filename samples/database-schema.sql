-- Illustrative MySQL 8+ schema for the public PickPlay case study.
-- This is not the production schema and contains no production data.

CREATE TABLE users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(254) NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    status ENUM('active', 'disabled') NOT NULL DEFAULT 'active',
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
        ON UPDATE CURRENT_TIMESTAMP(6),
    CONSTRAINT uq_users_email UNIQUE (email)
) ENGINE = InnoDB;

CREATE TABLE competitions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    slug VARCHAR(100) NOT NULL,
    name VARCHAR(160) NOT NULL,
    display_timezone VARCHAR(64) NOT NULL DEFAULT 'UTC',
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
        ON UPDATE CURRENT_TIMESTAMP(6),
    CONSTRAINT uq_competitions_slug UNIQUE (slug)
) ENGINE = InnoDB;

CREATE TABLE teams (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    competition_id BIGINT UNSIGNED NOT NULL,
    code VARCHAR(20) NOT NULL,
    name VARCHAR(120) NOT NULL,
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    CONSTRAINT fk_teams_competition FOREIGN KEY (competition_id)
        REFERENCES competitions (id) ON DELETE RESTRICT,
    CONSTRAINT uq_teams_competition_code UNIQUE (competition_id, code)
) ENGINE = InnoDB;

CREATE TABLE competition_groups (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    competition_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    CONSTRAINT fk_groups_competition FOREIGN KEY (competition_id)
        REFERENCES competitions (id) ON DELETE RESTRICT,
    CONSTRAINT uq_groups_competition_name UNIQUE (competition_id, name)
) ENGINE = InnoDB;

CREATE TABLE group_memberships (
    group_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    joined_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (group_id, user_id),
    CONSTRAINT fk_memberships_group FOREIGN KEY (group_id)
        REFERENCES competition_groups (id) ON DELETE CASCADE,
    CONSTRAINT fk_memberships_user FOREIGN KEY (user_id)
        REFERENCES users (id) ON DELETE RESTRICT,
    INDEX ix_memberships_user_group (user_id, group_id)
) ENGINE = InnoDB;

CREATE TABLE matchdays (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    competition_id BIGINT UNSIGNED NOT NULL,
    sequence_no INT UNSIGNED NOT NULL,
    name VARCHAR(100) NOT NULL,
    starts_at TIMESTAMP(6) NULL,
    ends_at TIMESTAMP(6) NULL,
    CONSTRAINT fk_matchdays_competition FOREIGN KEY (competition_id)
        REFERENCES competitions (id) ON DELETE RESTRICT,
    CONSTRAINT uq_matchdays_sequence UNIQUE (competition_id, sequence_no),
    CONSTRAINT ck_matchdays_interval CHECK (
        starts_at IS NULL OR ends_at IS NULL OR starts_at <= ends_at
    )
) ENGINE = InnoDB;

CREATE TABLE scoring_rules (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    competition_id BIGINT UNSIGNED NOT NULL,
    version_no INT UNSIGNED NOT NULL,
    exact_units SMALLINT UNSIGNED NOT NULL DEFAULT 10,
    goal_difference_units SMALLINT UNSIGNED NOT NULL DEFAULT 6,
    winner_units SMALLINT UNSIGNED NOT NULL DEFAULT 4,
    draw_units SMALLINT UNSIGNED NOT NULL DEFAULT 4,
    wildcard_numerator SMALLINT UNSIGNED NOT NULL DEFAULT 3,
    wildcard_denominator SMALLINT UNSIGNED NOT NULL DEFAULT 2,
    effective_from TIMESTAMP(6) NOT NULL,
    effective_to TIMESTAMP(6) NULL,
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    CONSTRAINT fk_rules_competition FOREIGN KEY (competition_id)
        REFERENCES competitions (id) ON DELETE RESTRICT,
    CONSTRAINT uq_rules_version UNIQUE (competition_id, version_no),
    CONSTRAINT ck_rules_interval CHECK (
        effective_to IS NULL OR effective_from < effective_to
    ),
    CONSTRAINT ck_rules_denominator CHECK (wildcard_denominator > 0),
    INDEX ix_rules_effective (competition_id, effective_from, effective_to)
) ENGINE = InnoDB;

CREATE TABLE matches (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    matchday_id BIGINT UNSIGNED NOT NULL,
    home_team_id BIGINT UNSIGNED NOT NULL,
    away_team_id BIGINT UNSIGNED NOT NULL,
    scoring_rule_id BIGINT UNSIGNED NOT NULL,
    kickoff_at TIMESTAMP(6) NOT NULL,
    closes_at TIMESTAMP(6) NOT NULL,
    status ENUM('scheduled', 'locked', 'final') NOT NULL DEFAULT 'scheduled',
    home_score SMALLINT UNSIGNED NULL,
    away_score SMALLINT UNSIGNED NULL,
    finalized_at TIMESTAMP(6) NULL,
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
        ON UPDATE CURRENT_TIMESTAMP(6),
    CONSTRAINT fk_matches_matchday FOREIGN KEY (matchday_id)
        REFERENCES matchdays (id) ON DELETE RESTRICT,
    CONSTRAINT fk_matches_home_team FOREIGN KEY (home_team_id)
        REFERENCES teams (id) ON DELETE RESTRICT,
    CONSTRAINT fk_matches_away_team FOREIGN KEY (away_team_id)
        REFERENCES teams (id) ON DELETE RESTRICT,
    CONSTRAINT fk_matches_rule FOREIGN KEY (scoring_rule_id)
        REFERENCES scoring_rules (id) ON DELETE RESTRICT,
    CONSTRAINT ck_matches_distinct_teams CHECK (home_team_id <> away_team_id),
    CONSTRAINT ck_matches_close_before_kickoff CHECK (closes_at <= kickoff_at),
    CONSTRAINT ck_matches_result_pair CHECK (
        (home_score IS NULL AND away_score IS NULL)
        OR (home_score IS NOT NULL AND away_score IS NOT NULL)
    ),
    INDEX ix_matches_matchday_status_kickoff (matchday_id, status, kickoff_at),
    INDEX ix_matches_close_status (closes_at, status)
) ENGINE = InnoDB;

CREATE TABLE predictions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    match_id BIGINT UNSIGNED NOT NULL,
    submitted_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
        ON UPDATE CURRENT_TIMESTAMP(6),
    CONSTRAINT fk_predictions_user FOREIGN KEY (user_id)
        REFERENCES users (id) ON DELETE RESTRICT,
    CONSTRAINT fk_predictions_match FOREIGN KEY (match_id)
        REFERENCES matches (id) ON DELETE RESTRICT,
    CONSTRAINT uq_predictions_user_match UNIQUE (user_id, match_id),
    INDEX ix_predictions_match_user (match_id, user_id)
) ENGINE = InnoDB;

CREATE TABLE prediction_details (
    prediction_id BIGINT UNSIGNED PRIMARY KEY,
    home_score SMALLINT UNSIGNED NOT NULL,
    away_score SMALLINT UNSIGNED NOT NULL,
    wildcard_applied BOOLEAN NOT NULL DEFAULT FALSE,
    awarded_units SMALLINT UNSIGNED NULL,
    award_reason VARCHAR(40) NULL,
    calculated_at TIMESTAMP(6) NULL,
    CONSTRAINT fk_details_prediction FOREIGN KEY (prediction_id)
        REFERENCES predictions (id) ON DELETE CASCADE
) ENGINE = InnoDB;

-- Optional derived snapshot. Source predictions/results remain authoritative.
CREATE TABLE rankings (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    competition_id BIGINT UNSIGNED NOT NULL,
    matchday_id BIGINT UNSIGNED NULL,
    group_id BIGINT UNSIGNED NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    scope_key VARCHAR(120) NOT NULL,
    total_units INT UNSIGNED NOT NULL,
    position_no INT UNSIGNED NOT NULL,
    source_version VARCHAR(64) NOT NULL,
    calculated_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    CONSTRAINT fk_rankings_competition FOREIGN KEY (competition_id)
        REFERENCES competitions (id) ON DELETE CASCADE,
    CONSTRAINT fk_rankings_matchday FOREIGN KEY (matchday_id)
        REFERENCES matchdays (id) ON DELETE CASCADE,
    CONSTRAINT fk_rankings_group FOREIGN KEY (group_id)
        REFERENCES competition_groups (id) ON DELETE CASCADE,
    CONSTRAINT fk_rankings_user FOREIGN KEY (user_id)
        REFERENCES users (id) ON DELETE RESTRICT,
    CONSTRAINT uq_rankings_snapshot UNIQUE
        (competition_id, scope_key, user_id, source_version),
    INDEX ix_rankings_display
        (competition_id, scope_key, source_version, position_no, user_id)
) ENGINE = InnoDB;

-- Cross-table rules (for example, ensuring both teams belong to the matchday's
-- competition and effective scoring periods do not overlap) require guarded
-- application transactions or database triggers beyond these local checks.
