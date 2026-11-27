import 'package:app_flutter/app/providers.dart';
import 'package:app_flutter/app/theme/tokens.dart';
import 'package:app_flutter/features/catalog/catalog.dart' show ProgressionRow;
import 'package:app_flutter/features/characters/domain/character.dart';
import 'package:app_flutter/features/characters/domain/rules/attributes.dart';
import 'package:app_flutter/features/characters/domain/rules/derived.dart';
import 'package:app_flutter/features/characters/presentation/sections/attributes/dice_shape_box.dart';
import 'package:app_flutter/features/characters/presentation/viewmodels/sheet_view_model.dart';
import 'package:app_flutter/shared/domain/attribute.dart';
import 'package:app_flutter/shared/widgets/auto_grid.dart';
import 'package:app_flutter/shared/widgets/section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 2. Atributos Base — cinco caixas com dados (d4…d20) e DT.
class AttributesSection extends ConsumerWidget {
  /// Cria a seção.
  const AttributesSection({required this.characterId, super.key});

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

    final restantes = derived.pontosAtributoRestantes;
    final (statusText, statusColor) = switch (true) {
      _ when restantes > 0 => (
          'Você tem $restantes ponto${restantes == 1 ? '' : 's'} de atributo '
              'não gasto${restantes == 1 ? '' : 's'}.',
          AppColors.accentCyan,
        ),
      _ when restantes < 0 => (
          'Atributos excedem o limite em ${restantes.abs()} '
              'ponto${restantes == -1 ? '' : 's'}.',
          AppColors.accentRed,
        ),
      _ => (
          'Todos os pontos de atributo foram distribuídos.',
          AppColors.textMuted,
        ),
    };

    return SectionCard(
      title: 'Atributos Base',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AutoGrid.grid5([
            for (final attribute in AttributeId.values)
              _AttributeBox(
                characterId: characterId,
                attribute: attribute,
                vm: vm,
                character: character,
              ),
          ]),
          const SizedBox(height: 12),
          Text(
            statusText,
            style: TextStyle(color: statusColor, fontSize: 14.4),
          ),
        ],
      ),
    );
  }
}

class _AttributeBox extends StatelessWidget {
  const _AttributeBox({
    required this.characterId,
    required this.attribute,
    required this.vm,
    required this.character,
  });

  final String characterId;
  final AttributeId attribute;
  final SheetViewModel vm;
  final Character character;

  @override
  Widget build(BuildContext context) {
    final state = character.atributos
        .firstWhere((a) => a.nome == attribute.jsonName);
    return DiceShapeBox(
      label: attribute.label,
      shape: diceShapeForValue(state.valor),
      value: state.valor,
      dt: AttributeRules.dt(state.valor, character.nivel),
      onChanged: (value) =>
          vm.setAtributo(attribute.jsonName, valor: value),
    );
  }
}
