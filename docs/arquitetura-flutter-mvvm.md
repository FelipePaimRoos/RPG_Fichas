# App Flutter — arquitetura MVVM por features

> **Plataformas desta entrega:** Windows desktop, Linux desktop e Android (telefone e tablet). iOS/macOS ficam preparados na arquitetura, mas fora do CI/build porque exigem toolchain Apple. Tablet usa a experiência desktop com toque.
> **Status:** implementação em andamento (fundação + dashboard + ficha desktop concluídos; shells tablet/mobile pendentes).
> **Data:** 2026-11-22
> **Relação com o projeto atual:** o backend FastAPI/Python foi removido — todo o código é Dart, dentro de `app_flutter/`. Os 17 JSONs autorais dos catálogos vivem em `app_flutter/json/` e são empacotados como assets (lidos direto, sem pipeline de sincronização). O app web antigo foi preservado em `app_flutter/web/`. Na raiz do repositório fica só a infraestrutura de git (`.github/`, `.githooks/`).

---

## Atualizações pós-proposta (2026-11-22)

Diferenças entre este documento e o que foi implementado:

- **Persistência:** SQLite via **Drift**, como planejado — `data/drift/` com modelo híbrido (colunas de resumo + documento JSON + checksum).
- **Catálogos:** lidos direto de `json/` (assets). O pipeline `tools/catalogs/` (Python) foi descartado junto com o backend; as validações que o backend fazia viraram testes Dart (`test/features/catalog/catalogs_test.dart`).
- **Regras portadas do backend:** reconciliação de perícias da origem, habilidades automáticas de perfil/origem, defaults de catálogo ("Nenhum"/"N/A"), limites e derivados — tudo em `domain/rules/`, testado.
- **Shell desktop:** a réplica do app web (coluna central de cards + sumário lateral flutuante) foi priorizada no lugar do shell com menu bar/sidebar/abas do §8.2; as seções a seguir descrevem a direção futura.
- **Autenticação/sessões do backend** não foram portadas (não fazem sentido local-first; doc §2).

---

## 1. Contexto e por que Flutter

O projeto atual é uma página única de ~5.300 linhas servida pelo FastAPI, com 15 seções de ficha, modais de catálogo e um modo local em IndexedDB. O novo requisito é rodar **instalado** em Windows e Linux, além de mobile.

Flutter cobre essa matriz com uma base de código e UI nativas, sem casca de webview. Isso evita as duas emendas que o React Native exigiria: `react-native-windows` (só Windows) e um invólucro Tauri/Electron para Linux. Também resolve, de forma uniforme, armazenamento local em SQLite, diálogos de arquivo, janela e atalhos de teclado.

O custo é trocar TypeScript/React por Dart/Flutter. Como o projeto ainda não tem código de app mobile, essa troca acontece antes de existir dívida.

## 2. Decisões que esta proposta assume

| Decisão | Escolha proposta | Por quê | Se estiver errada |
|---|---|---|---|
| Onde o app mora | `app_flutter/` na raiz, ao lado do web | Não quebra o app atual e mantém os JSONs no lugar | Um monorepo (`apps/`, `packages/`) muda caminhos e o pipeline de catálogo |
| Estado | Riverpod (`Notifier`/`AsyncNotifier`) | DI testável, sem `BuildContext` no ViewModel, bom para famílias por ficha | Bloc/Cubit mantém a estrutura; só muda a forma do ViewModel |
| Navegação | `go_router` | Shell adaptativo, deep link `character/:id`, rotas tipadas | `Navigator 2.0` manual aumenta bastante o código |
| Persistência | SQLite via Drift (ORM equivalente ao Room no mundo Flutter) | Room é Android/Kotlin e não roda em Flutter/desktop; Drift cobre Windows, Linux, Android e iOS com migrações versionadas | Floor é a alternativa mais parecida com Room; trocar de ORM não muda os ViewModels, só `data/` |
| Modelo de dados | Híbrido: colunas de resumo + documento JSON na tabela `characters`, com metadados e índices. **Decisão aprovada** | A ficha é editada como documento, mas o dashboard precisa listar/filtrar sem desserializar tudo; o JSON de export é uma projeção, não o armazenamento | Normalizar as oito listas internas multiplicaria tabelas, joins e migrações |
| Exportação | Envelope JSON (`aplicativo`, `versao`, `exportada_em`, `ficha`) gerado a partir do modelo em memória | Mantém compatibilidade com o app web e serve de backup/transferência | Se o formato interno vazar para o arquivo, fica difícil evoluir o banco |
| Layout | Três eixos: classe do dispositivo (phone/tablet/desktop), modo de interação (desktop/mobile) e ponteiro (toque/mouse). Tablet usa o shell desktop com densidade de toque | Breakpoint sozinho produz “celular esticado”; tablet precisa de navegação persistente, mas com alvos de toque | Um shell único reduz código, mas não entrega a sensação de app desktop |
| Tablet | Desktop com toque quando `shortestSide >= 600 dp`; split view abaixo de 600 dp cai para phone. **Decisão aprovada** | Cobre iPad mini e tablets Android, mantém telefones grandes no mobile e evita esmagar o layout em split view estreito | Se mudar, o tablet usa desktop sempre, mesmo em split view estreito |
| Catálogo | Assets JSON empacotados, gerados a partir de `json/`; **não** vão para o banco | Os JSONs são a fonte autoral e somente leitura; o SQLite guarda apenas fichas e preferências | Se o catálogo for para o banco, entra seed, versionamento e sincronização de conteúdo |
| Ferramenta de sync | Python + Pydantic em `tools/catalogs/` | Reaproveita a stack já usada no backend e cria uma borda única de normalização | Um CLI em Dart evita Python no build, mas duplica validação |
| Assets gerados | Versionados no Git, conferidos no CI | `flutter run` funciona sem passo manual; o CI detecta divergência | Gerar no build exige `postinstall`/make e deixa o clone incompleto |
| Sincronização com backend | Fora do escopo inicial | O app começa local-first, como o modo local atual | Sync multi-dispositivo adiciona outbox, conflitos e login |
| Postura das regras | Avisos, não bloqueios, para progressão e slots | É o comportamento atual do web; evita o app ser mais rígido que a mesa | Bloqueios mudam a API de regras e a UX de erro |
| Apple (iOS/macOS) | Fora desta entrega; arquitetura preparada | Builds e runners Apple exigem macOS/Xcode; os workflows cobrem Windows, Linux e Android | Se entrar depois, adiciona jobs `macos-latest` e assinatura |

## 3. O que “MVVM” significa no Flutter

Flutter não tem binding bidirecional. A adaptação saudável é:

- **View** — `Widget` (`ConsumerWidget`/`ConsumerStatefulWidget`). Renderiza, estiliza e encaminha intenções.
- **ViewModel** — classe `Notifier`/`AsyncNotifier` do Riverpod, com estado imutável e comandos. Não contém widgets, não usa `BuildContext`, não navega e não fala com o banco diretamente.
- **Model** — entidades, valores e regras puras do jogo (PV, SAN, defesa, carga, pré-requisitos, progressão). Dart puro, testável sem Flutter.
- **Data** — implementações das portas: SQLite/Drift, assets JSON, arquivos, futuro HTTP.

| Camada | Pasta | Pode importar | Não pode |
|---|---|---|---|
| View | `presentation/screens/`, `presentation/widgets/`, `sections/*_section.dart` | ViewModels, `shared/widgets` | repositórios, banco, regra de negócio |
| ViewModel | `presentation/viewmodels/`, `sections/*_view_model.dart` | Model, portas, `Ref`, utilitários | Widgets, `BuildContext`, navegação |
| Model | `domain/` | Dart puro, `shared/domain` | Flutter, Drift, arquivos, HTTP |
| Data | `data/` | Model, portas, libs externas | View, ViewModel |

Navegação fica na View/rota. O ViewModel devolve estado e eventos (`saved`, `deleted`, `canSave`); a tela decide para onde ir.

### 3.1 Estado persistido vs. estado de tela

Essa distinção evita o erro clássico de guardar tudo no documento:

