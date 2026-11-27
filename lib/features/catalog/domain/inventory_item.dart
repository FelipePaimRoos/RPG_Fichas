/// Item genérico do inventário da ficha.
class InventoryItem {
  /// Cria um item de inventário.
  const InventoryItem({
    this.nome = '',
    this.espaco = 1,
    this.descricao = '',
  });

  /// Cria o item a partir do JSON do web (`inventario`).
  factory InventoryItem.fromJson(Map<String, dynamic> json) => InventoryItem(
        nome: (json['nome'] ?? '') as String,
        espaco: (json['espaco'] as num?)?.toDouble() ?? 1,
        descricao: (json['descricao'] ?? '') as String,
      );

  /// Nome do item.
  final String nome;

  /// Espaço/carga ocupado.
  final double espaco;

  /// Descrição.
  final String descricao;

  /// Converte para o JSON do web.
  Map<String, dynamic> toJson() => {
        'nome': nome,
        'espaco': espaco,
        'descricao': descricao,
      };

  /// Cópia com campos alterados.
  InventoryItem copyWith({String? nome, double? espaco, String? descricao}) =>
      InventoryItem(
        nome: nome ?? this.nome,
        espaco: espaco ?? this.espaco,
        descricao: descricao ?? this.descricao,
      );
}
