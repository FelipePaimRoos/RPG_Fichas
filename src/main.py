import json
import hashlib
import hmac
import os
import secrets
import time
from pathlib import Path
from typing import Annotated, List, Optional

from fastapi import FastAPI, Depends, HTTPException, Cookie, Header, Response
from fastapi.responses import FileResponse, HTMLResponse
from pydantic import StringConstraints, field_validator
from pydantic import BaseModel, ConfigDict, Field
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError

from src import database
from src import models

database.ensure_schema()

app = FastAPI(title="RPG Ficha API", version="1.0")

SESSION_COOKIE = "rpg_session"
SESSION_DURATION = 60 * 60 * 24 * 14
PASSWORD_ITERATIONS = 310_000
SECURE_COOKIE = os.getenv("COOKIE_SECURE", "").lower() in {"1", "true", "yes"}
ROOT_DIR = Path(__file__).resolve().parent.parent
FRONTEND_PATH = ROOT_DIR / "ficha_rpg_completa.html"
MANIFEST_PATH = ROOT_DIR / "manifest.webmanifest"
SERVICE_WORKER_PATH = ROOT_DIR / "service-worker.js"
PWA_ICON_PATH = ROOT_DIR / "icon.svg"
DATA_DIR = Path(__file__).resolve().parent / "json"
ARCHETYPES_PATH = DATA_DIR / "arquetipos.json"
ORIGINS_PATH = DATA_DIR / "origens.json"
POWERS_PATH = DATA_DIR / "poderes paranormais.json"
ABILITIES_PATH = DATA_DIR / "habilidades.json"
RITUALS_PATH = DATA_DIR / "rituais.json"
WEAPONS_PATH = DATA_DIR / "armas.json"
MODIFICACOES_PATH = DATA_DIR / "modificacoes.json"
MALDICOES_PATH = DATA_DIR / "maldicoes.json"
PROTECOES_PATH = DATA_DIR / "protecoes.json"
CATALOGOS_INVENTARIO = {
    "operacionais": DATA_DIR / "itens operacionais.json",
    "acessorios": DATA_DIR / "acessorios.json",
    "explosivos": DATA_DIR / "explosivos.json",
    "amaldiçoados": DATA_DIR / "itens amaldicoados.json",
    "paranormais": DATA_DIR / "itens paranormais.json",
    "medicamentos": DATA_DIR / "medicamentos.json",
    "municoes": DATA_DIR / "municoes.json",
}



@app.get("/", response_class=HTMLResponse, include_in_schema=False)
def servir_ficha():
    if not FRONTEND_PATH.is_file():
        raise HTTPException(status_code=500, detail="Arquivo do frontend não encontrado")
    return HTMLResponse(
        FRONTEND_PATH.read_text(encoding="utf-8"),
        headers={"Cache-Control": "no-store"},
    )


@app.get("/manifest.webmanifest", include_in_schema=False)
def servir_manifest_pwa():
    return FileResponse(MANIFEST_PATH, media_type="application/manifest+json")


@app.get("/service-worker.js", include_in_schema=False)
def servir_service_worker():
    return FileResponse(
        SERVICE_WORKER_PATH,
        media_type="application/javascript",
        headers={"Cache-Control": "no-cache", "Service-Worker-Allowed": "/"},
    )


@app.get("/icon.svg", include_in_schema=False)
def servir_icone_pwa():
    return FileResponse(PWA_ICON_PATH, media_type="image/svg+xml")


class SchemaBase(BaseModel):
    model_config = ConfigDict(from_attributes=True)


def _json_string_para_lista(valor):
    """Aceita lista já validada ou string JSON do banco (ex: '["Cruel"]')."""
    if isinstance(valor, str):
        try:
            lista = json.loads(valor)
            return lista if isinstance(lista, list) else []
        except json.JSONDecodeError:
            return []
    if isinstance(valor, list):
        return valor
    return []


class AtributoSchema(SchemaBase):
    nome: str
    valor: int
    debilitado: Optional[bool] = False


class PericiaSchema(SchemaBase):
    nome: str
    treinamento: str
    bonus: int
    automatico_origem: bool = False


