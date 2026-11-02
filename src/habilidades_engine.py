"""
Motor de automação de habilidades.

Lê o campo `regras` (lista padronizada de efeitos) de cada habilidade em
habilidades.json e calcula os bônus totais que o personagem recebe.

Schema de cada efeito:
  {
    "tipo": "pericia" | "defesa" | "pv_max" | "san_max" | "rd" | "deslocamento"
            | "carga" | "atributo" | "iniciativa",
    "valor": <numero>,
    "alvo": "<perícia/atributo>"        # ex.: "Ocultismo", "Força"
    "condicao": "machucado" | "protecao_pesada" | "protecao_leve"   # opcional
    "descricao": "<trecho da regra original>"
  }

Somente efeitos passivos são automatizados; habilidades ativas (gastar SAN,
ações, rituais) permanecem apenas descritas no texto.
"""
from __future__ import annotations

import json
from pathlib import Path
from typing import Dict, List, Any

ABILITIES_PATH = Path(__file__).resolve().parent / "json" / "habilidades.json"

# Perícias de resistência e ataque aceitas como alvo de bônus
PERICIAS_VALIDAS = {
    "Acrobacia", "Adestramento", "Artes", "Atletismo", "Atualidades", "Ciências",
    "Crime", "Diplomacia", "Enganação", "Fortitude", "Furtividade", "Iniciativa",
    "Intimidação", "Intuição", "Investigação", "Luta", "Medicina", "Mecânica",
    "Medicina", "Ocultismo", "Percepção", "Pilotagem", "Pontaria", "Procurar",
    "Reflexos", "Religião", "Sobrevivência", "Tecnologia", "Tática", "Vontade",
}

ATRIBUTOS_VALIDOS = {"Força", "Agilidade", "Intelecto", "Presença", "Vigor"}


def carregar_regras() -> Dict[str, List[dict]]:
    """Retorna {nome_da_habilidade: [efeitos]} apenas para habilidades com regras."""
    if not ABILITIES_PATH.exists():
        return {}
    with open(ABILITIES_PATH, "r", encoding="utf-8") as f:
        catalogo = json.load(f)
    return {
        h["nome"]: h["regras"]
        for h in catalogo
        if isinstance(h.get("regras"), list) and h["regras"]
    }


def bonus_de_habilidades(habilidades: List[dict], contexto: Dict[str, Any]) -> Dict[str, Any]:
    """
    Soma os efeitos de todas as habilidades que o personagem possui.

    `contexto` descreve o estado atual da ficha e ativa condições:
      {
        "machucado": bool,             # metade dos PV ou menos
        "protecao_pesada": bool,       # vestindo proteção pesada
        "protecao_leve": bool,         # vestindo proteção leve
        "nivel": int
      }

    Retorno:
      {
        "pericias": {"Ocultismo": 2, "Reflexos": 2},
        "defesa": 2, "pv_max": 10, "san_max": 10, "rd": 2,
        "deslocamento": 3, "carga": 2, "iniciativa": 2,
        "atributos": {"Força": 1},
        "detalhes": [ ... habilidades que geraram bônus ... ]
      }
    """
    regras_todas = carregar_regras()
    resultado: Dict[str, Any] = {
        "pericias": {}, "atributos": {},
        "defesa": 0, "pv_max": 0, "san_max": 0, "rd": 0,
        "deslocamento": 0, "carga": 0, "iniciativa": 0,
        "detalhes": [],
    }
    if not habilidades:
        return resultado

    condicoes_ativas = {
        "machucado": bool(contexto.get("machucado")),
        "protecao_pesada": bool(contexto.get("protecao_pesada")),
        "protecao_leve": bool(contexto.get("protecao_leve")),
    }

    for hab in habilidades:
        nome_hab = hab.get("nome") if isinstance(hab, dict) else str(hab)
        efeitos = regras_todas.get(nome_hab)
        if not efeitos:
            continue  # habilidade sem regras automatizadas
        for efeito in efeitos:
            condicao = efeito.get("condicao")
            if condicao and not condicoes_ativas.get(condicao):
                resultado["detalhes"].append({
                    "habilidade": nome_hab, "efeito": efeito,
                    "aplicado": False, "motivo": f"condição '{condicao}' não ativa",
                })
                continue
            _aplicar_efeito(resultado, efeito)
            resultado["detalhes"].append({
                "habilidade": nome_hab, "efeito": efeito, "aplicado": True,
            })
    return resultado


def _aplicar_efeito(resultado: Dict[str, Any], efeito: dict) -> None:
    tipo = efeito.get("tipo")
    valor = efeito.get("valor") or 0
    alvo = efeito.get("alvo")

    if tipo == "pericia":
        if alvo:
            resultado["pericias"][alvo] = resultado["pericias"].get(alvo, 0) + valor
    elif tipo == "atributo":
        if alvo:
            resultado["atributos"][alvo] = resultado["atributos"].get(alvo, 0) + valor
    elif tipo in {"defesa", "pv_max", "san_max", "rd", "deslocamento", "carga", "iniciativa"}:
        resultado[tipo] += valor
