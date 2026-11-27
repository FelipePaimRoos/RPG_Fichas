/// Modificação de equipamento do catálogo (`json/modificacoes.json`).
class CatalogModification {
  /// Cria a modificação.
  const CatalogModification({
    required this.nome,
    required this.efeito,
    this.tipoArma = '',
    this.aplicacao = '',
    this.mecanicaDetalhada = '',
  });

  /// Cria a partir do JSON do catálogo.
  factory CatalogModification.fromJson(Map<String, dynamic> json) =>
      CatalogModification(
        nome: (json['nome'] ?? '') as String,
        efeito: (json['efeito'] ?? '') as String,
        tipoArma: (json['tipo_arma'] ?? '') as String,
        aplicacao: (json['aplicacao'] ?? '') as String,
        mecanicaDetalhada: (json['mecanica_detalhada'] ?? '') as String,
      );

  /// Nome.
  final String nome;

  /// Efeito resumido.
  final String efeito;

  /// Para armas: tipo de arma ao qual se aplica (informativo).
  final String tipoArma;

  /// Para proteções/itens: aplicação.
  final String aplicacao;

  /// Mecânica detalhada.
  final String mecanicaDetalhada;
}

/// Maldição de equipamento do catálogo (`json/maldicoes.json`).
class CatalogCurse {
  /// Cria a maldição.
  const CatalogCurse({
    required this.nome,
    required this.tipo,
    required this.efeito,
    this.elemento = '',
  });

  /// Cria a partir do JSON do catálogo.
  factory CatalogCurse.fromJson(Map<String, dynamic> json) => CatalogCurse(
        nome: (json['nome'] ?? '') as String,
        tipo: (json['tipo'] ?? '') as String,
        efeito: (json['efeito'] ?? '') as String,
        elemento: (json['elemento'] ?? '') as String,
      );

  /// Nome.
  final String nome;

  /// Tipo ("Maldição para Armas", "Maldição para Proteções").
  final String tipo;

  /// Efeito.
  final String efeito;

  /// Elemento associado, quando existe.
  final String elemento;
}
