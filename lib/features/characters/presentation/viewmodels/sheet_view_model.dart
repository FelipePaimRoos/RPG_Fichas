import 'package:app_flutter/app/providers.dart';
import 'package:app_flutter/features/catalog/catalog.dart'
    show
        Ability,
        InventoryItem,
        Origin,
        Power,
        Profile,
        ProgressionRow,
        Protection,
        Ritual,
        Weapon;
import 'package:app_flutter/features/characters/domain/character.dart';
import 'package:app_flutter/features/characters/domain/rules/derived.dart';
import 'package:app_flutter/features/characters/domain/rules/progression.dart';
import 'package:app_flutter/features/characters/domain/rules/skills.dart'
    show SkillRules, periciasBase;
import 'package:app_flutter/features/characters/presentation/viewmodels/autosave_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

/// Dono da ficha aberta — família por id (doc §6.3).
final AsyncNotifierProviderFamily<SheetViewModel, Character, String>
    sheetProvider = AsyncNotifierProvider.family<SheetViewModel, Character,
        String>(SheetViewModel.new);

/// Dono da ficha aberta — única fonte de verdade (doc §7).
/// As seções observam fatias via `select` e mutam por comandos.
class SheetViewModel extends AsyncNotifier<Character> {
  /// Cria o ViewModel para a ficha [characterId].
  SheetViewModel(this.characterId);

  /// Identificador da ficha gerenciada.
  final String characterId;

  List<ProgressionRow> _progressao = const [];

  /// A ficha carregada (para leituras pontuais fora do build).
  Character get current => state.requireValue;

  @override
  Future<Character> build() async {
    _progressao = await ref.watch(progressaoProvider.future);

    final repository = ref.watch(characterRepositoryProvider);
    final character = await repository.get(characterId);
    if (character == null) {
      throw StateError('Ficha $characterId não encontrada.');
    }
    return _normalizeSkills(character);
  }

  Character _normalizeSkills(Character character) {
    // Fichas novas ou importadas podem chegar com menos entradas do que as
    // 26 perícias base; completa por índice com os nomes canônicos.
    final pericias = [...character.pericias];
    while (pericias.length < periciasBase.length) {
      pericias.add(const SkillState(nome: '', treinamento: 'Destreinado'));
    }
    for (var i = 0; i < pericias.length; i++) {
      if (pericias[i].nome.isEmpty && i < periciasBase.length) {
        pericias[i] = pericias[i].copyWith(nome: periciasBase[i].nome);
      }
    }
    return character..pericias = pericias;
  }

  /// Aplica uma mutação na ficha, recalcula derivados e agenda o autosave.
  Future<void> edit(void Function(Character character) recipe) async {
    final current = state.requireValue.copy();
    recipe(current);
    final next = applyAutoStats(current, _progressao);
    state = AsyncData(next);
    ref
        .read(autosaveControllerProvider(characterId).notifier)
        .schedule(next);
  }

  /// Salva imediatamente o que estiver pendente.
  Future<void> flush() =>
      ref.read(autosaveControllerProvider(characterId).notifier).flush();

  // ---- Comandos das seções ----

  /// Atualiza um campo de texto simples.
  Future<void> set(void Function(Character) recipe) => edit(recipe);

  /// Define a origem e reconcilia perícias/habilidades automáticas.
  /// Réplica exata da regra do backend Python: perícia concedida pela
  /// origem fica Treinada com `automaticoOrigem`; quando a origem muda e a
  /// perícia não é mais concedida, volta a Destreinada.
  Future<void> setOrigem(String nome, Origin? origem) =>
      edit((c) {
        c.origem = nome;
        final concedidas = origem?.periciasTreinadas ?? const <String>[];
        c.pericias = SkillRules.reconciliarOrigem(c.pericias, concedidas);
        _reconciliarHabilidades(c);
      });

  /// Define o perfil e reconcilia habilidades automáticas.
  Future<void> setPerfil(String nome, Profile? perfil) => edit((c) {
        c
          ..perfil = nome
          ..marcadoresAnalise = 0
          ..impeto = 0;
        _reconciliarHabilidades(c);
      });

  void _reconciliarHabilidades(Character c) {
    final manuais = c.habilidades.where((h) => !h.automatico).toList();
    final automaticas = <Ability>[
      if (c.perfil.isNotEmpty)
        Ability(
          nome: c.perfil,
          classificacao: 'Habilidade de Perfil (${c.perfil})',
          efeito: ref.read(perfisProvider).value
                  ?.where((p) => p.nome == c.perfil)
                  .map((p) => p.efeito)
                  .firstOrNull ??
              '',
          automatico: true,
        ),
      if (c.origem.isNotEmpty)
        Ability(
          nome: ref.read(origensProvider).value
                  ?.where((o) => o.nome == c.origem)
                  .map((o) => o.habilidadeNome)
                  .firstOrNull ??
              c.origem,
          classificacao: 'Habilidade de Origem (${c.origem})',
          automatico: true,
        ),
    ];
    c.habilidades = [...manuais, ...automaticas];
  }

  /// Ajusta um atributo.
  Future<void> setAtributo(String nome, {int? valor, bool? debilitado}) =>
      edit((c) {
        final index = c.atributos.indexWhere((a) => a.nome == nome);
        if (index >= 0) {
          c.atributos[index] = AttributeValue(
            nome: nome,
            valor: valor ?? c.atributos[index].valor,
            debilitado: debilitado ?? c.atributos[index].debilitado,
          );
        }
      });

