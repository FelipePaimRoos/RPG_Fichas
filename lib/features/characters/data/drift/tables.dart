import 'package:drift/drift.dart';

@DataClassName('CharacterRow')

/// Tabela de fichas — modelo híbrido do doc §10.1: colunas de resumo para
/// listar/filtrar sem desserializar + documento JSON completo em `data`.
class Characters extends Table {
  /// Identificador estável da ficha (gerado no cliente).
  TextColumn get id => text()();

  /// Colunas de resumo do dashboard.
  TextColumn get nome => text()();
  IntColumn get nivel => integer().withDefault(const Constant(1))();
  TextColumn get conceito => text().nullable()();
  TextColumn get origem => text().nullable()();
  TextColumn get perfil => text().nullable()();

  /// Versão do documento Character (não do schema do banco).
  IntColumn get characterSchemaVersion => integer().withDefault(const Constant(1))();

  /// Character completo em JSON (formato do web).
  TextColumn get data => text()();

  /// Metadados.
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get lastOpenedAt => dateTime().nullable()();
  TextColumn get catalogVersion => text().nullable()();
  TextColumn get checksum => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
