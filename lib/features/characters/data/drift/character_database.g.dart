// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character_database.dart';

// ignore_for_file: type=lint
class $CharactersTable extends Characters
    with TableInfo<$CharactersTable, CharacterRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CharactersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nivelMeta = const VerificationMeta('nivel');
  @override
  late final GeneratedColumn<int> nivel = GeneratedColumn<int>(
    'nivel',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _conceitoMeta = const VerificationMeta(
    'conceito',
  );
  @override
  late final GeneratedColumn<String> conceito = GeneratedColumn<String>(
    'conceito',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _origemMeta = const VerificationMeta('origem');
  @override
  late final GeneratedColumn<String> origem = GeneratedColumn<String>(
    'origem',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _perfilMeta = const VerificationMeta('perfil');
  @override
  late final GeneratedColumn<String> perfil = GeneratedColumn<String>(
    'perfil',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _characterSchemaVersionMeta =
      const VerificationMeta('characterSchemaVersion');
  @override
  late final GeneratedColumn<int> characterSchemaVersion = GeneratedColumn<int>(
    'character_schema_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastOpenedAtMeta = const VerificationMeta(
    'lastOpenedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastOpenedAt = GeneratedColumn<DateTime>(
    'last_opened_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _catalogVersionMeta = const VerificationMeta(
    'catalogVersion',
  );
  @override
  late final GeneratedColumn<String> catalogVersion = GeneratedColumn<String>(
    'catalog_version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _checksumMeta = const VerificationMeta(
    'checksum',
  );
  @override
  late final GeneratedColumn<String> checksum = GeneratedColumn<String>(
    'checksum',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nome,
    nivel,
    conceito,
    origem,
    perfil,
    characterSchemaVersion,
    data,
    createdAt,
    updatedAt,
    lastOpenedAt,
    catalogVersion,
    checksum,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'characters';
  @override
  VerificationContext validateIntegrity(
    Insertable<CharacterRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('nivel')) {
      context.handle(
        _nivelMeta,
        nivel.isAcceptableOrUnknown(data['nivel']!, _nivelMeta),
      );
    }
    if (data.containsKey('conceito')) {
      context.handle(
        _conceitoMeta,
        conceito.isAcceptableOrUnknown(data['conceito']!, _conceitoMeta),
      );
    }
    if (data.containsKey('origem')) {
      context.handle(
        _origemMeta,
        origem.isAcceptableOrUnknown(data['origem']!, _origemMeta),
      );
    }
    if (data.containsKey('perfil')) {
      context.handle(
        _perfilMeta,
        perfil.isAcceptableOrUnknown(data['perfil']!, _perfilMeta),
      );
    }
    if (data.containsKey('character_schema_version')) {
      context.handle(
        _characterSchemaVersionMeta,
        characterSchemaVersion.isAcceptableOrUnknown(
          data['character_schema_version']!,
          _characterSchemaVersionMeta,
        ),
      );
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('last_opened_at')) {
      context.handle(
        _lastOpenedAtMeta,
        lastOpenedAt.isAcceptableOrUnknown(
          data['last_opened_at']!,
          _lastOpenedAtMeta,
        ),
      );
    }
    if (data.containsKey('catalog_version')) {
      context.handle(
        _catalogVersionMeta,
        catalogVersion.isAcceptableOrUnknown(
          data['catalog_version']!,
          _catalogVersionMeta,
        ),
      );
    }
    if (data.containsKey('checksum')) {
      context.handle(
        _checksumMeta,
        checksum.isAcceptableOrUnknown(data['checksum']!, _checksumMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CharacterRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CharacterRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      nivel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}nivel'],
      )!,
      conceito: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conceito'],
      ),
      origem: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origem'],
      ),
      perfil: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}perfil'],
      ),
      characterSchemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}character_schema_version'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      lastOpenedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_opened_at'],
      ),
      catalogVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catalog_version'],
      ),
      checksum: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}checksum'],
      ),
    );
  }

  @override
  $CharactersTable createAlias(String alias) {
    return $CharactersTable(attachedDatabase, alias);
  }
}

class CharacterRow extends DataClass implements Insertable<CharacterRow> {
  /// Identificador estável da ficha (gerado no cliente).
  final String id;

  /// Colunas de resumo do dashboard.
  final String nome;
  final int nivel;
  final String? conceito;
  final String? origem;
  final String? perfil;

  /// Versão do documento Character (não do schema do banco).
  final int characterSchemaVersion;