- **Persistido** (`Character`): nome, atributos, perícias, armas, rituais, poderes, histórico, flags de cálculo automático.
- **De tela** (`SectionViewModel`): filtro de Tier, busca do catálogo, modal aberto, elemento selecionado no picker, ordenação.

O `SheetViewModel` é o dono do documento. Os ViewModels de seção cuidam do estado efêmero e delegam mutações ao `SheetViewModel`.

## 4. Estrutura de pastas proposta

```
app_flutter/
├── lib/
│   ├── main.dart
│   ├── app/                              # composition root
│   │   ├── app.dart                      # MaterialApp.router
│   │   ├── router.dart                   # GoRouter + shell adaptativo
│   │   ├── providers.dart                # overrides de DI (repos, gateways)
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   └── tokens.dart
│   │   ├── layout/
│   │   │   ├── form_factor.dart          # phone/tablet/desktop + modo + input
│   │   │   ├── breakpoints.dart          # tiers compact/standard/wide do desktop
│   │   │   ├── app_shell.dart            # escolhe DesktopShell ou MobileShell
│   │   │   ├── desktop_shell.dart        # menu, sidebar persistente, abas
│   │   │   ├── mobile_shell.dart         # NavigationBar inferior
│   │   │   ├── desktop_menu_bar.dart
│   │   │   ├── command_registry.dart     # fonte única: menu + atalho + paleta
│   │   │   ├── command_palette.dart
│   │   │   ├── panel_layout_controller.dart
│   │   │   ├── density_controller.dart   # compacto no mouse, confortável no toque
│   │   │   └── responsive.dart
│   │   └── lifecycle/
│   │       └── app_lifecycle_observer.dart
│   │
│   ├── features/
│   │   ├── characters/                   # dashboard + ficha (mesmo agregado)
│   │   │   ├── presentation/
│   │   │   │   ├── screens/
│   │   │   │   │   ├── characters_screen.dart   # escolhe o layout do dashboard
│   │   │   │   │   └── sheet_screen.dart        # escolhe o layout da ficha
│   │   │   │   ├── layouts/
│   │   │   │   │   ├── desktop/
│   │   │   │   │   │   ├── characters_table_layout.dart
│   │   │   │   │   │   ├── sheet_desktop_layout.dart
│   │   │   │   │   │   └── sheet_inspector.dart
│   │   │   │   │   └── mobile/
│   │   │   │   │       ├── characters_list_layout.dart
│   │   │   │   │       └── sheet_mobile_layout.dart
│   │   │   │   ├── viewmodels/
│   │   │   │   │   ├── characters_view_model.dart
│   │   │   │   │   ├── sheet_view_model.dart      # dono da ficha aberta
│   │   │   │   │   ├── open_sheets_controller.dart # abas do desktop
│   │   │   │   │   ├── autosave_controller.dart
│   │   │   │   │   └── import_export_view_model.dart
│   │   │   │   ├── widgets/
│   │   │   │   │   ├── character_card.dart
│   │   │   │   │   ├── import_preview_dialog.dart
│   │   │   │   │   ├── sheet_section_nav.dart
│   │   │   │   │   └── save_status.dart
│   │   │   │   └── sections/             # 15 seções: view + viewmodel local
│   │   │   │       ├── general/          # 1. Informações Gerais
│   │   │   │       ├── attributes/       # 2. Atributos Base
│   │   │   │       ├── wounds/           # 3. Ferimentos Debilitantes
│   │   │   │       ├── defense/          # 4. Defesa e Proteções
│   │   │   │       ├── movement/         # 5. Deslocamento
│   │   │   │       ├── advantages/       # 6. Vantagens / Desvantagens
│   │   │   │       ├── resistances/      # 7. Resistências / Proficiências
│   │   │   │       ├── skills/           # 8. Perícias
│   │   │   │       ├── combat/           # 9. Combate / Ataques
│   │   │   │       ├── abilities/        # 10. Habilidades
│   │   │   │       ├── rituals/          # 11. Rituais
│   │   │   │       ├── powers/           # 12. Poderes Paranormais
│   │   │   │       ├── inventory/        # 13. Inventário
│   │   │   │       ├── paranormal/       # 14. Trilha & Afinidade
│   │   │   │       └── description/      # 15. Histórico & Descrição
│   │   │   ├── domain/
│   │   │   │   ├── character.dart
│   │   │   │   ├── character_summary.dart
│   │   │   │   ├── derived_stats.dart
│   │   │   │   ├── validation_issue.dart
│   │   │   │   ├── import/
│   │   │   │   │   ├── character_importer.dart
│   │   │   │   │   └── import_result.dart
│   │   │   │   ├── rules/
│   │   │   │   │   ├── attributes.dart
│   │   │   │   │   ├── derived.dart
│   │   │   │   │   ├── skills.dart
│   │   │   │   │   ├── combat.dart
│   │   │   │   │   ├── powers.dart
│   │   │   │   │   ├── rituals.dart
│   │   │   │   │   ├── progression.dart
│   │   │   │   │   └── encumbrance.dart
│   │   │   │   └── repositories/
│   │   │   │       └── character_repository.dart
│   │   │   ├── data/
│   │   │   │   ├── drift/
│   │   │   │   │   ├── character_database.dart
│   │   │   │   │   ├── character_dao.dart
│   │   │   │   │   ├── drift_character_repository.dart
│   │   │   │   │   ├── tables.dart
│   │   │   │   │   └── migrations.dart
│   │   │   │   └── mappers/
│   │   │   │       ├── character_mapper.dart
│   │   │   │       └── export_envelope.dart
│   │   │   └── characters.dart           # API pública da feature
│   │   │
│   │   ├── catalog/                      # catálogo somente leitura + pickers
│   │   │   ├── presentation/
│   │   │   │   ├── screens/catalog_screen.dart
│   │   │   │   ├── pickers/
│   │   │   │   │   ├── catalog_picker_shell.dart # diálogo no desktop, sheet no mobile
│   │   │   │   │   ├── weapon_picker.dart
│   │   │   │   │   ├── protection_picker.dart
│   │   │   │   │   ├── skill_picker.dart
│   │   │   │   │   ├── ritual_picker.dart
│   │   │   │   │   ├── power_picker.dart
│   │   │   │   │   └── inventory_item_picker.dart
│   │   │   │   └── viewmodels/
│   │   │   │       ├── catalog_view_model.dart
│   │   │   │       └── picker_view_model.dart
│   │   │   ├── domain/
│   │   │   │   ├── catalog_item.dart
│   │   │   │   ├── weapon.dart
│   │   │   │   ├── protection.dart
│   │   │   │   ├── skill.dart
│   │   │   │   ├── ritual.dart
│   │   │   │   ├── power.dart
│   │   │   │   ├── inventory_item.dart
│   │   │   │   ├── origin.dart
│   │   │   │   ├── profile.dart
│   │   │   │   ├── progression.dart
│   │   │   │   └── catalog_repository.dart
│   │   │   ├── data/
│   │   │   │   ├── asset_catalog_repository.dart
│   │   │   │   ├── catalog_parser.dart
│   │   │   │   └── models/               # DTOs json_serializable
│   │   │   └── catalog.dart              # API pública
│   │   │
│   │   └── settings/
│   │       ├── presentation/
│   │       │   ├── screens/settings_screen.dart
│   │       │   └── viewmodels/settings_view_model.dart
│   │       ├── domain/settings_repository.dart
│   │       ├── data/shared_preferences_settings_repository.dart
│   │       └── settings.dart
│   │
│   ├── shared/
│   │   ├── domain/                       # linguagem comum ao jogo
│   │   │   ├── dice.dart                 # d4…d20, média, rolagem
│   │   │   ├── attribute.dart
│   │   │   ├── element.dart
│   │   │   └── result.dart
│   │   ├── widgets/                      # design system sem regra de jogo
│   │   │   ├── app_button.dart
│   │   │   ├── app_card.dart
│   │   │   ├── app_field.dart
│   │   │   ├── app_modal.dart
│   │   │   ├── adaptive_overlay.dart     # dialog (desktop) / bottom sheet (mobile)
│   │   │   ├── adaptive_table.dart       # tabela densa (desktop) / cards (mobile)
│   │   │   ├── adaptive_character_list.dart
│   │   │   ├── split_pane.dart           # painéis redimensionáveis
│   │   │   ├── section_card.dart
│   │   │   └── stepper.dart
│   │   ├── platform/
│   │   │   ├── file_gateway.dart         # porta abstrata
│   │   │   ├── desktop_file_gateway.dart # file_selector
│   │   │   ├── mobile_file_gateway.dart  # file_picker + share_plus
│   │   │   ├── clipboard_gateway.dart    # colar JSON no desktop/tablet
│   │   │   └── window_service.dart       # window_manager (desktop)
│   │   └── utils/
│   │       ├── id.dart
│   │       ├── slug.dart
│   │       ├── debounce.dart
│   │       └── normalize.dart
│   │
├── assets/
│   ├── catalogs/                         # GERADO por tools/catalogs; versionado
│   │   ├── armas.json
│   │   ├── rituais.json
│   │   ├── ...
│   │   └── manifest.json
│   └── icons/
├── test/
│   ├── support/                          # fakes e fixtures (fora do bundle)
│   │   ├── fakes/
│   │   │   ├── fake_character_repository.dart
│   │   │   └── fake_file_gateway.dart
│   │   └── fixtures/
│   │       └── characters.dart
│   ├── features/
│   └── golden/
├── integration_test/
├── pubspec.yaml
├── analysis_options.yaml
└── README.md

tools/catalogs/                           # na raiz do repositório
├── schema.py                             # modelos Pydantic
├── sync.py                               # json/ -> app_flutter/assets/catalogs/
├── id_overrides.yaml                     # IDs fixados à mão, quando necessário
└── prereq_overrides.yaml                 # pré-requisitos/elementos ambíguos
```

