import 'package:flutter/material.dart';

/// Os quatro elementos paranormais do sistema.
enum ElementId { sangue, morte, energia, conhecimento }

/// Cores e rótulos dos elementos, iguais às classes `.poder-*`/`.ritual-*`
/// do app web.
extension ElementIdX on ElementId {
  /// Rótulo exibido (capitalizado).
  String get label => switch (this) {
        ElementId.sangue => 'Sangue',
        ElementId.morte => 'Morte',
        ElementId.energia => 'Energia',
        ElementId.conhecimento => 'Conhecimento',
      };

  /// Cor do título e da borda esquerda dos cards.
  Color get color => switch (this) {
        ElementId.sangue => const Color(0xFFFF4D4D),
        ElementId.morte => const Color(0xFFFFFFFF),
        ElementId.energia => const Color(0xFFB052FF),
        ElementId.conhecimento => const Color(0xFFFFD700),
      };

  /// Cor primária aplicada ao tema quando a afinidade é escolhida
  /// (`mudarAfinidadeTema` no web).
  Color get primaryColor => switch (this) {
        ElementId.sangue => const Color(0xFFB83232),
        ElementId.morte => const Color(0xFFD0D0D0),
        ElementId.energia => const Color(0xFF9B51E0),
        ElementId.conhecimento => const Color(0xFFF2C94C),
      };
}

/// Normaliza o texto de elemento como o web faz (`normalizarElementoPoder`):
/// trim + lowercase. Retorna null quando não reconhecido.
ElementId? normalizeElement(String? raw) {
  final value = (raw ?? '').trim().toLowerCase();
  for (final element in ElementId.values) {
    if (element.name == value) {
      return element;
    }
  }
  return null;
}