  /// Character completo em JSON (formato do web).
  final String data;

  /// Metadados.
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastOpenedAt;
  final String? catalogVersion;
  final String? checksum;
  const CharacterRow({
    required this.id,
    required this.nome,
    required this.nivel,
    this.conceito,
    this.origem,
    this.perfil,
    required this.characterSchemaVersion,
    required this.data,
    required this.createdAt,
    required this.updatedAt,
    this.lastOpenedAt,
    this.catalogVersion,
    this.checksum,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['nome'] = Variable<String>(nome);
    map['nivel'] = Variable<int>(nivel);
    if (!nullToAbsent || conceito != null) {
      map['conceito'] = Variable<String>(conceito);
    }
    if (!nullToAbsent || origem != null) {
      map['origem'] = Variable<String>(origem);
    }
    if (!nullToAbsent || perfil != null) {
      map['perfil'] = Variable<String>(perfil);
    }
    map['character_schema_version'] = Variable<int>(characterSchemaVersion);
    map['data'] = Variable<String>(data);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || lastOpenedAt != null) {
      map['last_opened_at'] = Variable<DateTime>(lastOpenedAt);
    }
    if (!nullToAbsent || catalogVersion != null) {
      map['catalog_version'] = Variable<String>(catalogVersion);
    }
    if (!nullToAbsent || checksum != null) {
      map['checksum'] = Variable<String>(checksum);
    }
    return map;
  }

