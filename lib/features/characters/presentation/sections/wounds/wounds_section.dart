import 'package:app_flutter/app/theme/tokens.dart';
import 'package:app_flutter/features/characters/presentation/viewmodels/sheet_view_model.dart';
import 'package:app_flutter/shared/domain/attribute.dart';
import 'package:app_flutter/shared/widgets/auto_grid.dart';
import 'package:app_flutter/shared/widgets/section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 3. Ferimentos Debilitantes — checkboxes por atributo com penalidades.
class WoundsSection extends ConsumerWidget {
  /// Cria a seção.
  const WoundsSection({required this.characterId, super.key});

  /// Id da ficha aberta.
  final String characterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final character =
        ref.watch(sheetProvider(characterId)).requireValue;
    final vm = ref.read(sheetProvider(characterId).notifier);

    return SectionCard(
      title: 'Ferimentos Debilitantes',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Marque os atributos afetados por ferimentos debilitantes para '
            'aplicar penalidades automáticas (desvantagens, redução de '
            'deslocamento, carga ou cura).',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 13.6,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          AutoGrid.grid5([
            for (final attribute in AttributeId.values)
              _WoundBox(
                label: attribute.label,
                hint: _hintFor(attribute),
                checked: character.atributos
                    .firstWhere((a) => a.nome == attribute.jsonName)
                    .debilitado,
                onChanged: (checked) => vm.setAtributo(
                  attribute.jsonName,
                  debilitado: checked,
                ),
              ),
          ]),
        ],
      ),
    );
  }

  static String _hintFor(AttributeId attribute) => switch (attribute) {
        AttributeId.forca => 'Desv. Força & Metade Carga',
        AttributeId.agilidade => 'Desv. Agilidade & -3m Desloc.',
        AttributeId.intelecto => 'Desv. Intelecto',
        AttributeId.presenca => 'Desv. Presença',
        AttributeId.vigor => 'Desv. Vigor & Metade Cura Vida',
      };
}

class _WoundBox extends StatelessWidget {
  const _WoundBox({
    required this.label,
    required this.hint,
    required this.checked,
    required this.onChanged,
  });

  final String label;
  final String hint;
  final bool checked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!checked),
      borderRadius: BorderRadius.circular(AppRadii.box),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.inputBg,
          border: Border.all(color: AppColors.cardBorder),
          borderRadius: BorderRadius.circular(AppRadii.box),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(
              width: 18,
              height: 18,
              child: Checkbox(
                value: checked,
                onChanged: (value) => onChanged(value ?? false),
              ),
            ),
            Text(
              hint,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.warnText,
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
