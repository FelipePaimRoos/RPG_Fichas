import 'package:app_flutter/features/characters/data/drift/character_dao.dart';
import 'package:app_flutter/features/characters/data/drift/tables.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';


part 'character_database.g.dart';

/// Banco SQLite do app (Drift). Conexão multiplataforma via `drift_flutter`;
/// SQLite empacotado por `sqlite3_flutter_libs` (nada instalado no sistema).
@DriftDatabase(tables: [Characters], daos: [CharacterDao])
class CharacterDatabase extends _$CharacterDatabase {
  /// Cria o banco com o nome de arquivo fixo.
  CharacterDatabase() : super(openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          // Postura do doc §10.1: escritas íntegras e FKs ativas.
          await customStatement('PRAGMA foreign_keys = ON');
          await customStatement('PRAGMA busy_timeout = 5000');
          await customStatement('PRAGMA journal_mode = WAL');
        },
      );

  /// Abre a conexão (mantido aqui para o codegen e testes).
  static QueryExecutor openConnection() => driftDatabase(name: 'rpg_fichas');
}
