import 'package:app_flutter/features/characters/data/drift/character_database.dart';
import 'package:app_flutter/features/characters/data/drift/tables.dart';
import 'package:drift/drift.dart';


part 'character_dao.g.dart';

/// Acesso aos dados de fichas. Escritas passam por transação, nunca
/// deixando uma ficha pela metade (doc §10.1).
@DriftAccessor(tables: [Characters])
class CharacterDao extends DatabaseAccessor<CharacterDatabase>
    with _$CharacterDaoMixin {
  /// Cria o DAO.
  CharacterDao(super.attachedDatabase);


  /// Lista os resumos ordenados por nome (dashboard).
  Future<List<CharacterRow>> listSummaries() {
    return (select(characters)..orderBy([(c) => OrderingTerm.asc(c.nome)]))
        .get();
  }

  /// Carrega a linha de uma ficha; null quando não existe.
  Future<CharacterRow?> find(String id) {
    return (select(characters)..where((c) => c.id.equals(id)))
        .getSingleOrNull();
  }

  /// Insere ou atualiza a ficha (colunas de resumo + documento JSON).
  Future<void> upsert(CharactersCompanion entry) {
    return transaction(() async {
      await into(characters).insertOnConflictUpdate(entry);
    });
  }

  /// Remove a ficha.
  Future<void> remove(String id) {
    return transaction(() async {
      await (delete(characters)..where((c) => c.id.equals(id))).go();
    });
  }

  /// Marca a ficha como aberta (lista de recentes).
  Future<void> touch(String id) {
    return (update(characters)..where((c) => c.id.equals(id))).write(
      CharactersCompanion(lastOpenedAt: Value(DateTime.now())),
    );
  }
}
