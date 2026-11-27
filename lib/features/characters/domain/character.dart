import 'package:app_flutter/features/catalog/catalog.dart'
    show Ability, InventoryItem, Power, Protection, Ritual, Weapon;

import 'package:app_flutter/shared/domain/attribute.dart';

/// A ficha completa do personagem. O formato de JSON é o mesmo usado pelo
/// app web (`salvarNaApi`), para que fichas sejam intercambiáveis.
class Character {
  /// Cria uma ficha com valores padrão (igual a uma ficha nova do web).
  Character({
    required this.id,
    this.nome = '',
    this.jogador = '',
    this.nivel = 1,
    this.conceito = '',
    this.origem = '',
    this.perfil = '',
    this.marcadoresAnalise = 0,
    this.impeto = 0,
    this.vidaAtual = 10,
    this.vidaMax = 10,
    this.sanidadeAtual = 10,
    this.sanidadeMax = 10,
    this.defesaAtual = 10,
    this.bonusProtecoes = 0,
    this.deslocamentoBase = 9,
    this.cargaMaxima = 5,
    this.autoVida = true,
    this.autoSanidade = true,
    this.autoDefesa = true,
    this.resistencias = '',
    this.proficiencias = '',
    this.exposicaoParanormal = 5,
    this.afinidadeElemento = '',
    this.crisesContador = 0,
    this.dadoParanormalIdx = 0,
    this.descAparencia = '',
    this.descPersonalidade = '',
    this.descHistorico = '',
    this.descObjetivo = '',
    this.descAnotacoes = '',
    List<AttributeValue>? atributos,
    List<SkillState>? pericias,
    List<InventoryItem>? inventario,
    List<Weapon>? armas,
    List<Protection>? protecoes,
    List<Ability>? habilidades,
    List<Ritual>? rituais,
    List<Power>? poderes,
    this.extras = const {},
  })  : atributos = atributos ?? defaultAttributes(),
        pericias = pericias ?? defaultSkills(),
        inventario = inventario ?? [],
        armas = armas ?? [],
        protecoes = protecoes ?? [],
        habilidades = habilidades ?? [],
        rituais = rituais ?? [],
        poderes = poderes ?? [];

