/// Envelope de exportação/importação — o mesmo formato do app web:
/// `{ aplicativo, versao, exportada_em, ficha }`.
abstract final class ExportEnvelope {
  /// Nome do aplicativo gravado no envelope.
  static const aplicativo = 'RPG_Fichas';

  /// Versão do formato do envelope.
  static const versao = 1;

  /// Constrói o envelope de exportação para uma ficha.
  static Map<String, dynamic> build(Map<String, dynamic> fichaJson) => {
        'aplicativo': aplicativo,
        'versao': versao,
        'exportada_em': DateTime.now().toUtc().toIso8601String(),
        'ficha': fichaJson,
      };

  /// Extrai o mapa da ficha de um arquivo importado. Aceita o envelope
  /// (novo ou do web), a ficha nua e a lista de fichas (backup múltiplo).
  static List<Map<String, dynamic>> extractFichas(Object? decoded) {
    if (decoded is List) {
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(_fichaOf)
          .toList(growable: false);
    }
    if (decoded is Map<String, dynamic>) {
      return [_fichaOf(decoded)];
    }
    return const [];
  }

  static Map<String, dynamic> _fichaOf(Map<String, dynamic> envelope) {
    final ficha = envelope['ficha'] ?? envelope['character'];
    if (ficha is Map<String, dynamic>) {
      return ficha;
    }
    return envelope;
  }
}
