import 'package:app_flutter/features/characters/domain/character.dart';
import 'package:app_flutter/features/characters/domain/character_summary.dart';
import 'package:app_flutter/features/characters/domain/repositories/character_repository.dart';

/// Repositório em memória para os testes (doc §12: fakes fora do bundle).
class FakeCharacterRepository implements CharacterRepository {
  /// Fichas pré-carregadas.
  FakeCharacterRepository(List<Character> initial) {
    for (final character in initial) {
      _storage[character.id] = character;
    }
  }

  final Map<String, Character> _storage = {};

  @override
  Future<List<CharacterSummary>> list() async => _storage.values
      .map(
        (c) => CharacterSummary(
          id: c.id,
          nome: c.nome,
          nivel: c.nivel,
          conceito: c.conceito,
        ),
      )
      .toList(growable: false);

  @override
  Future<Character?> get(String id) async => _storage[id];

  @override
  Future<void> save(Character character) async =>
      _storage[character.id] = character;

  @override
  Future<void> delete(String id) async => _storage.remove(id);
}
