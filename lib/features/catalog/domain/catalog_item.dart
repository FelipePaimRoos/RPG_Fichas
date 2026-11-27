import 'package:app_flutter/shared/utils/parse.dart';

/// Item do catálogo genérico (itens operacionais, acessórios, munições…).
class CatalogItem {
  /// Cria um item de catálogo.
  const CatalogItem({
    required this.nome,
    this.espaco = 1,
    this.campos = const {},
  });

  /// Cria o item a partir de um mapa qualquer do JSON de catálogo.
  factory CatalogItem.fromJson(Map<String, dynamic> json) {
    final campos = <String, String>{};
    for (final entry in json.entries) {
      if (entry.key == 'nome' || entry.key == 'espaco') {
        continue;
      }
      final value = entry.value;
      if (value == null || (value is String && value.isEmpty)) {
        continue;
      }
      final texto = value is List ? value.join(', ') : '$value';
      campos[entry.key.replaceAll('_', ' ')] = texto;
    }
    return CatalogItem(
      nome: (json['nome'] ?? '') as String,
      espaco: _parseEspaco(json['espaco']),
      campos: campos,
    );
  }

  /// Parse tolerante do espaço: alguns itens guardam texto ("0,5").
  static double _parseEspaco(Object? value) =>
      tryParseDouble(value) ?? 1;

  /// Nome do item.
  final String nome;

  /// Espaço/carga ocupado.
  final double espaco;

  /// Campos adicionais do item, em ordem de inserção.
  final Map<String, String> campos;

  /// Descrição composta na forma do web: `campo: valor | campo: valor`.
  String get descricao =>
      campos.entries.map((e) => '${e.key}: ${e.value}').join(' | ');
}
