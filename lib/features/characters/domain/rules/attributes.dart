import 'package:app_flutter/shared/domain/dice.dart';

/// Regras de atributo: DT e forma do dado, iguais ao web.
abstract final class AttributeRules {
  /// DT do atributo: `5 + valor + nível` (`getDT`).
  static int dt(int valorAtributo, int nivel) => 5 + valorAtributo + nivel;

  /// Dado associado ao valor do atributo (`atualizarDadoAtributo`).
  static String diceFor(int valorAtributo) =>
      Dice.diceForAttributeValue(valorAtributo);
}
