from sqlalchemy import Column, Integer, String, Text, Boolean, ForeignKey
from sqlalchemy.orm import relationship
from database import Base

class UsuarioModel(Base):
    __tablename__ = "usuarios"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(80), unique=True, index=True, nullable=False)
    password_salt = Column(String(32), nullable=False)
    password_hash = Column(String(64), nullable=False)
    personagens = relationship("PersonagemModel", back_populates="proprietario")
    sessoes = relationship("SessaoModel", back_populates="usuario", cascade="all, delete-orphan")

class SessaoModel(Base):
    __tablename__ = "sessoes"

    id = Column(Integer, primary_key=True, index=True)
    token_hash = Column(String(64), unique=True, index=True, nullable=False)
    csrf_token = Column(String(64), nullable=False)
    expires_at = Column(Integer, nullable=False)
    usuario_id = Column(Integer, ForeignKey("usuarios.id"), nullable=False)
    usuario = relationship("UsuarioModel", back_populates="sessoes")

class PersonagemModel(Base):
    __tablename__ = "personagens"

    id = Column(Integer, primary_key=True, index=True)
    owner_id = Column(Integer, ForeignKey("usuarios.id"), nullable=True, index=True)
    nome = Column(String, index=True)
    jogador = Column(String)
    nivel = Column(Integer, default=1)
    conceito = Column(String)
    origem = Column(String)
    arquetipo = Column(String)

    # Status e Vida
    vida_atual = Column(Integer, default=10)
    vida_max = Column(Integer, default=10)
    sanidade_atual = Column(Integer, default=10)
    sanidade_max = Column(Integer, default=10)
    defesa_atual = Column(Integer, default=10)
    bonus_protecoes = Column(Integer, default=0)

    # Deslocamento e Carga
    deslocamento_base = Column(Integer, default=9)
    carga_maxima = Column(Integer, default=10)

    # Resistências e Proficiências
    resistencias = Column(Text, default="")
    proficiencias = Column(Text, default="")

    # Trilha & Paranormal
    exposicao_paranormal = Column(Integer, default=5)
    afinidade_elemento = Column(String, default="")
    crises_contador = Column(Integer, default=0)
    dado_paranormal_idx = Column(Integer, default=0)

    # Histórico & Descrição
    desc_aparencia = Column(Text, default="")
    desc_personalidade = Column(Text, default="")
    desc_historico = Column(Text, default="")
    desc_objetivo = Column(Text, default="")
    desc_anotacoes = Column(Text, default="")

    proprietario = relationship("UsuarioModel", back_populates="personagens")

    # Relacionamentos 1-para-Muitos
    atributos = relationship("AtributoDB", back_populates="personagem", cascade="all, delete-orphan")
    pericias = relationship("PericiaDB", back_populates="personagem", cascade="all, delete-orphan")
    inventario = relationship("ItemInventarioDB", back_populates="personagem", cascade="all, delete-orphan")
    habilidades = relationship("HabilidadeDB", back_populates="personagem", cascade="all, delete-orphan")
    rituais = relationship("RitualDB", back_populates="personagem", cascade="all, delete-orphan")
    poderes = relationship("PoderDB", back_populates="personagem", cascade="all, delete-orphan")

class AtributoDB(Base):
    __tablename__ = "atributos"
    id = Column(Integer, primary_key=True, index=True)
    personagem_id = Column(Integer, ForeignKey("personagens.id"))
    nome = Column(String)
    valor = Column(Integer, default=1)
    debilitado = Column(Boolean, default=False)
    personagem = relationship("PersonagemModel", back_populates="atributos")

class PericiaDB(Base):
    __tablename__ = "pericias"
    id = Column(Integer, primary_key=True, index=True)
    personagem_id = Column(Integer, ForeignKey("personagens.id"))
    nome = Column(String)
    treinamento = Column(String, default="Destreinado")
    bonus = Column(Integer, default=0)
    personagem = relationship("PersonagemModel", back_populates="pericias")

class ItemInventarioDB(Base):
    __tablename__ = "inventario"
    id = Column(Integer, primary_key=True, index=True)
    personagem_id = Column(Integer, ForeignKey("personagens.id"))
    nome = Column(String)
    espaco = Column(Integer, default=1)
    descricao = Column(String, default="")
    personagem = relationship("PersonagemModel", back_populates="inventario")

class HabilidadeDB(Base):
    __tablename__ = "habilidades"
    id = Column(Integer, primary_key=True, index=True)
    personagem_id = Column(Integer, ForeignKey("personagens.id"))
    nome = Column(String)
    classificacao = Column(String, default="")
    prereq = Column(String, default="")
    custo = Column(String, default="")
    alcance = Column(String, default="")
    efeito = Column(Text, default="")
    automatico = Column(Boolean, default=False, nullable=False)
    nivel_desbloqueio = Column(Integer, nullable=True)
    personagem = relationship("PersonagemModel", back_populates="habilidades")

class RitualDB(Base):
    __tablename__ = "rituais"
    id = Column(Integer, primary_key=True, index=True)
    personagem_id = Column(Integer, ForeignKey("personagens.id"))
    nome = Column(String)
    classificacao = Column(String, default="")
    prereq = Column(String, default="")
    custo = Column(String, default="")
    alcance = Column(String, default="")
    efeito = Column(Text, default="")
    personagem = relationship("PersonagemModel", back_populates="rituais")

class PoderDB(Base):
    __tablename__ = "poderes"
    id = Column(Integer, primary_key=True, index=True)
    personagem_id = Column(Integer, ForeignKey("personagens.id"))
    nome = Column(String)
    elemento = Column(String, default="sangue")
    prereq = Column(String, default="")
    efeito = Column(Text, default="")
    afinidade = Column(Text, default="")
    personagem = relationship("PersonagemModel", back_populates="poderes")


class ArquetipoDB(Base):
    __tablename__ = "arquetipos"
    id = Column(Integer, primary_key=True, index=True)
    nome = Column(String, unique=True, index=True)
    atributos = Column(String)
    perfil = Column(Text)
    buffs = Column(Text)
    pp_tematico = Column(Text)
    habilidades = Column(Text) # Armazenadas em JSON stringificado ou tabela relacionada