  /// Reconstrói a ficha a partir do JSON do web, tolerando campos ausentes.
  factory Character.fromJson(String id, Map<String, dynamic> json) {
    final knownKeys = <String>{
      'nome', 'jogador', 'nivel', 'conceito', 'origem', 'perfil',
      'marcadores_analise', 'impeto', 'vida_atual', 'vida_max',
      'sanidade_atual', 'sanidade_max', 'defesa_atual', 'bonus_protecoes',
      'deslocamento_base', 'carga_maxima', 'auto_vida', 'auto_sanidade',
      'auto_defesa', 'resistencias', 'proficiencias', 'exposicao_paranormal',
      'afinidade_elemento', 'crises_contador', 'dado_paranormal_idx',
      'desc_aparencia', 'desc_personalidade', 'desc_historico',
      'desc_objetivo', 'desc_anotacoes', 'atributos', 'pericias',
      'inventario', 'armas', 'protecoes', 'habilidades', 'rituais', 'poderes',
    };
    final extras = Map<String, dynamic>.from(json)
      ..removeWhere((key, _) => knownKeys.contains(key));

    return Character(
      id: id,
      nome: (json['nome'] ?? '') as String,
      jogador: (json['jogador'] ?? '') as String,
      nivel: (json['nivel'] as num?)?.toInt() ?? 1,
      conceito: (json['conceito'] ?? '') as String,
      origem: (json['origem'] ?? '') as String,
      perfil: (json['perfil'] ?? '') as String,
      marcadoresAnalise:
          (json['marcadores_analise'] as num?)?.toInt() ?? 0,
      impeto: (json['impeto'] as num?)?.toInt() ?? 0,
      vidaAtual: (json['vida_atual'] as num?)?.toInt() ?? 10,
      vidaMax: (json['vida_max'] as num?)?.toInt() ?? 10,
      sanidadeAtual: (json['sanidade_atual'] as num?)?.toInt() ?? 10,
      sanidadeMax: (json['sanidade_max'] as num?)?.toInt() ?? 10,
      defesaAtual: (json['defesa_atual'] as num?)?.toInt() ?? 10,
      bonusProtecoes: (json['bonus_protecoes'] as num?)?.toInt() ?? 0,
      deslocamentoBase: (json['deslocamento_base'] as num?)?.toInt() ?? 9,
      cargaMaxima: (json['carga_maxima'] as num?)?.toInt() ?? 5,
      autoVida: (json['auto_vida'] ?? true) as bool,
      autoSanidade: (json['auto_sanidade'] ?? true) as bool,
      autoDefesa: (json['auto_defesa'] ?? true) as bool,
      resistencias: (json['resistencias'] ?? '') as String,
      proficiencias: (json['proficiencias'] ?? '') as String,
      exposicaoParanormal:
          (json['exposicao_paranormal'] as num?)?.toInt() ?? 5,
      afinidadeElemento: (json['afinidade_elemento'] ?? '') as String,
      crisesContador: (json['crises_contador'] as num?)?.toInt() ?? 0,
      dadoParanormalIdx: (json['dado_paranormal_idx'] as num?)?.toInt() ?? 0,
      descAparencia: (json['desc_aparencia'] ?? '') as String,
      descPersonalidade: (json['desc_personalidade'] ?? '') as String,
      descHistorico: (json['desc_historico'] ?? '') as String,
      descObjetivo: (json['desc_objetivo'] ?? '') as String,
      descAnotacoes: (json['desc_anotacoes'] ?? '') as String,
      atributos: _parseList(json['atributos'])
          .map(AttributeValue.fromJson)
          .toList(),
      pericias: _parseList(json['pericias']).map(SkillState.fromJson).toList(),
      inventario:
          _parseList(json['inventario']).map(InventoryItem.fromJson).toList(),
      armas: _parseList(json['armas']).map(Weapon.fromJson).toList(),
      protecoes: _parseList(json['protecoes']).map(Protection.fromJson).toList(),
      habilidades:
          _parseList(json['habilidades']).map(Ability.fromJson).toList(),
      rituais: _parseList(json['rituais']).map(Ritual.fromJson).toList(),
      poderes: _parseList(json['poderes']).map(Power.fromJson).toList(),
      extras: extras,
    );
  }

  /// Identificador da ficha.
  final String id;

  /// Nome do personagem.
  String nome;

  /// Nome do jogador.
  String jogador;

  /// Nível (1–20).
  int nivel;

  /// Conceito.
  String conceito;

  /// Origem selecionada.
  String origem;

  /// Perfil selecionado.
  String perfil;

  /// Marcadores de análise (perfil Analista).
  int marcadoresAnalise;

  /// Espaços de Ímpeto (perfil Executor).
  int impeto;

  /// Vida atual.
  int vidaAtual;

  /// Vida máxima.
  int vidaMax;

  /// Sanidade atual.
  int sanidadeAtual;

  /// Sanidade máxima.
  int sanidadeMax;

  /// Defesa atual.
  int defesaAtual;

  /// Bônus de proteções.
  int bonusProtecoes;

  /// Deslocamento base em metros.
  int deslocamentoBase;

  /// Carga máxima (Força × 5; persistida como no web).
  int cargaMaxima;

  /// Cálculo automático da vida ligado.
  bool autoVida;

  /// Cálculo automático da sanidade ligado.
  bool autoSanidade;

  /// Cálculo automático da defesa ligado.
  bool autoDefesa;

  /// Texto livre de resistências.
  String resistencias;

  /// Texto livre de proficiências.
  String proficiencias;

  /// Exposição paranormal em % (5–99).
  int exposicaoParanormal;