### Por que `characters` engloba dashboard e ficha

`Character` é um agregado só. Separar “lista de fichas” e “ficha aberta” em duas features obrigaria uma a importar o modelo e o repositório da outra. Dashboard e editor são duas telas do mesmo contexto; as 15 seções são subpastas internas.

`catalog` é uma feature de apoio: somente leitura, sem estado de ficha. `characters` pode consumi-la via `package:app_flutter/features/catalog/catalog.dart`, mas o contrário não.

## 5. Onde cada parte do app atual entra

| Hoje | Nova casa |
|---|---|
| Tela “Minhas fichas”, criar, excluir, importar, exportar | `features/characters/presentation/screens/characters_screen.dart` |
| Autosave e envelope de exportação | `viewmodels/autosave_controller.dart`, `data/mappers/export_envelope.dart` |
| As 15 seções | `features/characters/presentation/sections/<nome>/` |
| PV, SAN, defesa, carga, deslocamento | `domain/rules/derived.dart`, `encumbrance.dart` |
| Atributos, treino, DT | `domain/rules/attributes.dart`, `skills.dart` |
| Ataques, modificações e maldições | `domain/rules/combat.dart` + `sections/combat/` |
| Poderes, elemento, grau e afinidade | `domain/rules/powers.dart` + `sections/powers/` |
| Rituais por círculo/elemento | `domain/rules/rituals.dart` + `sections/rituals/` |
| Trilha paranormal, NEX, crises e dado | `domain/rules/progression.dart` + `sections/paranormal/` |
| Modais de arma, ritual, poder e item | `features/catalog/presentation/pickers/` |
| `PERICIAS_BASE` | `domain/rules/skills.dart` (dado de regra) |
| Catálogos em `json/` | `assets/catalogs/` via `tools/catalogs/sync.py` |
| IndexedDB | `DriftCharacterRepository` |
| Login/CSRF do modo servidor | fora do escopo inicial |

## 6. Contratos entre as camadas

### 6.1 Modelo: ficha, itens e valores derivados

A ficha guarda **cópias** dos itens de catálogo, como hoje. A novidade é um `catalogId` opcional, que identifica a origem sem transformar a ficha em referência viva:

```dart
class InventoryWeapon {
  final String? catalogId; // null = item personalizado
  final String nome;
  final String proficiencia;
  final String tipo;
  final String empunhadura;
  final String danoBase;
  final String critico;
  final String tipoDano;
  final String alcance;
  final double espaco;
  final String habilidades;
  final List<AppliedModification> modificacoes;
  final List<AppliedCurse> maldicoes;
}
```

Por que cópia e não referência: a ficha precisa continuar legível offline; uma errata no catálogo não deve mudar retroativamente um personagem em campanha; e o formato de exportação atual já é uma cópia. O `catalogId` serve para diagnóstico, migração e futuros recursos (ex.: “atualizar para a versão atual”), nunca para renderizar o item.

Valores derivados também precisam preservar o comportamento atual, que tem cálculo automático **e** override manual:

```dart
class Character {
  final String id;
  final int schemaVersion;

  final String nome;
  final int nivel;
  final String origem;
  final String perfil;

  // Flags que já existem no web (autoVida, autoSanidade, autoDefesa)
  final bool autoVida;
  final bool autoSanidade;
  final bool autoDefesa;

  // Valores persistidos; podem ser calculados ou digitados à mão
  final int vidaMax;
  final int sanidadeMax;
  final int defesa;
  final int bonusProtecoes;
  final int cargaMaxima;

  final List<Attribute> atributos;
  final List<SkillState> pericias;
  final List<InventoryWeapon> armas;
  final List<InventoryProtection> protecoes;
  final List<InventoryItem> inventario;
  final List<Ability> habilidades;
  final List<Ritual> rituais;
  final List<Power> poderes;

  // Campos desconhecidos de uma ficha importada, preservados para round-trip
  final Map<String, dynamic> extras;
}
```

A regra pura devolve sugestões; a aplicação só sobrescreve quando a flag correspondente está ligada:

```dart
DerivedStats computeDerived(Character c); // vida, sanidade, defesa, carga, deslocamento
Character applyAutoStats(Character c);     // respeita autoVida/autoSanidade/autoDefesa
```

Carga máxima é sempre derivada (`Força × 5`), como no web. A defesa persistida corresponde ao campo `defesa_atual` do web; `bonus_protecoes` é um campo separado que participa do cálculo automático.

### 6.2 Porta do repositório

```dart
abstract interface class CharacterRepository {
  Future<List<CharacterSummary>> list();
  Future<Character?> get(String id);
  Future<void> save(Character character);
  Future<void> delete(String id);
}
```

A implementação Drift fica em `data/`. A tela nunca a importa: recebe pelo provider. Isso permite fake nos testes e, no futuro, um repositório remoto.

### 6.3 ViewModel com Riverpod

```dart
final sheetProvider =
    AsyncNotifierProvider.family<SheetViewModel, Character, String>(
  SheetViewModel.new,
);

class SheetViewModel extends FamilyAsyncNotifier<Character, String> {
  @override
  Future<Character> build(String characterId) async {
    final repository = ref.watch(characterRepositoryProvider);
    final character = await repository.get(characterId);
    if (character == null) throw const CharacterNotFound();
    return character;
  }

  Future<void> update(void Function(CharacterDraft draft) recipe) async {
    final current = state.requireValue;
    final draft = CharacterDraft.from(current);
    recipe(draft);
    final next = applyAutoStats(draft.toCharacter());
    state = AsyncData(next);
    await ref.read(autosaveControllerProvider(characterId)).schedule(next);
  }

  Future<void> flush() =>
      ref.read(autosaveControllerProvider(characterId)).flush();
}
```

> O esboço usa a forma da API 2.x do Riverpod; a versão exata será fixada no `pubspec.yaml`. A ideia arquitetural não muda.

O `SheetViewModel` é **o único dono** da ficha aberta. As seções não carregam a ficha de novo: elas observam a mesma instância da família.

### 6.4 ViewModel de seção e View

