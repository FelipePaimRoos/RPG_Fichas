/// Habilidade de personagem (manual, de origem ou de perfil).
class Ability {
  /// Cria uma habilidade.
  const Ability({
    this.nome = '',
    this.classificacao = '',
    this.prereq = '',
    this.custo = '',
    this.alcance = '',
    this.efeito = '',
    this.automatico = false,
    this.nivelDesbloqueio,
  });

  /// Cria a habilidade a partir do JSON do web (`habilidades`).
  factory Ability.fromJson(Map<String, dynamic> json) => Ability(
        nome: (json['nome'] ?? '') as String,
        classificacao: (json['classificacao'] ?? '') as String,
        prereq: (json['prereq'] ?? '') as String,
        custo: (json['custo'] ?? '') as String,
        alcance: (json['alcance'] ?? '') as String,
        efeito: (json['efeito'] ?? '') as String,
        automatico: (json['automatico'] ?? false) as bool,
        nivelDesbloqueio: (json['nivel_desbloqueio'] as num?)?.toInt(),
      );

  /// Nome da habilidade.
  final String nome;

  /// Classificação (ex.: "Tier I", "Habilidade de Origem (X)").
  final String classificacao;

  /// Pré-requisitos.
  final String prereq;

  /// Custo.
  final String custo;

  /// Alcance.
  final String alcance;

  /// Efeito/descrição.
  final String efeito;

  /// Se é automática (concedida por origem/perfil/nível).
  final bool automatico;

  /// Nível em que foi desbloqueada (quando automática de arquétipo).
  final int? nivelDesbloqueio;

  /// Converte para o JSON do web.
  Map<String, dynamic> toJson() => {
        'nome': nome,
        'classificacao': classificacao,
        'prereq': prereq,
        'custo': custo,
        'alcance': alcance,
        'efeito': efeito,
        'automatico': automatico,
        'nivel_desbloqueio': nivelDesbloqueio,
      };

  /// Cópia com campos alterados.
  Ability copyWith({
    String? nome,
    String? classificacao,
    String? prereq,
    String? custo,
    String? alcance,
    String? efeito,
    bool? automatico,
    int? nivelDesbloqueio,
  }) =>
      Ability(
        nome: nome ?? this.nome,
        classificacao: classificacao ?? this.classificacao,
        prereq: prereq ?? this.prereq,
        custo: custo ?? this.custo,
        alcance: alcance ?? this.alcance,
        efeito: efeito ?? this.efeito,
        automatico: automatico ?? this.automatico,
        nivelDesbloqueio: nivelDesbloqueio ?? this.nivelDesbloqueio,
      );
}
