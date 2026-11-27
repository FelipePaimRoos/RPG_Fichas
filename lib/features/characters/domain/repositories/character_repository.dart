import 'package:app_flutter/features/characters/domain/character.dart';
import 'package:app_flutter/features/characters/domain/character_summary.dart';

/// Porta de persistência de fichas. A tela nunca importa a implementação —
/// recebe pelo provider (hoje, arquivos JSON; depois, Drift/SQLite).
abstract interface class CharacterRepository {
  /// Lista os resumos para o dashboard.
  Future<List<CharacterSummary>> list();

  /// Carrega a ficha completa; null quando não existe.
  Future<Character?> get(String id);

  /// Cria ou atualiza a ficha.
  Future<void> save(Character character);

  /// Remove a ficha.
  Future<void> delete(String id);
}
