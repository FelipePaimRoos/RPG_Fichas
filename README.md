# Backend RPG Ficha (FastAPI + SQLite)

## Como rodar o projeto:

1. Instale as dependências:
   ```bash
   pip install -r requirements.txt
   ```

2. Inicie o servidor FastAPI:
   ```bash
   uvicorn main:app --reload
   ```

3. Abra `http://localhost:8000/` para entrar ou criar uma conta. O painel mostra o nome e nível das fichas e permite acessá-las ou excluí-las. As alterações da ficha são salvas automaticamente enquanto você edita; use “Minhas fichas” para voltar ao painel. Cada ficha é vinculada à conta que a criou; a API verifica o proprietário ao listar, carregar, salvar ou excluir fichas. O campo “Arquétipo” oferece as opções cadastradas em `arquetipos.json`.

4. A documentação interativa da API fica disponível em:
   - `http://localhost:8000/docs`

As senhas são armazenadas com hash e salt. Para usar cookies seguros em produção com HTTPS, defina `COOKIE_SECURE=true` antes de iniciar o servidor. Fichas antigas sem proprietário são vinculadas automaticamente ao único perfil existente; se ainda não houver perfis, ficam com a primeira conta criada. Se já houver vários perfis, fichas sem proprietário não são atribuídas automaticamente para evitar expor dados à conta errada.

No nível 1, os valores automáticos são PV `10 + Vigor`, SAN `10 + Presença`, Defesa `5 + Agilidade` e Carga `Força x 5`; PV e SAN aumentam em 2 por nível a partir do nível 2. Bônus estruturados dos arquétipos em `arquetipos.json` continuam ativos e não acumulam a cada salvamento. A escolha de arquétipo continua disponível no nível 1, com um aviso, e arquétipos com `+1 Perícia Treinada` acrescentam um espaço ao limite de treinamento sem uma escolha automática de perícia. No nível 1, o limite base é `3 + Intelecto` perícias treinadas, todas em Dado d4. O bônus de duas perícias da origem não está aplicado. As habilidades do arquétipo são liberadas nos níveis 2, 8, 13 e 20, nessa ordem, e são sincronizadas também pelo backend ao salvar a ficha.
