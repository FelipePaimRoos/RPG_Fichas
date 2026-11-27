# AGENTS.md — RPG Fichas

Instruções persistentes para agentes que trabalham neste repositório.

## Commits: Conventional Commits (obrigatório)

Toda mensagem de commit segue [Conventional Commits](https://www.conventionalcommits.org/pt-br/).
O hook versionado `.githooks/commit-msg` recusa mensagens fora do padrão.

Formato:

```text
<tipo>(<escopo opcional>): <descrição>
```

- **Tipos aceitos:** `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`.
- **Descrição:** minúscula, no imperativo, sem ponto final, curta (primeira linha com até ~72 caracteres).
- **Escopo:** opcional, indica o módulo afetado. Sugestões: `api`, `ficha`, `ui`, `tests`, `catalogo`, `docs`.
- **Quebra de compatibilidade:** `!` antes dos dois-pontos — `feat(api)!: remove o endpoint antigo`.
- **Corpo e rodapé:** opcionais, após uma linha em branco.

Exemplos válidos:

```text
feat(ficha): adiciona cálculo automático de carga
fix(api): corrige validação de NEX negativo
docs: atualiza instruções de instalação offline
test(api): cobre importação de ficha sem perfil
chore(deps): atualiza requirements.txt
```

Exemplos inválidos (bloqueados pelo hook):

```text
att
correcao na instalacao
Feature: Adiciona campo
feat:sem espaço depois dos dois-pontos
feat:
```

## Antes de commitar

1. Confirme que o hook está ativo neste clone:

   ```bash
   git config --get core.hooksPath   # deve imprimir: .githooks
   ```

2. Se não estiver, ative (uma vez por clone, na raiz do projeto):

   ```bash
   git config core.hooksPath .githooks
   git config commit.template .gitmessage
   ```

3. `.gitmessage` já fornece o template com tipos e exemplos no editor ao rodar `git commit`.

**Nunca** use `git commit --no-verify` para contornar a validação, exceto quando o usuário pedir explicitamente. Commits gerados automaticamente (`Merge`, `Revert`, `fixup!`, `squash!`, `amend!`) passam sem validação.

## Escopo destas instruções

Valem para todo o repositório. Regras específicas de um subdiretório devem ficar em um `AGENTS.md` naquele diretório, que o OpenCode carrega ao acessá-lo.