class ItemSchema(SchemaBase):
    nome: str
    espaco: float
    descricao: Optional[str] = ""


class ArmaInventarioSchema(SchemaBase):
    nome: str
    proficiencia: Optional[str] = ""
    tipo: Optional[str] = ""
    empunhadura: Optional[str] = ""
    dano_base: Optional[str] = ""
    critico: Optional[str] = ""
    tipo_dano: Optional[str] = ""
    alcance: Optional[str] = ""
    espaco: int = 1
    habilidades: Optional[str] = ""
    modificacoes: List[str] = Field(default_factory=list)
    maldicoes: List[str] = Field(default_factory=list)
    personalizada: bool = False

    @field_validator("modificacoes", "maldicoes", mode="before")
    @classmethod
    def _json_string_para_lista(cls, valor):
        return _json_string_para_lista(valor)


class ProtecaoInventarioSchema(SchemaBase):
    nome: str
    tipo: Optional[str] = "Proteção"
    bonus_defesa: Optional[str] = ""
    espaco: int = 1
    resistencia_dano: Optional[str] = ""
    penalidade: Optional[str] = ""
    empunhadura: Optional[str] = ""
    regras_especiais: Optional[str] = ""
    descricao: Optional[str] = ""
    modificacoes: List[str] = Field(default_factory=list)
    maldicoes: List[str] = Field(default_factory=list)
    personalizada: bool = False

    @field_validator("modificacoes", "maldicoes", mode="before")
    @classmethod
    def _json_string_para_lista(cls, valor):
        return _json_string_para_lista(valor)


class HabilidadeSchema(SchemaBase):
    nome: str
    classificacao: Optional[str] = ""
    prereq: Optional[str] = ""
    custo: Optional[str] = ""
    alcance: Optional[str] = ""
    efeito: Optional[str] = ""
    automatico: bool = False
    nivel_desbloqueio: Optional[int] = None


class RitualSchema(SchemaBase):
    nome: str
    classificacao: Optional[str] = ""
    prereq: Optional[str] = ""
    custo: Optional[str] = ""
    alcance: Optional[str] = ""
    efeito: Optional[str] = ""
    elemento: Optional[str] = ""
    automatico: bool = False
    nivel_desbloqueio: Optional[int] = None


class PoderSchema(SchemaBase):
    nome: str
    elemento: str
    prereq: Optional[str] = ""
    custo: Optional[str] = ""
    alcance: Optional[str] = ""
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
    armas: List[ArmaInventarioSchema] = Field(default_factory=list)
    protecoes: List[ProtecaoInventarioSchema] = Field(default_factory=list)
    habilidades: List[HabilidadeSchema] = Field(default_factory=list)
    rituais: List[RitualSchema] = Field(default_factory=list)
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
        or any(
            not isinstance(habilidade, dict)
            or not isinstance(habilidade.get("nome"), str)
            or not habilidade["nome"].strip()
            or type(habilidade.get("nivel")) is not int
            or habilidade["nivel"] < 1
            for habilidade in arquetipo.get("habilidades", [])
        )
        or not isinstance(arquetipo.get("bonus", {}), dict)
        for arquetipo in arquetipos
    ):
        raise HTTPException(status_code=500, detail="Formato inválido em arquetipos.json")
    return arquetipos


