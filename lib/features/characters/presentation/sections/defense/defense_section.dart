import 'package:app_flutter/app/providers.dart';
import 'package:app_flutter/features/catalog/catalog.dart' show ProgressionRow;
import 'package:app_flutter/features/characters/domain/rules/derived.dart';
import 'package:app_flutter/features/characters/presentation/viewmodels/sheet_view_model.dart';
import 'package:app_flutter/shared/widgets/app_field.dart';
import 'package:app_flutter/shared/widgets/auto_grid.dart';
import 'package:app_flutter/shared/widgets/section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 4. Defesa e Proteções — bloqueio, esquiva e bônus de proteções.
class DefenseSection extends ConsumerWidget {
  /// Cria a seção.
  const DefenseSection({required this.characterId, super.key});

  /// Id da ficha aberta.
  final String characterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final character =
        ref.watch(sheetProvider(characterId)).requireValue;
    final vm = ref.read(sheetProvider(characterId).notifier);
    final progressao =
        ref.watch(progressaoProvider).value ?? <ProgressionRow>[];
    final derived = computeDerived(character, progressao);

    return SectionCard(
      title: 'Defesa e Proteções',
      child: AutoGrid.grid3([
        FieldLabel(
          label: 'Valor de Bloqueio',
          child: BoundNumberField(
            value: derived.bloqueio,
            readOnly: true,
            onChanged: (_) {},
          ),
        ),
        FieldLabel(
          label: 'Valor de Esquiva',
          child: BoundNumberField(
            value: derived.esquiva,
            readOnly: true,
            onChanged: (_) {},
          ),
        ),
        FieldLabel(
          label: 'Bônus de Proteções',
          child: BoundNumberField(
            value: character.bonusProtecoes,
            onChanged: vm.setBonusProtecoes,
          ),
        ),
      ]),
    );
  }
}
