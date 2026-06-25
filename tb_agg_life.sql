WITH tb_agg_life AS (

    SELECT t1.dt_match,
            t1.team_current_name,

            sum(CASE WHEN t2.score > t2.away_score THEN 1 ELSE 0 END) AS qtdWinnerMatches,
            sum(CASE WHEN t2.score < t2.away_score THEN 1 ELSE 0 END) AS qtdLoserMatches,

            avg(CASE WHEN t2.score > t2.away_score THEN 1 ELSE 0 END) AS avgWinnerMatches,
            avg(CASE WHEN t2.score < t2.away_score THEN 1 ELSE 0 END) AS avgLoserMatches,

            COUNT(DISTINCT CASE WHEN t2.tournament = 'FIFA World Cup' THEN t2.year_tournament END) AS qtdWorldCup,
            COUNT(DISTINCT CASE WHEN t2.tournament = 'FIFA World Cup' THEN t2.match_id END) AS qtdWorldCupMatches,
            sum(CASE WHEN t2.tournament = 'FIFA World Cup' THEN t2.score END) AS qtdWorldCupScore,
            sum(CASE WHEN t2.tournament = 'FIFA World Cup' THEN t2.away_score END) AS qtdWorldCupAwayScore,
            sum(CASE WHEN t2.tournament = 'FIFA World Cup' THEN t2.score - t2.away_score END) AS qtdWorldCupBalanceScore,
            sum(CASE WHEN t2.tournament = 'FIFA World Cup' THEN t2.score > t2.away_score END) AS qtdWorldCupWinnerMatches,
            sum(CASE WHEN t2.tournament = 'FIFA World Cup' THEN t2.score < t2.away_score END) AS qtdWorldCupLoserMatches,

            COUNT(DISTINCT CASE WHEN t2.tournament = 'FIFA World Cup qualification' THEN t2.year_tournament END) AS qtdeFifaWorldCupQualification,
            COUNT(DISTINCT CASE WHEN t2.tournament = 'FIFA World Cup qualification' THEN t2.match_id END) AS qtdWorldCupQualificationMatches,
            sum(CASE WHEN t2.tournament = 'FIFA World Cup qualification' THEN t2.score END) AS qtdWorldCupQualificationScore,
            sum(CASE WHEN t2.tournament = 'FIFA World Cup qualification' THEN t2.away_score END) AS qtdWorldCupQualificationAwayScore,
            sum(CASE WHEN t2.tournament = 'FIFA World Cup qualification' THEN t2.score - t2.away_score END) AS qtdWorldCupQualificationBalanceScore,
            sum(CASE WHEN t2.tournament = 'FIFA World Cup qualification' THEN t2.score > t2.away_score END) AS qtdWorldCupQualificationWinnerMatches,
            sum(CASE WHEN t2.tournament = 'FIFA World Cup qualification' THEN t2.score < t2.away_score END) AS qtdWorldCupQualificationLoserMatches,

            avg(CASE WHEN t2.tournament = 'FIFA World Cup' THEN t2.score END) AS avgWorldCupScore,
            avg(CASE WHEN t2.tournament = 'FIFA World Cup' THEN t2.away_score END) AS avgWorldCupAwayScore,
            avg(CASE WHEN t2.tournament = 'FIFA World Cup' THEN t2.score - t2.away_score END) AS avgWorldCupBalanceScore,
            avg(CASE WHEN t2.tournament = 'FIFA World Cup' THEN t2.score > t2.away_score END) AS avgWorldCupWinnerMatches,
            avg(CASE WHEN t2.tournament = 'FIFA World Cup' THEN t2.score < t2.away_score END) AS avgWorldCupLoserMatches,
            avg(CASE WHEN t2.tournament = 'FIFA World Cup qualification' THEN t2.score END) AS avgWorldCupQualificationScore,
            avg(CASE WHEN t2.tournament = 'FIFA World Cup qualification' THEN t2.away_score END) AS avgWorldCupQualificationAwayScore,
            avg(CASE WHEN t2.tournament = 'FIFA World Cup qualification' THEN t2.score - t2.away_score END) AS avgWorldCupQualificationBalanceScore,
            avg(CASE WHEN t2.tournament = 'FIFA World Cup qualification' THEN t2.score > t2.away_score END) AS avgWorldCupQualificationWinnerMatches,
            avg(CASE WHEN t2.tournament = 'FIFA World Cup qualification' THEN t2.score < t2.away_score END) AS avgWorldCupQualificationLoserMatches,


            COUNT(DISTINCT CASE WHEN t2.tournament = 'Copa América' THEN t2.year_tournament END) AS qtdeCopaAmerica,
            COUNT(DISTINCT CASE WHEN t2.tournament = 'Copa América' THEN t2.match_id END) AS qtdeCopaAmericaMatches,

            COUNT(DISTINCT CASE WHEN t2.tournament = 'Copa América qualification' THEN t2.year_tournament END) AS qtdeCopaAmericaQualification,
            COUNT(DISTINCT CASE WHEN t2.tournament = 'Copa América qualification' THEN t2.match_id END) AS qtdeCopaAmericaQualificationMatches,

            COUNT(DISTINCT CASE WHEN t2.tournament = 'African Cup of Nations' THEN t2.year_tournament END) AS qtdeAfricanCupOfNations,
            COUNT(DISTINCT CASE WHEN t2.tournament = 'African Cup of Nations' THEN t2.match_id END) AS qtdeAfricanCupOfNationsMatches,

            COUNT(DISTINCT CASE WHEN t2.tournament = 'African Cup of Nations qualification' THEN t2.year_tournament END) AS qtdeAfricanCupOfNationsQualification,
            COUNT(DISTINCT CASE WHEN t2.tournament = 'African Cup of Nations qualification' THEN t2.match_id END) AS qtdeAfricanCupOfNationsQualificationMatches,

            COUNT(DISTINCT CASE WHEN t2.tournament = 'AFC Asian Cup' THEN t2.year_tournament END) AS qtdeAfcAsianCup,
            COUNT(DISTINCT CASE WHEN t2.tournament = 'AFC Asian Cup' THEN t2.match_id END) AS qtdeAfcAsianCupMatches,

            COUNT(DISTINCT CASE WHEN t2.tournament = 'AFC Asian Cup qualification' THEN t2.year_tournament END) AS qtdeAfcAsianCupQualification,
            COUNT(DISTINCT CASE WHEN t2.tournament = 'AFC Asian Cup qualification' THEN t2.match_id END) AS qtdeAfcAsianCupQualificationMatches,

            COUNT(DISTINCT CASE WHEN t2.tournament = 'CECAFA Cup' THEN t2.year_tournament END) AS qtdeCecafaCup,
            COUNT(DISTINCT CASE WHEN t2.tournament = 'CECAFA Cup' THEN t2.match_id END) AS qtdeCecafaCupMatches,

            COUNT(DISTINCT CASE WHEN t2.tournament = 'CONCACAF Championship' THEN t2.year_tournament END) AS qtdeConcacafChampionship,
            COUNT(DISTINCT CASE WHEN t2.tournament = 'CONCACAF Championship' THEN t2.match_id END) AS qtdeConcacafChampionshipMatches,

            COUNT(DISTINCT CASE WHEN t2.tournament = 'CONCACAF Championship qualification' THEN t2.year_tournament END) AS qtdeConcacafChampionshipQualification,
            COUNT(DISTINCT CASE WHEN t2.tournament = 'CONCACAF Championship qualification' THEN t2.match_id END) AS qtdeConcacafChampionshipQualificationMatches,

            COUNT(DISTINCT CASE WHEN t2.tournament = 'CONCACAF Nations League' THEN t2.year_tournament END) AS qtdeConcacafNationsLeague,
            COUNT(DISTINCT CASE WHEN t2.tournament = 'CONCACAF Nations League' THEN t2.match_id END) AS qtdeConcacafNationsLeagueMatches,

            COUNT(DISTINCT CASE WHEN t2.tournament = 'CONCACAF Nations League qualification' THEN t2.year_tournament END) AS qtdeConcacafNationsLeagueQualification,
            COUNT(DISTINCT CASE WHEN t2.tournament = 'CONCACAF Nations League qualification' THEN t2.match_id END) AS qtdeConcacafNationsLeagueQualificationMatches,

            COUNT(DISTINCT CASE WHEN t2.tournament = 'Oceania Nations Cup' THEN t2.year_tournament END) AS qtdeOceaniaNationsCup,
            COUNT(DISTINCT CASE WHEN t2.tournament = 'Oceania Nations Cup' THEN t2.match_id END) AS qtdeOceaniaNationsCupMatches,

            COUNT(DISTINCT CASE WHEN t2.tournament = 'Oceania Nations Cup qualification' THEN t2.year_tournament END) AS qtdeOceaniaNationsCupQualification,
            COUNT(DISTINCT CASE WHEN t2.tournament = 'Oceania Nations Cup qualification' THEN t2.match_id END) AS qtdeOceaniaNationsCupQualificationMatches,

            COUNT(DISTINCT CASE WHEN t2.tournament = 'Gold Cup' THEN t2.year_tournament END) AS qtdeGoldCup,
            COUNT(DISTINCT CASE WHEN t2.tournament = 'Gold Cup' THEN t2.match_id END) AS qtdeGoldCupMatches,

            COUNT(DISTINCT CASE WHEN t2.tournament = 'Gold Cup qualification' THEN t2.year_tournament END) AS qtdeGoldCupQualification,
            COUNT(DISTINCT CASE WHEN t2.tournament = 'Gold Cup qualification' THEN t2.match_id END) AS qtdeGoldCupQualificationMatches,

            COUNT(DISTINCT CASE WHEN t2.tournament = 'Pan American Championship' THEN t2.year_tournament END) AS qtdePanAmericanChampionship,
            COUNT(DISTINCT CASE WHEN t2.tournament = 'Pan American Championship' THEN t2.match_id END) AS qtdePanAmericanChampionshipMatches,

            COUNT(DISTINCT CASE WHEN t2.tournament = 'UEFA Euro' THEN t2.year_tournament END) AS qtdeUefaEuro,
            COUNT(DISTINCT CASE WHEN t2.tournament = 'UEFA Euro' THEN t2.match_id END) AS qtdeUefaEuroMatches,

            COUNT(DISTINCT CASE WHEN t2.tournament = 'UEFA Euro qualification' THEN t2.year_tournament END) AS qtdeUefaEuroQualification,
            COUNT(DISTINCT CASE WHEN t2.tournament = 'UEFA Euro qualification' THEN t2.match_id END) AS qtdeUefaEuroQualificationMatches,

            COUNT(DISTINCT CASE WHEN t2.tournament = 'UEFA Nations League' THEN t2.year_tournament END) AS qtdeUefaNationsLeague,
            COUNT(DISTINCT CASE WHEN t2.tournament = 'UEFA Nations League' THEN t2.match_id END) AS qtdeUefaNationsLeagueMatches

    FROM tb_team_matches AS t1

    LEFT JOIN tb_team_matches AS t2
    ON t1.team_current_name = t2.team_current_name
    AND t1.dt_match > t2.dt_match

    WHERE t1.dt_match = '{date}'

    GROUP BY t1.dt_match, t1.team_current_name

    ORDER BY t1.match_id
)

SELECT * FROM tb_agg_life