```dart
class SkillsSectionViewModel {
  SkillsSectionViewModel(this.ref, this.characterId);

  final Ref ref;
  final String characterId;

  List<SkillState> get skills => ref.watch(
        sheetProvider(characterId).select(
          (value) => value.valueOrNull?.pericias ?? const [],
        ),
      );

  void setTraining(int index, TrainingLevel level) {
    ref.read(sheetProvider(characterId).notifier).update((draft) {
      draft.pericias[index] = draft.pericias[index].copyWith(treinamento: level);
    });
  }
}
```

```dart
class SkillsSection extends ConsumerWidget {
  const SkillsSection({super.key, required this.characterId});

  final String characterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = SkillsSectionViewModel(ref, characterId);
    return SectionCard(
      title: 'Perícias',
      child: Column(
        children: [
          for (final (i, skill) in vm.skills.indexed)
            SkillRow(
              skill: skill,
              onChanged: (level) => vm.setTraining(i, level),
            ),
        ],
      ),
    );
  }
}
```

A View não conhece Drift nem o parser de catálogo. O ViewModel de seção não conhece widgets.

### 6.5 Fluxo completo: adicionar arma do catálogo

1. `CombatSection` abre o `WeaponPicker` (estado local da seção).
2. O picker consulta o `CatalogRepository` e devolve um `Weapon` canônico.
3. O ViewModel de combate chama `SheetViewModel.update` com `InventoryWeapon.fromCatalog(item)`.
4. A regra `applyAutoStats` recalcula defesa/carga, respeitando os overrides manuais.
5. O autosave persiste a ficha com debounce; a UI mostra `salvando` → `salvo`.

## 7. Uma ficha, um dono

O erro mais fácil de cometer é cada seção carregar sua própria cópia da ficha. Para evitar:

- `sheetProvider.family(characterId)` é a única fonte de verdade da ficha aberta.
- As seções usam `select` para observar só a fatia que lhes interessa.
- Mutações passam por comandos do `SheetViewModel`; nunca por `setState` local no documento.
- O autosave observa o `SheetViewModel`, não cada seção.

### 7.1 Autosave e ciclo de vida

- Debounce de ~600 ms após a última edição.
- Um controlador de autosave por ficha aberta (`autosaveControllerProvider.family(id)`), para que múltiplas abas no desktop não compartilhem timer nem estado de salvamento.
- Estado visível: `ocioso`, `salvando`, `salvo`, `erro`.
- `flush()` ao sair da rota, ao fechar uma aba, ao app ir para background (`AppLifecycleListener`) e ao fechar a janela no desktop (`window_manager`).
- Ao fechar a janela, o `OpenSheetsController` faz `flush()` de todas as abas antes de encerrar.
- `PopScope`/`onPopInvoked` na tela da ficha garante o flush antes de voltar no mobile.
- Se o salvamento falhar, a ficha permanece em memória e o erro fica visível; nunca descartar alterações.

## 8. Duas experiências, um domínio: desktop e mobile

### 8.1 Premissa: largura não define a experiência

O erro que produz “celular esticado” é escolher o shell só pela largura da janela. Um app desktop com 900 px continua sendo desktop; **um tablet continua sendo desktop, mesmo em retrato**. A decisão precisa de três eixos:

1. **Classe do dispositivo** — `phone`, `tablet` ou `desktop`.
2. **Modo de interação** — desktop ou mobile.
3. **Tipo de ponteiro** — toque ou mouse/teclado.

```dart
enum DeviceClass { phone, tablet, desktop }
enum InteractionMode { desktop, mobile }
enum InputKind { touch, pointer }

DeviceClass resolveDeviceClass(TargetPlatform platform, Size size) {
  final isDesktopPlatform = platform == TargetPlatform.windows ||
      platform == TargetPlatform.linux ||
      platform == TargetPlatform.macOS;
  if (isDesktopPlatform) return DeviceClass.desktop;

  // shortestSide em dp: telefones ficam abaixo de ~600,
  // tablets (inclusive iPad mini) ficam acima.
  return size.shortestSide >= 600 ? DeviceClass.tablet : DeviceClass.phone;
}

InteractionMode resolveInteractionMode(DeviceClass device) =>
    device == DeviceClass.phone ? InteractionMode.mobile : InteractionMode.desktop;

InputKind resolveInputKind(TargetPlatform platform) {
  return platform == TargetPlatform.android || platform == TargetPlatform.iOS
      ? InputKind.touch
      : InputKind.pointer;
}
```

Consequências:

- **Tablet = desktop com toque.** Usa sidebar/rail, abas, tabela, inspetor lateral e diálogos; não usa barra inferior nem bottom sheet.
- **Telefone = mobile.** Coluna única, navegação inferior, bottom sheets e alvos grandes.
- Um telefone em paisagem continua phone, porque `shortestSide` continua abaixo de 600.
- Um tablet em retrato continua tablet; girar não troca para mobile.
- Um split view muito estreito em tablet (janela abaixo de 600 dp) cai para phone. É a única exceção, para não esmagar o layout — **decisão aprovada**.
- Um desktop com janela pequena continua desktop; `window_manager` impõe um tamanho mínimo (ex.: 960×640) para preservar a experiência.

A largura, dentro do modo desktop, escolhe a densidade de painéis:

| Faixa | Tier | Shell desktop | Ficha |
|---|---|---|---|
| `600–839` | compact | rail lateral + top bar | conteúdo + inspetor como painel lateral opcional |
| `840–1199` | standard | sidebar completa | conteúdo + inspetor recolhível |
| `≥ 1200` | wide | sidebar + abas | três painéis simultâneos |

O que é compartilhado entre as experiências:

- domínio, regras, ViewModels, repositórios e catálogo;
- corpos das 15 seções (os campos e comandos);
- componentes de formulário e validação.

O que muda:

- shell (menu/sidebar/abas vs. barra inferior);
- layout do dashboard e da ficha;
- overlays (diálogo/popover vs. bottom sheet);
- densidade, foco, hover, atalhos e menus de contexto;
- alvos de toque: tablet usa densidade confortável (≥ 44 px) mesmo com layout desktop.
iOS/Android não têm hover; no tablet, menu de contexto é por toque longo, e os atalhos funcionam quando há teclado externo.

### 8.2 Shell desktop

Desktop e tablet têm navegação persistente e múltiplos documentos abertos. Nada de barra inferior, hambúrguer ou uma coluna centralizada com cartões enormes.

```
┌──────────────────────────────────────────────────────────────────────────────┐
│ RPG Fichas   Arquivo   Editar   Exibir   Ajuda              Buscar…   [+ Nova]│
├───────────────┬──────────────────────────────────────────────────────────────┤
│ PERSONAGENS   │ Fichas                                     [Importar] [Filtro]│
│  Ana          │ ┌──────────────────────────────────────────────────────────┐ │
│  Bruno        │ │ Nome    Nível  Origem      Perfil     Atualizado         │ │
│  Carla        │ │ Ana     3      Acadêmico   Analista   22/11 14:32        │ │
│               │ │ Bruno   5      Militar     Executor   21/11 09:10        │ │
│ CATÁLOGO      │ │ Carla   2      Civil       Vigilante  20/11 18:05        │ │
│  Armas        │ └──────────────────────────────────────────────────────────┘ │
│  Rituais      │                                                              │
│  Poderes      │                                                              │
├───────────────┴──────────────────────────────────────────────────────────────┤
│ 3 fichas · armazenamento local · última alteração 14:32                      │
└──────────────────────────────────────────────────────────────────────────────┘
```

- **Barra de menus** (`Arquivo`, `Editar`, `Exibir`, `Ajuda`) com ações reais, não decoração.
- **Sidebar persistente** com personagens e catálogo; colapsável e com largura lembrada.
- **Barra de comando/paleta** (`Ctrl+K`) para abrir ficha, ir a uma seção ou executar uma ação.
- **Tabela** no dashboard, não grade de cartões: colunas ordenáveis, linha selecionável, duplo clique para abrir, menu de contexto.
- **Importar** aceita `.json` pela toolbar/menu, `Ctrl+O` e drag-and-drop; a pré-visualização mostra nome, nível, contagens e avisos antes de gravar.
- **Rodapé de status** discreto com contagem, armazenamento e estado do autosave.

