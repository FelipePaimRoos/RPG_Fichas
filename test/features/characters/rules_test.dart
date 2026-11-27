import 'package:app_flutter/features/catalog/catalog.dart';
import 'package:app_flutter/features/characters/data/mappers/export_envelope.dart';
import 'package:app_flutter/features/characters/domain/character.dart';
import 'package:app_flutter/features/characters/domain/rules/attributes.dart';
import 'package:app_flutter/features/characters/domain/rules/combat.dart';
import 'package:app_flutter/features/characters/domain/rules/derived.dart';
import 'package:app_flutter/features/characters/domain/rules/progression.dart';
import 'package:app_flutter/features/characters/domain/rules/skills.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AttributeRules', () {
    test('DT = 5 + valor + nível', () {
      expect(AttributeRules.dt(1, 1), 7);
      expect(AttributeRules.dt(4, 5), 14);
    });
  });

  group('SkillRules', () {
    test('dado por treinamento e ajudado', () {
      const destreinada = SkillState(nome: 'Luta', treinamento: 'Destreinado');
      const treinada = SkillState(nome: 'Luta', treinamento: 'Treinado');
      const expert = SkillState(nome: 'Luta', treinamento: 'Expert');
      expect(SkillRules.diceFor(destreinada), 'd4');
      expect(SkillRules.diceFor(treinada), 'd6');
      expect(SkillRules.diceFor(expert), 'd10');
      expect(SkillRules.diceFor(destreinada, ajudado: true), 'd6');
      expect(SkillRules.diceFor(expert, ajudado: true), 'd12');
    });

    test('limite de treinadas = 3 + Intelecto', () {
      expect(SkillRules.limiteTreinadas(1), 4);
      expect(SkillRules.limiteTreinadas(3), 6);
    });

    test('contador inclui regras de nível para veterano/expert', () {
      final texto = SkillRules.contadorTexto(
        nivel: 1,
        intelecto: 1,
        progressao: const [],
        pericias: SkillRules.defaultStates(),
      );
      expect(texto, contains('Treinado: 0/4'));
      expect(texto, contains('Veterano: disponível no nível 7'));
      expect(texto, contains('Expert: disponível no nível 14'));
    });

    test('problemas avisam, mas não lançam', () {
      final pericias = SkillRules.defaultStates()
        ..[0] = const SkillState(nome: 'Acrobacia', treinamento: 'Expert');
      final problemas = SkillRules.problemas(
        nivel: 1,
        intelecto: 1,
        progressao: const [],
        pericias: pericias,
      );
      expect(problemas, isNotEmpty);
      expect(
        problemas,
        contains('Veterano só é liberado a partir do nível 7.'),
      );
    });
  });

  group('computeDerived', () {
    final progressao = <ProgressionRow>[
      const ProgressionRow(nivel: 4, categoria: 'Atributo', recurso: '+1'),
      const ProgressionRow(nivel: 2, categoria: 'Habilidade', recurso: 'x'),
      const ProgressionRow(nivel: 7, categoria: 'Perícia & Proficiência', recurso: 'y'),
    ];

    test('valores automáticos de uma ficha nova', () {
      final character = Character(id: 'a');
      final derived = computeDerived(character, progressao);
      expect(derived.vidaMaxAuto, 11); // 10 + vigor(1)
      expect(derived.sanidadeMaxAuto, 11); // 10 + presença(1)
      expect(derived.defesaAuto, 6); // 5 + agilidade(1) + 0
      expect(derived.cargaMaxima, 5); // força(1) × 5
      expect(derived.pontosAtributoRestantes, 4);
    });

    test('carga em excesso penaliza o deslocamento', () {
      final character = Character(id: 'a')
        ..atributos[0] = const AttributeValue(
          nome: 'forca',
          valor: 1,
          debilitado: false,
        )
        ..inventario.add(const InventoryItem(nome: 'Ferro', espaco: 8));
      final derived = computeDerived(character, progressao);
      // Excesso = 8 - 5 = 3 → 1 par → -3 m / -2 quadrados.
      expect(derived.cargaAtual, 8);
      expect(derived.deslocamentoMetros, 6);
      expect(derived.deslocamentoQuadrados, 4);
    });

    test('agilidade debilitada reduz 3 m e 2 quadrados', () {
      final character = Character(id: 'a')
        ..atributos[1] = const AttributeValue(
          nome: 'agilidade',
          valor: 1,
          debilitado: true,
        );
      final derived = computeDerived(character, progressao);
      expect(derived.deslocamentoMetros, 6);
      expect(derived.deslocamentoQuadrados, 4);
    });
  });

  group('ProgressionRules', () {
    test('trilha paranormal de 5% a 99%', () {
      expect(ProgressionRules.niveisParanormal.first, 5);
      expect(ProgressionRules.niveisParanormal.last, 99);
      expect(ProgressionRules.niveisParanormal.length, 20);
    });
  });

  group('CombatRules', () {
    test('ataque básico soma dado de atributo e perícia', () {
      final result = CombatRules.calcular(
        valorAtributo: 2,
        nomePericia: 'Luta',
        treinamentoPericia: 'Treinado',
        bonusDado: '',
        bonusFixo: 0,
        acaoArriscada: 'normal',
      );
      expect(result.dadoAtaque, 'd6 + d6');
      expect(result.dano, 'd6');
      expect(result.critico, '2d6');
    });

    test('ação arriscada dobra dano e penaliza o dado', () {
      final result = CombatRules.calcular(
        valorAtributo: 2,
        nomePericia: '',
        treinamentoPericia: 'Destreinado',
        bonusDado: '',
        bonusFixo: 3,
        acaoArriscada: '2v_dobrar',
      );
      expect(result.dadoAtaque, 'd6 + d4 - 1d6');
      expect(result.dano, '2d6 + 6');
      expect(result.critico, '4d6 + 12');
    });
  });

  group('Character JSON', () {
    test('round-trip preserva campos', () {
      final character = Character(id: 'abc', nome: 'Ana', nivel: 3)
        ..conceito = 'Detetive'
        ..atributos[0] =
            const AttributeValue(nome: 'forca', valor: 3, debilitado: false)
        ..armas.add(
          const Weapon(
            nome: 'Pistola',
            proficiencia: 'Tática',
            danoBase: '1d6',
            critico: 'x3',
            tipoDano: 'Balístico',
          ),
        );
      final json = character.toJson();
      final restored = Character.fromJson('abc', json);
      expect(restored.nome, 'Ana');
      expect(restored.nivel, 3);
      expect(restored.conceito, 'Detetive');
      expect(restored.atributos.first.valor, 3);
      expect(restored.armas.first.danoBase, '1d6');
      expect(restored.toJson(), json);
    });

    test('campos desconhecidos são preservados (round-trip com web)', () {
      final json = <String, dynamic>{
        'nome': 'Bruno',
        'nivel': 2,
        'campo_futuro': {'a': 1},
      };
      final restored = Character.fromJson('x', json);
      expect(restored.extras['campo_futuro'], {'a': 1});
      expect(restored.toJson()['campo_futuro'], {'a': 1});
    });
  });

  group('ExportEnvelope', () {
    test('envelope na forma do web', () {
      final envelope = ExportEnvelope.build({'nome': 'Ana'});
      expect(envelope['aplicativo'], 'RPG_Fichas');
      expect(envelope['versao'], 1);
      expect(envelope['exportada_em'], isA<String>());
      expect((envelope['ficha'] as Map)['nome'], 'Ana');
    });

    test('extrai ficha de envelope e de ficha nua', () {
      final doEnvelope =
          ExportEnvelope.extractFichas({'ficha': {'nome': 'A'}});
      final nua = ExportEnvelope.extractFichas({'nome': 'B'});
      expect(doEnvelope.single['nome'], 'A');
      expect(nua.single['nome'], 'B');
    });
  });
}
