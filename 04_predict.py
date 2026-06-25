# %%

import itertools
import pandas as pd

pd.options.display.max_columns = None
pd.options.display.max_rows = None

import sqlalchemy

import mlflow

mlflow.set_tracking_uri("http://192.168.0.18:5000")

engine = sqlalchemy.create_engine("sqlite:///data/database.db")

def import_query(path):
    with open(path, "r") as file:
        query = file.read()
    return query

# %%
query_teams_fs = import_query("tb_team_features.sql")
df_team_fs = pd.read_sql_query(query_teams_fs, engine)
df_team_fs.head()

query_team_away_fs = import_query("tb_team_away_features.sql")
df_away_fs = pd.read_sql_query(query_team_away_fs, engine)
df_away_fs.head()

df_matches = pd.read_csv("data/2026/wc_2026_fixtures.csv")

df_matches['team1'] = df_matches['team1'].replace({
    'Czechia': 'Czech Republic',
    'Türkiye': 'Turkey',
    'USA': 'United States'
})

df_matches['team2'] = df_matches['team2'].replace({
    'Czechia': 'Czech Republic',
    'Türkiye': 'Turkey',
    'USA': 'United States'
})

df_matches.head()
# %%

df_matches_teams = df_matches[['group', 'team1', 'team2']].copy()

df_matches_teams["match_id"] = df_matches_teams.index

df_1 = df_matches_teams.rename(columns={"team1": "team_current_name", "team2": "away_team_current_name"})
df_2 = df_matches_teams.rename(columns={"team2": "team_current_name", "team1": "away_team_current_name"})

df_all = (pd.concat([df_1, df_2], ignore_index=True)
            .sort_values(by=['group', 'team_current_name', 'away_team_current_name'])
            .reset_index(drop=True))

df_all = df_all.merge(df_team_fs, on="team_current_name", how="left").merge(df_away_fs, on=["team_current_name", "away_team_current_name"], how="left")
df_all['tournament'] = 'FIFA World Cup'

df_groups = df_all.dropna(subset=["group"]).copy()

# %%

model = mlflow.sklearn.load_model("models:/copa-mundo/5")

X = df_groups[model.feature_names_in_].copy()

# %%

predictions = model.predict_proba(X)

df_groups['prob_win'] = predictions[:, 1]

df_groups_analytics = (df_groups[['group', 'match_id', 'team_current_name', 'away_team_current_name', 'prob_win']]
                      .sort_values(by=['match_id', 'prob_win'], ascending=[True, False])
                      .drop_duplicates(subset=['match_id'], keep='first')
                      .groupby(['group', 'team_current_name']).agg({"match_id": "count", "prob_win": "mean"})
                      .reset_index()
                      .sort_values(by=['group', 'match_id'], ascending=[True, False]))

# %%

df_qualified_groups = df_groups_analytics[df_groups_analytics['match_id'] >= 2]
df_qualified_groups

# %%

df_qualified_best_3 = (df_groups_analytics[df_groups_analytics['match_id']==1]
                            .sort_values(by='prob_win', ascending=False)
                            .head(8))

df_qualified_best_3

# %%

df_mata_mata = (pd.concat([df_qualified_groups, df_qualified_best_3], ignore_index=True)
                    .sort_values(by=['group', 'prob_win'], ascending=[True, False])
                    .reset_index(drop=True))


combinacoes = list(itertools.permutations(df_mata_mata["team_current_name"].unique().tolist(), 2))

df_combinacoes = pd.DataFrame(combinacoes, columns=["team_current_name", "away_team_current_name"])
df_combinacoes['tournament'] = 'FIFA World Cup'
df_combinacoes = (df_combinacoes.merge(df_team_fs, on="team_current_name", how="left")
                               .merge(df_away_fs, on=["team_current_name", "away_team_current_name"], how="left"))

df_combinacoes['prob_win'] = model.predict_proba(df_combinacoes[model.feature_names_in_])[:, 1]

# %%

def make_id(row):
    teams = [row['team_current_name'], row['away_team_current_name']]
    teams.sort()
    return "-".join(teams)


df_combinacoes_analytics = (df_combinacoes[['team_current_name', 'away_team_current_name', 'prob_win']].copy())

df_combinacoes_analytics["match_id"] = df_combinacoes_analytics.apply( make_id, axis=1)

df_combinacoes_analytics = (df_combinacoes_analytics.sort_values(by='prob_win', ascending=False).drop_duplicates(subset=['match_id'], keep='first')
                                                    .groupby(['team_current_name'])
                                                    .agg({"match_id": "count", "prob_win": "mean"})
                                                    .reset_index()
                                                    .sort_values(by=['match_id', 'prob_win'], ascending=False)
                                                    .reset_index(drop=True)
                                                    .reset_index(drop=False)
                                                    .rename(columns={"index": "rank"})
                                                    )

df_combinacoes_analytics["rank"] = df_combinacoes_analytics["rank"] + 1
df_combinacoes_analytics["aproveitamento"] = df_combinacoes_analytics['match_id'] / 31
df_combinacoes_analytics = df_combinacoes_analytics[['rank', 'team_current_name', 'aproveitamento']].rename(columns={"team_current_name": "equipe"})
df_combinacoes_analytics
# %%

df_combinacoes_analytics.head(10).to_markdown("ranking_copa.md", index=False)

# %%