**Variante tablet (600–839 dp).** O mesmo shell, com rail lateral, tabela com colunas essenciais e o menu do app no botão `⋯`:

```
┌──────────────────────────────────────────────────┐
│ RPG Fichas        [Ana]  [⋯]                     │
├──────┬───────────────────────────────────────────┤
│ Fich │ Fichas                        [Importar]  │
│ Cat  │ ┌───────────────────────────────────────┐ │
│ Aju  │ │ Nome      Nível   Atualizado          │ │
│      │ │ Ana       3       22/11 14:32         │ │
│      │ │ Bruno     5       21/11 09:10         │ │
│      │ └───────────────────────────────────────┘ │
└──────┴───────────────────────────────────────────┘
```

O rail continua sendo navegação persistente; não vira bottom navigation. A tabela esconde colunas secundárias (Origem, Perfil) antes de virar lista de cartões.

### 8.3 Ficha desktop: três painéis e abas

```
┌──────────────────────────────────────────────────────────────────────────────┐
│ Arquivo  Editar  Exibir  Ajuda                         [Salvo]      [⋯]       │
├──────────────────────────────────────────────────────────────────────────────┤
│ [ Ana × ] [ Bruno × ]  +                                                     │
├───────────────┬──────────────────────────────────────────┬───────────────────┤
│ SEÇÕES        │ Ana › Perícias                           │ RESUMO            │
│ 1 Geral       │ ┌──────────────────────────────────────┐ │ PV    12 / 12     │
│ 2 Atributos   │ │ Perícia     Treino    Dado   Bônus   │ │ SAN   10 / 10     │
│ 3 Ferimentos  │ │ Acrobacia   Treinado  d6     +0      │ │ Defesa 14         │
│ 4 Defesa      │ │ Atletismo   Destr.    d4     +0      │ │ Carga  12 / 15    │
│ 5 Deslocam.   │ │ ...                                  │ │                   │
│ 6 Vantagens   │ └──────────────────────────────────────┘ │ Condições         │
│ 7 Resist.     │                                          │ ▸ Ferido          │
│ 8 Perícias  ● │ [Adicionar perícia]  [Filtrar…]          │ ▸ Atordoado       │
│ 9 Combate     │                                          │                   │
│ ...           │                                          │ [Rolar d20]       │
└───────────────┴──────────────────────────────────────────┴───────────────────┘
```

- **Abas de fichas abertas** no topo. O `sheetProvider.family(id)` já suporta várias sessões; um `OpenSheetsController` mantém a lista, a aba ativa e o flush ao fechar.
- **Navegação de seções** à esquerda, com indicador da seção atual.
- **Conteúdo** no centro, com tabelas e edição inline quando fizer sentido.
- **Inspetor** à direita, persistente: PV/SAN/Defesa/Carga, condições e rolagens rápidas. Em larguras menores, ele colapsa; a sidebar também.
- **Painéis redimensionáveis** (`multi_split_view` ou implementação própria), com larguras persistidas nas preferências.
- **Fechar aba** pede flush e só fecha depois de salvar; `Ctrl+W` e o “×” fazem o mesmo.

**Variante tablet (600–839 dp).** Abas continuam; a sidebar de seções vira rail estreito; o inspetor fica oculto por padrão e abre como painel lateral pelo botão **Resumo**. Nunca como bottom sheet.

```
┌──────────────────────────────────────────────────┐
│ [ Ana × ] [ Bruno × ] +        Resumo    Salvo   │
├──────┬───────────────────────────────────────────┤
│ 1    │ Ana › Perícias                            │
│ 2    │ ┌───────────────────────────────────────┐ │
│ 3    │ │ Acrobacia      d6                 >   │ │
│ 8 ●  │ │ Atletismo      d4                 >   │ │
│ 9    │ └───────────────────────────────────────┘ │
│      │ [Adicionar perícia]                       │
└──────┴───────────────────────────────────────────┘
```

### 8.4 Mobile (telefones)

No mobile, a mesma ficha vira uma coluna, com navegação inferior e bottom sheets. O resumo vira um cabeçalho recolhível.

```
┌────────────────────────────┐
│ ‹  Ana            Salvo    │
│ [Geral][Atr][Perícias][…]  │
│                            │
│ Perícias                   │
│ ┌────────────────────────┐ │
│ │ Acrobacia     d6    >  │ │
│ │ Atletismo     d4    >  │ │
│ └────────────────────────┘ │
│                            │
│ [ Adicionar perícia ]      │
├────────────────────────────┤
│  Fichas  Catálogo  Ajustes │
└────────────────────────────┘
```

- Uma ficha por vez; sem abas.
- Bottom sheets para pickers e ações rápidas.
- Importar ficha por `.json` via seletor de arquivos; o mesmo importador e a mesma pré-visualização do desktop.
- Alvos de toque grandes; menos informação por tela.
- Sem menu bar; ações no app bar e em menus contextuais por toque longo.

### 8.5 Componentes adaptativos e interação

| Necessidade | Desktop | Tablet | Phone | Como isolar |
|---|---|---|---|---|
| Navegação principal | sidebar + abas | rail + abas | `NavigationBar` | `InteractionMode` escolhe `DesktopShell`/`MobileShell` |
| Lista de fichas | tabela ordenável | tabela com colunas essenciais | lista de cartões | `AdaptiveCharacterList` |
| Overlay | diálogo/popover | diálogo/painel lateral | `showModalBottomSheet` | `AdaptiveOverlay` |
| Catálogo | diálogo com busca e tabela | diálogo com busca e tabela | tela cheia com cartões | picker escolhe o layout |
| Densidade | compacta (linhas ~32–36 px) | confortável (≥ 44 px) | confortável (48–56 px) | `DensityController` pelo `InputKind` |
| Ações | menu, atalho, contexto | app menu, toque longo, teclado externo | app bar, toque longo | `CommandRegistry` |
| Painéis | redimensionáveis/persistidos | inspetor lateral opcional | fixos | `PanelLayoutController` |

Tablet é **`InteractionMode.desktop` + `InputKind.touch`**: herda a estrutura de navegação e informação do desktop, mas não a densidade de mouse.

**Atalhos mínimos:**

| Atalho | Ação |
|---|---|
| `Ctrl+N` | Nova ficha |
| `Ctrl+O` | Importar ficha |
| `Ctrl+S` | Salvar agora (flush) |
| `Ctrl+W` | Fechar aba atual |
| `Ctrl+Tab` | Próxima aba |
| `Ctrl+K` | Paleta de comandos |
| `Esc` | Fechar overlay/voltar |
| `F1` | Ajuda/atalhos |

**Regras de experiência que valem teste de regressão:**

- O shell desktop **e o de tablet** nunca mostram `NavigationBar` inferior.
- O shell de telefone nunca mostra menu bar ou abas de documentos.
- Nenhuma tela desktop/tablet usa um modal de tela cheia para escolher item; usa diálogo/painel.
- Tablet não usa bottom sheet para picker, resumo ou ação; usa diálogo ou painel lateral.
- Linhas de tabela no desktop têm densidade compacta; no tablet, alvos de toque ≥ 44 px.
- Girar o tablet não troca para o shell mobile.
- Hover e menu de contexto são complementares, nunca a única forma de descobrir uma ação.
- Toda ação de menu também existe como comando/atalho e vice-versa (`CommandRegistry` é a fonte única).

### 8.6 Janela, arquivos e sistema

- **Janela (desktop):** `window_manager` para tamanho mínimo, restaurar posição/tamanho, título e interceptar o fechamento para `flush()`. Tablet não tem janela gerenciada; responder a resize/split view via `MediaQuery`.
- **Arquivos:** `file_selector` no desktop para abrir/salvar; tablet e telefone usam `file_picker` para importar e `share_plus` para exportar. A porta `FileGateway` esconde a diferença.
- **Drag and drop:** `desktop_drop` no desktop e, quando o sistema suportar, no tablet.
- **Teclado:** no tablet, atalhos ficam ativos quando há teclado externo; sem teclado, as mesmas ações aparecem no app menu e no toque longo.
- **Tema:** claro/escuro/sistema, com densidade separada.
- **Sem chrome customizado na v1:** usar a decoração de janela do sistema; custom title bar só se houver motivo forte.

