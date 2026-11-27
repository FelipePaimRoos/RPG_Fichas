import 'package:app_flutter/shared/domain/element.dart';

/// Ritual de personagem (manual ou do catálogo).
class Ritual {
  /// Cria um ritual.
  const Ritual({
    this.nome = '',
    this.classificacao = '',
    this.prereq = '',
    this.custo = '',
    this.alcance = '',
    this.efeito = '',
    this.elemento = '',
    this.execucao = '',
    this.automatico = false,
    this.nivelDesbloqueio,
  });

  /// Cria o ritual a partir do JSON do web (`rituais`).
  factory Ritual.fromJson(Map<String, dynamic> json) => Ritual(
        nome: (json['nome'] ?? '') as String,
        classificacao: (json['classificacao'] ?? '') as String,
        prereq: (json['prereq'] ?? '') as String,
        custo: (json['custo'] ?? '') as String,
        alcance: (json['alcance'] ?? '') as String,
        efeito: (json['efeito'] ?? '') as String,
        elemento: (json['elemento'] ?? '') as String,
        execucao: (json['execucao'] ?? '') as String,
        automatico: (json['automatico'] ?? false) as bool,
        nivelDesbloqueio: (json['nivel_desbloqueio'] as num?)?.toInt(),
      );

  /// Nome do ritual.
  final String nome;

  /// Círculo (ex.: "1° Círculo").
  final String classificacao;

  /// Pré-requisitos.
  final String prereq;

  /// Custo (SAN).
  final String custo;

  /// Alcance.
  final String alcance;

  /// Efeito/descrição.
  final String efeito;

  /// Elemento declarado, quando conhecido.
  final String elemento;

  /// Execução (Padrão, Completa, Livre, Reação, Cena).
  final String execucao;

  /// Se é automático.
  final bool automatico;

  /// Nível de desbloqueio, quando automático.
  final int? nivelDesbloqueio;

  /// Converte para o JSON do web.
  Map<String, dynamic> toJson() => {
        'nome': nome,
        'classificacao': classificacao,
        'prereq': prereq,
        'custo': custo,
        'alcance': alcance,
        'efeito': efeito,
        'elemento': elemento,
        'execucao': execucao,
        'automatico': automatico,
        'nivel_desbloqueio': nivelDesbloqueio,
      };

  /// Cópia com campos alterados.
  Ritual copyWith({
    String? nome,
    String? classificacao,
    String? prereq,
    String? custo,
    String? alcance,
    String? efeito,
    String? elemento,
    String? execucao,
    bool? automatico,
    int? nivelDesbloqueio,
  }) =>
      Ritual(
        nome: nome ?? this.nome,
        classificacao: classificacao ?? this.classificacao,
        prereq: prereq ?? this.prereq,
        custo: custo ?? this.custo,
        alcance: alcance ?? this.alcance,
        efeito: efeito ?? this.efeito,
        elemento: elemento ?? this.elemento,
        execucao: execucao ?? this.execucao,
        automatico: automatico ?? this.automatico,
        nivelDesbloqueio: nivelDesbloqueio ?? this.nivelDesbloqueio,
      );

  /// Elemento canônico detectado (`detectarElementoRitual` do web):
  /// 1. campo próprio; 2. "Elemento: X" dentro do efeito; 3. palavras-chave.
  ElementId? detectarElemento() {
    final armazenado = normalizeElement(elemento);
    if (armazenado != null) {
      return armazenado;
    }
    final efeitoLower = efeito.toLowerCase();
    final declarado = RegExp(
      r'elemento:\s*(sangue|morte|energia|conhecimento)',
    ).firstMatch(efeitoLower);
    if (declarado != null) {
      return normalizeElement(declarado.group(1));
    }
    final texto = '$nome $classificacao $efeitoLower';
    const mapa = <ElementId, List<String>>{
      ElementId.sangue: [
        'sangue',
        'hemoglobina',
        'hemat',
        'vitílico',
        'vitilico',
      ],
      ElementId.morte: [
        'morte',
        'mortal',
        'cinzas',
        'cadáver',
        'cadaver',
        'necro',
        'óssua',
        'ossua',
      ],
      ElementId.energia: [
        'energia',
        'elétric',
        'eletric',
        'chama',
        'fogo',
        'raio',
        'tempestade',
      ],
      ElementId.conhecimento: [
        'conhecimento',
        'mental',
        'mente',
        'ilusão',
        'ilusao',
        'percepção',
        'percepcao',
        'intelecto',
      ],
    };
    for (final entry in mapa.entries) {
      if (entry.value.any(texto.contains)) {
        return entry.key;
      }
    }
    return null;
  }
}
