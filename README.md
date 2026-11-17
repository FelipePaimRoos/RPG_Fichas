# RPG Fichas (FastAPI + SQLite)

## Estrutura do projeto:

- `main.py`, `models.py`, `database.py`, `catalogo.py` — código do backend/FastAPI
- `ficha_rpg_completa.html` — frontend (servido pelo FastAPI)
- `json/` — dados de catálogo (armas, rituais, origens, perfis, modificações, maldições, etc.)
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

3. Abra `http://localhost:8000/` para acessar o painel local. Ele mostra o nome e nível das fichas e permite acessá-las, importar, exportar ou excluir. As alterações são salvas automaticamente no navegador enquanto você edita; use “Minhas fichas” para voltar ao painel. A interface desta branch não exibe login; as fichas ficam no IndexedDB do navegador, não no SQLite do servidor. Os campos “Origem” e “Arquétipo” oferecem as opções dos catálogos JSON.

4. A documentação interativa da API fica disponível em:
   - `http://localhost:8000/docs`

No inventário, além de armas, proteções e itens personalizados, é possível adicionar itens dos catálogos JSON de itens operacionais, acessórios, explosivos, itens amaldiçoados, itens paranormais, medicamentos e munições. Os itens escolhidos são copiados para a ficha do personagem; a criação manual continua disponível para itens personalizados.

## Usar no navegador sem internet

1. Instale Python e as dependências de `requirements.txt`, depois execute `Iniciar RPG Fichas Offline.bat`. A página abre em `http://localhost:8000/` e usa automaticamente o armazenamento local do navegador, sem login.
2. Deixe a página carregar os catálogos enquanto o servidor está ativo. Em navegador compatível, use **Fixar como aplicativo** ou o menu do navegador para instalar; no iPhone/iPad, use **Compartilhar → Adicionar à Tela de Início**. A instalação e o cache offline dependem de um endereço seguro (HTTPS ou `localhost`).
3. As fichas são armazenadas no IndexedDB deste navegador e perfil, sem sincronização. Use **Exportar** para backup/transferência e **Importar ficha** no outro navegador. Limpar os dados do navegador pode apagar as fichas.

### Acessar pelo celular na mesma rede

Execute o inicializador no computador e descubra seu IPv4 com `ipconfig` (seção do adaptador Wi-Fi). No celular conectado à mesma rede Wi-Fi, abra `http://IP-DO-COMPUTADOR:8000/`, por exemplo `http://192.168.1.10:8000/`. Se o Windows perguntar, permita o acesso do Python na rede privada. O servidor aceita conexões da rede local; não o exponha à internet.

Esse endereço HTTP por IP local permite abrir e usar o sistema no celular. Como navegadores normalmente não consideram essa origem segura, o app usa uma alternativa compatível para gerar IDs nesse endereço; a instalação PWA e o service worker/cache offline ainda podem não funcionar. Para instalar e continuar usando sem o computador/servidor, é necessário servir o app por HTTPS confiável no celular ou usar `localhost` no próprio dispositivo. Os dados também são separados por navegador e aparelho.

As senhas são armazenadas com hash e salt. Para usar cookies seguros em produção com HTTPS, defina `COOKIE_SECURE=true` antes de iniciar o servidor. Fichas antigas sem proprietário são vinculadas automaticamente ao único perfil existente; se ainda não houver perfis, ficam com a primeira conta criada. Se já houver vários perfis, fichas sem proprietário não são atribuídas automaticamente para evitar expor dados à conta errada.

Os valores automáticos da ficha são PV `10 + Vigor`, SAN `10 + Presença`, perícias treinadas `3 + Intelecto` e Carga `Força x 5`, sem bônus de perfil nem crescimento por nível. A Defesa automática continua sendo `5 + Agilidade` e o bônus de proteções. Toda ficha deve escolher um perfil; a habilidade correspondente, incluindo seu efeito de `perfis.json`, é adicionada automaticamente. Analista possui marcadores de análise de 0 a 4, Executor possui uma barra de Ímpeto com 5 espaços e Vigilante não possui recurso adicional. No nível 1, as perícias começam em Dado d4. Cada origem aplica as perícias listadas como Treinado e concede sua habilidade, sem aumentar o limite de perícias; a origem Amnésico informa que as duas perícias são escolhidas pelo Mestre. Artes é associada a Intelecto. As habilidades de origem são sincronizadas pelo backend ao salvar a ficha. Cada poder paranormal adquirido aumenta o NEX em 5 pontos percentuais e reduz a SAN atual em 1, sem alterar o nível de personagem. Os graus de pré-requisito exigem um poder anterior a menos do mesmo elemento (grau 1 não exige poder prévio); poderes variáveis usam o elemento selecionado no filtro. Os efeitos e bônus de afinidade ficam descritos nos cartões, e o bônus de afinidade recebe destaque quando corresponde à afinidade escolhida.
