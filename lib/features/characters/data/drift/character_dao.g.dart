// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character_dao.dart';

// ignore_for_file: type=lint
mixin _$CharacterDaoMixin on DatabaseAccessor<CharacterDatabase> {
  $CharactersTable get characters => attachedDatabase.characters;
  CharacterDaoManager get managers => CharacterDaoManager(this);
}

class CharacterDaoManager {
  final _$CharacterDaoMixin _db;
  CharacterDaoManager(this._db);
  $$CharactersTableTableManager get characters =>
      $$CharactersTableTableManager(_db.attachedDatabase, _db.characters);
}
