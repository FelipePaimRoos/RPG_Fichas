import 'dart:convert';
import 'package:app_flutter/features/characters/data/drift/character_dao.dart';
import 'package:app_flutter/features/characters/data/drift/character_database.dart';
import 'package:app_flutter/features/characters/domain/character.dart';
import 'package:app_flutter/features/characters/domain/character_summary.dart';
import 'package:app_flutter/features/characters/domain/repositories/character_repository.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';



/// Implementação do repositório sobre SQLite (Drift). Substitui a
/// persistência do backend Python (SQLAlchemy) com o mesmo contrato.
class DriftCharacterRepository implements CharacterRepository {
  /// Cria o repositório sobre o banco informado.
  DriftCharacterRepository(this._dao);

  final CharacterDao _dao;

  @override
  Future<List<CharacterSummary>> list() async {
    final rows = await _dao.listSummaries();
    return rows
        .map(
          (row) => CharacterSummary(
            id: row.id,
            nome: row.nome,
            nivel: row.nivel,
            conceito: row.conceito ?? '',
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<Character?> get(String id) async {
    final row = await _dao.find(id);
    if (row == null) {
      return null;
    }
    final decoded = jsonDecode(row.data);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }
    return Character.fromJson(id, decoded);
  }

  @override
  Future<void> save(Character character) async {
    final data = jsonEncode(character.toJson());
    final now = DateTime.now();
    final existing = await _dao.find(character.id);
    await _dao.upsert(
      CharactersCompanion.insert(
        id: character.id,
        nome: character.nome,
        data: data,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
        nivel: Value(character.nivel),
        conceito:
            Value(character.conceito.isEmpty ? null : character.conceito),
        origem: Value(character.origem.isEmpty ? null : character.origem),
        perfil: Value(character.perfil.isEmpty ? null : character.perfil),
        characterSchemaVersion: const Value(1),
        lastOpenedAt: Value(existing?.lastOpenedAt),
        checksum: Value(sha256.convert(utf8.encode(data)).toString()),
      ),
    );
  }

  @override
  Future<void> delete(String id) => _dao.remove(id);

  /// Registra o momento de abertura (lista de recentes).
  Future<void> markOpened(String id) => _dao.touch(id);
}
