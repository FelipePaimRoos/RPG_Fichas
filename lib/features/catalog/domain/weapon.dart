import 'package:app_flutter/shared/utils/parse.dart';

/// Arma — tanto item do catálogo quanto cópia na ficha do personagem.
/// Formato de JSON idêntico ao do app web/backend.
class Weapon {
  /// Cria uma arma.
  const Weapon({
    this.nome = '',
    this.proficiencia = '',
    this.tipo = '',
    this.empunhadura = '',
    this.danoBase = '',
    this.critico = '',
    this.tipoDano = '',
    this.alcance = '',
    this.espaco = 1,
    this.habilidades = '',
    this.modificacoes = const [],
    this.maldicoes = const [],
    this.personalizada = false,
  });

  /// Cria a arma a partir do JSON do web/backend (`armas`).
  factory Weapon.fromJson(Map<String, dynamic> json) => Weapon(
        nome: (json['nome'] ?? '') as String,
        proficiencia: (json['proficiencia'] ?? '') as String,
        tipo: (json['tipo'] ?? '') as String,
        empunhadura: (json['empunhadura'] ?? '') as String,
        danoBase: (json['dano_base'] ?? '') as String,
        critico: (json['critico'] ?? '') as String,
        tipoDano: (json['tipo_dano'] ?? '') as String,
        alcance: (json['alcance'] ?? '') as String,
        espaco: tryParseDouble(json['espaco']) ?? 1,
        habilidades: (json['habilidades'] ?? '') as String,
        modificacoes: stringList(json['modificacoes']),
        maldicoes: stringList(json['maldicoes']),
        personalizada: (json['personalizada'] ?? false) as bool,
      );



  /// Nome da arma.
  final String nome;

  /// Proficiência (Simples, Tática, Pesada…).
  final String proficiencia;

  /// Tipo (Corpo a Corpo, Disparo, Fogo…).
  final String tipo;

  /// Empunhadura (Leve, Uma Mão, Duas Mãos).
  final String empunhadura;

  /// Dano base (ex.: "1d6").
  final String danoBase;

  /// Crítico (ex.: "x2").
  final String critico;

  /// Tipo de dano (Corte, Balístico…).
  final String tipoDano;

  /// Alcance (ex.: "Curto (6m)").
  final String alcance;

  /// Espaço de carga ocupado.
  final double espaco;

  /// Habilidades/descrição da arma.
  final String habilidades;

  /// Nomes das modificações aplicadas (cópias; o catálogo é referência).
  final List<String> modificacoes;

  /// Nomes das maldições aplicadas.
  final List<String> maldicoes;

  /// Se foi criada manualmente nesta ficha (não veio do catálogo).
  final bool personalizada;

  /// Converte para o JSON do web.
  Map<String, dynamic> toJson() => {
        'nome': nome,
        'proficiencia': proficiencia,
        'tipo': tipo,
        'empunhadura': empunhadura,
        'dano_base': danoBase,
        'critico': critico,
        'tipo_dano': tipoDano,
        'alcance': alcance,
        'espaco': espaco,
        'habilidades': habilidades,
        'modificacoes': modificacoes,
        'maldicoes': maldicoes,
        'personalizada': personalizada,
      };

  /// Cópia com campos alterados.
  Weapon copyWith({
    String? nome,
    String? proficiencia,
    String? tipo,
    String? empunhadura,
    String? danoBase,
    String? critico,
    String? tipoDano,
    String? alcance,
    double? espaco,
    String? habilidades,
    List<String>? modificacoes,
    List<String>? maldicoes,
    bool? personalizada,
  }) =>
      Weapon(
        nome: nome ?? this.nome,
        proficiencia: proficiencia ?? this.proficiencia,
        tipo: tipo ?? this.tipo,
        empunhadura: empunhadura ?? this.empunhadura,
        danoBase: danoBase ?? this.danoBase,
        critico: critico ?? this.critico,
        tipoDano: tipoDano ?? this.tipoDano,
        alcance: alcance ?? this.alcance,
        espaco: espaco ?? this.espaco,
        habilidades: habilidades ?? this.habilidades,
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