### 8.7 O que evitar

- Sidebar que vira gaveta escondida atrás de um hambúrguer no desktop ou no tablet.
- Cartões de largura total com pouca informação e muito espaço vazio.
- Modais de tela cheia para pickers no desktop/tablet.
- Uma única coluna centralizada em janelas de 1440 px.
- Controles com 48–56 px de altura em tabelas densas de mouse.
- Depender de hover para revelar ações essenciais.
- Tratar tablet como telefone grande: barra inferior, uma coluna e bottom sheets.
- Trocar para mobile ao girar o tablet.
- Duplicar regra de negócio no layout; layout é composição, não uma segunda implementação do domínio.

### 8.8 Matriz de plataformas

| Alvo | Suporte Flutter | Build exige | Observações |
|---|---|---|---|
| Windows 10/11 x64 | estável | Visual Studio 2022 + workload C++ Desktop | SQLite empacotado via Drift; diálogos nativos |
| Linux x64 | estável | clang, cmake, ninja, GTK 3 dev, pkg-config | Testar em GNOME e KDE; fontes podem variar |
| Android phone | estável | Android SDK/JDK | Shell mobile; exportação via share sheet |
| Android tablet | estável | Android SDK/JDK | Shell desktop + densidade de toque; split view |
| iPhone | preparado | macOS + Xcode | Fora desta entrega; sem workflow Apple |
| iPad | preparado | macOS + Xcode | Fora desta entrega; sem workflow Apple |
| Web | fora do escopo | — | Exigiria storage/arquivos condicionais; o app web atual cobre o navegador |

## 9. Catálogos: os JSONs continuam sendo a fonte

### 9.1 Pipeline

```
json/*.json  ──►  tools/catalogs/schema.py  ──►  tools/catalogs/sync.py  ──►  app_flutter/assets/catalogs/*.json
   (autoral)          (Pydantic)                   (normaliza + IDs)              (gerado, versionado)
```

O script é a **única borda de normalização**:

- aceita as duas formas de raiz (`[...]` e `{ "origens": [...] }`);
- resolve aliases (`tier`/`classificacao`, `efeito`/`mecanica_detalhada`);
- converte tipos previsíveis (`espaco: double`, `bonus_defesa: int`);
- extrai `[cite: N]` para `fonte.paginas` e limpa o texto exibido;
- gera `id` estável por item (ver 9.3);
- estrutura pré-requisitos e elementos (ver 9.4);
- grava `manifest.json` com `catalogVersion` (hash dos arquivos), contagens e data de geração.

Comandos:

```bash
python tools/catalogs/sync.py            # gera assets
python tools/catalogs/sync.py --check    # CI: falha se os assets divergirem da fonte
```

O app não lê `../json` em runtime nem em build. Os assets gerados são versionados; o CI garante que ninguém esqueceu de rodar o sync.

### 9.2 Cópia ou referência? Cópia com `catalogId`

Decidido em 6.1: a ficha guarda o snapshot e, quando veio do catálogo, o `catalogId`. Consequências:

- Itens personalizados têm `catalogId: null`.
- Uma correção no catálogo não altera fichas existentes.
- Um item removido do catálogo continua legível na ficha.
- Fichas antigas do web (sem `catalogId`) continuam válidas; o importador tenta resolver o ID por nome apenas quando não há ambiguidade e registra o resultado, sem mudar o conteúdo.
- O teste de contrato garante que todo `catalogId` é globalmente único (o prefixo de `kind` separa nomes repetidos entre arquivos).

### 9.3 IDs estáveis e colisões reais

O nome sozinho não é chave. Existem colisões de verdade nos dados:

- `rituais.json` tem **quatro** “Amaldiçoar Arma” (Sangue, Morte, Energia, Conhecimento).
- `modificacoes.json` tem **duas** “Discreta” (uma para proteções leves, outra para armas).
- “Proteção Pesada” aparece em `habilidades.json` e `protecoes.json`.

Algoritmo:

```
id = kind + "/" + slug(nome)
se repetir dentro do kind:
    acrescentar discriminador semântico: elemento | aplicacao | tipo_arma | classificacao
se ainda repetir:
    falhar o sync e exigir uma entrada em tools/catalogs/id_overrides.yaml
nunca usar índice de array
```

Exemplos:

```
rituais/amaldicoar-arma-sangue
rituais/amaldiocar-arma-morte
modificacoes/discreta-protecao
modificacoes/discreta-arma
habilidades/protecao-pesada
protecoes/protecao-pesada
```

`id_overrides.yaml` existe para dois casos: colisão sem campo discriminante e ID que precisa sobreviver a uma correção de typo. Se um nome mudar, o ID derivado muda; fichas antigas não quebram porque guardam o snapshot. O override só é necessário se quisermos continuidade de identidade entre versões.

### 9.4 Pré-requisitos e elementos em texto livre

Hoje `prereq` é prosa (“Elemento 1”, “Nenhum”), `elemento` pode ser “Variável (...)”, e o web infere elementos/graus com heurísticas no HTML. O app não deve repetir esse parser na UI. O sync emite os dois:

```json
{
  "id": "poderes/aprender-ritual",
  "nome": "Aprender Ritual",
  "elemento": "Variável (Corresponde ao Elemento do Ritual Escolhido)",
  "elementoCanonico": "variavel",
  "prereq": "Elemento 1",
  "grauPrerequisito": 1,
  "elementoPrerequisito": "variavel",
  "fonte": { "arquivo": "poderes paranormais.json", "paginas": [42] }
}
```

- `elementoCanonico` é enum (`sangue`, `morte`, `energia`, `conhecimento`, `medo`, `variavel`).
- `grauPrerequisito` é inteiro ou nulo para “Nenhum”.
- Casos ambíguos vão para `tools/catalogs/prereq_overrides.yaml`.
- O texto original permanece para exibição; a regra usa os campos estruturados.
- Se um campo estruturado faltar, a regra cai num parser conservador e emite um aviso, em vez de bloquear.

### 9.5 Atualização remota futura

Se um dia o catálogo vier do backend, entra uma segunda implementação de `CatalogRepository` que baixa um bundle versionado e o mantém em cache. A UI e os ViewModels não mudam. O modo atual (assets) continua sendo o fallback offline.

## 10. Fichas: armazenamento, importação e regras

### 10.1 SQLite com Drift (o equivalente ao Room no Flutter)

Room é uma biblioteca Android/Kotlin (Jetpack) e não existe no Flutter. Os equivalentes são **Floor** (API inspirada no Room) e **Drift** (ORM SQLite mais maduro e multiplataforma). A escolha é Drift porque funciona em Windows, Linux, Android e iOS, tem migrações versionadas e gera código type-safe.

A tabela de fichas guarda as colunas usadas para listar/filtrar e o documento completo em JSON. A classe `CharacterDatabase` fica em `features/characters/data/drift/character_database.dart`; tabelas e migrações ficam ao lado, dentro da mesma feature.

```dart
class Characters extends Table {
  TextColumn get id => text()();
  TextColumn get nome => text()();
  IntColumn get nivel => integer().withDefault(const Constant(1))();
  TextColumn get conceito => text().nullable()();
  TextColumn get origem => text().nullable()();
  TextColumn get perfil => text().nullable()();

  // Versão do documento Character, não do schema do banco.
  IntColumn get characterSchemaVersion => integer()();
  TextColumn get data => text()(); // Character completo em JSON

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get lastOpenedAt => dateTime().nullable()();
  TextColumn get catalogVersion => text().nullable()();
  TextColumn get checksum => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
```

O **arquivo** JSON não é o formato interno de armazenamento; ele é o contrato de exportação/importação. Internamente, o documento serializado vive na coluna `data` do SQLite, cercado de colunas indexadas e metadados:

```
Character (memória)
   │ save
   ▼
DriftCharacterRepository ──► SQLite: colunas de resumo + data JSON + metadados
   │ export
   ▼
exportEnvelope ──► ficha.json (backup/intercâmbio)
```

