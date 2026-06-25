WITH tb_away AS (

    SELECT t1.dt_match,
           t1.team_current_name,
           t2.away_team_current_name,

            count(DISTINCT CASE WHEN t2.tournament = 'Friendly' THEN t2.match_id END) AS qtdeFriendlyAwayTeamMatches,
            sum(CASE WHEN t2.tournament = 'Friendly' THEN t2.score - t2.away_score END) AS qtdeFriendlyAwayTeamBalanceScore,
            sum(CASE WHEN t2.tournament = 'Friendly' THEN t2.score > t2.away_score END) AS qtdeFriendlyAwayTeamWinner,

            count(DISTINCT CASE WHEN t2.tournament = 'FIFA World Cup' THEN t2.match_id END) AS qtdeWorldCupAwayTeamMatches,
            sum(CASE WHEN t2.tournament = 'FIFA World Cup' THEN t2.score - t2.away_score END) AS qtdeFifaWorldCupAwayTeamBalanceScore,
            sum(CASE WHEN t2.tournament = 'FIFA World Cup' THEN t2.score > t2.away_score END) AS qtdeFifaWorldCupAwayTeamWinner,

            count(DISTINCT CASE WHEN t2.tournament = 'FIFA World Cup qualification' THEN t2.match_id END) AS qtdeFifaWorldCupQualificationAwayTeamMacthes,
            sum(CASE WHEN t2.tournament = 'FIFA World Cup qualification' THEN t2.score - t2.away_score END) AS qtdeFifaWorldCupQualificationAwayTeamBalanceScore,
            sum(CASE WHEN t2.tournament = 'FIFA World Cup qualification' THEN t2.score > t2.away_score END) AS qtdeFifaWorldCupQualificationAwayTeamWinner

    FROM tb_team_matches AS t1

    LEFT JOIN tb_team_matches AS t2
    ON t1.team_current_name = t2.team_current_name
    AND t1.dt_match > t2.dt_match

    WHERE t1.dt_match = '{date}'

    GROUP BY t1.dt_match,
            t1.team_current_name,
            t2.away_team_current_name

)

SELECT * FROM tb_away