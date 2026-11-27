/// Utilidades de dados (d4…d20) espelhando as regras do app web.
abstract final class Dice {
  /// Sequência de dados usada nos badges da ficha.
  static const List<String> faces = ['d4', 'd6', 'd8', 'd10', 'd12', 'd20'];

  /// Dado associado ao valor de um atributo:
  /// 1→d4, 2→d6, 3→d8, 4→d10, 5→d12, 6+→d20.
  static String diceForAttributeValue(int value) => switch (value) {
        1 => 'd4',
        2 => 'd6',
        3 => 'd8',
        4 => 'd10',
        5 => 'd12',
        >= 6 => 'd20',
        _ => 'd-none',
      };

  /// Faces do dado por nível de treinamento da perícia:
  /// Destreinado 4, Treinado 6, Veterano 8, Expert 10.
  static int facesForTraining(String treinamento) => switch (treinamento) {
        'Treinado' => 6,
        'Veterano' => 8,
        'Expert' => 10,
        _ => 4,
      };

  /// Índice do dado na sequência [faces]; desconhecidos viram d4.
  static int indexOf(String dice) {
    final index = faces.indexOf(dice);
    return index < 0 ? 0 : index;
  }

  /// Média matemática usada nos cálculos do web:
  /// `(faces / 2) + 0.5`, arredondada para baixo.
  static int averageRoll(int facesCount) => (facesCount / 2 + 0.5).floor();

  /// Sobe um passo na sequência de dados, limitado ao d20.
  static String stepUp(String dice) =>
      faces[(indexOf(dice) + 1).clamp(0, faces.length - 1)];
}
