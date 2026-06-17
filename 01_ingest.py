# %%

import pandas as pd
import sqlalchemy

import os

from rich.progress import track

# %%

engine = sqlalchemy.create_engine("sqlite:///data/database.db")

files = os.listdir("data/")
files
# %%

for i in track(files, description="enviando dados para o banco de dados...."):
    path = os.path.join("data/", i)
    df = pd.read_csv(path)
    df.to_sql(i.split(".")[0], engine, if_exists="replace", index=False)