from pathlib import Path

from sqlalchemy import create_engine, inspect, text
from sqlalchemy.orm import declarative_base, sessionmaker

SQLALCHEMY_DATABASE_URL = "sqlite:///" + str(Path(__file__).resolve().parent / "rpg_fichas.db")

engine = create_engine(
    SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False}
)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

def ensure_schema():
    Base.metadata.create_all(bind=engine)
    columns = {column["name"] for column in inspect(engine).get_columns("personagens")}
    if "owner_id" not in columns:
        with engine.begin() as connection:
            connection.execute(text(
                "ALTER TABLE personagens ADD COLUMN owner_id INTEGER REFERENCES usuarios(id)"
            ))
    ability_columns = {
        column["name"] for column in inspect(engine).get_columns("habilidades")
    }
    skill_columns = {
        column["name"] for column in inspect(engine).get_columns("pericias")
    }
    power_columns = {
        column["name"] for column in inspect(engine).get_columns("poderes")
    }
    ritual_columns = {
        column["name"] for column in inspect(engine).get_columns("rituais")
    }
    with engine.begin() as connection:
        if "automatico" not in ability_columns:
            connection.execute(text(
                "ALTER TABLE habilidades ADD COLUMN automatico BOOLEAN NOT NULL DEFAULT 0"
            ))
        if "nivel_desbloqueio" not in ability_columns:
            connection.execute(text(
                "ALTER TABLE habilidades ADD COLUMN nivel_desbloqueio INTEGER"
            ))
        if "automatico_origem" not in skill_columns:
            connection.execute(text(
                "ALTER TABLE pericias ADD COLUMN automatico_origem BOOLEAN NOT NULL DEFAULT 0"
            ))
        if "custo" not in power_columns:
            connection.execute(text(
                "ALTER TABLE poderes ADD COLUMN custo VARCHAR DEFAULT ''"
            ))
        if "alcance" not in power_columns:
            connection.execute(text(
                "ALTER TABLE poderes ADD COLUMN alcance VARCHAR DEFAULT ''"
            ))
        if "elemento" not in ritual_columns:
            connection.execute(text(
                "ALTER TABLE rituais ADD COLUMN elemento VARCHAR DEFAULT ''"
            ))

    with engine.begin() as connection:
        connection.execute(text(
            "CREATE INDEX IF NOT EXISTS ix_personagens_owner_id ON personagens (owner_id)"
        ))
        user_count = connection.execute(text("SELECT COUNT(*) FROM usuarios")).scalar_one()
        if user_count == 1:
            user_id = connection.execute(text("SELECT id FROM usuarios")).scalar_one()
            connection.execute(
                text("UPDATE personagens SET owner_id = :user_id WHERE owner_id IS NULL"),
                {"user_id": user_id},
            )

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