  CharactersCompanion toCompanion(bool nullToAbsent) {
    return CharactersCompanion(
      id: Value(id),
      nome: Value(nome),
      nivel: Value(nivel),
      conceito: conceito == null && nullToAbsent
          ? const Value.absent()
          : Value(conceito),
      origem: origem == null && nullToAbsent
          ? const Value.absent()
          : Value(origem),
      perfil: perfil == null && nullToAbsent
          ? const Value.absent()
          : Value(perfil),
      characterSchemaVersion: Value(characterSchemaVersion),
      data: Value(data),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastOpenedAt: lastOpenedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastOpenedAt),
      catalogVersion: catalogVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(catalogVersion),
      checksum: checksum == null && nullToAbsent
          ? const Value.absent()
          : Value(checksum),
    );
  }

  factory CharacterRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CharacterRow(
      id: serializer.fromJson<String>(json['id']),
      nome: serializer.fromJson<String>(json['nome']),
      nivel: serializer.fromJson<int>(json['nivel']),
      conceito: serializer.fromJson<String?>(json['conceito']),
      origem: serializer.fromJson<String?>(json['origem']),
      perfil: serializer.fromJson<String?>(json['perfil']),
      characterSchemaVersion: serializer.fromJson<int>(
        json['characterSchemaVersion'],
      ),
      data: serializer.fromJson<String>(json['data']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      lastOpenedAt: serializer.fromJson<DateTime?>(json['lastOpenedAt']),
      catalogVersion: serializer.fromJson<String?>(json['catalogVersion']),
      checksum: serializer.fromJson<String?>(json['checksum']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nome': serializer.toJson<String>(nome),
      'nivel': serializer.toJson<int>(nivel),
      'conceito': serializer.toJson<String?>(conceito),
      'origem': serializer.toJson<String?>(origem),
      'perfil': serializer.toJson<String?>(perfil),
      'characterSchemaVersion': serializer.toJson<int>(characterSchemaVersion),
      'data': serializer.toJson<String>(data),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'lastOpenedAt': serializer.toJson<DateTime?>(lastOpenedAt),
      'catalogVersion': serializer.toJson<String?>(catalogVersion),
      'checksum': serializer.toJson<String?>(checksum),
    };
  }

  CharacterRow copyWith({
    String? id,
    String? nome,
    int? nivel,
    Value<String?> conceito = const Value.absent(),
    Value<String?> origem = const Value.absent(),
    Value<String?> perfil = const Value.absent(),
    int? characterSchemaVersion,
    String? data,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> lastOpenedAt = const Value.absent(),
    Value<String?> catalogVersion = const Value.absent(),
    Value<String?> checksum = const Value.absent(),
  }) => CharacterRow(
    id: id ?? this.id,
    nome: nome ?? this.nome,
    nivel: nivel ?? this.nivel,
    conceito: conceito.present ? conceito.value : this.conceito,
    origem: origem.present ? origem.value : this.origem,
    perfil: perfil.present ? perfil.value : this.perfil,
    characterSchemaVersion:
        characterSchemaVersion ?? this.characterSchemaVersion,
    data: data ?? this.data,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastOpenedAt: lastOpenedAt.present ? lastOpenedAt.value : this.lastOpenedAt,
    catalogVersion: catalogVersion.present
        ? catalogVersion.value
        : this.catalogVersion,
    checksum: checksum.present ? checksum.value : this.checksum,
  );
  CharacterRow copyWithCompanion(CharactersCompanion data) {
    return CharacterRow(
      id: data.id.present ? data.id.value : this.id,
      nome: data.nome.present ? data.nome.value : this.nome,
      nivel: data.nivel.present ? data.nivel.value : this.nivel,
      conceito: data.conceito.present ? data.conceito.value : this.conceito,
      origem: data.origem.present ? data.origem.value : this.origem,
      perfil: data.perfil.present ? data.perfil.value : this.perfil,
      characterSchemaVersion: data.characterSchemaVersion.present
          ? data.characterSchemaVersion.value
          : this.characterSchemaVersion,
      data: data.data.present ? data.data.value : this.data,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastOpenedAt: data.lastOpenedAt.present
          ? data.lastOpenedAt.value
          : this.lastOpenedAt,
      catalogVersion: data.catalogVersion.present
          ? data.catalogVersion.value
          : this.catalogVersion,
      checksum: data.checksum.present ? data.checksum.value : this.checksum,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CharacterRow(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('nivel: $nivel, ')
          ..write('conceito: $conceito, ')
          ..write('origem: $origem, ')
          ..write('perfil: $perfil, ')
          ..write('characterSchemaVersion: $characterSchemaVersion, ')
          ..write('data: $data, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastOpenedAt: $lastOpenedAt, ')
          ..write('catalogVersion: $catalogVersion, ')
          ..write('checksum: $checksum')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nome,
    nivel,
    conceito,
    origem,
    perfil,
    characterSchemaVersion,
    data,
    createdAt,
    updatedAt,
    lastOpenedAt,
    catalogVersion,
    checksum,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CharacterRow &&
          other.id == this.id &&
          other.nome == this.nome &&
          other.nivel == this.nivel &&
          other.conceito == this.conceito &&
          other.origem == this.origem &&
          other.perfil == this.perfil &&
          other.characterSchemaVersion == this.characterSchemaVersion &&
          other.data == this.data &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastOpenedAt == this.lastOpenedAt &&
          other.catalogVersion == this.catalogVersion &&
          other.checksum == this.checksum);
}

class CharactersCompanion extends UpdateCompanion<CharacterRow> {
  final Value<String> id;
  final Value<String> nome;
  final Value<int> nivel;
  final Value<String?> conceito;
  final Value<String?> origem;
  final Value<String?> perfil;
  final Value<int> characterSchemaVersion;
  final Value<String> data;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> lastOpenedAt;
  final Value<String?> catalogVersion;
  final Value<String?> checksum;
  final Value<int> rowid;
  const CharactersCompanion({
    this.id = const Value.absent(),
    this.nome = const Value.absent(),
    this.nivel = const Value.absent(),
    this.conceito = const Value.absent(),
    this.origem = const Value.absent(),
    this.perfil = const Value.absent(),
    this.characterSchemaVersion = const Value.absent(),
    this.data = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastOpenedAt = const Value.absent(),
    this.catalogVersion = const Value.absent(),
    this.checksum = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CharactersCompanion.insert({
    required String id,
    required String nome,
    this.nivel = const Value.absent(),
    this.conceito = const Value.absent(),
    this.origem = const Value.absent(),
    this.perfil = const Value.absent(),
    this.characterSchemaVersion = const Value.absent(),
    required String data,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.lastOpenedAt = const Value.absent(),
    this.catalogVersion = const Value.absent(),
    this.checksum = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nome = Value(nome),
       data = Value(data),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CharacterRow> custom({
    Expression<String>? id,
    Expression<String>? nome,
    Expression<int>? nivel,
    Expression<String>? conceito,
    Expression<String>? origem,
    Expression<String>? perfil,
    Expression<int>? characterSchemaVersion,
    Expression<String>? data,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? lastOpenedAt,
    Expression<String>? catalogVersion,
    Expression<String>? checksum,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nome != null) 'nome': nome,
      if (nivel != null) 'nivel': nivel,
      if (conceito != null) 'conceito': conceito,
      if (origem != null) 'origem': origem,
      if (perfil != null) 'perfil': perfil,
      if (characterSchemaVersion != null)
        'character_schema_version': characterSchemaVersion,
      if (data != null) 'data': data,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastOpenedAt != null) 'last_opened_at': lastOpenedAt,
      if (catalogVersion != null) 'catalog_version': catalogVersion,
      if (checksum != null) 'checksum': checksum,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CharactersCompanion copyWith({
    Value<String>? id,
    Value<String>? nome,
    Value<int>? nivel,
    Value<String?>? conceito,
    Value<String?>? origem,
    Value<String?>? perfil,
    Value<int>? characterSchemaVersion,
    Value<String>? data,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? lastOpenedAt,
    Value<String?>? catalogVersion,
    Value<String?>? checksum,
    Value<int>? rowid,
  }) {
    return CharactersCompanion(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      nivel: nivel ?? this.nivel,
      conceito: conceito ?? this.conceito,
      origem: origem ?? this.origem,
      perfil: perfil ?? this.perfil,
      characterSchemaVersion:
          characterSchemaVersion ?? this.characterSchemaVersion,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      catalogVersion: catalogVersion ?? this.catalogVersion,
      checksum: checksum ?? this.checksum,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (nivel.present) {
      map['nivel'] = Variable<int>(nivel.value);
    }
    if (conceito.present) {
      map['conceito'] = Variable<String>(conceito.value);
    }
    if (origem.present) {
      map['origem'] = Variable<String>(origem.value);
    }
    if (perfil.present) {
      map['perfil'] = Variable<String>(perfil.value);
    }
    if (characterSchemaVersion.present) {
      map['character_schema_version'] = Variable<int>(
        characterSchemaVersion.value,
      );
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (lastOpenedAt.present) {
      map['last_opened_at'] = Variable<DateTime>(lastOpenedAt.value);
    }
    if (catalogVersion.present) {
      map['catalog_version'] = Variable<String>(catalogVersion.value);
    }
    if (checksum.present) {
      map['checksum'] = Variable<String>(checksum.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CharactersCompanion(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('nivel: $nivel, ')
          ..write('conceito: $conceito, ')
          ..write('origem: $origem, ')
          ..write('perfil: $perfil, ')
          ..write('characterSchemaVersion: $characterSchemaVersion, ')
          ..write('data: $data, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastOpenedAt: $lastOpenedAt, ')
          ..write('catalogVersion: $catalogVersion, ')
          ..write('checksum: $checksum, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$CharacterDatabase extends GeneratedDatabase {
  _$CharacterDatabase(QueryExecutor e) : super(e);
  $CharacterDatabaseManager get managers => $CharacterDatabaseManager(this);
  late final $CharactersTable characters = $CharactersTable(this);
  late final CharacterDao characterDao = CharacterDao(
    this as CharacterDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [characters];
}

typedef $$CharactersTableCreateCompanionBuilder = CharactersCompanion Function({
  required String id,
  required String nome,
  Value<int> nivel,
  Value<String?> conceito,
  Value<String?> origem,
  Value<String?> perfil,
  Value<int> characterSchemaVersion,
  required String data,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> lastOpenedAt,
  Value<String?> catalogVersion,
  Value<String?> checksum,
  Value<int> rowid,
});
typedef $$CharactersTableUpdateCompanionBuilder = CharactersCompanion Function({
  Value<String> id,
  Value<String> nome,
  Value<int> nivel,
  Value<String?> conceito,
  Value<String?> origem,
  Value<String?> perfil,
  Value<int> characterSchemaVersion,
  Value<String> data,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> lastOpenedAt,
  Value<String?> catalogVersion,
  Value<String?> checksum,
  Value<int> rowid,
});

class $$CharactersTableFilterComposer
    extends Composer<_$CharacterDatabase, $CharactersTable> {
  $$CharactersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nivel => $composableBuilder(
    column: $table.nivel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conceito => $composableBuilder(
    column: $table.conceito,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origem => $composableBuilder(
    column: $table.origem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get perfil => $composableBuilder(
    column: $table.perfil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get characterSchemaVersion => $composableBuilder(
    column: $table.characterSchemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get catalogVersion => $composableBuilder(
    column: $table.catalogVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get checksum => $composableBuilder(
    column: $table.checksum,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CharactersTableOrderingComposer
    extends Composer<_$CharacterDatabase, $CharactersTable> {
  $$CharactersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nivel => $composableBuilder(
    column: $table.nivel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conceito => $composableBuilder(
    column: $table.conceito,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origem => $composableBuilder(
    column: $table.origem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get perfil => $composableBuilder(
    column: $table.perfil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get characterSchemaVersion => $composableBuilder(
    column: $table.characterSchemaVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get catalogVersion => $composableBuilder(
    column: $table.catalogVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get checksum => $composableBuilder(
    column: $table.checksum,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CharactersTableAnnotationComposer
    extends Composer<_$CharacterDatabase, $CharactersTable> {
  $$CharactersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<int> get nivel =>
      $composableBuilder(column: $table.nivel, builder: (column) => column);

  GeneratedColumn<String> get conceito =>
      $composableBuilder(column: $table.conceito, builder: (column) => column);

  GeneratedColumn<String> get origem =>
      $composableBuilder(column: $table.origem, builder: (column) => column);

  GeneratedColumn<String> get perfil =>
      $composableBuilder(column: $table.perfil, builder: (column) => column);

  GeneratedColumn<int> get characterSchemaVersion => $composableBuilder(
    column: $table.characterSchemaVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get catalogVersion => $composableBuilder(
    column: $table.catalogVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get checksum =>
      $composableBuilder(column: $table.checksum, builder: (column) => column);
}

class $$CharactersTableTableManager
    extends
        RootTableManager<
          _$CharacterDatabase,
          $CharactersTable,
          CharacterRow,
          $$CharactersTableFilterComposer,
          $$CharactersTableOrderingComposer,
          $$CharactersTableAnnotationComposer,
          $$CharactersTableCreateCompanionBuilder,
          $$CharactersTableUpdateCompanionBuilder,
          (
            CharacterRow,
            BaseReferences<_$CharacterDatabase, $CharactersTable, CharacterRow>,
          ),
          CharacterRow,
          PrefetchHooks Function()
        > {
  $$CharactersTableTableManager(_$CharacterDatabase db, $CharactersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CharactersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CharactersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CharactersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<int> nivel = const Value.absent(),
                Value<String?> conceito = const Value.absent(),
                Value<String?> origem = const Value.absent(),
                Value<String?> perfil = const Value.absent(),
                Value<int> characterSchemaVersion = const Value.absent(),
                Value<String> data = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastOpenedAt = const Value.absent(),
                Value<String?> catalogVersion = const Value.absent(),
                Value<String?> checksum = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CharactersCompanion(
                id: id,
                nome: nome,
                nivel: nivel,
                conceito: conceito,
                origem: origem,
                perfil: perfil,
                characterSchemaVersion: characterSchemaVersion,
                data: data,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastOpenedAt: lastOpenedAt,
                catalogVersion: catalogVersion,
                checksum: checksum,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String nome,
                Value<int> nivel = const Value.absent(),
                Value<String?> conceito = const Value.absent(),
                Value<String?> origem = const Value.absent(),
                Value<String?> perfil = const Value.absent(),
                Value<int> characterSchemaVersion = const Value.absent(),
                required String data,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> lastOpenedAt = const Value.absent(),
                Value<String?> catalogVersion = const Value.absent(),
                Value<String?> checksum = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CharactersCompanion.insert(
                id: id,
                nome: nome,
                nivel: nivel,
                conceito: conceito,
                origem: origem,
                perfil: perfil,
                characterSchemaVersion: characterSchemaVersion,
                data: data,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastOpenedAt: lastOpenedAt,
                catalogVersion: catalogVersion,
                checksum: checksum,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CharactersTable, CharacterRow>(table),
                  BaseReferences<
                    _$CharacterDatabase,
                    $CharactersTable,
                    CharacterRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CharactersTableProcessedTableManager =
    ProcessedTableManager<
      _$CharacterDatabase,
      $CharactersTable,
      CharacterRow,
      $$CharactersTableFilterComposer,
      $$CharactersTableOrderingComposer,
      $$CharactersTableAnnotationComposer,
      $$CharactersTableCreateCompanionBuilder,
      $$CharactersTableUpdateCompanionBuilder,
      (
        CharacterRow,
        BaseReferences<_$CharacterDatabase, $CharactersTable, CharacterRow>,
      ),
      CharacterRow,
      PrefetchHooks Function()
    >;

class $CharacterDatabaseManager {
  final _$CharacterDatabase _db;
  $CharacterDatabaseManager(this._db);
  $$CharactersTableTableManager get characters =>
      $$CharactersTableTableManager(_db, _db.characters);
}
