import json
from pathlib import Path
from typing import List, Dict, Any, Optional

BASE_DIR = Path(__file__).resolve().parent
DATA_DIR = BASE_DIR / "json"

class CatalogoService:
    _habilidades_tier_1: List[Dict[str, Any]] = []
    _poderes_paranormais: List[Dict[str, Any]] = []

    @classmethod
    def carregar_habilidades_tier_1(cls) -> List[Dict[str, Any]]:
        if not cls._habilidades_tier_1:
            path = DATA_DIR / "habilidades tier 1.json"
            if path.exists():
                with open(path, "r", encoding="utf-8") as f:
                    cls._habilidades_tier_1 = json.load(f)
        return cls._habilidades_tier_1

    @classmethod
    def carregar_poderes_paranormais(cls) -> List[Dict[str, Any]]:
        if not cls._poderes_paranormais:
            path = DATA_DIR / "poderes paranormais.json"
            if path.exists():
                with open(path, "r", encoding="utf-8") as f:
                    cls._poderes_paranormais = json.load(f)
        return cls._poderes_paranormais

    @classmethod
    def buscar_habilidade(cls, nome: str) -> Optional[Dict[str, Any]]:
        todas = cls.carregar_habilidades_tier_1()
        for h in todas:
            if h.get("nome", "").strip().lower() == nome.strip().lower():
                return h
        return None

    @classmethod
    def buscar_poder(cls, nome: str) -> Optional[Dict[str, Any]]:
        todos = cls.carregar_poderes_paranormais()
        for p in todos:
            if p.get("nome", "").strip().lower() == nome.strip().lower():
                return p
        return None