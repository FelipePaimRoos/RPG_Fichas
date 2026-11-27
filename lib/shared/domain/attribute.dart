/// Os cinco atributos base do sistema, na ordem usada pela ficha.
enum AttributeId { forca, agilidade, intelecto, presenca, vigor }

/// Utilidades de exibição e serialização dos atributos.
extension AttributeIdX on AttributeId {
  /// Rótulo exibido na ficha, igual ao app web.
  String get label => switch (this) {
        AttributeId.forca => 'Força',
        AttributeId.agilidade => 'Agilidade',
        AttributeId.intelecto => 'Intelecto',
        AttributeId.presenca => 'Presença',
        AttributeId.vigor => 'Vigor',
      };

  /// Chave usada nos JSONs do app web (`atr_forca`, `deb_forca`…).
  String get jsonName => name;
}

/// Converte a chave do JSON em enum; desconhecido vira `forca` (não deve ocorrer).
AttributeId attributeIdFromJsonName(String name) =>
    AttributeId.values.where((a) => a.name == name).firstOrNull ??
    AttributeId.forca;
