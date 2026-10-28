import json
import hashlib
import hmac
import os
import secrets
import time
from pathlib import Path
from typing import Annotated, List, Optional

from fastapi import FastAPI, Depends, HTTPException, Cookie, Header, Response
from fastapi.responses import HTMLResponse
from pydantic import StringConstraints
from pydantic import BaseModel, ConfigDict, Field
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError

import database
import models

database.ensure_schema()

app = FastAPI(title="RPG Ficha API", version="1.0")

SESSION_COOKIE = "rpg_session"
SESSION_DURATION = 60 * 60 * 24 * 14
PASSWORD_ITERATIONS = 310_000
SECURE_COOKIE = os.getenv("COOKIE_SECURE", "").lower() in {"1", "true", "yes"}
FRONTEND_PATH = Path(__file__).with_name("ficha_rpg_completa.html")
ARCHETYPES_PATH = Path(__file__).with_name("arquetipos.json")


@app.get("/", response_class=HTMLResponse, include_in_schema=False)
def servir_ficha():
    if not FRONTEND_PATH.is_file():
        raise HTTPException(status_code=500, detail="Arquivo do frontend não encontrado")
    return HTMLResponse(
        FRONTEND_PATH.read_text(encoding="utf-8"),
        headers={"Cache-Control": "no-store"},
    )


class SchemaBase(BaseModel):
    model_config = ConfigDict(from_attributes=True)


class AtributoSchema(SchemaBase):
    nome: str
    valor: int
    debilitado: Optional[bool] = False


class PericiaSchema(SchemaBase):
    nome: str
    treinamento: str
    bonus: int


class ItemSchema(SchemaBase):
    nome: str
    espaco: int
    descricao: Optional[str] = ""


class HabilidadeSchema(SchemaBase):
    nome: str
    classificacao: Optional[str] = ""
    prereq: Optional[str] = ""
    custo: Optional[str] = ""
    alcance: Optional[str] = ""
    efeito: Optional[str] = ""
    automatico: bool = False
    nivel_desbloqueio: Optional[int] = None


class PoderSchema(SchemaBase):
    nome: str
    elemento: str
    prereq: Optional[str] = ""
    efeito: Optional[str] = ""
    afinidade: Optional[str] = ""


class FichaCompletaSchema(SchemaBase):
    nome: str
    jogador: Optional[str] = ""
    nivel: int = 1
    conceito: Optional[str] = ""
    origem: Optional[str] = ""
    arquetipo: Optional[str] = ""
    vida_atual: int = 10
    vida_max: int = 10
    sanidade_atual: int = 10
    sanidade_max: int = 10
    defesa_atual: int = 10
    bonus_protecoes: int = 0
    deslocamento_base: int = 9
    carga_maxima: int = 10
    resistencias: Optional[str] = ""
    proficiencias: Optional[str] = ""
    exposicao_paranormal: int = 5
    afinidade_elemento: Optional[str] = ""
    crises_contador: int = 0
    dado_paranormal_idx: int = 0
    desc_aparencia: Optional[str] = ""
    desc_personalidade: Optional[str] = ""
    desc_historico: Optional[str] = ""
    desc_objetivo: Optional[str] = ""
    desc_anotacoes: Optional[str] = ""

    atributos: List[AtributoSchema] = Field(default_factory=list)
    pericias: List[PericiaSchema] = Field(default_factory=list)
    inventario: List[ItemSchema] = Field(default_factory=list)
    habilidades: List[HabilidadeSchema] = Field(default_factory=list)
    rituais: List[HabilidadeSchema] = Field(default_factory=list)
    poderes: List[PoderSchema] = Field(default_factory=list)

class CredenciaisSchema(BaseModel):
    username: Annotated[str, StringConstraints(min_length=3, max_length=80)]
    password: Annotated[str, StringConstraints(min_length=8, max_length=128)]


def _hash_password(password: str, salt: bytes) -> bytes:
    return hashlib.pbkdf2_hmac(
        "sha256", password.encode("utf-8"), salt, PASSWORD_ITERATIONS
    )


