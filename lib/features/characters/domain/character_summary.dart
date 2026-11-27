/// Resumo de ficha para o dashboard, sem desserializar o documento completo
/// (quando o Drift entrar, vem das colunas indexadas).
class CharacterSummary {
  /// Cria o resumo.
  const CharacterSummary({
    required this.id,
    required this.nome,
    required this.nivel,
    required this.conceito,
  });

  /// Identificador da ficha.
  final String id;

  /// Nome do personagem.
  final String nome;

  /// Nível.
  final int nivel;

  /// Conceito.
  final String conceito;

  /// Nome exibido no dashboard ("Sem nome" quando vazio).
  String get displayName => nome.isEmpty ? 'Sem nome' : nome;

  /// Linha de detalhes do card: `Nível X · conceito`.
  String get detailsLine {
    final conceitoPart = conceito.isEmpty ? '' : ' · $conceito';
    return 'Nível $nivel$conceitoPart';
  }
}
