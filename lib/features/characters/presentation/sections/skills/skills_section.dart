import 'package:app_flutter/app/providers.dart';
import 'package:app_flutter/app/theme/tokens.dart';
import 'package:app_flutter/features/catalog/catalog.dart' show ProgressionRow;
import 'package:app_flutter/features/characters/domain/character.dart';
import 'package:app_flutter/features/characters/domain/rules/skills.dart';
import 'package:app_flutter/features/characters/presentation/viewmodels/sheet_view_model.dart';
import 'package:app_flutter/shared/widgets/app_field.dart';
import 'package:app_flutter/shared/widgets/section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 8. Perícias — categorias, treino, dado resultante, bônus e "Ajudado".
class SkillsSection extends ConsumerStatefulWidget {
  /// Cria a seção.
  const SkillsSection({required this.characterId, super.key});

  /// Id da ficha aberta.
  final String characterId;

  @override
  ConsumerState<SkillsSection> createState() => _SkillsSectionState();
}

class _SkillsSectionState extends ConsumerState<SkillsSection> {
  // Estado de tela: quais perícias estão marcadas como "Ajudado".
  final Set<int> _ajudadas = {};

  @override
  Widget build(BuildContext context) {
    final character = ref
        .watch(sheetProvider(widget.characterId))
        .requireValue;
    final vm = ref.read(sheetProvider(widget.characterId).notifier);
    final progressao =
        ref.watch(progressaoProvider).value ?? <ProgressionRow>[];
    final rows = progressao
        .map((r) => (nivel: r.nivel, categoria: r.categoria))
        .toList(growable: false);

    final intelecto = character.atributos
        .firstWhere((a) => a.nome == 'intelecto')
        .valor;
    final contador = SkillRules.contadorTexto(
      nivel: character.nivel,
      intelecto: intelecto,
      progressao: rows,
      pericias: character.pericias,
    );
    final problemas = SkillRules.problemas(
      nivel: character.nivel,
      intelecto: intelecto,
      progressao: rows,
      pericias: character.pericias,
    );

    return SectionCard(
      title: 'Perícias',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            contador,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          if (problemas.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              problemas.join(' '),
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 16,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 10),
          for (var i = 0; i < periciasBase.length; i++) ...[
            if (i == 0 ||
                periciasBase[i].categoria != periciasBase[i - 1].categoria)
              _CategoryTitle(periciasBase[i].categoria),
            _SkillRow(
              definition: periciasBase[i],
              state: character.pericias[i],
              ajudado: _ajudadas.contains(i),
              onTreinamento: (value) =>
                  vm.setPericiaTreinamento(i, value),
              onBonus: (value) => vm.setPericiaBonus(i, value),
              onAjudado: (checked) => setState(() {
                if (checked) {
                  _ajudadas.add(i);
                } else {
                  _ajudadas.remove(i);
                }
              }),
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryTitle extends StatelessWidget {
  const _CategoryTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 8),
      child: Container(
        padding: const EdgeInsets.only(bottom: 4),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
        ),
        child: Text(
          title,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _SkillRow extends StatelessWidget {
  const _SkillRow({
    required this.definition,
    required this.state,
    required this.ajudado,
    required this.onTreinamento,
    required this.onBonus,
    required this.onAjudado,
  });

  final SkillDefinition definition;
  final SkillState state;
  final bool ajudado;
  final ValueChanged<String> onTreinamento;
  final ValueChanged<int> onBonus;
  final ValueChanged<bool> onAjudado;

  @override
  Widget build(BuildContext context) {
    final dado = SkillRules.diceFor(state, ajudado: ajudado);
    final badges = <(String, bool)>[
      (definition.atributo, false),
      if (definition.carga) ('Penalidade Carga', true),
      if (definition.somenteTreinado) ('Somente Treinado', false),
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        border: Border.all(color: AppColors.rowBorder),
        borderRadius: BorderRadius.circular(AppRadii.input),
      ),
      child: Row(
        children: [
          // Nome + badges (2fr)
          Expanded(
            flex: 2,
            child: Wrap(
              spacing: 6,
              runSpacing: 2,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  definition.nome,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 14.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                for (final (texto, warn) in badges)
                  _SkillBadge(texto: texto, warn: warn),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Treino + dado (1.2fr)
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: AppDropdown(
                    value: state.treinamento,
                    items: const [
                      ('Destreinado', 'Destreinado'),
                      ('Treinado', 'Treinado'),
                      ('Veterano', 'Veterano'),
                      ('Expert', 'Expert'),
                    ],
                    onChanged: onTreinamento,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  constraints: const BoxConstraints(minWidth: 32),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.inputBorder,
                    borderRadius: BorderRadius.circular(AppRadii.input),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    dado,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Bônus (0.8fr)
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Bônus:',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 14.4,
                  ),
                ),
                const SizedBox(width: 6),
                BoundNumberField(
                  value: state.bonus,
                  width: 60,
                  onChanged: onBonus,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Ajudado
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: ajudado ? const Color(0xFF282836) : AppColors.inputBg,
              border: Border.all(
                color: ajudado ? AppColors.primary : AppColors.inputBorder,
              ),
              borderRadius: BorderRadius.circular(AppRadii.input),
            ),
            child: WebCheckbox(
              value: ajudado,
              label: 'Ajudado',
              labelStyle: TextStyle(
                color: ajudado ? AppColors.text : AppColors.textMuted,
                fontSize: 12,
              ),
              onChanged: onAjudado,
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillBadge extends StatelessWidget {
  const _SkillBadge({required this.texto, required this.warn});

  final String texto;
  final bool warn;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: warn ? const Color(0xFF5A2A2A) : AppColors.badgeBg,
        borderRadius: BorderRadius.circular(AppRadii.input),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: warn ? AppColors.warnText : const Color(0xFFAAAAAA),
          fontSize: 11.2,
        ),
      ),
    );
  }
}

/// Lista dos nomes das perícias para os dropdowns de combate.
List<String> skillNames() =>
    periciasBase.map((def) => def.nome).toList(growable: false);

/// Atributo de uma perícia pelo nome.
String skillAttribute(String nome) =>
    periciasBase.firstWhere((def) => def.nome == nome).atributo;