def _create_session(
    user: models.UsuarioModel, db: Session, response: Response
) -> dict:
    token = secrets.token_urlsafe(32)
    csrf_token = secrets.token_urlsafe(32)
    db.add(models.SessaoModel(
        usuario_id=user.id,
        token_hash=hashlib.sha256(token.encode("ascii")).hexdigest(),
        csrf_token=csrf_token,
        expires_at=int(time.time()) + SESSION_DURATION,
    ))
    db.commit()
    response.set_cookie(
        key=SESSION_COOKIE,
        value=token,
        max_age=SESSION_DURATION,
        httponly=True,
        secure=SECURE_COOKIE,
        samesite="lax",
        path="/",
    )
    return {"username": user.username, "csrf_token": csrf_token}


def get_current_session(
    session_token: Optional[str] = Cookie(default=None, alias=SESSION_COOKIE),
    db: Session = Depends(database.get_db),
) -> models.SessaoModel:
    if not session_token:
        raise HTTPException(status_code=401, detail="Faça login para continuar")

    token_hash = hashlib.sha256(session_token.encode("ascii", errors="ignore")).hexdigest()
    auth_session = db.query(models.SessaoModel).filter(
        models.SessaoModel.token_hash == token_hash
    ).first()
    if not auth_session or auth_session.expires_at <= int(time.time()):
        if auth_session:
            db.delete(auth_session)
            db.commit()
        raise HTTPException(status_code=401, detail="Sessão inválida ou expirada")
    return auth_session


def require_csrf(
    csrf_token: Optional[str] = Header(default=None, alias="X-CSRF-Token"),
    auth_session: models.SessaoModel = Depends(get_current_session),
) -> models.SessaoModel:
    if not csrf_token or not hmac.compare_digest(csrf_token, auth_session.csrf_token):
        raise HTTPException(status_code=403, detail="Token de segurança inválido")
    return auth_session


@app.post("/api/auth/register", status_code=201)
def registrar(
    dados: CredenciaisSchema,
    response: Response,
    db: Session = Depends(database.get_db),
):
    username = dados.username.strip().casefold()
    if len(username) < 3:
        raise HTTPException(status_code=422, detail="O login deve ter ao menos 3 caracteres")
    salt = secrets.token_bytes(16)
    user = models.UsuarioModel(
        username=username,
        password_salt=salt.hex(),
        password_hash=_hash_password(dados.password, salt).hex(),
    )
    db.add(user)
    try:
        db.flush()
        user_count = db.query(models.UsuarioModel).count()
        if user_count == 1:
            db.query(models.PersonagemModel).filter(
                models.PersonagemModel.owner_id.is_(None)
            ).update({models.PersonagemModel.owner_id: user.id})
        db.commit()
    except IntegrityError as exc:
        db.rollback()
        raise HTTPException(status_code=409, detail="Este login já está em uso") from exc
    return _create_session(user, db, response)


@app.post("/api/auth/login")
def login(
    dados: CredenciaisSchema,
    response: Response,
    db: Session = Depends(database.get_db),
):
    username = dados.username.strip().casefold()
    user = db.query(models.UsuarioModel).filter(
        models.UsuarioModel.username == username
    ).first()
    salt = bytes.fromhex(user.password_salt) if user else bytes(16)
    expected_hash = bytes.fromhex(user.password_hash) if user else bytes(32)
    actual_hash = _hash_password(dados.password, salt)
    if not user or not hmac.compare_digest(actual_hash, expected_hash):
        raise HTTPException(status_code=401, detail="Login ou senha incorretos")
    return _create_session(user, db, response)


@app.get("/api/auth/me")
def obter_perfil(
    auth_session: models.SessaoModel = Depends(get_current_session),
):
    return {
        "username": auth_session.usuario.username,
        "csrf_token": auth_session.csrf_token,
    }


