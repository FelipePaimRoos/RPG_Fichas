# RPG Fichas (FastAPI + SQLite)

## Estrutura do projeto:

- `main.py`, `models.py`, `database.py`, `catalogo.py` — código do backend/FastAPI
- `ficha_rpg_completa.html` — frontend (servido pelo FastAPI)
- `json/` — dados de catálogo (armas, rituais, origens, arquétipos, modificações, maldições, etc.)
- `tests/` — scripts de teste/QA (`qa_*.mjs`, `check_all.py`) e artefatos temporários
- `rpg_fichas.db` — banco SQLite (criado automaticamente)

## Como rodar o projeto:

1. Instale as dependências:
   ```bash
   pip install -r requirements.txt
   ```

2. Inicie o servidor FastAPI:
   ```bash
   uvicorn main:app --reload
   ```

3. Abra `http://localhost:8000/` para entrar ou criar uma conta. O painel mostra o nome e nível das fichas e permite acessá-las ou excluí-las. As alterações da ficha são salvas automaticamente enquanto você edita; use “Minhas fichas” para voltar ao painel. Cada ficha é vinculada à conta que a criou; a API verifica o proprietário ao listar, carregar, salvar ou excluir fichas. Os campos “Origem” e “Arquétipo” oferecem as opções de `origens.json` e `arquetipos.json`; os catálogos são sincronizados com o banco na inicialização. O seletor de poderes paranormais lê `poderes paranormais.json`.

4. A documentação interativa da API fica disponível em:
   - `http://localhost:8000/docs`

As senhas são armazenadas com hash e salt. Para usar cookies seguros em produção com HTTPS, defina `COOKIE_SECURE=true` antes de iniciar o servidor. Fichas antigas sem proprietário são vinculadas automaticamente ao único perfil existente; se ainda não houver perfis, ficam com a primeira conta criada. Se já houver vários perfis, fichas sem proprietário não são atribuídas automaticamente para evitar expor dados à conta errada.

No nível 1, os valores automáticos são PV `10 + Vigor`, SAN `10 + Presença`, Defesa `5 + Agilidade` e Carga `Força x 5`; PV e SAN aumentam em 2 por nível a partir do nível 2. Bônus estruturados dos arquétipos em `arquetipos.json` continuam ativos e não acumulam a cada salvamento. A escolha de arquétipo continua disponível no nível 1, com um aviso, e arquétipos com `+1 Perícia Treinada` acrescentam um espaço ao limite de treinamento sem uma escolha automática de perícia. No nível 1, o limite base é `3 + Intelecto` perícias treinadas, todas em Dado d4. Cada origem acrescenta duas vagas de perícia treinada, aplica as perícias listadas como Treinado e concede sua habilidade; a origem Amnésico informa que as duas perícias são escolhidas pelo Mestre. Artes é associada a Intelecto. As habilidades de origem são sincronizadas pelo backend ao salvar a ficha. As habilidades do arquétipo são liberadas conforme o campo `nivel` de cada habilidade em `arquetipos.json` e sincronizadas pelo backend ao salvar a ficha. Cada poder paranormal adquirido aumenta o NEX em 5 pontos percentuais e reduz a SAN atual em 1, sem alterar o nível de personagem. Os graus de pré-requisito exigem um poder anterior a menos do mesmo elemento (grau 1 não exige poder prévio); poderes variáveis usam o elemento selecionado no filtro. Os efeitos e bônus de afinidade ficam descritos nos cartões, e o bônus de afinidade recebe destaque quando corresponde à afinidade escolhida.
