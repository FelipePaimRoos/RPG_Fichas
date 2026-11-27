
import 'package:app_flutter/features/catalog/data/asset_catalog_repository.dart';
import 'package:app_flutter/features/characters/domain/character.dart';
import 'package:app_flutter/features/characters/domain/rules/skills.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final repository = AssetCatalogRepository();

  group('Catálogos (assets)', () {
    test('armas carregam com proficiência e espaço', () async {
      final armas = await repository.loadArmas();
      expect(armas, isNotEmpty);
      for (final arma in armas) {
        expect(arma.nome, isNotEmpty);
        expect(arma.proficiencia, isNotEmpty);
        expect(arma.personalizada, isFalse);
        expect(arma.espaco, greaterThanOrEqualTo(0));
      }
    });

    test('proteções carregam com tipo e bônus', () async {
      final protecoes = await repository.loadProtecoes();
      expect(protecoes, isNotEmpty);
      for (final protecao in protecoes) {
        expect(protecao.nome, isNotEmpty);
        expect(protecao.tipo, isNotEmpty);
        expect(protecao.personalizada, isFalse);
      }
    });

    test('habilidades normalizam tier e defaults do backend', () async {
      final habilidades = await repository.loadHabilidades();
      expect(habilidades, isNotEmpty);
      for (final habilidade in habilidades) {
        expect(habilidade.classificacao, startsWith('Tier'));
        expect(habilidade.custo, isNotEmpty);
        expect(habilidade.alcance, isNotEmpty);
        expect(habilidade.prereq, isNotEmpty);
      }
    });

    test('rituais normalizam círculo', () async {
      final rituais = await repository.loadRituais();
      expect(rituais, isNotEmpty);
      for (final ritual in rituais) {
        expect(ritual.classificacao, contains('Círculo'));
      }
    });

    test('poderes carregam com elemento', () async {
      final poderes = await repository.loadPoderes();
      expect(poderes, isNotEmpty);
      for (final poder in poderes) {
        expect(poder.nome, isNotEmpty);
        expect(poder.elemento, isNotEmpty);
      }
    });

    test('itens por categoria carregam (e inválida falha)', () async {
      final operacionais = await repository.loadItens('operacionais');
      expect(operacionais, isNotEmpty);
      for (final item in operacionais) {
        expect(item.nome, isNotEmpty);
      }
      await expectLater(
        () => repository.loadItens('categoria-inexistente'),
        throwsA(isA<StateError>()),
      );
    });

    test('modificações e maldições são filtradas por tipo', () async {
      final modsArmas = await repository.loadModificacoesArmas();
      final modsProtecoes = await repository.loadModificacoesProtecoes();
      final maldsArmas = await repository.loadMaldicoesArmas();
      final maldsProtecoes = await repository.loadMaldicoesProtecoes();

      for (final mod in modsArmas) {
        expect(mod.tipoArma, isNotEmpty);
      }
      for (final mod in modsProtecoes) {
        expect(mod.aplicacao.toLowerCase(), contains('prote'));
      }
      for (final mald in maldsArmas) {
        expect(mald.tipo, contains('Arma'));
      }
      for (final mald in maldsProtecoes) {
        expect(mald.tipo, contains('Proteç'));
      }
      expect(modsArmas.isNotEmpty, isTrue);
      expect(maldsArmas.isNotEmpty, isTrue);
      expect(maldsProtecoes.isNotEmpty, isTrue);
    });

    test('origens/perfis/progressão carregam e validam', () async {
      final origens = await repository.loadOrigens();
      final perfis = await repository.loadPerfis();
      final progressao = await repository.loadProgressao();

      expect(origens, isNotEmpty);
      for (final origem in origens) {
        expect(origem.nome, isNotEmpty);
        expect(origem.habilidadeNome, isNotEmpty);
      }
      expect(perfis.map((p) => p.nome), containsAll(['Analista', 'Executor']));
      expect(progressao.length, 20);
      expect(progressao.first.nivel, 1);
      expect(progressao.last.nivel, 20);
    });
  });

  group('Regra de perícias da origem (portada do backend)', () {
    final base = SkillRules.defaultStates();
    int idx(String nome) => base.indexWhere((p) => p.nome == nome);

    test('perícia concedida e destreinada vira Treinada automática', () {
      final resultado = SkillRules.reconciliarOrigem(
        base,
        ['Ciências', 'Procurar'],
      );
      final ciencias = resultado[idx('Ciências')];
      expect(ciencias.treinamento, 'Treinado');
      expect(ciencias.automaticoOrigem, isTrue);
    });

    test('perícia concedida já treinada mantém o nível do usuário', () {
      final modificada = [...base]..[idx('Ciências')] =
          const SkillState(nome: 'Ciências', treinamento: 'Veterano');
      final resultado = SkillRules.reconciliarOrigem(
        modificada,
        ['Ciências'],
      );
      expect(resultado[idx('Ciências')].treinamento, 'Veterano');
    });

    test('perícia que deixou de ser concedida volta a Destreinada', () {
      final comOrigem = SkillRules.reconciliarOrigem(base, ['Ciências']);
      final semOrigem = SkillRules.reconciliarOrigem(comOrigem, []);
      final ciencias = semOrigem[idx('Ciências')];
      expect(ciencias.treinamento, 'Destreinado');
      expect(ciencias.automaticoOrigem, isFalse);
    });
  });
}