@app.post("/api/auth/logout")
def logout(
    response: Response,
    auth_session: models.SessaoModel = Depends(require_csrf),
    db: Session = Depends(database.get_db),
):
    db.delete(auth_session)
    db.commit()
    response.delete_cookie(
        key=SESSION_COOKIE, path="/", httponly=True, samesite="lax",
        secure=SECURE_COOKIE,
    )
    return {"status": "sucesso"}


@app.get("/api/personagens")
def listar_personagens(
    auth_session: models.SessaoModel = Depends(get_current_session),
    db: Session = Depends(database.get_db),
):
    chars = db.query(models.PersonagemModel).filter(
        models.PersonagemModel.owner_id == auth_session.usuario_id
    ).all()
    return [
        {"id": c.id, "nome": c.nome, "nivel": c.nivel, "conceito": c.conceito}
        for c in chars
    ]


NIVEIS_HABILIDADES_ARQUETIPO = (2, 8, 13, 20)


def _carregar_dados_arquetipos() -> list[dict]:
    try:
        arquetipos = json.loads(ARCHETYPES_PATH.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise HTTPException(
            status_code=500, detail="Não foi possível carregar os arquétipos"
        ) from exc

    if not isinstance(arquetipos, list) or any(
        not isinstance(arquetipo, dict)
        or not isinstance(arquetipo.get("nome"), str)
        or not arquetipo["nome"].strip()
        or not isinstance(arquetipo.get("habilidades", []), list)
        or not isinstance(arquetipo.get("bonus", {}), dict)
        for arquetipo in arquetipos
    ):
        raise HTTPException(status_code=500, detail="Formato inválido em arquetipos.json")
    return arquetipos


def _habilidades_automaticas_arquetipo(
    nome_arquetipo: Optional[str], nivel_personagem: int
) -> list[dict]:
    arquetipo = next(
        (
            item
            for item in _carregar_dados_arquetipos()
            if item["nome"] == nome_arquetipo
        ),
        None,
    )
    if not arquetipo:
        return []

    habilidades = []
    for index, habilidade in enumerate(arquetipo.get("habilidades", [])):
        if not isinstance(habilidade, dict) or index >= len(NIVEIS_HABILIDADES_ARQUETIPO):
            continue
        nivel_desbloqueio = NIVEIS_HABILIDADES_ARQUETIPO[index]
        if nivel_personagem < nivel_desbloqueio:
            continue

        detalhes = []
        if habilidade.get("gatilho"):
            detalhes.append(f"Gatilho: {habilidade['gatilho']}")
        if habilidade.get("acao"):
            detalhes.append(f"Ação: {habilidade['acao']}")
        if habilidade.get("efeito"):
            detalhes.append(habilidade["efeito"])

        habilidades.append({
            "nome": habilidade.get("nome", ""),
            "classificacao": f"Habilidade de Arquétipo ({nome_arquetipo})",
            "prereq": habilidade.get("prereq", ""),
            "custo": habilidade.get("custo", ""),
            "alcance": habilidade.get("alcance", ""),
            "efeito": "\n".join(detalhes),
            "automatico": True,
            "nivel_desbloqueio": nivel_desbloqueio,
        })
    return habilidades


@app.get("/api/arquetipos")
def listar_arquetipos(
    auth_session: models.SessaoModel = Depends(get_current_session),
):
    return [
        {
            **arquetipo,
            "habilidades": [
                {
                    **habilidade,
                    "nivel_desbloqueio": NIVEIS_HABILIDADES_ARQUETIPO[index],
                }
                for index, habilidade in enumerate(arquetipo.get("habilidades", []))
                if isinstance(habilidade, dict)
                and index < len(NIVEIS_HABILIDADES_ARQUETIPO)
            ],
        }
        for arquetipo in _carregar_dados_arquetipos()
    ]


@app.get("/api/personagem/{char_id}", response_model=FichaCompletaSchema)
def carregar_personagem(
    char_id: int,
    auth_session: models.SessaoModel = Depends(get_current_session),
    db: Session = Depends(database.get_db),
):
    char = (
        db.query(models.PersonagemModel)
        .filter(
            models.PersonagemModel.id == char_id,
            models.PersonagemModel.owner_id == auth_session.usuario_id,
        )
        .first()
    )
    if not char:
        raise HTTPException(status_code=404, detail="Personagem não encontrado")
    return char


@app.delete("/api/personagem/{char_id}")
def excluir_personagem(
    char_id: int,
    auth_session: models.SessaoModel = Depends(require_csrf),
    db: Session = Depends(database.get_db),
):
    char = db.query(models.PersonagemModel).filter(
        models.PersonagemModel.id == char_id,
        models.PersonagemModel.owner_id == auth_session.usuario_id,
    ).first()
    if not char:
        raise HTTPException(status_code=404, detail="Personagem não encontrado")
    db.delete(char)
    db.commit()
    return {"status": "sucesso", "mensagem": "Ficha excluída com sucesso"}


@app.post("/api/personagem", status_code=201)
def salvar_ou_criar_personagem(
    dados: FichaCompletaSchema,
    char_id: Optional[int] = None,
    auth_session: models.SessaoModel = Depends(require_csrf),
    db: Session = Depends(database.get_db),
):
    char = None
    if char_id is not None:
        char = (
            db.query(models.PersonagemModel)
            .filter(
                models.PersonagemModel.id == char_id,
                models.PersonagemModel.owner_id == auth_session.usuario_id,
            )
            .first()
        )
        if not char:
            raise HTTPException(status_code=404, detail="Personagem não encontrado")

    if not char:
        char = models.PersonagemModel(owner_id=auth_session.usuario_id)
        db.add(char)

    excluded_fields = {
        "atributos", "pericias", "inventario", "habilidades", "rituais", "poderes"
    }
    for key, value in dados.model_dump(exclude=excluded_fields).items():
        setattr(char, key, value)
    db.flush()

    db.query(models.AtributoDB).filter(
        models.AtributoDB.personagem_id == char.id
    ).delete()
    db.query(models.PericiaDB).filter(
        models.PericiaDB.personagem_id == char.id
    ).delete()
    db.query(models.ItemInventarioDB).filter(
        models.ItemInventarioDB.personagem_id == char.id
    ).delete()
    db.query(models.HabilidadeDB).filter(
        models.HabilidadeDB.personagem_id == char.id
    ).delete()
    db.query(models.RitualDB).filter(
        models.RitualDB.personagem_id == char.id
    ).delete()
    db.query(models.PoderDB).filter(
        models.PoderDB.personagem_id == char.id
    ).delete()

    for attr in dados.atributos:
        db.add(models.AtributoDB(**attr.model_dump(), personagem_id=char.id))
    for per in dados.pericias:
        db.add(models.PericiaDB(**per.model_dump(), personagem_id=char.id))
    for item in dados.inventario:
        db.add(models.ItemInventarioDB(**item.model_dump(), personagem_id=char.id))
    habilidades_automaticas = _habilidades_automaticas_arquetipo(
        dados.arquetipo, dados.nivel
    )
    for hab in dados.habilidades:
        if not hab.automatico:
            db.add(models.HabilidadeDB(
                **hab.model_dump(exclude={"automatico", "nivel_desbloqueio"}),
                personagem_id=char.id,
                automatico=False,
                nivel_desbloqueio=None,
            ))
    for habilidade in habilidades_automaticas:
        db.add(models.HabilidadeDB(**habilidade, personagem_id=char.id))
    for rit in dados.rituais:
        db.add(models.RitualDB(**rit.model_dump(), personagem_id=char.id))
    for pod in dados.poderes:
        db.add(models.PoderDB(**pod.model_dump(), personagem_id=char.id))

    db.commit()
    db.refresh(char)
    return {
        "status": "sucesso",
        "id": char.id,
        "mensagem": "Ficha salva com sucesso no banco SQLite!",
    }
