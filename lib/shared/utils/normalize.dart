/// Normalizações de texto compartilhadas entre as features.
extension NormalizeX on String {
  /// trim + lowercase, igual a `normalizarElementoPoder` do web.
  String get normalized => trim().toLowerCase();
}

/// Slug simples para IDs estáveis (pipeline de catálogo futuro).
String slugify(String text) => text
    .trim()
    .toLowerCase()
    .replaceAll(RegExp('[áàâã]'), 'a')
    .replaceAll(RegExp('[éèê]'), 'e')
    .replaceAll(RegExp('[íìî]'), 'i')
    .replaceAll(RegExp('[óòôõ]'), 'o')
    .replaceAll(RegExp('[úùû]'), 'u')
    .replaceAll(RegExp('ç'), 'c')
    .replaceAll(RegExp('[^a-z0-9]+'), '-')
    .replaceAll(RegExp(r'^-+|-+$'), '');