  /// Ajusta vida/sanidade/defesa com proteção dos mínimos (como o web).
  Future<void> setVidaAtual(int value) => edit((c) {
        c.vidaAtual = value.clamp(0, 9999);
      });

  /// Ajusta vida máxima (desliga o automático, como o web ao digitar).
  Future<void> setVidaMax(int value) =>
      edit((c) => c..autoVida = false..vidaMax = value.clamp(0, 9999));

  /// Liga/desliga o cálculo automático da vida.
  Future<void> setAutoVida({required bool value}) =>
      edit((c) => c.autoVida = value);

  /// Ajusta sanidade atual.
  Future<void> setSanidadeAtual(int value) => edit((c) {
        c.sanidadeAtual = value.clamp(0, 9999);
      });

  /// Ajusta sanidade máxima (desliga o automático).
  Future<void> setSanidadeMax(int value) =>
      edit((c) => c..autoSanidade = false..sanidadeMax = value.clamp(0, 9999));

  /// Liga/desliga o cálculo automático da sanidade.
  Future<void> setAutoSanidade({required bool value}) =>
      edit((c) => c.autoSanidade = value);

  /// Ajusta defesa atual (desliga o automático).
  Future<void> setDefesa(int value) =>
      edit((c) => c..autoDefesa = false..defesaAtual = value.clamp(0, 9999));

  /// Liga/desliga o cálculo automático da defesa.
  Future<void> setAutoDefesa({required bool value}) =>
      edit((c) => c.autoDefesa = value);

  /// Bônus de proteções.
  Future<void> setBonusProtecoes(int value) =>
      edit((c) => c.bonusProtecoes = value);

  /// Deslocamento base em metros.
  Future<void> setDeslocamentoBase(int value) =>
      edit((c) => c.deslocamentoBase = value.clamp(0, 999));

  /// Treinamento de uma perícia.
  Future<void> setPericiaTreinamento(int index, String treinamento) =>
      edit((c) {
        c.pericias[index] = c.pericias[index].copyWith(
          treinamento: treinamento,
        );
      });

  /// Bônus de uma perícia.
  Future<void> setPericiaBonus(int index, int bonus) => edit((c) {
        c.pericias[index] = c.pericias[index].copyWith(bonus: bonus);
      });

  /// Define o nível de exposição paranormal pela posição na trilha.
  Future<void> setExposicao(int index) => edit((c) {
        if (index >= 0 && index < ProgressionRules.niveisParanormal.length) {
          c.exposicaoParanormal =
              ProgressionRules.niveisParanormal[index];
        }
      });

  /// Ajusta a afinidade elementar (>= 50%).
  Future<void> setAfinidade(String elemento) =>
      edit((c) => c.afinidadeElemento = elemento);

  /// Registra o resultado de um teste contra o paranormal
  /// (`rolarParanormal` do web).
  Future<void> registrarCrise({required bool vitoria}) => edit((c) {
        c.crisesContador += 1;
        if (vitoria) {
          if (c.dadoParanormalIdx < 4) {
            c.dadoParanormalIdx += 1;
          }
        } else {
          if (c.exposicaoParanormal < 99) {
            c.exposicaoParanormal += 5;
          }
          c.dadoParanormalIdx = 0;
        }
      });

  /// Adiciona arma ao inventário.
  Future<void> addArma(Weapon arma) => edit((c) => c.armas.add(arma));

  /// Atualiza arma.
  Future<void> setArma(int index, Weapon arma) =>
      edit((c) => c.armas[index] = arma);

  /// Remove arma.
  Future<void> removeArma(int index) => edit((c) => c.armas.removeAt(index));

  /// Adiciona proteção.
  Future<void> addProtecao(Protection protecao) =>
      edit((c) => c.protecoes.add(protecao));

  /// Atualiza proteção.
  Future<void> setProtecao(int index, Protection protecao) =>
      edit((c) => c.protecoes[index] = protecao);

  /// Remove proteção.
  Future<void> removeProtecao(int index) =>
      edit((c) => c.protecoes.removeAt(index));

  /// Adiciona item genérico.
  Future<void> addItem(InventoryItem item) =>
      edit((c) => c.inventario.add(item));

  /// Atualiza item genérico.
  Future<void> setItem(int index, InventoryItem item) =>
      edit((c) => c.inventario[index] = item);

  /// Remove item genérico.
  Future<void> removeItem(int index) =>
      edit((c) => c.inventario.removeAt(index));

  /// Adiciona habilidade manual.
  Future<void> addHabilidade(Ability habilidade) =>
      edit((c) => c.habilidades.add(habilidade));

  /// Atualiza habilidade.
  Future<void> setHabilidade(int index, Ability habilidade) =>
      edit((c) => c.habilidades[index] = habilidade);

  /// Remove habilidade (somente manuais).
  Future<void> removeHabilidade(int index) =>
      edit((c) => c.habilidades.removeAt(index));

  /// Adiciona ritual.
  Future<void> addRitual(Ritual ritual) => edit((c) => c.rituais.add(ritual));

  /// Atualiza ritual.
  Future<void> setRitual(int index, Ritual ritual) =>
      edit((c) => c.rituais[index] = ritual);

  /// Remove ritual.
  Future<void> removeRitual(int index) =>
      edit((c) => c.rituais.removeAt(index));

  /// Adiciona poder.
  Future<void> addPoder(Power poder) => edit((c) => c.poderes.add(poder));

  /// Atualiza poder.
  Future<void> setPoder(int index, Power poder) =>
      edit((c) => c.poderes[index] = poder);

  /// Remove poder.
  Future<void> removePoder(int index) =>
      edit((c) => c.poderes.removeAt(index));
}
