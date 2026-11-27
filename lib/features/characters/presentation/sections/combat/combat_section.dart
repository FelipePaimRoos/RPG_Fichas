import 'package:app_flutter/app/theme/tokens.dart';
import 'package:app_flutter/features/characters/domain/character.dart';
import 'package:app_flutter/features/characters/domain/rules/combat.dart';
import 'package:app_flutter/features/characters/domain/rules/skills.dart'
    show periciasBase;
import 'package:app_flutter/features/characters/presentation/viewmodels/sheet_view_model.dart';
import 'package:app_flutter/shared/domain/attribute.dart';
import 'package:app_flutter/shared/widgets/app_button.dart';
import 'package:app_flutter/shared/widgets/app_field.dart';
import 'package:app_flutter/shared/widgets/section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 9. Combate / Testes de Ataque — cards efêmeros como no web.
class CombatSection extends ConsumerStatefulWidget {
  /// Cria a seção.
  const CombatSection({required this.characterId, super.key});

  /// Id da ficha aberta.
  final String characterId;

  @override
  ConsumerState<CombatSection> createState() => _CombatSectionState();
}

class _CombatSectionState extends ConsumerState<CombatSection> {
  final List<AttackEntry> _ataques = [];

  @override
  Widget build(BuildContext context) {
    final character = ref
        .watch(sheetProvider(widget.characterId))
        .requireValue;

    return SectionCard(
      title: 'Combate / Testes de Ataque',
      trailing: SmallButton(
        label: '+ Adicionar Ataque',
        onPressed: () => setState(() => _ataques.add(AttackEntry())),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          for (var i = 0; i < _ataques.length; i++)
            _AttackCard(
              entry: _ataques[i],
              character: character,
              onChanged: () => setState(() {}),
              onRemove: () => setState(() => _ataques.removeAt(i)),
            ),
        ],
      ),
    );
  }
}

class _AttackCard extends StatelessWidget {
  const _AttackCard({
    required this.entry,
    required this.character,
    required this.onChanged,
    required this.onRemove,
  });

  final AttackEntry entry;
  final Character character;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final armasNomeados = <(String, String)>[
      ('', '(Nenhuma / Desarmado)'),
      for (final arma in character.armas)
        if (arma.nome.trim().isNotEmpty) (arma.nome, arma.nome),
    ];
    final armaSelecionada = character.armas
        .where((a) => a.nome == entry.armaNome)
        .firstOrNull;

    final valorAtributo = character.atributos
        .firstWhere((a) => a.nome == entry.atributo)
        .valor;
    final indexPericia =
        character.pericias.indexWhere((p) => p.nome == entry.periciaNome);
    final treinoPericia = indexPericia >= 0
        ? character.pericias[indexPericia].treinamento
        : 'Destreinado';

    final result = CombatRules.calcular(
      valorAtributo: valorAtributo,
      nomePericia: entry.periciaNome,
      treinamentoPericia: treinoPericia,
      bonusDado: entry.bonusDado,
      bonusFixo: entry.bonusFixo,
      acaoArriscada: entry.acaoArriscada,
      arma: armaSelecionada,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(AppRadii.box),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Linha 1
          Row(
            children: [
              Expanded(
                child: FieldLabel(
                  label: 'Nome do Ataque',
                  child: BoundTextField(
                    value: entry.nome,
                    hint: 'Ex: Corte Rápido',
                    onChanged: (value) {
                      entry.nome = value;
                      onChanged();
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FieldLabel(
                  label: 'Arma (Inventário)',
                  child: AppDropdown(
                    value: entry.armaNome,
                    items: armasNomeados,
                    onChanged: (value) {
                      entry.armaNome = value;
                      final arma = character.armas
                          .where((a) => a.nome == value)
                          .firstOrNull;
                      if (arma != null && arma.critico.isNotEmpty) {
                        entry.critico = arma.critico;
                      }
                      onChanged();
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FieldLabel(
                  label: 'Atributo / Perícia',
                  child: Row(
                    children: [
                      Expanded(
                        child: AppDropdown(
                          value: entry.atributo,
                          items: [
                            for (final attribute in AttributeId.values)
                              (
                                attribute.jsonName,
                                attribute.label,
                              ),
                          ],
                          onChanged: (value) {
                            entry.atributo = value;
                            onChanged();
                          },
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        flex: 2,
                        child: AppDropdown(
                          value: entry.periciaNome,
                          items: [
                            const ('', '(Nenhuma / Perícia)'),
                            for (final def in periciasBase)
                              (def.nome, '${def.nome} (${def.atributo})'),
                          ],
                          onChanged: (value) {
                            entry.periciaNome = value;
                            onChanged();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FieldLabel(
                  label: 'Ação Arriscada',
                  child: AppDropdown(
                    value: entry.acaoArriscada,
                    items: const [
                      ('normal', 'Normal'),
                      ('2v_dobrar', '2 Desv. (Dobrar Dano)'),
                      ('3v_triplicar', '3 Desv. (Triplicar Dano)'),
                    ],
                    onChanged: (value) {
                      entry.acaoArriscada = value;
                      onChanged();
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FieldLabel(
                  label: 'Crítico',
                  child: BoundTextField(
                    value: entry.critico,
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      entry.critico = value;
                      onChanged();
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              DangerButton(label: 'X', onPressed: onRemove),
            ],
          ),
          const SizedBox(height: 10),
          // Linha 2 — resultados
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.bg,
              border: Border.all(color: AppColors.rowBorder),
              borderRadius: BorderRadius.circular(AppRadii.input),
            ),
            child: Row(
              children: [
                FieldLabel(
                  label: 'Bônus Dado',
                  child: BoundTextField(
                    value: entry.bonusDado,
                    hint: '+d6',
                    width: 65,
                    onChanged: (value) {
                      entry.bonusDado = value;
                      onChanged();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                FieldLabel(
                  label: 'Bônus Fixo',
                  child: BoundNumberField(
                    value: entry.bonusFixo,
                    width: 65,
                    onChanged: (value) {
                      entry.bonusFixo = value;
                      onChanged();
                    },
                  ),
                ),
                const SizedBox(width: 15),
                _ResultColumn(
                  label: 'Dado de Ataque:',
                  value: result.dadoAtaque,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 15),
                _ResultColumn(
                  label: 'Dano Base:',
                  value: result.dano,
                  color: Colors.white,
                ),
                const SizedBox(width: 15),
                _ResultColumn(
                  label: 'Dano Crítico:',
                  value: result.critico,
                  color: AppColors.error,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultColumn extends StatelessWidget {
  const _ResultColumn({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12.8,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
