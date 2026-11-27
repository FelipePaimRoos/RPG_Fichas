import 'package:app_flutter/features/characters/domain/character.dart';
import 'package:app_flutter/shared/domain/dice.dart';

/// Definição de uma perícia base (`PERICIAS_BASE` do web).
class SkillDefinition {
  /// Cria a definição.
  const SkillDefinition({
    required this.nome,
    required this.atributo,
    required this.carga,
    required this.somenteTreinado,
    required this.categoria,
  });

  /// Nome da perícia.
  final String nome;

  /// Atributo associado (rótulo).
  final String atributo;

  /// Sofre penalidade de carga.
  final bool carga;

  /// Somente treinado (não pode ficar destreinado).
  final bool somenteTreinado;

  /// Categoria agrupadora exibida na seção.
  final String categoria;
}

/// As 26 perícias base, na ordem e categorias do web.
const List<SkillDefinition> periciasBase = [
  SkillDefinition(nome: 'Acrobacia', atributo: 'Agilidade', carga: true, somenteTreinado: false, categoria: '1. Perícias Físicas (Mobilidade e Operação)'),
  SkillDefinition(nome: 'Atletismo', atributo: 'Força', carga: false, somenteTreinado: false, categoria: '1. Perícias Físicas (Mobilidade e Operação)'),
  SkillDefinition(nome: 'Crime', atributo: 'Agilidade', carga: true, somenteTreinado: true, categoria: '1. Perícias Físicas (Mobilidade e Operação)'),
  SkillDefinition(nome: 'Furtividade', atributo: 'Agilidade', carga: true, somenteTreinado: false, categoria: '1. Perícias Físicas (Mobilidade e Operação)'),
  SkillDefinition(nome: 'Pilotagem', atributo: 'Agilidade', carga: false, somenteTreinado: true, categoria: '1. Perícias Físicas (Mobilidade e Operação)'),
  SkillDefinition(nome: 'Iniciativa', atributo: 'Agilidade', carga: false, somenteTreinado: false, categoria: '2. Perícias de Combate (Ofensiva e Prontidão)'),
  SkillDefinition(nome: 'Luta', atributo: 'Força', carga: false, somenteTreinado: false, categoria: '2. Perícias de Combate (Ofensiva e Prontidão)'),
  SkillDefinition(nome: 'Pontaria', atributo: 'Agilidade', carga: false, somenteTreinado: false, categoria: '2. Perícias de Combate (Ofensiva e Prontidão)'),
  SkillDefinition(nome: 'Fortitude', atributo: 'Vigor', carga: false, somenteTreinado: false, categoria: '3. Perícias de Resistência (Tríade Defensiva)'),
  SkillDefinition(nome: 'Reflexos', atributo: 'Agilidade', carga: true, somenteTreinado: false, categoria: '3. Perícias de Resistência (Tríade Defensiva)'),
  SkillDefinition(nome: 'Vontade', atributo: 'Presença', carga: false, somenteTreinado: false, categoria: '3. Perícias de Resistência (Tríade Defensiva)'),
  SkillDefinition(nome: 'Atualidades', atributo: 'Intelecto', carga: false, somenteTreinado: false, categoria: '4. Perícias de Investigação Analítica e Técnica'),
  SkillDefinition(nome: 'Artes', atributo: 'Intelecto', carga: false, somenteTreinado: false, categoria: '4. Perícias de Investigação Analítica e Técnica'),
  SkillDefinition(nome: 'Ciências', atributo: 'Intelecto', carga: false, somenteTreinado: true, categoria: '4. Perícias de Investigação Analítica e Técnica'),
  SkillDefinition(nome: 'Mecânica', atributo: 'Intelecto', carga: false, somenteTreinado: true, categoria: '4. Perícias de Investigação Analítica e Técnica'),
  SkillDefinition(nome: 'Medicina', atributo: 'Intelecto', carga: false, somenteTreinado: true, categoria: '4. Perícias de Investigação Analítica e Técnica'),
  SkillDefinition(nome: 'Ocultismo', atributo: 'Intelecto', carga: false, somenteTreinado: true, categoria: '4. Perícias de Investigação Analítica e Técnica'),
  SkillDefinition(nome: 'Procurar', atributo: 'Intelecto', carga: false, somenteTreinado: false, categoria: '4. Perícias de Investigação Analítica e Técnica'),
  SkillDefinition(nome: 'Religião', atributo: 'Intelecto', carga: false, somenteTreinado: false, categoria: '4. Perícias de Investigação Analítica e Técnica'),
  SkillDefinition(nome: 'Sobrevivência', atributo: 'Intelecto', carga: false, somenteTreinado: false, categoria: '4. Perícias de Investigação Analítica e Técnica'),
  SkillDefinition(nome: 'Tecnologia', atributo: 'Intelecto', carga: false, somenteTreinado: true, categoria: '4. Perícias de Investigação Analítica e Técnica'),
  SkillDefinition(nome: 'Adestramento', atributo: 'Presença', carga: false, somenteTreinado: false, categoria: '5. Perícias de Interação e Percepção Social'),
  SkillDefinition(nome: 'Diplomacia', atributo: 'Presença', carga: false, somenteTreinado: false, categoria: '5. Perícias de Interação e Percepção Social'),
  SkillDefinition(nome: 'Enganação', atributo: 'Presença', carga: false, somenteTreinado: false, categoria: '5. Perícias de Interação e Percepção Social'),
  SkillDefinition(nome: 'Intimidação', atributo: 'Presença', carga: false, somenteTreinado: false, categoria: '5. Perícias de Interação e Percepção Social'),
  SkillDefinition(nome: 'Intuição', atributo: 'Presença', carga: false, somenteTreinado: false, categoria: '5. Perícias de Interação e Percepção Social'),
  SkillDefinition(nome: 'Percepção', atributo: 'Presença', carga: false, somenteTreinado: false, categoria: '5. Perícias de Interação e Percepção Social'),
];

