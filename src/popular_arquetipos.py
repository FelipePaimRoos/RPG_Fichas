import json
from pathlib import Path
from src import database
from src import models

# Garante que as tabelas existem
models.Base.metadata.create_all(bind=database.engine)
db = database.SessionLocal()

with open(Path(__file__).with_name("json") / "arquetipos.json", "r", encoding="utf-8") as f:
    dados = json.load(f)

for arq in dados:
    # Verifica se já existe para evitar duplicatas
    existe = db.query(models.PersonagemModel).filter_by(arquetipo=arq["nome"]).first() # ou tabela dedicada
    # Insere na tabela correspondente...
    