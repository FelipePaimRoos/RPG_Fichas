import 'package:app_flutter/app/providers.dart';
import 'package:app_flutter/app/theme/tokens.dart';
import 'package:app_flutter/features/catalog/catalog.dart' show ProgressionRow;
import 'package:app_flutter/features/characters/domain/rules/derived.dart';
import 'package:app_flutter/features/characters/presentation/viewmodels/sheet_view_model.dart';
import 'package:app_flutter/shared/widgets/app_field.dart';
import 'package:app_flutter/shared/widgets/auto_grid.dart';
import 'package:app_flutter/shared/widgets/section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 5. Deslocamento — base, efetivo e quadrados, com penalidades aplicadas.
class MovementSection extends ConsumerWidget {
  /// Cria a seção.
  const MovementSection({required this.characterId, super.key});

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

    const readOnlyStyle = TextStyle(
      color: AppColors.primary,
      fontSize: 15.2,
      fontWeight: FontWeight.w700,
    );

    return SectionCard(
      title: 'Deslocamento',
      child: AutoGrid.grid3([
        FieldLabel(
          label: 'Deslocamento Base (m)',
          child: BoundNumberField(
            value: character.deslocamentoBase,
            onChanged: vm.setDeslocamentoBase,
          ),
        ),
        FieldLabel(
          label: 'Deslocamento Efetivo (m)',
          child: BoundNumberField(
            value: derived.deslocamentoMetros,
            readOnly: true,
            fillColor: AppColors.readOnlyBox,
            onChanged: (_) {},
            style: readOnlyStyle,
          ),
        ),
        FieldLabel(
          label: 'Deslocamento (Quadrados)',
          child: BoundNumberField(
            value: derived.deslocamentoQuadrados,
            readOnly: true,
            fillColor: AppColors.readOnlyBox,
            onChanged: (_) {},
            style: readOnlyStyle,
          ),
        ),
      ]),
    );
  }
}
