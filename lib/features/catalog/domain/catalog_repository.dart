import 'package:app_flutter/features/catalog/domain/ability.dart';
import 'package:app_flutter/features/catalog/domain/catalog_item.dart';
import 'package:app_flutter/features/catalog/domain/modification.dart';
import 'package:app_flutter/features/catalog/domain/origin.dart';
import 'package:app_flutter/features/catalog/domain/power.dart';
import 'package:app_flutter/features/catalog/domain/profile.dart';
import 'package:app_flutter/features/catalog/domain/progression.dart';
import 'package:app_flutter/features/catalog/domain/protection.dart';
import 'package:app_flutter/features/catalog/domain/ritual.dart';
import 'package:app_flutter/features/catalog/domain/weapon.dart';

/// Porta de leitura dos catálogos. Hoje os dados vêm dos assets empacotados
/// (`json/` dentro do app_flutter, fonte única); a normalização replica
/// exatamente o que o backend Python fazia em `main.py`.
///
/// Os itens são as mesmas classes usadas nas cópias da ficha
/// (`personalizada: false` quando vêm do catálogo).
abstract interface class CatalogRepository {
  /// Origens disponíveis.
  Future<List<Origin>> loadOrigens();

  /// Perfis disponíveis.
  Future<List<Profile>> loadPerfis();

  /// Tabela de progressão de nível.
  Future<List<ProgressionRow>> loadProgressao();

  /// Catálogo de armas (com defaults do backend).
  Future<List<Weapon>> loadArmas();

  /// Catálogo de proteções.
  Future<List<Protection>> loadProtecoes();

  /// Catálogo de poderes paranormalis.
  Future<List<Power>> loadPoderes();

  /// Catálogo de habilidades (por tier).
  Future<List<Ability>> loadHabilidades();

  /// Catálogo de rituais (por círculo).
  Future<List<Ritual>> loadRituais();

  /// Itens de inventário de uma categoria do seletor.
  Future<List<CatalogItem>> loadItens(String categoria);

  /// Modificações aplicáveis a armas (campo `tipo_arma` preenchido).
  Future<List<CatalogModification>> loadModificacoesArmas();

  /// Modificações aplicáveis a proteções (aplicação menciona "prote").
  Future<List<CatalogModification>> loadModificacoesProtecoes();

  /// Maldições para armas.
  Future<List<CatalogCurse>> loadMaldicoesArmas();

  /// Maldições para proteções.
  Future<List<CatalogCurse>> loadMaldicoesProtecoes();
}
