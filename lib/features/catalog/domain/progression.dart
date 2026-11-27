/// Linha da tabela de progressão de nível (`json/progressao_niveis.json`).
class ProgressionRow {
  /// Cria uma linha de progressão.
  const ProgressionRow({
    required this.nivel,
    required this.categoria,
    required this.recurso,
    this.tier,
  });

  /// Cria a linha a partir do JSON do catálogo.
  factory ProgressionRow.fromJson(Map<String, dynamic> json) => ProgressionRow(
        nivel: (json['nivel'] as num?)?.toInt() ?? 0,
        categoria: (json['categoria'] ?? '') as String,
        recurso: (json['recurso'] ?? '') as String,
        tier: json['tier'] as String?,
      );

  /// Nível a que a linha se refere (1–20).
  final int nivel;

  /// Categoria do recurso ("Habilidade", "Atributo", "Perícia & Proficiência"…).
  final String categoria;

  /// Descrição do recurso obtido.
  final String recurso;

  /// Tier da habilidade, quando aplicável.
  final String? tier;
}
