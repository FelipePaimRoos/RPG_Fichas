/// Valores derivados calculados da ficha (vida, sanidade, defesa, carga,
/// bloqueio, esquiva, deslocamento e pontos de atributo).
class DerivedStats {
  /// Cria o conjunto de valores derivados.
  const DerivedStats({
    required this.vidaMaxAuto,
    required this.sanidadeMaxAuto,
    required this.defesaAuto,
    required this.cargaMaxima,
    required this.cargaMaxEfetiva,
    required this.cargaAtual,
    required this.bloqueio,
    required this.esquiva,
    required this.deslocamentoMetros,
    required this.deslocamentoQuadrados,
    required this.pontosAtributoRestantes,
  });

  /// Vida máxima calculada (10 + Vigor).
  final int vidaMaxAuto;

  /// Sanidade máxima calculada (10 + Presença).
  final int sanidadeMaxAuto;

  /// Defesa calculada (5 + Agilidade + bônus de proteções).
  final int defesaAuto;

  /// Carga máxima (Força × 5).
  final int cargaMaxima;

  /// Carga máxima efetiva (metade se Força debilitada).
  final int cargaMaxEfetiva;

  /// Carga total ocupada.
  final double cargaAtual;

  /// Valor de bloqueio (média do dado de Fortitude + bônus).
  final int bloqueio;

  /// Valor de esquiva (defesa + média do dado de Reflexos + bônus).
  final int esquiva;

  /// Deslocamento efetivo em metros.
  final int deslocamentoMetros;

  /// Deslocamento efetivo em quadrados.
  final int deslocamentoQuadrados;

  /// Pontos de atributo não gastos (negativo = excedido).
  final int pontosAtributoRestantes;
}
