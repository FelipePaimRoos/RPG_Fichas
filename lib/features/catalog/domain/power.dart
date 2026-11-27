import 'package:app_flutter/shared/domain/element.dart';

/// Poder paranormal de personagem (manual ou do catálogo).
class Power {
  /// Cria um poder.
  const Power({
    this.nome = '',
    this.elemento = '',
    this.prereq = '',
    this.custo = '',
    this.alcance = '',
    this.efeito = '',
    this.afinidade = '',
  });

  /// Cria o poder a partir do JSON do web (`poderes`).
  factory Power.fromJson(Map<String, dynamic> json) => Power(
        nome: (json['nome'] ?? '') as String,
        elemento: (json['elemento'] ?? '') as String,
        prereq: (json['prereq'] ?? '') as String,
        custo: (json['custo'] ?? '') as String,
        alcance: (json['alcance'] ?? '') as String,
        efeito: (json['efeito'] ?? '') as String,
        afinidade: (json['afinidade'] ?? '') as String,
      );

  /// Nome do poder.
  final String nome;

  /// Elemento (texto livre; pode ser "Variável (...)").
  final String elemento;

  /// Pré-requisito.
  final String prereq;

  /// Custo.
  final String custo;

  /// Alcance.
  final String alcance;

  /// Efeito/descrição.
  final String efeito;

  /// Bônus de afinidade.
  final String afinidade;

  /// Converte para o JSON do web.
  Map<String, dynamic> toJson() => {
        'nome': nome,
        'elemento': elemento,
        'prereq': prereq,
        'custo': custo,
        'alcance': alcance,
        'efeito': efeito,
        'afinidade': afinidade,
      };

  /// Cópia com campos alterados.
  Power copyWith({
    String? nome,
    String? elemento,
    String? prereq,
    String? custo,
    String? alcance,
    String? efeito,
    String? afinidade,
  }) =>
      Power(
        nome: nome ?? this.nome,
        elemento: elemento ?? this.elemento,
        prereq: prereq ?? this.prereq,
        custo: custo ?? this.custo,
        alcance: alcance ?? this.alcance,
        efeito: efeito ?? this.efeito,
        afinidade: afinidade ?? this.afinidade,
      );

  /// Elemento canônico do poder para colorir o card.
  ElementId? get element => normalizeElement(elemento);
}
