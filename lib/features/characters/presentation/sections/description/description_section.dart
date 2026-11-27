import 'package:app_flutter/features/characters/presentation/viewmodels/sheet_view_model.dart';
import 'package:app_flutter/shared/widgets/app_field.dart';
import 'package:app_flutter/shared/widgets/auto_grid.dart';
import 'package:app_flutter/shared/widgets/section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 15. Histórico & Descrição — textareas do personagem.
class DescriptionSection extends ConsumerWidget {
  /// Cria a seção.
  const DescriptionSection({required this.characterId, super.key});

  /// Id da ficha aberta.
  final String characterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final character =
        ref.watch(sheetProvider(characterId)).requireValue;
    final vm = ref.read(sheetProvider(characterId).notifier);

    return SectionCard(
      title: 'Histórico & Descrição',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AutoGrid.grid2([
            FieldLabel(
              label: 'Aparência',
              child: BoundTextArea(
                value: character.descAparencia,
                onChanged: (value) =>
                    vm.set((c) => c.descAparencia = value),
              ),
            ),
            FieldLabel(
              label: 'Personalidade',
              child: BoundTextArea(
                value: character.descPersonalidade,
                onChanged: (value) =>
                    vm.set((c) => c.descPersonalidade = value),
              ),
            ),
            FieldLabel(
              label: 'Histórico',
              child: BoundTextArea(
                value: character.descHistorico,
                onChanged: (value) =>
                    vm.set((c) => c.descHistorico = value),
              ),
            ),
            FieldLabel(
              label: 'Objetivo',
              child: BoundTextArea(
                value: character.descObjetivo,
                onChanged: (value) =>
                    vm.set((c) => c.descObjetivo = value),
              ),
            ),
          ]),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: FieldLabel(
              label: 'Anotações Gerais',
              child: BoundTextArea(
                value: character.descAnotacoes,
                onChanged: (value) =>
                    vm.set((c) => c.descAnotacoes = value),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
