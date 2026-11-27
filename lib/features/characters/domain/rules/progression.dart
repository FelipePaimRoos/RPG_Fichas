/// Constantes e funções de progressão (níveis, trilha paranormal, slots).
abstract final class ProgressionRules {
  /// Níveis de exposição paranormal: 5% a 95% de 5 em 5, depois 99%.
  static const List<int> niveisParanormal = [
    5, 10, 15, 20, 25, 30, 35, 40, 45, 50, //
    55, 60, 65, 70, 75, 80, 85, 90, 95, 99,
  ];

  /// Sequência do dado paranormal: sobe a cada vitória, reseta na derrota.
  static const List<String> dadoParanormalSeq = ['d4', 'd6', 'd8', 'd12', 'd20'];

  /// Pontos de atributo disponíveis até o nível:
  /// `4 + linhas de categoria "Atributo"` (`atualizarCalculos`).
  static int pontosAtributoDisponiveis(
    int nivel,
    List<({int nivel, String categoria})> progressao,
  ) =>
      4 +
      progressao
          .where((row) => row.categoria == 'Atributo' && row.nivel <= nivel)
          .length;

  /// Slots de habilidades liberados até o nível (`recompensasHabilidadeAteNivel`).
  static int slotsHabilidade(
    int nivel,
    List<({int nivel, String categoria})> progressao,
  ) =>
      progressao
          .where((row) => row.categoria == 'Habilidade' && row.nivel <= nivel)
          .length;

  /// Limita o nível digitado a 1–20 (comportamento do web).
  static int clampNivel(int value) => value.clamp(1, 20);
}