  /// Elemento de afinidade ('', sangue, morte, energia, conhecimento).
  String afinidadeElemento;

  /// Contador de crises/testes paranormais.
  int crisesContador;

  /// Índice do dado paranormal na sequência d4→d20.
  int dadoParanormalIdx;

  /// Aparência.
  String descAparencia;

  /// Personalidade.
  String descPersonalidade;

  /// Histórico.
  String descHistorico;

  /// Objetivo.
  String descObjetivo;

  /// Anotações gerais.
  String descAnotacoes;

  /// Atributos base (5, sempre na ordem do sistema).
  List<AttributeValue> atributos;

  /// Estado das 26 perícias base.
  List<SkillState> pericias;

  /// Itens genéricos do inventário.
  List<InventoryItem> inventario;

  /// Armas da ficha (cópias do catálogo ou personalizadas).
  List<Weapon> armas;

  /// Proteções da ficha.
  List<Protection> protecoes;

  /// Habilidades (manuais + automáticas de origem/perfil).
  List<Ability> habilidades;

  /// Rituais.
  List<Ritual> rituais;

  /// Poderes paranormais.
  List<Power> poderes;

  /// Campos desconhecidos preservados para round-trip com o web.
  Map<String, dynamic> extras;

  /// Cópia profunda (listas novas; itens imutáveis podem ser compartilhados).
  Character copy() => Character(
        id: id,
        nome: nome,
        jogador: jogador,
        nivel: nivel,
        conceito: conceito,
        origem: origem,
        perfil: perfil,
        marcadoresAnalise: marcadoresAnalise,
        impeto: impeto,
        vidaAtual: vidaAtual,
        vidaMax: vidaMax,
        sanidadeAtual: sanidadeAtual,
        sanidadeMax: sanidadeMax,
        defesaAtual: defesaAtual,
        bonusProtecoes: bonusProtecoes,
        deslocamentoBase: deslocamentoBase,
        cargaMaxima: cargaMaxima,
        autoVida: autoVida,
        autoSanidade: autoSanidade,
        autoDefesa: autoDefesa,
        resistencias: resistencias,
        proficiencias: proficiencias,
        exposicaoParanormal: exposicaoParanormal,
        afinidadeElemento: afinidadeElemento,
        crisesContador: crisesContador,
        dadoParanormalIdx: dadoParanormalIdx,
        descAparencia: descAparencia,
        descPersonalidade: descPersonalidade,
        descHistorico: descHistorico,
        descObjetivo: descObjetivo,
        descAnotacoes: descAnotacoes,
        atributos: [...atributos],
        pericias: [...pericias],
        inventario: [...inventario],
        armas: [...armas],
        protecoes: [...protecoes],
        habilidades: [...habilidades],
        rituais: [...rituais],
        poderes: [...poderes],
        extras: {...extras},
      );

  /// Serializa na forma usada pelo app web.
  Map<String, dynamic> toJson() => {
        ...extras,
        'nome': nome,
        'jogador': jogador,
        'nivel': nivel,
        'conceito': conceito,
        'origem': origem,
        'perfil': perfil,
        'marcadores_analise': marcadoresAnalise,
        'impeto': impeto,
        'vida_atual': vidaAtual,
        'vida_max': vidaMax,
        'sanidade_atual': sanidadeAtual,
        'sanidade_max': sanidadeMax,
        'defesa_atual': defesaAtual,
        'bonus_protecoes': bonusProtecoes,
        'deslocamento_base': deslocamentoBase,
        'carga_maxima': cargaMaxima,
        'auto_vida': autoVida,
        'auto_sanidade': autoSanidade,
        'auto_defesa': autoDefesa,
        'resistencias': resistencias,
        'proficiencias': proficiencias,
        'exposicao_paranormal': exposicaoParanormal,
        'afinidade_elemento': afinidadeElemento,
        'crises_contador': crisesContador,
        'dado_paranormal_idx': dadoParanormalIdx,
        'desc_aparencia': descAparencia,
        'desc_personalidade': descPersonalidade,
        'desc_historico': descHistorico,
        'desc_objetivo': descObjetivo,
        'desc_anotacoes': descAnotacoes,
        'atributos': atributos.map((a) => a.toJson()).toList(),
        'pericias': pericias.map((p) => p.toJson()).toList(),
        'inventario': inventario.map((i) => i.toJson()).toList(),
        'armas': armas.map((a) => a.toJson()).toList(),
        'protecoes': protecoes.map((p) => p.toJson()).toList(),
        'habilidades': habilidades.map((h) => h.toJson()).toList(),
        'rituais': rituais.map((r) => r.toJson()).toList(),
        'poderes': poderes.map((p) => p.toJson()).toList(),
      };