/// Regras de perícia: limites, contadores e dado resultante.
abstract final class SkillRules {
  /// Estado inicial das perícias para uma ficha nova.
  static List<SkillState> defaultStates() => periciasBase
      .map(
        (def) => SkillState(
          nome: def.nome,
          treinamento: 'Destreinado',
        ),
      )
      .toList(growable: false);

  /// Faces do dado por treinamento (`obterFacesDadoTreinamento`).
  static int facesForTraining(String treinamento) =>
      Dice.facesForTraining(treinamento);

  /// Dado exibido no badge, considerando "Ajudado" (`atualizarDadoPericia`).
  /// "Ajudado" é estado de tela e vem por parâmetro.
  static String diceFor(SkillState state, {bool ajudado = false}) {
    final base = Dice.facesForTraining(state.treinamento);
    final baseIndex = Dice.indexOf('d$base');
    final index = (baseIndex + (ajudado ? 1 : 0))
        .clamp(0, Dice.faces.length - 1);
    return Dice.faces[index];
  }

  /// Limite de perícias treinadas: `3 + Intelecto` (`limitePericiasTreinadas`).
  static int limiteTreinadas(int intelecto) => (3 + intelecto).clamp(0, 100);

  /// Limite de perícias veterana/expert: nº de linhas de
  /// "Perícia & Proficiência" até o nível (`limitePericiasAprimoradas`).
  static int limiteAprimoradas(
    int nivel,
    List<({int nivel, String categoria})> progressao,
  ) =>
      progressao
          .where((row) => row.categoria == 'Perícia & Proficiência')
          .where((row) => row.nivel <= nivel)
          .length;