def _carregar_dados_origens() -> list[dict]:
    try:
        payload = json.loads(ORIGINS_PATH.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise RuntimeError("Não foi possível carregar origens.json") from exc

    origens = payload.get("origens") if isinstance(payload, dict) else None
    if not isinstance(origens, list) or any(
        not isinstance(origem, dict)
        or not isinstance(origem.get("nome"), str)
        or not origem["nome"].strip()
        or not isinstance(origem.get("pericias_treinadas"), list)
        or any(not isinstance(pericia, str) for pericia in origem["pericias_treinadas"])
        or not isinstance(origem.get("habilidade"), dict)
        or not isinstance(origem["habilidade"].get("nome"), str)
        or not isinstance(origem["habilidade"].get("descricao"), str)
        for origem in origens
    ):
        raise RuntimeError("Formato inválido em origens.json")
    return origens


def _carregar_catalogo_poderes() -> list[dict]:
    try:
        poderes = json.loads(POWERS_PATH.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise HTTPException(
            status_code=500, detail="Não foi possível carregar o catálogo de poderes"
        ) from exc

    if not isinstance(poderes, list) or any(
        not isinstance(poder, dict)
        or not isinstance(poder.get("nome"), str)
        or not poder["nome"].strip()
        or not isinstance(poder.get("elemento"), str)
        or not poder["elemento"].strip()
        or not isinstance(poder.get("prereq"), str)
        or not isinstance(poder.get("efeito"), str)
        for poder in poderes
    ):
        raise HTTPException(
            status_code=500, detail="Formato inválido em poderes paranormais.json"
        )

    return [
        {
            **poder,
            "custo": poder.get("custo") or "",
            "alcance": poder.get("alcance") or "",
            "afinidade": poder.get("afinidade") or "",
        }
        for poder in poderes
    ]


def _carregar_catalogo_habilidades() -> list[dict]:
    if not ABILITIES_PATH.exists():
        raise HTTPException(
            status_code=404, 
            detail=f"Ficheiro {ABILITIES_PATH.name} não foi encontrado."
        )

    try:
        data = json.loads(ABILITIES_PATH.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise HTTPException(
            status_code=500, detail="Erro ao ler o ficheiro de habilidades."
        ) from exc

    resultado = []
    for hab in data:
        tier_valor = hab.get("tier") or hab.get("classificacao") or "Tier I"
        resultado.append({
            **hab,
            "tier": str(tier_valor).strip(),
            "classificacao": str(tier_valor).strip(),
            "custo": hab.get("custo") or "Nenhum",
            "alcance": hab.get("alcance") or "N/A",
            "prereq": hab.get("prereq") or "Nenhum",
            "efeito": hab.get("efeito") or ""
        })

    return resultado

@app.get("/api/catalogo/habilidades")
def listar_habilidades():
    return _carregar_catalogo_habilidades()


def _carregar_catalogo_rituais() -> list[dict]:
    if not RITUALS_PATH.exists():
        raise HTTPException(
            status_code=404,
            detail=f"Ficheiro {RITUALS_PATH.name} não foi encontrado."
        )

    try:
        data = json.loads(RITUALS_PATH.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise HTTPException(
            status_code=500, detail="Erro ao ler o ficheiro de rituais."
        ) from exc

    resultado = []
    for rit in data:
        circulo_valor = rit.get("tier") or rit.get("classificacao") or "1° Círculo"
        resultado.append({
            **rit,
            "circulo": str(circulo_valor).strip(),
            "classificacao": str(circulo_valor).strip(),
            "custo": rit.get("custo") or "Nenhum",
            "alcance": rit.get("alcance") or "N/A",
            "prereq": rit.get("prereq") or "Nenhum",
            "efeito": rit.get("efeito") or ""
        })

    return resultado


@app.get("/api/catalogo/rituais")
def listar_rituais():
    return _carregar_catalogo_rituais()


def _carregar_catalogo_armas() -> list[dict]:
    if not WEAPONS_PATH.exists():
        raise HTTPException(
            status_code=404,
            detail=f"Ficheiro {WEAPONS_PATH.name} não foi encontrado."
        )

    try:
        data = json.loads(WEAPONS_PATH.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise HTTPException(
            status_code=500, detail="Erro ao ler o ficheiro de armas."
        ) from exc

    if not isinstance(data, list) or any(
        not isinstance(arma, dict) or not isinstance(arma.get("nome"), str)
        or not arma["nome"].strip()
        for arma in data
    ):
        raise HTTPException(status_code=500, detail="Formato inválido em armas.json")

    resultado = []
    for arma in data:
        resultado.append({
            "nome": arma.get("nome") or "",
            "proficiencia": arma.get("proficiencia") or "Nenhuma",
            "tipo": arma.get("tipo") or "",
            "empunhadura": arma.get("empunhadura") or "",
            "dano_base": arma.get("dano_base") or "",
            "critico": arma.get("critico") or "",
            "tipo_dano": arma.get("tipo_dano") or "",
            "alcance": arma.get("alcance") or "",
            "espaco": arma.get("espaco") if isinstance(arma.get("espaco"), (int, float)) else 1,
            "habilidades": arma.get("habilidades") or "",
            "personalizada": False
        })

    return resultado


@app.get("/api/catalogo/armas")
def listar_armas():
    return _carregar_catalogo_armas()


def _carregar_catalogo_simples(path: Path, campo_filtro: Optional[str], valor_filtro: str) -> list[dict]:
    if not path.exists():
        raise HTTPException(status_code=404, detail=f"Ficheiro {path.name} não foi encontrado.")
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise HTTPException(status_code=500, detail=f"Erro ao ler o ficheiro {path.name}.") from exc
    if not isinstance(data, list):
        raise HTTPException(status_code=500, detail=f"Formato inválido em {path.name}.")
    if campo_filtro is None:
        return data
    return [
        item for item in data
        if isinstance(item, dict)
        and valor_filtro.lower() in str(item.get(campo_filtro, "")).lower()
    ]


@app.get("/api/catalogo/inventario/{categoria}")
def listar_itens_catalogo_inventario(categoria: str):
    path = CATALOGOS_INVENTARIO.get(categoria)
    if path is None:
        raise HTTPException(status_code=404, detail="Categoria de inventário não encontrada.")
    data = _carregar_catalogo_simples(path, None, "")
    if any(
        not isinstance(item, dict)
        or not isinstance(item.get("nome"), str)
        or not item["nome"].strip()
        for item in data
    ):
        raise HTTPException(status_code=500, detail=f"Formato inválido em {path.name}.")
    return data


@app.get("/api/catalogo/modificacoes")
def listar_modificacoes():
    """Modificações aplicáveis a armas: as que possuem o campo tipo_arma.
    O valor de tipo_arma é informativo (apenas visual); o frontend não bloqueia
    a atribuição de uma modificação a uma arma de outro tipo."""
    todas = _carregar_catalogo_simples(MODIFICACOES_PATH, None, "")
    resultado = []
    for item in todas:
        tipo_arma = str(item.get("tipo_arma", "") or "").strip()
        if tipo_arma:
            resultado.append({
                "nome": item.get("nome") or "",
                "tipo_arma": tipo_arma,
                "efeito": item.get("efeito") or "",
                "mecanica_detalhada": item.get("mecanica_detalhada") or ""
            })
    return resultado


@app.get("/api/catalogo/maldicoes-armas")
def listar_maldicoes_armas():
    return _carregar_catalogo_simples(MALDICOES_PATH, "tipo", "Arma")


def _carregar_catalogo_protecoes() -> list[dict]:
    if not PROTECOES_PATH.exists():
        raise HTTPException(
            status_code=404,
            detail=f"Ficheiro {PROTECOES_PATH.name} não foi encontrado."
        )
    try:
        data = json.loads(PROTECOES_PATH.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise HTTPException(status_code=500, detail="Erro ao ler o ficheiro de proteções.") from exc
    if not isinstance(data, list) or any(
        not isinstance(p, dict) or not isinstance(p.get("nome"), str) or not p["nome"].strip()
        for p in data
    ):
        raise HTTPException(status_code=500, detail="Formato inválido em protecoes.json")
    return [
        {
            "nome": p.get("nome") or "",
            "tipo": p.get("tipo") or "Proteção",
            "bonus_defesa": p.get("bonus_defesa") or "",
            "espaco": p.get("espaco") if isinstance(p.get("espaco"), (int, float)) else 1,
            "resistencia_dano": p.get("resistencia_dano") or "",
            "penalidade": p.get("penalidade") or "",
            "empunhadura": p.get("empunhadura") or "",
            "regras_especiais": p.get("regras_especiais") or "",
            "descricao": p.get("descricao") or "",
            "personalizada": False,
        }
        for p in data
    ]


@app.get("/api/catalogo/protecoes")
def listar_protecoes():
    return _carregar_catalogo_protecoes()


@app.get("/api/catalogo/modificacoes-protecoes")
def listar_modificacoes_protecoes():
    """Modificações aplicáveis a proteções (campo aplicacao menciona proteções)."""
    todas = _carregar_catalogo_simples(MODIFICACOES_PATH, None, "")
    return [
        {
            "nome": item.get("nome") or "",
            "aplicacao": str(item.get("aplicacao", "") or "").strip(),
            "efeito": item.get("efeito") or "",
            "mecanica_detalhada": item.get("mecanica_detalhada") or ""
        }
        for item in todas
        if "prote" in str(item.get("aplicacao", "") or "").lower()
    ]


@app.get("/api/catalogo/maldicoes-protecoes")
def listar_maldicoes_protecoes():
    return _carregar_catalogo_simples(MALDICOES_PATH, "tipo", "Proteç")

def _sincronizar_catalogo_origens() -> None:
    origens = _carregar_dados_origens()
    db = database.SessionLocal()
    try:
        nomes = []
        for origem in origens:
            nomes.append(origem["nome"])
            registro = db.query(models.OrigemDB).filter_by(nome=origem["nome"]).first()
            if registro is None:
                registro = models.OrigemDB(nome=origem["nome"])
                db.add(registro)
            registro.pericias_treinadas = json.dumps(
                origem["pericias_treinadas"], ensure_ascii=False
            )
            registro.habilidade_nome = origem["habilidade"]["nome"]
            registro.habilidade_descricao = origem["habilidade"]["descricao"]
        if nomes:
            db.query(models.OrigemDB).filter(
                ~models.OrigemDB.nome.in_(nomes)
            ).delete(synchronize_session=False)
        db.commit()
    except Exception:
        db.rollback()
        raise
    finally:
        db.close()


@app.on_event("startup")
def sincronizar_catalogo_origens_ao_iniciar() -> None:
    _sincronizar_catalogo_origens()


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
    for habilidade in arquetipo.get("habilidades", []):
        nivel_desbloqueio = habilidade["nivel"]
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


def _habilidade_automatica_origem(
    nome_origem: Optional[str], db: Session
) -> Optional[dict]:
    if not nome_origem:
        return None
    origem = db.query(models.OrigemDB).filter_by(nome=nome_origem).first()
    if not origem:
        return None
    return {
        "nome": origem.habilidade_nome,
        "classificacao": f"Habilidade de Origem ({origem.nome})",
        "prereq": "",
        "custo": "",
        "alcance": "",
        "efeito": origem.habilidade_descricao,
        "automatico": True,
        "nivel_desbloqueio": None,
    }


@app.get("/api/arquetipos")
def listar_arquetipos():
    return [
        {
            **arquetipo,
            "habilidades": [
                {
                    **habilidade,
                    "nivel_desbloqueio": habilidade["nivel"],
                }
                for habilidade in arquetipo.get("habilidades", [])
            ],
        }
        for arquetipo in _carregar_dados_arquetipos()
    ]


@app.get("/api/origens")
def listar_origens(
    db: Session = Depends(database.get_db),
):
    return [
        {
            "nome": origem.nome,
            "pericias_treinadas": json.loads(origem.pericias_treinadas),
            "habilidade": {
                "nome": origem.habilidade_nome,
                "descricao": origem.habilidade_descricao,
            },
        }
        for origem in db.query(models.OrigemDB).order_by(models.OrigemDB.id).all()
    ]


@app.get("/api/poderes-paranormais")
def listar_catalogo_poderes():
    return _carregar_catalogo_poderes()


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

    # O model_validate já converte as strings JSON de modificações/maldições
    # para listas, via field_validator das schemas.
    return FichaCompletaSchema.model_validate(char)


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
        "atributos", "pericias", "inventario", "armas", "protecoes", "habilidades", "rituais", "poderes"
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
    db.query(models.ArmaInventarioDB).filter(
        models.ArmaInventarioDB.personagem_id == char.id
    ).delete()
    db.query(models.ProtecaoInventarioDB).filter(
        models.ProtecaoInventarioDB.personagem_id == char.id
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
    origem_registro = db.query(models.OrigemDB).filter_by(nome=dados.origem).first()
    pericias_origem = set(json.loads(origem_registro.pericias_treinadas)) if origem_registro else set()
    for per in dados.pericias:
        treinamento = per.treinamento
        automatico_origem = per.automatico_origem
        if per.nome in pericias_origem:
            if treinamento == "Destreinado":
                treinamento = "Treinado"
                automatico_origem = True
        elif automatico_origem and treinamento == "Treinado":
            treinamento = "Destreinado"
            automatico_origem = False
        db.add(models.PericiaDB(
            nome=per.nome,
            treinamento=treinamento,
            bonus=per.bonus,
            automatico_origem=automatico_origem,
            personagem_id=char.id,
        ))
    for item in dados.inventario:
        db.add(models.ItemInventarioDB(**item.model_dump(), personagem_id=char.id))
    for protecao in dados.protecoes:
        db.add(models.ProtecaoInventarioDB(
            **protecao.model_dump(exclude={"modificacoes", "maldicoes"}),
            modificacoes=json.dumps(protecao.modificacoes, ensure_ascii=False),
            maldicoes=json.dumps(protecao.maldicoes, ensure_ascii=False),
            personagem_id=char.id,
        ))
    for arma in dados.armas:
        dados_arma = arma.model_dump(exclude={"modificacoes", "maldicoes"})
        db.add(models.ArmaInventarioDB(
            **dados_arma,
            modificacoes=json.dumps(arma.modificacoes, ensure_ascii=False),
            maldicoes=json.dumps(arma.maldicoes, ensure_ascii=False),
            personagem_id=char.id,
        ))
    habilidades_automaticas = _habilidades_automaticas_arquetipo(
        dados.arquetipo, dados.nivel
    )
    habilidade_origem = _habilidade_automatica_origem(dados.origem, db)
    if habilidade_origem:
        habilidades_automaticas.append(habilidade_origem)
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
        db.add(models.RitualDB(
            **rit.model_dump(exclude={"automatico", "nivel_desbloqueio"}),
            personagem_id=char.id,
        ))
    for pod in dados.poderes:
        db.add(models.PoderDB(**pod.model_dump(), personagem_id=char.id))

    db.commit()
    db.refresh(char)
    return {
        "status": "sucesso",
        "id": char.id,
        "mensagem": "Ficha salva com sucesso no banco SQLite!",
    }
from pydantic import BaseModel
from typing import Optional
from fastapi import Depends, HTTPException
from sqlalchemy.orm import Session

class HabilidadeCreateSchema(BaseModel):
    nome: str
    classificacao: Optional[str] = "Tier I"
    prereq: Optional[str] = ""
    custo: Optional[str] = ""
    alcance: Optional[str] = ""
    efeito: Optional[str] = ""
    automatico: Optional[bool] = False
    nivel_desbloqueio: Optional[int] = None

# ATENÇÃO À URL: /api/personagem/{personagem_id}/habilidades
@app.post("/api/personagem/{personagem_id}/habilidades")
def criar_habilidade_personagem(
    personagem_id: int, 
    dados: HabilidadeCreateSchema, 
    auth_session: models.SessaoModel = Depends(get_current_session),
    db: Session = Depends(database.get_db)
):
    personagem = db.query(models.PersonagemModel).filter(
        models.PersonagemModel.id == personagem_id,
        models.PersonagemModel.owner_id == auth_session.usuario_id,
    ).first()
    if not personagem:
        raise HTTPException(status_code=404, detail="Personagem não encontrado")

    nova_habilidade = models.HabilidadeDB(
        personagem_id=personagem_id,
        nome=dados.nome,
        classificacao=dados.classificacao,
        prereq=dados.prereq,
        custo=dados.custo,
        alcance=dados.alcance,
        efeito=dados.efeito,
        automatico=dados.automatico,
        nivel_desbloqueio=dados.nivel_desbloqueio
    )

    db.add(nova_habilidade)
    db.commit()
    db.refresh(nova_habilidade)

    return {"sucesso": True, "id": nova_habilidade.id}