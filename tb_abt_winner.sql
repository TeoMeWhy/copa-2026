DROP TABLE IF EXISTS tb_abt_winner;
CREATE TABLE IF NOT EXISTS tb_abt_winner AS

SELECT 
        distinct
        CASE WHEN t1.score > t1.away_score THEN 1 ELSE 0 END AS winner,
        t1.match_id,
        t1.dt_match,
        t1.team_current_name,
        t1.away_team_current_name,
        t1.country,
        t1.city,
        t1.score,
        t1.away_score,
        t1.tournament,
       t2.qtdWorldCup,
       t2.qtdWorldCupMatches,
       t2.qtdWorldCupScore,
       t2.qtdWorldCupAwayScore,
       t2.qtdWorldCupBalanceScore,
       t2.qtdWorldCupWinnerMatches,
       t2.qtdWorldCupLoserMatches,
       t2.qtdeFifaWorldCupQualification,
       t2.qtdWorldCupQualificationMatches,
       t2.qtdWorldCupQualificationScore,
       t2.qtdWorldCupQualificationAwayScore,
       t2.qtdWorldCupQualificationBalanceScore,
       t2.qtdWorldCupQualificationWinnerMatches,
       t2.qtdWorldCupQualificationLoserMatches,
       t2.qtdeCopaAmerica,
       t2.qtdeCopaAmericaMatches,
       t2.qtdeCopaAmericaQualification,
       t2.qtdeCopaAmericaQualificationMatches,
       t2.qtdeAfricanCupOfNations,
       t2.qtdeAfricanCupOfNationsMatches,
       t2.qtdeAfricanCupOfNationsQualification,
       t2.qtdeAfricanCupOfNationsQualificationMatches,
       t2.qtdeAfcAsianCup,
       t2.qtdeAfcAsianCupMatches,
       t2.qtdeAfcAsianCupQualification,
       t2.qtdeAfcAsianCupQualificationMatches,
       t2.qtdeCecafaCup,
       t2.qtdeCecafaCupMatches,
       t2.qtdeConcacafChampionship,
       t2.qtdeConcacafChampionshipMatches,
       t2.qtdeConcacafChampionshipQualification,
       t2.qtdeConcacafChampionshipQualificationMatches,
       t2.qtdeConcacafNationsLeague,
       t2.qtdeConcacafNationsLeagueMatches,
       t2.qtdeConcacafNationsLeagueQualification,
       t2.qtdeConcacafNationsLeagueQualificationMatches,
       t2.qtdeOceaniaNationsCup,
       t2.qtdeOceaniaNationsCupMatches,
       t2.qtdeOceaniaNationsCupQualification,
       t2.qtdeOceaniaNationsCupQualificationMatches,
       t2.qtdeGoldCup,
       t2.qtdeGoldCupMatches,
       t2.qtdeGoldCupQualification,
       t2.qtdeGoldCupQualificationMatches,
       t2.qtdePanAmericanChampionship,
       t2.qtdePanAmericanChampionshipMatches,
       t2.qtdeUefaEuro,
       t2.qtdeUefaEuroMatches,
       t2.qtdeUefaEuroQualification,
       t2.qtdeUefaEuroQualificationMatches,
       t2.qtdeUefaNationsLeague,
       t2.qtdeUefaNationsLeagueMatches,
       t3.qtdeFriendlyAwayTeamMatches,
       t3.qtdeFriendlyAwayTeamBalanceScore,
       t3.qtdeFriendlyAwayTeamWinner,
       t3.qtdeWorldCupAwayTeamMatches,
       t3.qtdeFifaWorldCupAwayTeamBalanceScore,
       t3.qtdeFifaWorldCupAwayTeamWinner,
       t3.qtdeFifaWorldCupQualificationAwayTeamMacthes,
       t3.qtdeFifaWorldCupQualificationAwayTeamBalanceScore,
       t3.qtdeFifaWorldCupQualificationAwayTeamWinner

FROM tb_team_matches AS t1

LEFT JOIN tb_agg_life AS t2
ON t1.team_current_name = t2.team_current_name
AND t1.dt_match = t2.dt_match

LEFT JOIN tb_away AS t3
ON t1.dt_match = t3.dt_match
AND t1.team_current_name = t3.team_current_name
AND t1.away_team_current_name = t3.away_team_current_name

WHERE t1.dt_match >= '2000-01-01'
AND t1.tournament <> 'Friendly'

ORDER BY match_id

;