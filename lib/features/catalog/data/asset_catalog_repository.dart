import 'dart:convert';
import 'package:app_flutter/features/catalog/domain/ability.dart';
import 'package:app_flutter/features/catalog/domain/catalog_item.dart';
import 'package:app_flutter/features/catalog/domain/catalog_repository.dart';
import 'package:app_flutter/features/catalog/domain/modification.dart';
import 'package:app_flutter/features/catalog/domain/origin.dart';
import 'package:app_flutter/features/catalog/domain/power.dart';
import 'package:app_flutter/features/catalog/domain/profile.dart';
import 'package:app_flutter/features/catalog/domain/progression.dart';
import 'package:app_flutter/features/catalog/domain/protection.dart';
import 'package:app_flutter/features/catalog/domain/ritual.dart';
import 'package:app_flutter/features/catalog/domain/weapon.dart';
import 'package:flutter/services.dart' show rootBundle;



/// Implementação que lê os catálogos dos assets empacotados.
///
/// Aceita as duas formas de raiz existentes nos JSONs autorais: lista pura
/// ou objeto com uma única chave (ex.: `{"origens": [...]}`). As
/// normalizações/defaults são as mesmas de `_carregar_*` no backend Python.
class AssetCatalogRepository implements CatalogRepository {
  @override
  Future<List<Origin>> loadOrigens() async {
    final data = await _loadJsonList('json/origens.json');
    return data.map(Origin.fromJson).toList(growable: false);
  }

  @override
  Future<List<Profile>> loadPerfis() async {
    final data = await _loadJsonList('json/perfis.json');
    return data.map(Profile.fromJson).toList(growable: false);
  }

  @override
  Future<List<ProgressionRow>> loadProgressao() async {
    final data = await _loadJsonList('json/progressao_niveis.json');
    return data.map(ProgressionRow.fromJson).toList(growable: false);
  }

  @override
  Future<List<Weapon>> loadArmas() async {
    final data = await _loadJsonList('json/armas.json');
    return data.map(Weapon.fromJson).toList(growable: false);
  }

  @override
  Future<List<Protection>> loadProtecoes() async {
    final data = await _loadJsonList('json/protecoes.json');
    return data.map(Protection.fromJson).toList(growable: false);
  }

  @override
  Future<List<Power>> loadPoderes() async {
    final data =
        await _loadJsonList('json/poderes paranormais.json');
    return data.map(Power.fromJson).toList(growable: false);
  }

  @override
  Future<List<Ability>> loadHabilidades() async {
    final data = await _loadJsonList('json/habilidades.json');
    // Normalização do backend: tier faz fallback para classificacao e
    // defaults de texto ("Nenhum"/"N/A").
    return data.map((raw) {
      final hab = Ability.fromJson(raw);
      final tier =
          (raw['tier'] ?? raw['classificacao'] ?? 'Tier I').toString().trim();
      return Ability(
        nome: hab.nome,
        classificacao: tier,
        prereq: hab.prereq.isEmpty ? 'Nenhum' : hab.prereq,
        custo: hab.custo.isEmpty ? 'Nenhum' : hab.custo,
        alcance: hab.alcance.isEmpty ? 'N/A' : hab.alcance,
        efeito: hab.efeito,
      );
    }).toList(growable: false);
  }

  @override
  Future<List<Ritual>> loadRituais() async {
    final data = await _loadJsonList('json/rituais.json');
    // Normalização do backend: circulo = tier ou classificacao ("1° Círculo").
    return data.map((raw) {
      final ritual = Ritual.fromJson(raw);
      final circulo = (raw['tier'] ?? raw['classificacao'] ?? '1° Círculo')
          .toString()
          .trim();
      return Ritual(
        nome: ritual.nome,
        classificacao: circulo,
        prereq: ritual.prereq.isEmpty ? 'Nenhum' : ritual.prereq,
        custo: ritual.custo.isEmpty ? 'Nenhum' : ritual.custo,
        alcance: ritual.alcance.isEmpty ? 'N/A' : ritual.alcance,
        efeito: ritual.efeito,
        elemento: ritual.elemento,
        execucao: ritual.execucao,
      );
    }).toList(growable: false);
  }

  @override
  Future<List<CatalogItem>> loadItens(String categoria) async {
    final arquivo = _arquivosInventario[categoria];
    if (arquivo == null) {
      throw StateError('Categoria de inventário não encontrada: $categoria');
    }
    final data = await _loadJsonList('json/$arquivo');
    return data.map(CatalogItem.fromJson).toList(growable: false);
  }

  @override
  Future<List<CatalogModification>> loadModificacoesArmas() async {
    final data = await _loadJsonList('json/modificacoes.json');
    return data
        .map(CatalogModification.fromJson)
        .where((mod) => mod.tipoArma.trim().isNotEmpty)
        .toList(growable: false);
  }

  @override
  Future<List<CatalogModification>> loadModificacoesProtecoes() async {
    final data = await _loadJsonList('json/modificacoes.json');
    return data
        .map(CatalogModification.fromJson)
        .where((mod) => mod.aplicacao.toLowerCase().contains('prote'))
        .toList(growable: false);
  }

  @override
  Future<List<CatalogCurse>> loadMaldicoesArmas() async {
    final data = await _loadJsonList('json/maldicoes.json');
    return data
        .map(CatalogCurse.fromJson)
        .where((mald) => mald.tipo.contains('Arma'))
        .toList(growable: false);
  }

  @override
  Future<List<CatalogCurse>> loadMaldicoesProtecoes() async {
    final data = await _loadJsonList('json/maldicoes.json');
    return data
        .map(CatalogCurse.fromJson)
        .where((mald) => mald.tipo.contains('Proteç'))
        .toList(growable: false);
  }

  /// Categorias do seletor de inventário → arquivos, igual ao backend.
  static const Map<String, String> _arquivosInventario = {
    'operacionais': 'itens operacionais.json',
    'acessorios': 'acessorios.json',
    'explosivos': 'explosivos.json',
    'amaldiçoados': 'itens amaldicoados.json',
    'paranormais': 'itens paranormais.json',
    'medicamentos': 'medicamentos.json',
    'municoes': 'municoes.json',
  };

  Future<List<Map<String, dynamic>>> _loadJsonList(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    final value = jsonDecode(raw);
    if (value is List) {
      return value.whereType<Map<String, dynamic>>().toList(growable: false);
    }
    if (value is Map<String, dynamic>) {
      for (final entry in value.entries) {
        if (entry.value is List) {
          return (entry.value! as List<dynamic>)
              .whereType<Map<String, dynamic>>()
              .toList(growable: false);
        }
      }
    }
    return <Map<String, dynamic>>[];
  }
}
