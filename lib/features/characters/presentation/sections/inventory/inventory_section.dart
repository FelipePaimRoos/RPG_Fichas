import 'dart:async';

import 'package:app_flutter/app/providers.dart';
import 'package:app_flutter/app/theme/tokens.dart';
import 'package:app_flutter/features/catalog/catalog.dart'
    show InventoryItem, Protection, Weapon;
import 'package:app_flutter/features/catalog/presentation/pickers/inventory_item_picker.dart';
import 'package:app_flutter/features/catalog/presentation/pickers/protection_picker.dart';
import 'package:app_flutter/features/catalog/presentation/pickers/weapon_picker.dart';
import 'package:app_flutter/features/characters/domain/character.dart';
import 'package:app_flutter/features/characters/presentation/viewmodels/sheet_view_model.dart';
import 'package:app_flutter/shared/widgets/app_button.dart';
import 'package:app_flutter/shared/widgets/app_field.dart';
import 'package:app_flutter/shared/widgets/app_modal.dart';
import 'package:app_flutter/shared/widgets/section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 13. Inventário — carga, itens genéricos editáveis e linhas readonly
/// de armas (dourado) e proteções (azulado), como no web.
class InventorySection extends ConsumerWidget {
  /// Cria a seção.
  const InventorySection({required this.characterId, super.key});

  /// Id da ficha aberta.
  final String characterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final character =
        ref.watch(sheetProvider(characterId)).requireValue;
    final vm = ref.read(sheetProvider(characterId).notifier);
    final progressao =
        ref.watch(progressaoProvider).value ?? const [];

    // Calcula carga + bônus de proteções (calcularBonusProtecoes do web).
    var cargaAtual = 0.0;
    for (final item in character.inventario) {
      cargaAtual += item.espaco;
    }
    for (final arma in character.armas) {
      cargaAtual += arma.espaco;
    }
    for (final protecao in character.protecoes) {
      cargaAtual += protecao.espaco;
    }
    final debForca = character.atributos
        .firstWhere((a) => a.nome == 'forca')
        .debilitado;
    final cargaMaxEfetiva = debForca
        ? (character.cargaMaxima / 2).floor()
        : character.cargaMaxima;
    final hintCarga = debForca
        ? '(Máx.: $cargaMaxEfetiva [metade por Força])'
        : '(Máx.: $cargaMaxEfetiva)';