| Representação | Onde vive | Papel |
|---|---|---|
| `Character` | memória/domínio | regras, ViewModels e UI |
| `CharacterRow` | SQLite (Drift) | armazenamento indexado + documento + metadados |
| `ExportEnvelope` | arquivo `.json` | backup, transferência e compatibilidade com o web |
| Catálogo JSON | `assets/catalogs/` | referência somente leitura, nunca editada pelo app |

Não existe um arquivo `.json` por ficha no disco: o banco é a fonte local. O arquivo só aparece quando o usuário exporta.

- `nome`, `nivel`, `conceito`, `origem` e `perfil` ficam fora do `data` para listar, ordenar e filtrar o dashboard sem desserializar tudo.
- `data` é a representação persistida do `Character` e a base do envelope de exportação.
- `characterSchemaVersion` permite a cadeia de migrações do documento; o `schemaVersion` do Drift (em `MigrationStrategy`) cuida das mudanças de tabela.
- `catalogVersion` registra com qual versão do catálogo a ficha foi salva pela última vez (diagnóstico e futura atualização de itens).
- `checksum` (SHA-256 de `data`) detecta corrupção sem precisar abrir e interpretar o documento.
- `lastOpenedAt` alimenta a lista de recentes; `updatedAt` ordena e serve de base para sincronização futura.
- Escritas passam por transação; o banco abre com WAL, `foreign_keys=ON` e `busy_timeout`; o autosave nunca deixa uma ficha pela metade.
- Índices em `nome`, `updatedAt` e `nivel` cobrem o dashboard.
- `shared_preferences` guarda preferências simples (tema, densidade, largura de painéis, limites da janela); fichas ficam no SQLite.

**Por que JSON dentro do SQLite e não oito tabelas normalizadas?** A ficha é editada como um documento e tem oito listas internas (atributos, perícias, armas, proteções, inventário, habilidades, rituais, poderes). Normalizar tudo geraria oito tabelas, joins e uma migração para cada campo novo, sem ganho de consulta neste domínio. O híbrido indexa só o que o sistema precisa consultar e mantém o resto como documento. Se um dia houver relatórios relacionais, a normalização entra atrás da mesma porta `CharacterRepository`.

**Opcional, fora do núcleo:** uma tabela `character_revisions` pode guardar checkpoints (não cada autosave) para desfazer/restaurar uma ficha. O formato de exportação não muda; é só mais uma tabela interna.

Os **catálogos JSON não são copiados para o banco**: continuam como assets somente leitura em `assets/catalogs/`. O SQLite guarda apenas fichas e preferências.

Dependências principais:

```yaml
dependencies:
  drift: <versão atual>
  drift_flutter: <versão atual>       # abertura multiplataforma (path_provider)
  sqlite3_flutter_libs: <versão atual> # SQLite empacotado em Android/iOS/Windows/Linux
  shared_preferences: <versão atual>
dev_dependencies:
  drift_dev: <versão atual>
  build_runner: <versão atual>
```

Testes de repositório usam `NativeDatabase.memory()`; os testes de migração abrem um banco na versão anterior e verificam que a ficha chega intacta à versão atual.

Se você preferir a API do Room, **Floor** entra atrás da mesma porta. Se preferir tabelas normalizadas, a decisão fica em `data/drift/tables.dart` e não vaza para ViewModels.

### 10.2 Importar e exportar por JSON

A opção **Importar ficha** aceita JSON em todas as plataformas. O armazenamento interno continua sendo SQLite; o arquivo é só o transporte.

**Formatos aceitos:**

1. Envelope do app: `{ aplicativo, versao, exportada_em, ficha }`.
2. Envelope antigo do app web (mesma forma, sem `schemaVersion` interna).
3. Ficha nua: um objeto JSON com os campos do `Character`.
4. Uma lista de fichas (backup múltiplo), tratada como vários imports em sequência. *(Opcional; se não entrar na v1, aceitar só os formatos 1–3.)*

**Fluxo:**

```
Arquivo .json / JSON colado / drag-and-drop
        │
        ▼
FileGateway / ClipboardGateway
        │
        ▼
JsonCharacterImporter ──► parse + valida + migra + resolve catalogId (sem alterar conteúdo)
        │
        ▼
Pré-visualização (nome, nível, origem, perfil, contagens, avisos)
        │
        ├── Cancelar ──► nada é gravado
        └── Importar ──► DriftCharacterRepository.save() ──► dashboard
```

- **Entradas:** botão/menu "Importar", `Ctrl+O`, drag-and-drop de `.json` no desktop/tablet e a opção "Colar JSON" no desktop/tablet.
- **Mobile/tablet:** `file_picker` abre o seletor de arquivos filtrando `.json`; o conteúdo passa pelo mesmo importador.
- **Pré-visualização antes de salvar:** mostra nome, nível, origem, perfil, quantidade de armas/perícias/poderes e os avisos de validação. Nada é gravado enquanto o usuário não confirma.
- **ID:** por padrão, toda importação cria um **novo ID** (mesma lógica do app web), para não sobrescrever uma ficha existente sem intenção. Se o arquivo trouxer um ID já existente, a pré-visualização oferece "Criar cópia" (padrão) ou "Substituir".
- **Fichas antigas do web:** sem `schemaVersion`, assumem a versão 1 e passam pela cadeia de migrações.
- **Campos desconhecidos:** preservados em `extras` e reemitidos no nível superior do próximo export, para round-trip.
- **Itens de catálogo:** vêm como snapshot; se faltar `catalogId`, o importador tenta resolver por nome apenas quando não há ambiguidade e registra o resultado sem alterar o conteúdo.
- **Habilidades automáticas:** reconciliadas de forma idempotente; importar duas vezes não duplica nem remove habilidades manuais.
- **Erros:** JSON inválido, versão futura não suportada ou campo conhecido com tipo errado aparecem **antes** de salvar, com campo e motivo; não há importação parcial.
- **Exportação:** o mesmo modelo gera o envelope JSON; exportar nunca grava direto no banco, apenas produz o arquivo.

Testes de ida e volta com uma ficha exportada pelo app web são obrigatórios. O importador nunca altera os JSONs de catálogo em `assets/catalogs/`.

### 10.3 Paridade de regras: avisar, não bloquear

O README atual é explícito: progressão e slots de habilidade não impedem nada; várias checagens são só aviso. O app Flutter deve manter isso:

```dart
enum IssueSeverity { info, warning, error }

class ValidationIssue {
  final String code;
  final IssueSeverity severity;
  final String message;
  final String? field;
}
```

- **Erro** só para dados inválidos de verdade (nível fora de 1–20, atributo não numérico, JSON corrompido).
- **Aviso** para pontos de atributo não gastos, slots excedidos, pré-requisito não cumprido, perícia acima do limite.
- **Info** para dicas de progressão.
- O usuário pode salvar com avisos. A UI mostra um resumo, não um bloqueio.

Isso evita que o app fique mais rígido que a mesa e mantém paridade com o web.

## 11. Regras de dependência

1. `shared/` não importa nada de `features/`.
2. Uma feature não importa arquivos internos de outra; só a API pública (`features/catalog/catalog.dart`).
3. `app/` só compõe: rotas, tema, providers e shell. Nada de regra de negócio.
4. `domain/` é Dart puro. Se precisar de Flutter, Drift ou `dart:io`, está na camada errada.
5. `data/` implementa portas; não é importada por `presentation/`.
6. Nenhum widget conhece Drift, JSON cru ou nome de tabela.
7. Navegação não entra em ViewModel.
8. O composition root (`app/providers.dart`) é o único lugar que importa implementações de `data/` para injetá-las.

Para não depender de disciplina: `very_good_analysis` + uma regra de fronteira via `custom_lint` (ou um teste de arquitetura) no CI.

## 12. Testes

