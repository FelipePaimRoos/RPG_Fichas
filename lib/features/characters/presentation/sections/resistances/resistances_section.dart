import 'package:app_flutter/features/characters/presentation/viewmodels/sheet_view_model.dart';
import 'package:app_flutter/shared/widgets/app_field.dart';
import 'package:app_flutter/shared/widgets/auto_grid.dart';
import 'package:app_flutter/shared/widgets/section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 7. Resistências / Proficiências — dois textareas, como no web.
class ResistancesSection extends ConsumerWidget {
  /// Cria a seção.
  const ResistancesSection({required this.characterId, super.key});

  /// Id da ficha aberta.
  final String characterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final character =
        ref.watch(sheetProvider(characterId)).requireValue;
    final vm = ref.read(sheetProvider(characterId).notifier);

    return SectionCard(
      child: AutoGrid.grid2([
        FieldLabel(
          label: 'Resistências',
          child: BoundTextArea(
            value: character.resistencias,
            hint: 'Ex: Fogo 5, Balístico 2...',
            onChanged: (value) => vm.set((c) => c.resistencias = value),
          ),
        ),
        FieldLabel(
          label: 'Proficiências',
          child: BoundTextArea(
            value: character.proficiencias,
            hint: 'Ex: Armas Táticas, Proteções Leves...',
            onChanged: (value) => vm.set((c) => c.proficiencias = value),
          ),
        ),
      ]),
    );
  }
}