    return SectionCard(
      title: 'Inventário',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text(
                'Carga:',
                style: TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                cargaAtual % 1 == 0
                    ? '${cargaAtual.toInt()}'
                    : cargaAtual.toStringAsFixed(1),
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 6),
              BoundNumberField(
                value: character.cargaMaxima,
                width: 60,
                readOnly: true,
                onChanged: (_) {},
              ),
              const SizedBox(width: 8),
              Text(
                hintCarga,
                style: const TextStyle(
                  color: AppColors.warnText,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SmallButton(
                label: '+ Adicionar do Catálogo',
                onPressed: () => unawaited(
                  showAppModal(
                    context: context,
                    title: 'Adicionar item do catálogo',
                    maxWidth: 780,
                    builder: (dialogContext) => InventoryItemPicker(
                      onSelect: (item) {
                        unawaited(
                          vm.addItem(
                            InventoryItem(
                              nome: item.nome,
                              espaco: item.espaco,
                              descricao: item.descricao,
                            ),
                          ),
                        );
                        Navigator.of(dialogContext).pop();
                      },
                    ),
                  ),
                ),
              ),
              SmallButton(
                label: '+ Novo Item Personalizado',
                onPressed: () => vm.addItem(
                  const InventoryItem(nome: 'Novo item'),
                ),
              ),
              SmallButton(
                label: '+ Adicionar Arma',
                onPressed: () => unawaited(
                  showAppModal(
                    context: context,
                    title: 'Adicionar Arma',
                    maxWidth: 780,
                    builder: (dialogContext) => WeaponPicker(
                      onSelect: (arma) {
                        unawaited(vm.addArma(arma));
                        Navigator.of(dialogContext).pop();
                      },
                    ),
                  ),
                ),
              ),
              SmallButton(
                label: '+ Adicionar Proteção',
                onPressed: () => unawaited(
                  showAppModal(
                    context: context,
                    title: 'Adicionar Proteção',
                    maxWidth: 780,
                    builder: (dialogContext) => ProtectionPicker(
                      onSelect: (protecao) {
                        unawaited(vm.addProtecao(protecao));
                        Navigator.of(dialogContext).pop();
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _InventoryTable(
            character: character,
            vm: vm,
            progressaoRows: progressao
                .map((r) => (nivel: r.nivel, categoria: r.categoria))
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _InventoryTable extends StatelessWidget {
  const _InventoryTable({
    required this.character,
    required this.vm,
    required this.progressaoRows,
  });

  final Character character;
  final SheetViewModel vm;
  final List<({int nivel, String categoria})> progressaoRows;

  @override
  Widget build(BuildContext context) {
    const headerStyle = TextStyle(
      color: AppColors.textMuted,
      fontSize: 13.6,
    );
    final cells = <TableRow>[
      const TableRow(
        decoration: BoxDecoration(color: AppColors.inputBg),
        children: [
          _Td(Text('Item', style: headerStyle)),
          _Td(Text('Espaço / Carga', style: headerStyle)),
          _Td(Text('Descrição', style: headerStyle)),
          _Td(Text('Ações', style: headerStyle)),
        ],
      ),
    ];

    // Itens genéricos (editáveis inline).
    for (var i = 0; i < character.inventario.length; i++) {
      final item = character.inventario[i];
      cells.add(
        TableRow(
          children: [
            _Td(
              BoundTextField(
                value: item.nome,
                onChanged: (value) =>
                    vm.setItem(i, item.copyWith(nome: value)),
              ),
            ),
            _Td(
              BoundNumberField(
                value: item.espaco.toInt(),
                width: 60,
                onChanged: (value) =>
                    vm.setItem(i, item.copyWith(espaco: value.toDouble())),
              ),
            ),
            _Td(
              BoundTextField(
                value: item.descricao,
                onChanged: (value) =>
                    vm.setItem(i, item.copyWith(descricao: value)),
              ),
            ),
            _Td(
              DangerButton(
                label: 'X',
                onPressed: () => vm.removeItem(i),
              ),
            ),
          ],
        ),
      );
    }

    // Armas (readonly dourado, clique abre edição).
    for (var i = 0; i < character.armas.length; i++) {
      final arma = character.armas[i];
      cells.add(
        TableRow(
          decoration: const BoxDecoration(
            color: Color(0x00000000),
          ),
          children: [
            _Td(
              BoundTextField(
                value: '${arma.nome.isEmpty ? '(sem nome)' : arma.nome} 🗡',
                readOnly: true,
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 15.2,
                ),
                onChanged: (_) {},
              ),
            ),
            _Td(
              Center(
                child: Text(
                  '${arma.espaco.toInt()}',
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 15.2,
                  ),
                ),
              ),
            ),
            _Td(
              BoundTextField(
                value: armaDescricao(arma),
                readOnly: true,
                style: const TextStyle(
                  color: Color(0xFFCBB37A),
                  fontSize: 12,
                ),
                onChanged: (_) {},
              ),
            ),
            _Td(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DangerButton(
                    label: 'X',
                    onPressed: () => _confirmarRemocao(
                      context,
                      'Remover esta arma do inventário?',
                      () => vm.removeArma(i),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Proteções (readonly azulado, clique abre edição).
    for (var i = 0; i < character.protecoes.length; i++) {
      final protecao = character.protecoes[i];
      cells.add(
        TableRow(
          children: [
            _Td(
              BoundTextField(
                value:
                    '${protecao.nome.isEmpty ? '(sem nome)' : protecao.nome} 🛡',
                readOnly: true,
                style: const TextStyle(
                  color: Color(0xFF7EC8FF),
                  fontSize: 15.2,
                ),
                onChanged: (_) {},
              ),
            ),
            _Td(
              Center(
                child: Text(
                  '${protecao.espaco.toInt()}',
                  style: const TextStyle(
                    color: Color(0xFF7EC8FF),
                    fontSize: 15.2,
                  ),
                ),
              ),
            ),
            _Td(
              BoundTextField(
                value: protecaoDescricao(protecao),
                readOnly: true,
                style: const TextStyle(
                  color: Color(0xFF9FC8E8),
                  fontSize: 12,
                ),
                onChanged: (_) {},
              ),
            ),
            _Td(
              DangerButton(
                label: 'X',
                onPressed: () => _confirmarRemocao(
                  context,
                  'Remover esta proteção do inventário?',
                  () => vm.removeProtecao(i),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(),
        2: FlexColumnWidth(3),
        3: FlexColumnWidth(0.8),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      border: const TableBorder(
        horizontalInside: BorderSide(color: AppColors.cardBorder),
      ),
      children: cells,
    );
  }

  void _confirmarRemocao(
    BuildContext context,
    String pergunta,
    VoidCallback onConfirm,
  ) {
    unawaited(
      showAppModal(
      context: context,
      title: 'Confirmar',
      maxWidth: 420,
      builder: (dialogContext) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            pergunta,
            style: const TextStyle(color: AppColors.text, fontSize: 15.2),
          ),
          const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                DangerButton(
                  label: 'Cancelar',
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
                const SizedBox(width: 8),
                AppButton(
                  label: 'Remover',
                  onPressed: () {
                    onConfirm();
                    Navigator.of(dialogContext).pop();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Td extends StatelessWidget {
  const _Td(this.child);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: child,
    );
  }
}

/// Descrição resumida da arma nas linhas do inventário (`_armaDescricao`).
String armaDescricao(Weapon arma) {
  final tipoEmpunhadura =
      'Tipo: ${arma.tipo.isEmpty ? '—' : arma.tipo} | Empunhadura: ${arma.empunhadura.isEmpty ? '—' : arma.empunhadura}';
  final dano =
      'Dano: ${arma.danoBase.isEmpty ? '—' : arma.danoBase} (crítico ${arma.critico.isEmpty ? '—' : arma.critico}, ${arma.tipoDano.isEmpty ? '—' : arma.tipoDano})';
  final partes = [
    'Proficiência: ${arma.proficiencia.isEmpty ? '—' : arma.proficiencia}',
    tipoEmpunhadura,
    dano,
    'Alcance: ${arma.alcance.isEmpty ? '—' : arma.alcance}',
  ];
  if (arma.habilidades.isNotEmpty) {
    partes.add(arma.habilidades);
  }
  return partes.join('\n').replaceAll('\n', ' | ');
}

/// Descrição resumida da proteção nas linhas do inventário
/// (`_protecaoDescricao`).
String protecaoDescricao(Protection protecao) {
  final partes = [
    'Bônus de Defesa: ${protecao.bonusDefesa.isEmpty ? '—' : protecao.bonusDefesa}',
    'RD: ${protecao.resistenciaDano.isEmpty ? '—' : protecao.resistenciaDano}',
    'Penalidade: ${protecao.penalidade.isEmpty ? 'Nenhuma' : protecao.penalidade}',
    if (protecao.empunhadura.isNotEmpty)
      'Empunhadura: ${protecao.empunhadura}',
    if (protecao.regrasEspeciais.isNotEmpty) protecao.regrasEspeciais,
    if (protecao.descricao.isNotEmpty) protecao.descricao,
  ];
  return partes.join(' | ');
}