- **Domínio/regras** — testes Dart puros: PV, SAN, defesa com e sem auto, carga, pontos de atributo, pré-requisitos, limites de perícia.
- **ViewModels** — `ProviderContainer` com repositórios fake; testar comandos e autosave.
- **Persistência** — `DriftCharacterRepository` com `NativeDatabase.memory()`; testes de migração de schema e de round-trip JSON.
- **Widgets** — `flutter_test` + fakes; fluxos de criar, editar, adicionar arma, importar/exportar.
- **Golden tests** — dashboard desktop (tabela), dashboard tablet (tabela compacta), ficha desktop (três painéis + abas), ficha tablet (rail + inspetor lateral) e ficha phone (coluna única). Fixar fontes para não variar entre Windows/Linux.
- **Regressão de shell** — desktop e tablet nunca renderizam `NavigationBar` inferior; phone nunca renderiza menu bar/abas; pickers de desktop/tablet não usam tela cheia nem bottom sheet.
- **Tablet** — retrato e paisagem usam o mesmo shell; girar não troca para mobile; alvos de toque ≥ 44 px; inspetor abre como painel lateral.
- **Interação desktop** — atalhos, menu de contexto, fechamento de aba com flush, persistência de largura dos painéis e densidade.
- **Integração** — `integration_test` em Windows, Linux e Android; iOS quando houver macOS.
- **Catálogo** — `sync.py --check` no CI + testes de contrato (IDs únicos por tipo, campos obrigatórios, pré-requisitos estruturados).
- **Compatibilidade** — fixture de ficha exportada pelo web, incluindo campos desconhecidos, e teste de round-trip.
- **Importação JSON** — envelope Flutter, envelope web, ficha nua, JSON inválido, versão futura, campos desconhecidos preservados, novo ID, conflito de ID, habilidades automáticas sem duplicar e nenhuma gravação parcial.
- **UI de importação** — menu/atalho, drag-and-drop e pré-visualização nos três shells (desktop, tablet, phone).

## 13. Build e CI

Os workflows ficam em `.github/workflows/`:

### `ci.yml` — validação

Dispara em todo PR e em push para `main` ou `develop`, além de execução manual. Sem filtro de caminho: assim os checks obrigatórios existem também em PRs que só mexem em documentação.

| Job | Runner | O que faz |
|---|---|---|
| `preflight` | ubuntu | Detecta se `app_flutter/` e `tools/catalogs/` já existem; evita falha antes do scaffold |
| `catalogs` | ubuntu | `python tools/catalogs/sync.py --check` + conferência dos assets versionados |
| `analyze-test` | ubuntu e windows | `flutter pub get`, codegen do Drift (Linux), `flutter analyze`, `flutter test` |

### `pr-flow.yml` — fluxo de branches

Roda em todo PR e falha se o destino não seguir `feature/fix → develop → main`:

- PR para `main` só é aceito vindo de `develop` do mesmo repositório.
- PR para `develop` não pode vir de `main`.
- Qualquer outro destino falha.

O fluxo completo, as regras de ruleset e os comandos estão em [`docs/fluxo-git.md`](fluxo-git.md).

### `build.yml` — artefatos

Dispara manualmente (`workflow_dispatch`) e em tags `v*`. Cobre **Windows, Linux e Android**; Apple (iOS/macOS) fica fora desta entrega.

| Job | Runner | Artefato |
|---|---|---|
| `linux` | ubuntu | `rpg-fichas-linux-x64.tar.gz` |
| `windows` | windows | `rpg-fichas-windows-x64.zip` |
| `android` | ubuntu | `rpg-fichas-android.apk` |
| `release` | ubuntu | Anexa os três artefatos à release da tag |

Observações:

- Build Windows exige Visual Studio com workload C++; o runner `windows-latest` já traz.
- Build Linux instala `clang`, `cmake`, `ninja-build`, `pkg-config`, `libgtk-3-dev`, `liblzma-dev` e `build-essential`.
- Android usa JDK 17 e cache do Gradle. O APK de release usa a assinatura de debug até existir uma chave de release configurada em secrets.
- Drift usa `build_runner`; os `*.g.dart` são versionados e o CI confere se estão atualizados.
- O build também valida os catálogos antes de compilar, para não empacotar assets desatualizados.
- `sqlite3_flutter_libs` empacota o SQLite; o app não depende do SQLite instalado no sistema.
- Golden tests podem variar por plataforma; rodar em um único runner e fixar fontes.
- O app não deve depender de Python em runtime; Python só é necessário para atualizar catálogos.
- Apple fica preparado na arquitetura, mas sem job de build/CI enquanto não houver macOS/Xcode.

## 14. Ordem de construção sugerida

1. **Contrato de dados** — schemas Pydantic, IDs/overrides, pré-requisitos estruturados, sync e validação dos 17 JSONs.
2. **Fundação Flutter** — projeto, tema, `go_router`, `DeviceClass`/`InteractionMode`/`InputKind`, `DesktopShell`/`MobileShell`, providers, Drift/SQLite, `FileGateway`.
3. **Fichas** — dashboard em tabela (desktop/tablet) e lista (phone), criar, listar, excluir, importar/exportar e repositório Drift.
4. **Núcleo da ficha** — sessão única, layout desktop de três painéis com abas e inspetor (com variante tablet), informações gerais, atributos, derivados, ferimentos, perícias.
5. **Combate e inventário** — armas, proteções, modificações, maldições e pickers adaptativos.
6. **Paranormal** — habilidades, rituais, poderes e trilha.
7. **Polimento** — paleta de comandos, atalhos, drag-and-drop, densidade, acessibilidade, testes de paridade desktop/tablet/phone.

## 15. Alternativas consideradas

| Alternativa | Por que não |
|---|---|
| React Native + React Native Web + Tauri | O desktop vira webview; `expo-sqlite` e diálogos não existem no desktop; exige adaptadores por plataforma e uma casca Rust. Flutter resolve nativo. |
| React Native mobile + UI React separada para desktop | Duas UIs e duas bases de teste para manter; só compensa se desktop e mobile tiverem experiências muito diferentes. |
| PWA apenas | Não é aplicativo instalado de verdade, tem limitações de filesystem e não cobre o requisito de janela própria. |
| Flutter + Bloc | A estrutura continua válida; troca-se `Notifier` por `Cubit`. Riverpod foi escolhido pela DI e pelas famílias por ficha. |
| Room (Jetpack) | Não existe no Flutter: é Android/Kotlin. O equivalente conceitual é Floor; Drift foi escolhido por maturidade e suporte a desktop. |
| Flutter + Floor | API parecida com Room, mas menos madura que Drift e com menos suporte a Windows/Linux. |
| Flutter + Sembast | Banco de documentos; atende, mas você pediu SQLite explicitamente. |

## 16. Decisões fechadas e defaults

**Fechadas:**

- **Tablet** — desktop com toque em `shortestSide >= 600 dp`; split view abaixo de 600 dp cai para phone.
- **Modelo de dados** — híbrido: colunas de resumo + documento JSON + metadados no SQLite; o arquivo JSON é o formato de exportação, não o armazenamento.
- **Catálogo** — JSONs autorais permanecem como assets; não há seed do catálogo no banco.

**Defaults assumidos (revisáveis):**

- **Drift** como ORM SQLite; **Floor** se você quiser a API do Room.
- **Riverpod**; **go_router**; **shared_preferences** para preferências.
- **Assets gerados versionados** no Git, com `--check` no CI.
- **Snapshot + `catalogId`** nos itens de catálogo copiados para a ficha.
- **Abas de fichas** no desktop/tablet e uma ficha por vez no phone.
- **Importação JSON** disponível em todas as plataformas; por padrão cria um novo ID e mostra pré-visualização antes de salvar.
- **CI/build** cobrem Windows, Linux e Android; Apple fica fora desta entrega.

Não há pendências abertas neste desenho.

## 17. Não-objetivos deste primeiro desenho

- Reescrever o backend ou o app web.
- Sincronização multi-dispositivo, contas e resolução de conflitos.
- Normalizar o conteúdo dos 17 JSONs à mão; o pipeline prevê a borda, não a limpeza editorial.
- Escolher biblioteca de gráficos, animação ou dados 3D.
- Suporte a web no app Flutter (o app web atual cobre esse alvo).
- Builds, assinatura e distribuição Apple nesta entrega.
- Impressão/PDF da ficha.