  /// Contagem por grau (`contarPericiasPorGrau`).
  static ({int treinadas, int veteranas, int experts}) contar(
    List<SkillState> pericias,
  ) {
    var treinadas = 0;
    var veteranas = 0;
    var experts = 0;
    for (final pericia in pericias) {
      switch (pericia.treinamento) {
        case 'Treinado':
          treinadas += 1;
        case 'Veterano':
          treinadas += 1;
          veteranas += 1;
        case 'Expert':
          treinadas += 1;
          veteranas += 1;
          experts += 1;
      }
    }
    return (treinadas: treinadas, veteranas: veteranas, experts: experts);
  }

  /// Reconcilia as perícias quando a origem muda — réplica exata da regra
  /// do backend Python: perícia concedida pela origem fica Treinada com
  /// `automaticoOrigem`; quando não é mais concedida e estava marcada como
  /// automática de origem com Treinado, volta a Destreinada.
  static List<SkillState> reconciliarOrigem(
    List<SkillState> pericias,
    List<String> concedidas,
  ) {
    return [
      for (final pericia in pericias)
        if (concedidas.contains(pericia.nome))
          if (pericia.treinamento == 'Destreinado')
            pericia.copyWith(
              treinamento: 'Treinado',
              automaticoOrigem: true,
            )
          else
            pericia
        else if (pericia.automaticoOrigem &&
            pericia.treinamento == 'Treinado')
          pericia.copyWith(treinamento: 'Destreinado', automaticoOrigem: false)
        else
          pericia,
    ];
  }

  /// Avisos de limite (`problemasLimitePericias`) — avisos, nunca bloqueios.
  static List<String> problemas({
    required int nivel,
    required int intelecto,
    required List<({int nivel, String categoria})> progressao,
    required List<SkillState> pericias,
  }) {
    final limite = limiteTreinadas(intelecto);
    final limiteApr = limiteAprimoradas(nivel, progressao);
    final contagem = contar(pericias);
    final problemas = <String>[
      if (contagem.treinadas > limite)
        'O limite de perícias treinadas é $limite.',
      if (contagem.veteranas > limiteApr)
        'O limite de perícias Veteranas é $limiteApr.',
      if (contagem.experts > limiteApr)
        'O limite de perícias Expert é $limiteApr.',
      if (nivel < 7 && contagem.veteranas > 0)
        'Veterano só é liberado a partir do nível 7.',
      if (nivel < 14 && contagem.experts > 0)
        'Expert só é liberado a partir do nível 14.',
    ];
    return problemas;
  }

  /// Texto do contador de perícias (`atualizarContadorPericiasTreinadas`).
  static String contadorTexto({
    required int nivel,
    required int intelecto,
    required List<({int nivel, String categoria})> progressao,
    required List<SkillState> pericias,
  }) {
    final limite = limiteTreinadas(intelecto);
    final limiteApr = limiteAprimoradas(nivel, progressao);
    final contagem = contar(pericias);
    final vagasTreinadas =
        (limite - contagem.treinadas).clamp(0, limite);
    final vagasVeteranas =
        (limiteApr - contagem.veteranas).clamp(0, limiteApr);
    final vagasExpert =
        (limiteApr - contagem.experts).clamp(0, limiteApr);
    String plural(int n) => n == 1 ? '' : 's';
    final linhaTreinado =
        'Treinado: ${contagem.treinadas}/$limite ($vagasTreinadas não gasta${plural(vagasTreinadas)})';
    final linhaVeterano = nivel >= 7
        ? 'Veterano: ${contagem.veteranas}/$limiteApr ($vagasVeteranas não gasta${plural(vagasVeteranas)})'
        : 'Veterano: disponível no nível 7 (até $limiteApr perícias)';
    final linhaExpert = nivel >= 14
        ? 'Expert: ${contagem.experts}/$limiteApr ($vagasExpert não gasta${plural(vagasExpert)})'
        : 'Expert: disponível no nível 14 (até $limiteApr perícias)';
    return [linhaTreinado, linhaVeterano, linhaExpert].join('\n');
  }
}
