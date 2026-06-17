WITH tb_rn AS (

    SELECT *,
            row_number() OVER (PARTITION BY team_current_name, away_team_current_name ORDER BY dt_match DESC) AS rn
    FROM tb_away

)

SELECT * FROM tb_rn
WHERE rn=1