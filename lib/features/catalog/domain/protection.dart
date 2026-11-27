import 'package:app_flutter/shared/utils/parse.dart';

/// Proteção — tanto item do catálogo quanto cópia na ficha do personagem.
/// Formato de JSON idêntico ao do app web/backend.
class Protection {
  /// Cria uma proteção.
  const Protection({
    this.nome = '',
    this.tipo = 'Proteção',
    this.bonusDefesa = '',
    this.espaco = 1,
    this.resistenciaDano = '',
    this.penalidade = '',
    this.empunhadura = '',
    this.regrasEspeciais = '',
    this.descricao = '',
    this.modificacoes = const [],
    this.maldicoes = const [],
    this.personalizada = false,
  });

  /// Cria a proteção a partir do JSON do web/backend (`protecoes`).
  factory Protection.fromJson(Map<String, dynamic> json) => Protection(
        nome: (json['nome'] ?? '') as String,
        tipo: (json['tipo'] ?? 'Proteção') as String,
        bonusDefesa: (json['bonus_defesa'] ?? '') as String,
        espaco: tryParseDouble(json['espaco']) ?? 1,
        resistenciaDano: (json['resistencia_dano'] ?? '') as String,
        penalidade: (json['penalidade'] ?? '') as String,
        empunhadura: (json['empunhadura'] ?? '') as String,
        regrasEspeciais: (json['regras_especiais'] ?? '') as String,
        descricao: (json['descricao'] ?? '') as String,
        modificacoes: stringList(json['modificacoes']),
        maldicoes: stringList(json['maldicoes']),
        personalizada: (json['personalizada'] ?? false) as bool,
      );



  /// Nome da proteção.
  final String nome;

  /// Tipo ("Proteção", "Escudo"…).
  final String tipo;

  /// Bônus de defesa (ex.: "+2").
  final String bonusDefesa;

  /// Espaço de carga ocupado.
  final double espaco;

  /// Resistência a dano (ex.: "RD 1 contra Balístico").
  final String resistenciaDano;

  /// Penalidade imposta.
  final String penalidade;

  /// Empunhadura (para escudos).
  final String empunhadura;

  /// Regras especiais.
  final String regrasEspeciais;

  /// Descrição.
  final String descricao;

  /// Nomes das modificações aplicadas.
  final List<String> modificacoes;

  /// Nomes das maldições aplicadas.
  final List<String> maldicoes;

  /// Se foi criada manualmente nesta ficha.
  final bool personalizada;

  /// Converte para o JSON do web.
  Map<String, dynamic> toJson() => {
        'nome': nome,
        'tipo': tipo,
        'bonus_defesa': bonusDefesa,
        'espaco': espaco,
        'resistencia_dano': resistenciaDano,
        'penalidade': penalidade,
        'empunhadura': empunhadura,
        'regras_especiais': regrasEspeciais,
        'descricao': descricao,
        'modificacoes': modificacoes,
        'maldicoes': maldicoes,
        'personalizada': personalizada,
      };

  /// Cópia com campos alterados.
  Protection copyWith({
    String? nome,
    String? tipo,
    String? bonusDefesa,
    double? espaco,
    String? resistenciaDano,
    String? penalidade,
    String? empunhadura,
    String? regrasEspeciais,
    String? descricao,
    List<String>? modificacoes,
    List<String>? maldicoes,
    bool? personalizada,
  }) =>
      Protection(
        nome: nome ?? this.nome,
        tipo: tipo ?? this.tipo,
        bonusDefesa: bonusDefesa ?? this.bonusDefesa,
        espaco: espaco ?? this.espaco,
        resistenciaDano: resistenciaDano ?? this.resistenciaDano,
        penalidade: penalidade ?? this.penalidade,
        empunhadura: empunhadura ?? this.empunhadura,
        regrasEspeciais: regrasEspeciais ?? this.regrasEspeciais,
        descricao: descricao ?? this.descricao,
        modificacoes: modificacoes ?? this.modificacoes,
        maldicoes: maldicoes ?? this.maldicoes,
        personalizada: personalizada ?? this.personalizada,
      );

  /// Aceita lista já resolvida (o backend guarda strings JSON; aqui a
  /// ficha em memória usa listas).
  static List<String> stringList(Object? value) {
    if (value is List) {
      return value.whereType<String>().toList(growable: false);
    }
    return const [];
  }
}
