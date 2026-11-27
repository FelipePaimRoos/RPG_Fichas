import 'package:app_flutter/features/catalog/catalog.dart' show ProgressionRow;

import 'package:app_flutter/features/characters/domain/character.dart';
import 'package:app_flutter/features/characters/domain/derived_stats.dart';
import 'package:app_flutter/features/characters/domain/rules/progression.dart';
import 'package:app_flutter/shared/domain/dice.dart';

/// Calcula todos os valores derivados de uma ficha — réplica exata de
/// `atualizarCalculos`, `atualizarDeslocamentoBase` e `calcularCarga` do web.
DerivedStats computeDerived(
  Character character,
  List<ProgressionRow> progressao,
) {
  int atributo(String nome) => character.atributos
      .firstWhere((a) => a.nome == nome, orElse: () => const AttributeValue(nome: '', valor: 1, debilitado: false))
      .valor;
  final forca = atributo('forca');
  final agilidade = atributo('agilidade');
  final presenca = atributo('presenca');
  final vigor = atributo('vigor');
  final debForca = character.atributos
      .firstWhere((a) => a.nome == 'forca')
      .debilitado;
  final debAgilidade = character.atributos
      .firstWhere((a) => a.nome == 'agilidade')
      .debilitado;

  // Carga: itens genéricos + armas + proteções.
  var cargaAtual = 0.0;
  for (final item in character.inventario) {
    cargaAtual += item.espaco;
  }
  for (final arma in character.armas) {
    cargaAtual += arma.espaco;
  }
  for (final protecao in character.protecoes) {
    cargaAtual += protecao.espaco;
  }

  final cargaMaxima = forca * 5;
  final cargaMaxEfetiva =
      debForca ? (cargaMaxima / 2).floor() : cargaMaxima;

  // Médias dos dados de Fortitude e Reflexos.
  int mediaDe(String nomePericia) {
    final index =
        character.pericias.indexWhere((p) => p.nome == nomePericia);
    if (index < 0) {
      return Dice.averageRoll(4);
    }
    final state = character.pericias[index];
    final faces = Dice.facesForTraining(state.treinamento);
    return Dice.averageRoll(faces) + state.bonus;
  }
  final bloqueio = mediaDe('Fortitude');
  final esquiva = character.defesaAtual + mediaDe('Reflexos');

  // Deslocamento: penalidade de carga em pares de excesso.
  final baseM = character.deslocamentoBase;
  final baseQ = (baseM / 1.5).floor();
  final excesso = cargaAtual - cargaMaxEfetiva;
  var penalidadeM = 0;
  var penalidadeQ = 0;
  if (excesso > 0) {
    final paresExtras = (excesso / 2).floor();
    penalidadeM = paresExtras * 3;
    penalidadeQ = paresExtras * 2;
  }
  var efetivoM = (baseM - penalidadeM).clamp(0, baseM);
  var efetivoQ = (baseQ - penalidadeQ).clamp(0, baseQ);
  if (debAgilidade) {
    efetivoM = (efetivoM - 3).clamp(0, efetivoM);
    efetivoQ = (efetivoQ - 2).clamp(0, efetivoQ);
  }

  // Pontos de atributo.
  final disponiveis = ProgressionRules.pontosAtributoDisponiveis(
    character.nivel,
    progressao.map((r) => (nivel: r.nivel, categoria: r.categoria)).toList(),
  );
  final distribuidos = character.atributos.fold<int>(
    0,
    (total, a) => total + (a.valor - 1).clamp(0, a.valor - 1),
  );

  return DerivedStats(
    vidaMaxAuto: 10 + vigor,
    sanidadeMaxAuto: 10 + presenca,
    defesaAuto: 5 + agilidade + character.bonusProtecoes,
    cargaMaxima: cargaMaxima,
    cargaMaxEfetiva: cargaMaxEfetiva,
    cargaAtual: cargaAtual,
    bloqueio: bloqueio,
    esquiva: esquiva,
    deslocamentoMetros: efetivoM,
    deslocamentoQuadrados: efetivoQ,
    pontosAtributoRestantes: disponiveis - distribuidos,
  );
}

/// Reaplica os valores automáticos respeitando as flags
/// `autoVida`/`autoSanidade`/`autoDefesa` (`applyAutoStats` do doc).
Character applyAutoStats(Character character, List<ProgressionRow> progressao) {
  final derived = computeDerived(character, progressao);
  final next = character.copy();
  if (next.autoVida) {
    next.vidaMax = derived.vidaMaxAuto;
    if (next.vidaAtual > next.vidaMax) {
      next.vidaAtual = next.vidaMax;
    }
  }
  if (next.autoSanidade) {
    next.sanidadeMax = derived.sanidadeMaxAuto;
    if (next.sanidadeAtual > next.sanidadeMax) {
      next.sanidadeAtual = next.sanidadeMax;
    }
  }
  if (next.autoDefesa) {
    next.defesaAtual = derived.defesaAuto;
  }
  next.cargaMaxima = derived.cargaMaxima;
  return next;
}
