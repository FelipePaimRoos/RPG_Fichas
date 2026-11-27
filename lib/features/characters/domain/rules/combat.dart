import 'package:app_flutter/features/catalog/catalog.dart' show Weapon;

import 'package:app_flutter/shared/domain/dice.dart';

/// Estado efêmero de um card de ataque (não é persistido — igual ao web).
class AttackEntry {
  /// Cria um card de ataque com os defaults do web.
  AttackEntry({
    this.nome = '',
    this.armaNome = '',
    this.atributo = 'forca',
    this.periciaNome = '',
    this.acaoArriscada = 'normal',
    this.critico = 'x2',
    this.bonusDado = '',
    this.bonusFixo = 0,
  });

  /// Nome do ataque.
  String nome;

  /// Nome da arma do inventário ('' = desarmado).
  String armaNome;

  /// Chave do atributo usado.
  String atributo;

  /// Nome da perícia usada ('' = nenhuma).
  String periciaNome;

  /// Ação arriscada: normal / 2v_dobrar / 3v_triplicar.
  String acaoArriscada;

  /// Crítico (ex.: "x2").
  String critico;

  /// Bônus de dado textual (ex.: "+d6").
  String bonusDado;

  /// Bônus fixo numérico.
  int bonusFixo;
}

/// Resultado calculado de um ataque.
class AttackResult {
  /// Cria o resultado.
  const AttackResult({
    required this.dadoAtaque,
    required this.dano,
    required this.critico,
  });

  /// String do dado de ataque (ex.: "d4 + d6 + d6 - 1d6").
  final String dadoAtaque;

  /// String do dano base (ex.: "2d4 · Arma: 1d8 + 6").
  final String dano;

  /// String do dano crítico.
  final String critico;
}

/// Cálculo dos cards de ataque — portagem de `calcularAtaqueCard`.
abstract final class CombatRules {
  /// Dado associado ao valor do atributo (sem o d-none).
  static String dadoAtributo(int valorAtributo) {
    final dice = Dice.diceForAttributeValue(valorAtributo);
    return dice == 'd-none' ? 'd4' : dice;
  }

  /// Calcula dado de ataque, dano e crítico do card.
  static AttackResult calcular({
    required int valorAtributo,
    required String nomePericia,
    required String treinamentoPericia,
    required String bonusDado,
    required int bonusFixo,
    required String acaoArriscada,
    Weapon? arma,
  }) {
    final dadoAtr = dadoAtributo(valorAtributo);

    var dadoPericiaStr = 'd4';
    if (nomePericia.isNotEmpty) {
      dadoPericiaStr = 'd${Dice.facesForTraining(treinamentoPericia)}';
    }

    var dadoFinalStr = '$dadoAtr + $dadoPericiaStr';
    final bonusDadoTrim = bonusDado.trim();
    if (bonusDadoTrim.isNotEmpty) {
      dadoFinalStr += ' + $bonusDadoTrim';
    }
    if (acaoArriscada == '2v_dobrar') {
      dadoFinalStr += ' - 1d6';
    } else if (acaoArriscada == '3v_triplicar') {
      dadoFinalStr += ' - 1d8';
    }

    final multDano = switch (acaoArriscada) {
      '2v_dobrar' => 2,
      '3v_triplicar' => 3,
      _ => 1,
    };

    var danoStr = (multDano > 1 ? '$multDano' : '') + dadoAtr;
    final armaDano = arma?.danoBase ?? '';
    if (armaDano.isNotEmpty) {
      danoStr += ' · Arma: $armaDano';
    }
    if (bonusFixo != 0) {
      final bonusAjustado = bonusFixo * multDano;
      danoStr +=
          bonusAjustado > 0 ? ' + $bonusAjustado' : ' - ${bonusAjustado.abs()}';
    }

    final multCrit = multDano * 2;
    var critStr = '$multCrit$dadoAtr';
    if (bonusFixo != 0) {
      final bonusCrit = bonusFixo * multCrit;
      if (bonusCrit > 0) {
        critStr += ' + $bonusCrit';
      }
    }

    return AttackResult(
      dadoAtaque: dadoFinalStr,
      dano: danoStr,
      critico: critStr,
    );
  }
}
