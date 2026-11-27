import 'package:app_flutter/features/catalog/catalog.dart' show ProgressionRow;

import 'package:app_flutter/features/characters/domain/character.dart';
import 'package:app_flutter/features/characters/domain/rules/derived.dart';

/// Regras de carga e deslocamento — fachada sobre [computeDerived] para
/// consultas pontuais (mantém `domain/rules/encumbrance.dart` do plano).
abstract final class EncumbranceRules {
  /// Penalidade de deslocamento por excesso de carga:
  /// cada 2 pontos de excesso custam 3 m / 2 quadrados.
  static ({int metros, int quadrados}) penalidadePorExcesso(
    double excesso,
  ) {
    if (excesso <= 0) {
      return (metros: 0, quadrados: 0);
    }
    final pares = (excesso / 2).floor();
    return (metros: pares * 3, quadrados: pares * 2);
  }

  /// Deslocamento efetivo (m, quadrados) da ficha.
  static ({int metros, int quadrados}) deslocamentoEfetivo(
    Character character,
    List<ProgressionRow> progressao,
  ) {
    final derived = computeDerived(character, progressao);
    return (
      metros: derived.deslocamentoMetros,
      quadrados: derived.deslocamentoQuadrados,
    );
  }

  /// Conversão metros → quadrados (floor(m / 1.5)).
  static int metrosParaQuadrados(int metros) => (metros / 1.5).floor();
}
