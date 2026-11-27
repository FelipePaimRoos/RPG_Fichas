import 'dart:math';

/// Gera IDs locais na mesma forma do app web (`gerarIdLocal`):
/// timestamp em base 36 + sufixo aleatório.
String gerarId() {
  final now = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
  final random = Random().nextInt(0xFFFFFFFF).toRadixString(36);
  return '$now$random';
}
