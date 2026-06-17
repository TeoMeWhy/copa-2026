DROP TABLE IF EXISTS tb_team_matches;
CREATE TABLE IF NOT EXISTS tb_team_matches AS

WITH tb_home_team AS (

    SELECT

    date || '-' || home_team || '-' || away_team || '-' || tournament AS match_id,
    date as dt_match,
    home_team as team,
    home_score as score,
    away_team,
    away_score,
    tournament,
    city,
    country,
    neutral
    
    FROM results
),

tb_away_team AS (

    SELECT
        date || '-' || home_team || '-' || away_team || '-' || tournament AS match_id,
        date as dt_match,
        away_team as team,
        away_score as score,
        home_team as away_team,
        home_score as away_score,
        tournament,
        city,
        country,
        neutral

    FROM results

),

tb_union AS (

    SELECT t1.*,
            strftime('%Y', JULIANDAY(dt_match)) || '-' || tournament AS year_tournament,
            COALESCE(t2.former, t1.team) AS team_current_name,
            COALESCE(t3.former, t1.away_team) AS away_team_current_name

    FROM (
        SELECT * FROM tb_home_team
        UNION ALL
        SELECT * FROM tb_away_team
    ) AS t1

    LEFT JOIN former_names AS t2
    ON t1.team = t2.former

    LEFT JOIN former_names AS t3
    ON t1.away_team = t3.former

)


SELECT * FROM tb_union;