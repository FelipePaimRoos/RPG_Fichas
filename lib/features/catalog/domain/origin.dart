/// Origem de personagem do catálogo (`json/origens.json`).
class Origin {
  /// Cria uma origem.
  const Origin({
    required this.nome,
    this.periciasTreinadas = const [],
    this.habilidadeNome = '',
    this.habilidadeDescricao = '',
  });

  /// Cria a origem a partir do JSON do catálogo.
  factory Origin.fromJson(Map<String, dynamic> json) {
    final habilidade = json['habilidade'];
    final pericias = (json['pericias_treinadas'] ?? const <dynamic>[]) as List;
    return Origin(
      nome: (json['nome'] ?? '') as String,
      periciasTreinadas: pericias.whereType<String>().toList(growable: false),
      habilidadeNome: habilidade is Map ? (habilidade['nome'] ?? '') as String : '',
      habilidadeDescricao:
          habilidade is Map ? (habilidade['descricao'] ?? '') as String : '',
    );
  }

  /// Nome da origem ("Acadêmico", "Militar"…).
  final String nome;

  /// Perícias treinadas automaticamente por esta origem.
  final List<String> periciasTreinadas;

  /// Nome da habilidade de origem.
  final String habilidadeNome;

  /// Descrição da habilidade de origem.
  final String habilidadeDescricao;
}
