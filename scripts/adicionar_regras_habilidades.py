"""Adiciona o campo `regras` (efeitos padronizados) às habilidades de habilidades.json.

Cobre as famílias 1 (bônus passivos) e 2 (bônus condicionais detectáveis).
Habilidades ativas/narrativas continuam sem `regras` (sem automação).
"""
import json
from pathlib import Path

PATH = Path(__file__).resolve().parent.parent / "src" / "json" / "habilidades.json"

# nome -> lista de efeitos padronizados
REGRAS = {
    # --- Tier I: bônus passivos diretos ---
    "Casca Grossa": [{"tipo": "pv_max", "valor": 10}],
    "Combatente Esforçado": [{"tipo": "san_max", "valor": 10}],
    "Iniciativa Aprimorada": [{"tipo": "iniciativa", "valor": 2}],
    "Correria Desesperada": [{"tipo": "deslocamento", "valor": 3}],
    "Atlético": [{"tipo": "pericia", "valor": 2, "alvo": "Atletismo"},
                 {"tipo": "deslocamento", "valor": 3}],
    "Acrobático": [{"tipo": "pericia", "valor": 2, "alvo": "Acrobacia"}],
    "Ás do Volante": [{"tipo": "pericia", "valor": 2, "alvo": "Pilotagem"}],
    "Atraente": [{"tipo": "pericia", "valor": 2, "alvo": "Diplomacia"}],
    "Dedos Ágeis": [{"tipo": "pericia", "valor": 2, "alvo": "Crime"}],
    "Detector de Mentiras": [{"tipo": "pericia", "valor": 2, "alvo": "Intuição"}],
    "Especialista em Emergências": [{"tipo": "pericia", "valor": 2, "alvo": "Medicina"}],
    "Hacker": [{"tipo": "pericia", "valor": 2, "alvo": "Tecnologia"}],
    "Informado": [{"tipo": "pericia", "valor": 2, "alvo": "Atualidades"}],
    "Interrogador": [{"tipo": "pericia", "valor": 2, "alvo": "Intimidação"}],
    "Inventário Organizado": [{"tipo": "pericia", "valor": 2, "alvo": "Investigação"},
                              {"tipo": "carga", "valor": 0}],
    "Mentiroso Nato": [{"tipo": "pericia", "valor": 2, "alvo": "Enganação"}],
    "Observador": [{"tipo": "pericia", "valor": 2, "alvo": "Procurar"}],
    "Pai de Pet": [{"tipo": "pericia", "valor": 2, "alvo": "Adestramento"}],
    "Palavras de Devoção": [{"tipo": "pericia", "valor": 2, "alvo": "Religião"}],
    "Personalidade Esotérica": [{"tipo": "pericia", "valor": 2, "alvo": "Ocultismo"},
                                {"tipo": "san_max", "valor": 2}],
    "Persuasivo": [{"tipo": "pericia", "valor": 2, "alvo": "Diplomacia"}],
    "Pesquisador Científico": [{"tipo": "pericia", "valor": 2, "alvo": "Ciências"}],
    "Proativo": [{"tipo": "pericia", "valor": 2, "alvo": "Iniciativa"}],
    "Racionalidade Inflexível": [{"tipo": "pericia", "valor": 2, "alvo": "Vontade"}],
    "Rato de Computador": [{"tipo": "pericia", "valor": 2, "alvo": "Tecnologia"}],
    "Resposta Rápida": [{"tipo": "pericia", "valor": 2, "alvo": "Reflexos"}],
    "Sentidos Aguçados": [{"tipo": "pericia", "valor": 2, "alvo": "Percepção"}],
    "Sobrevivencialista": [{"tipo": "pericia", "valor": 2, "alvo": "Sobrevivência"}],
    "Sorrateiro": [{"tipo": "pericia", "valor": 2, "alvo": "Furtividade"}],
    "Tenacidade": [{"tipo": "pericia", "valor": 2, "alvo": "Fortitude"}],
    "Talentoso": [{"tipo": "pericia", "valor": 2, "alvo": "Artes"}],
    "Adepto do Escuro": [{"tipo": "pericia", "valor": 2, "alvo": "Percepção"}],
    "Carteirada": [{"tipo": "pericia", "valor": 2, "alvo": "Diplomacia"}],
    "Ciente das Cicatrizes": [{"tipo": "pericia", "valor": 2, "alvo": "Percepção"}],
    "Rastrear o Paranormal": [{"tipo": "pericia", "valor": 2, "alvo": "Sobrevivência"}],
    "Estigmado": [{"tipo": "pericia", "valor": 2, "alvo": "Vontade"}],
    "Teimosia Obstinada": [{"tipo": "pericia", "valor": 2, "alvo": "Vontade"}],
    "Vitalidade Reforçada": [{"tipo": "pericia", "valor": 2, "alvo": "Fortitude"},
                             {"tipo": "pv_max", "valor": 0, "por_nivel": 1}],
    "Vontade Inabalável": [{"tipo": "pericia", "valor": 2, "alvo": "Vontade"},
                           {"tipo": "san_max", "valor": 0, "por_nivel": 1}],
    "Curiosidade Oculta": [{"tipo": "pericia", "valor": 2, "alvo": "Ocultismo"}],
    "Mente Sã": [{"tipo": "pericia", "valor": 2, "alvo": "Vontade"},
                 {"tipo": "pericia", "valor": 2, "alvo": "Fortitude"},
                 {"tipo": "pericia", "valor": 2, "alvo": "Reflexos"}],
    "Parceiro": [{"tipo": "pericia", "valor": 2, "alvo": "Diplomacia"}],
    "Provisões de Emergência": [{"tipo": "pericia", "valor": 2, "alvo": "Procurar"}],
    "A Força do Saber": [{"tipo": "atributo", "valor": 1, "alvo": "Intelecto"}],
    "Apaixonado por Veículos": [{"tipo": "pericia", "valor": 2, "alvo": "Pilotagem"}],
    "Adaptação Climática": [{"tipo": "pericia", "valor": 2, "alvo": "Fortitude"}],
    "Instintos Urbanos": [{"tipo": "pericia", "valor": 2, "alvo": "Crime"}],
    "Muito Sorrateiro": [{"tipo": "pericia", "valor": 2, "alvo": "Furtividade"}],
    "Laboratório de Campo": [{"tipo": "pericia", "valor": 2, "alvo": "Mecânica"}],
    "Doutor em Emergências": [{"tipo": "pericia", "valor": 2, "alvo": "Medicina"}],
    "Meus Bebês": [{"tipo": "pericia", "valor": 2, "alvo": "Mecânica"}],
    # --- Tier I: bônus condicionais ---
    "Apego Angustiado": [{"tipo": "pericia", "valor": 2, "alvo": "Fortitude", "condicao": "machucado"},
                         {"tipo": "pericia", "valor": 2, "alvo": "Reflexos", "condicao": "machucado"},
                         {"tipo": "pericia", "valor": 2, "alvo": "Vontade", "condicao": "machucado"}],
    "Proteção Pesada": [{"tipo": "rd", "valor": 2, "condicao": "protecao_pesada"}],
    "Especialista em Proteção Leve": [{"tipo": "defesa", "valor": 2, "condicao": "protecao_leve"},
                                      {"tipo": "pericia", "valor": 2, "alvo": "Reflexos", "condicao": "protecao_leve"}],
    "Inquebrável": [{"tipo": "defesa", "valor": 2, "condicao": "machucado"},
                    {"tipo": "rd", "valor": 2, "condicao": "machucado"}],
    "Tanque de Guerra": [{"tipo": "defesa", "valor": 2, "condicao": "protecao_pesada"},
                         {"tipo": "rd", "valor": 4, "condicao": "protecao_pesada"}],
    # --- Tier II: bônus passivos ---
    "Direção Defensiva": [{"tipo": "pericia", "valor": 2, "alvo": "Pilotagem"}],
    "Discurso Motivador": [{"tipo": "pericia", "valor": 2, "alvo": "Diplomacia"}],
}

def main():
    with open(PATH, "r", encoding="utf-8") as f:
        catalogo = json.load(f)

    adicionados = 0
    for hab in catalogo:
        regras = REGRAS.get(hab.get("nome", ""))
        if regras and "regras" not in hab:
            hab["regras"] = regras
            adicionados += 1

    with open(PATH, "w", encoding="utf-8") as f:
        json.dump(catalogo, f, ensure_ascii=False, indent=2)

    print(f"Regras adicionadas a {adicionados} habilidades de {len(REGRAS)} definidas.")
    faltando = set(REGRAS) - {h.get("nome") for h in catalogo}
    if faltando:
        print("Nomes não encontrados no catálogo:", faltando)

if __name__ == "__main__":
    main()
