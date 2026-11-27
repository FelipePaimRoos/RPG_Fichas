import 'package:app_flutter/features/catalog/catalog.dart';
import 'package:app_flutter/features/catalog/data/asset_catalog_repository.dart';
import 'package:app_flutter/features/characters/data/drift/character_database.dart';
import 'package:app_flutter/features/characters/data/drift/drift_character_repository.dart';
import 'package:app_flutter/features/characters/domain/repositories/character_repository.dart';
import 'package:app_flutter/shared/platform/desktop_file_gateway.dart';
import 'package:app_flutter/shared/platform/file_gateway.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';


/// Banco SQLite (Drift). Único lugar (composition root) que conhece a
/// implementação concreta da persistência.
final characterDatabaseProvider = Provider<CharacterDatabase>((ref) {
  final database = CharacterDatabase();
  ref.onDispose(database.close);
  return database;
});

/// Porta de persistência de fichas (SQLite via Drift).
final characterRepositoryProvider = Provider<CharacterRepository>((ref) {
  final database = ref.watch(characterDatabaseProvider);
  return DriftCharacterRepository(database.characterDao);
});

/// Porta dos catálogos (assets hoje; backend/sync no futuro).
final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return AssetCatalogRepository();
});

/// Porta de arquivos (diálogos nativos no desktop).
final fileGatewayProvider = Provider<FileGateway>((ref) {
  return DesktopFileGateway();
});

/// Catálogo de origens.
final origensProvider = FutureProvider<List<Origin>>(
  (ref) => ref.watch(catalogRepositoryProvider).loadOrigens(),
);

/// Catálogo de perfis.
final perfisProvider = FutureProvider<List<Profile>>(
  (ref) => ref.watch(catalogRepositoryProvider).loadPerfis(),
);

/// Tabela de progressão de nível.
final progressaoProvider = FutureProvider<List<ProgressionRow>>(
  (ref) => ref.watch(catalogRepositoryProvider).loadProgressao(),
);

/// Catálogo de armas.
final armasCatalogoProvider = FutureProvider<List<Weapon>>(
  (ref) => ref.watch(catalogRepositoryProvider).loadArmas(),
);

/// Catálogo de proteções.
final protecoesCatalogoProvider = FutureProvider<List<Protection>>(
  (ref) => ref.watch(catalogRepositoryProvider).loadProtecoes(),
);

/// Catálogo de poderes paranormalis.
final poderesCatalogoProvider = FutureProvider<List<Power>>(
  (ref) => ref.watch(catalogRepositoryProvider).loadPoderes(),
);

/// Catálogo de habilidades.
final habilidadesCatalogoProvider = FutureProvider<List<Ability>>(
  (ref) => ref.watch(catalogRepositoryProvider).loadHabilidades(),
);

/// Catálogo de rituais.
final rituaisCatalogoProvider = FutureProvider<List<Ritual>>(
  (ref) => ref.watch(catalogRepositoryProvider).loadRituais(),
);

/// Itens de inventário por categoria do seletor.
final FutureProviderFamily<List<CatalogItem>, String> itensCatalogoProvider =
    FutureProvider.family<List<CatalogItem>, String>(
  (ref, categoria) => ref.watch(catalogRepositoryProvider).loadItens(categoria),
);

/// Modificações de armas.
final modificacoesArmasProvider = FutureProvider<List<CatalogModification>>(
  (ref) => ref.watch(catalogRepositoryProvider).loadModificacoesArmas(),
);

/// Modificações de proteções.
final modificacoesProtecoesProvider = FutureProvider<List<CatalogModification>>(
  (ref) => ref.watch(catalogRepositoryProvider).loadModificacoesProtecoes(),
);

/// Maldições de armas.
final maldicoesArmasProvider = FutureProvider<List<CatalogCurse>>(
  (ref) => ref.watch(catalogRepositoryProvider).loadMaldicoesArmas(),
);

/// Maldições de proteções.
final maldicoesProtecoesProvider = FutureProvider<List<CatalogCurse>>(
  (ref) => ref.watch(catalogRepositoryProvider).loadMaldicoesProtecoes(),
);