  static List<Map<String, dynamic>> _parseList(Object? value) =>
      (value is List ? value : const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .toList(growable: false);

  /// Atributos padrão (todos com valor 1, não debilitados).
  static List<AttributeValue> defaultAttributes() => AttributeId.values
      .map(
        (id) => AttributeValue(
          nome: id.jsonName,
          valor: 1,
          debilitado: false,
        ),
      )
      .toList(growable: false);

  /// Perícias padrão (todas destreinadas, bônus 0).
  static List<SkillState> defaultSkills() => List.generate(
        26,
        (index) => const SkillState(nome: '', treinamento: 'Destreinado'),
      );
}

/// Valor e estado de um atributo (linha do JSON `atributos`).
class AttributeValue {
  /// Cria o valor de atributo.
  const AttributeValue({
    required this.nome,
    required this.valor,
    required this.debilitado,
  });

  /// Cria a partir do JSON do web.
  factory AttributeValue.fromJson(Map<String, dynamic> json) => AttributeValue(
        nome: (json['nome'] ?? '') as String,
        valor: (json['valor'] as num?)?.toInt() ?? 1,
        debilitado: (json['debilitado'] ?? false) as bool,
      );

  /// Chave do atributo (`forca`, `agilidade`…).
  final String nome;

  /// Valor (1–…).
  final int valor;

  /// Se está debilitado por ferimento.
  final bool debilitado;

  /// Converte para o JSON do web.
  Map<String, dynamic> toJson() =>
      {'nome': nome, 'valor': valor, 'debilitado': debilitado};
}

/// Estado de uma perícia da ficha.
class SkillState {
  /// Cria o estado de perícia.
  const SkillState({
    required this.nome,
    required this.treinamento,
    this.bonus = 0,
    this.automaticoOrigem = false,
  });

  /// Cria a partir do JSON do web.
  factory SkillState.fromJson(Map<String, dynamic> json) => SkillState(
        nome: (json['nome'] ?? '') as String,
        treinamento: (json['treinamento'] ?? 'Destreinado') as String,
        bonus: (json['bonus'] as num?)?.toInt() ?? 0,
        automaticoOrigem: (json['automatico_origem'] ?? false) as bool,
      );

  /// Nome da perícia.
  final String nome;

  /// Nível de treinamento (Destreinado/Treinado/Veterano/Expert).
  final String treinamento;

  /// Bônus extra.
  final int bonus;

  /// Se foi concedida automaticamente pela origem.
  final bool automaticoOrigem;

  /// Converte para o JSON do web.
  Map<String, dynamic> toJson() => {
        'nome': nome,
        'treinamento': treinamento,
        'bonus': bonus,
        'automatico_origem': automaticoOrigem,
      };

  /// Cópia com campos alterados.
  SkillState copyWith({
    String? nome,
    String? treinamento,
    int? bonus,
    bool? automaticoOrigem,
  }) =>
      SkillState(
        nome: nome ?? this.nome,
        treinamento: treinamento ?? this.treinamento,
        bonus: bonus ?? this.bonus,
        automaticoOrigem: automaticoOrigem ?? this.automaticoOrigem,
      );
}
