# %%

import argparse

import pandas as pd
import sqlalchemy

from rich.progress import track

# %%

def import_query(path: str) -> str:
    with open(path, "r") as f:
        query = f.read()
    return query

parser = argparse.ArgumentParser(description="Processa as safras para o banco de dados.")
parser.add_argument("--query", type=str, default="tb_away", help="Nome da query a ser processada (sem extensão .sql).")
args = parser.parse_args()

engine = sqlalchemy.create_engine("sqlite:///data/database.db")

query_name = args.query
query = import_query(f"{query_name}.sql")

dates = [i.strftime("%Y-%m-%d") for i in pd.date_range(start="2000-01-01", end="2026-06-01", freq="D")]

for d in track(dates, description=f"Processandod safras para {query_name}..."):
    df = pd.read_sql_query(query.format(date=d), con=engine)
    df.to_sql(query_name, con=engine, if_exists="append", index=False)

