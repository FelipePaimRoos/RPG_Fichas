import 'dart:convert';

import 'package:app_flutter/app/providers.dart';
import 'package:app_flutter/features/characters/data/mappers/export_envelope.dart';
import 'package:app_flutter/features/characters/domain/character.dart';
import 'package:app_flutter/features/characters/domain/character_summary.dart';
import 'package:app_flutter/features/characters/domain/rules/derived.dart';
import 'package:app_flutter/shared/utils/id.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider do dashboard (lista de fichas).
final charactersProvider = AsyncNotifierProvider<CharactersViewModel,
    List<CharacterSummary>>(CharactersViewModel.new);

/// ViewModel do dashboard: lista, criar, excluir e exportar fichas.
class CharactersViewModel extends AsyncNotifier<List<CharacterSummary>> {
  @override
  Future<List<CharacterSummary>> build() =>
      ref.watch(characterRepositoryProvider).list();


  /// Cria uma ficha nova (nome opcional), abre os valores de vida/sanidade
  /// e retorna o id — o fluxo do web abre a ficha em seguida.
  Future<String> createCharacter(String nome) async {
    final repository = ref.watch(characterRepositoryProvider);
    final id = gerarId();
    final character = Character(id: id, nome: nome.trim());
    final progressao = await ref.watch(progressaoProvider.future);
    final comAuto = applyAutoStats(character, progressao);
    // O web abre a ficha nova com vida/sanidade cheias.
    comAuto
      ..vidaAtual = comAuto.vidaMax
      ..sanidadeAtual = comAuto.sanidadeMax;
    await repository.save(comAuto);
    await refresh();
    return id;
  }

  /// Exclui a ficha após confirmação (a confirmação é da tela).
  Future<void> deleteCharacter(String id) async {
    await ref.watch(characterRepositoryProvider).delete(id);
    await refresh();
  }

  /// Exporta a ficha como JSON (envelope do web). Retorna mensagem para o
  /// dashboard: caminho salvo ou null quando cancelado.
  Future<String?> exportCharacter(String id) async {
    final repository = ref.watch(characterRepositoryProvider);
    final character = await repository.get(id);
    if (character == null) {
      throw StateError('A ficha selecionada não foi encontrada neste dispositivo.');
    }
    final envelope = ExportEnvelope.build(character.toJson());
    final fileName = _safeFileName(character.nome);
    final savedPath = await ref
        .watch(fileGatewayProvider)
        .saveFile(fileName: '$fileName.json', content: jsonEncode(envelope));
    return savedPath;
  }

  /// Recarrega a lista.
  Future<void> refresh() async {
    ref.invalidate(charactersProvider);
  }
}

/// Remove caracteres inválidos para nome de arquivo (como o web faz).
String _safeFileName(String nome) {
  final base = nome.isEmpty ? 'ficha' : nome;
  final sanitized = base.replaceAll(RegExp(r'[<>:"/\\|?*]+'), '_');
  return sanitized.isEmpty ? 'ficha' : sanitized;
}
