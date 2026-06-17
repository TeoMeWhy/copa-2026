# %%

import pandas as pd
import matplotlib.pyplot as plt

pd.options.display.max_columns = None
pd.options.display.max_rows = None

import sqlalchemy

from sklearn import model_selection
from sklearn import ensemble
from sklearn import metrics
from sklearn import pipeline

from feature_engine import imputation as fei
from feature_engine import encoding as fee

import mlflow


engine = sqlalchemy.create_engine("sqlite:///data/database.db")

mlflow.set_tracking_uri("http://192.168.0.18:5000")

df = pd.read_sql("SELECT * FROM tb_abt_winner",engine)
df.head()

# %%

df.dtypes

# %%

to_remove = [
    'match_id',
    'dt_match',
    'winner',
    'score',
    'away_score',
]


cat_features = [
    "team_current_name",
    "away_team_current_name",
    # "country",
    # "city",
    "tournament",
]

number_features = [
    "qtdWorldCup",
    "qtdWorldCupMatches",
    "qtdWorldCupScore",
    "qtdWorldCupAwayScore",
    "qtdWorldCupBalanceScore",
    "qtdWorldCupWinnerMatches",
    "qtdWorldCupLoserMatches",
    "qtdeFifaWorldCupQualification",
    "qtdWorldCupQualificationMatches",
    "qtdWorldCupQualificationScore",
    "qtdWorldCupQualificationAwayScore",
    "qtdWorldCupQualificationBalanceScore",
    "qtdWorldCupQualificationWinnerMatches",
    "qtdWorldCupQualificationLoserMatches",
    "qtdeCopaAmerica",
    "qtdeCopaAmericaMatches",
    "qtdeCopaAmericaQualification",
    "qtdeCopaAmericaQualificationMatches",
    "qtdeAfricanCupOfNations",
    "qtdeAfricanCupOfNationsMatches",
    "qtdeAfricanCupOfNationsQualification",
    "qtdeAfricanCupOfNationsQualificationMatches",
    "qtdeAfcAsianCup",
    "qtdeAfcAsianCupMatches",
    "qtdeAfcAsianCupQualification",
    "qtdeAfcAsianCupQualificationMatches",
    "qtdeCecafaCup",
    "qtdeCecafaCupMatches",
    "qtdeConcacafChampionship",
    "qtdeConcacafChampionshipMatches",
    "qtdeConcacafChampionshipQualification",
    "qtdeConcacafChampionshipQualificationMatches",
    "qtdeConcacafNationsLeague",
    "qtdeConcacafNationsLeagueMatches",
    "qtdeConcacafNationsLeagueQualification",
    "qtdeConcacafNationsLeagueQualificationMatches",
    "qtdeOceaniaNationsCup",
    "qtdeOceaniaNationsCupMatches",
    "qtdeOceaniaNationsCupQualification",
    "qtdeOceaniaNationsCupQualificationMatches",
    "qtdeGoldCup",
    "qtdeGoldCupMatches",
    "qtdeGoldCupQualification",
    "qtdeGoldCupQualificationMatches",
    "qtdePanAmericanChampionship",
    "qtdePanAmericanChampionshipMatches",
    "qtdeUefaEuro",
    "qtdeUefaEuroMatches",
    "qtdeUefaEuroQualification",
    "qtdeUefaEuroQualificationMatches",
    "qtdeUefaNationsLeague",
    "qtdeUefaNationsLeagueMatches",
    "qtdeFriendlyAwayTeamMatches",
    "qtdeFriendlyAwayTeamBalanceScore",
    "qtdeFriendlyAwayTeamWinner",
    "qtdeWorldCupAwayTeamMatches",
    "qtdeFifaWorldCupAwayTeamBalanceScore",
    "qtdeFifaWorldCupAwayTeamWinner",
    "qtdeFifaWorldCupQualificationAwayTeamMacthes",
    "qtdeFifaWorldCupQualificationAwayTeamBalanceScore",
    "qtdeFifaWorldCupQualificationAwayTeamWinner",
]


X = df[cat_features + number_features].copy()
y = df['winner'].copy()


X[number_features] = X[number_features].astype(float)


# %%


X_train, X_test, y_train, y_test = model_selection.train_test_split(X,y,
                                                    test_size=0.2,
                                                    random_state=42,
                                                    stratify=y)

print("Base de Treino:", X_train.shape[0])
print("Base de Teste:", X_test.shape[0])

print("Taxa de resposta Treino:", y_train.mean())
print("Taxa de resposta Teste:", y_test.mean())

# %%

onehot_encoder = fee.OneHotEncoder(variables=["tournament"])
mean_encoder = fee.MeanEncoder(variables=["team_current_name", "away_team_current_name"])
imputer = fei.ArbitraryNumberImputer(variables=number_features, arbitrary_number=0)

clf = ensemble.RandomForestClassifier(random_state=42, n_jobs=-1)

params_grid = {
    "n_estimators": [500],
    "max_depth": [None],
    "min_samples_leaf": [20, 30, 50],
    "max_features": [None],
    "criterion": ['entropy']
}

grid = model_selection.GridSearchCV(estimator=clf,
                                    param_grid=params_grid,
                                    cv=4,
                                    scoring="roc_auc",
                                    verbose=4)


# %%
mlflow.set_experiment("copa-mundo-tmw")

with mlflow.start_run(run_name="random-forest") as run:
    
    mlflow.sklearn.autolog()
    
    model = pipeline.Pipeline(steps=[
        ('onehot_encoder', onehot_encoder),
        ('mean_encoder', mean_encoder),
        ('imputer', imputer),
        ('model', grid)
    ])
    
    model.fit(X_train, y_train)
    y_pred_train = model.predict(X_train)
    y_proba_train = model.predict_proba(X_train)[:,1]
    
    y_pred_test = model.predict(X_test)
    y_proba_test = model.predict_proba(X_test)[:,1]
    
    acc_train = metrics.accuracy_score(y_train, y_pred_train)
    acc_test = metrics.accuracy_score(y_test, y_pred_test)
    
    auc_train = metrics.roc_auc_score(y_train, y_proba_train)
    auc_test = metrics.roc_auc_score(y_test, y_proba_test)
    
    mlflow.log_metrics({
        "acc_train": acc_train,
        "acc_test": acc_test,
        "auc_train": auc_train,
        "auc_test": auc_test
    })
    
    plt.figure(figsize=(7,6), dpi=300)

    rocs_curve_train = metrics.roc_curve(y_train, y_proba_train)
    rocs_curve_test = metrics.roc_curve(y_test, y_proba_test)

    plt.plot(rocs_curve_train[0], rocs_curve_train[1], label="Train")
    plt.plot(rocs_curve_test[0], rocs_curve_test[1], label="Test")
    plt.xlabel("Taxa Falso Positivo")
    plt.ylabel("Taxa Verdadeiro Positivo")
    plt.title("Curva ROC")
    plt.grid(True)
    plt.legend([f"Treino: {auc_train:.4f}", f"Teste: {auc_test:.4f}"])
    plt.savefig("roc_curve.png")
    
    mlflow.log_artifact("roc_curve.png")


    features = model[:-1].transform(X_train).columns.tolist()
    feature_importance = pd.DataFrame(model[-1].best_estimator_.feature_importances_,
                                    index=features,
                                    columns=["importance"]).sort_values("importance", ascending=False)

    feature_importance.to_markdown("feature_importance.md")
    mlflow.log_artifact("feature_importance.md")
    
# %%