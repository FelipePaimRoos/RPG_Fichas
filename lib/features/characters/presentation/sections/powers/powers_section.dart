import 'dart:async';

import 'package:app_flutter/app/theme/tokens.dart';
import 'package:app_flutter/features/catalog/catalog.dart' show Power;
import 'package:app_flutter/features/catalog/presentation/pickers/power_picker.dart';
import 'package:app_flutter/features/characters/presentation/viewmodels/sheet_view_model.dart';
import 'package:app_flutter/shared/domain/element.dart';
import 'package:app_flutter/shared/widgets/app_button.dart';
import 'package:app_flutter/shared/widgets/app_field.dart';
import 'package:app_flutter/shared/widgets/app_modal.dart';
import 'package:app_flutter/shared/widgets/delete_card_button.dart';
import 'package:app_flutter/shared/widgets/section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 12. Poderes Paranormais — linhas com cor por elemento + modal.
class PowersSection extends ConsumerWidget {
  /// Cria a seção.
  const PowersSection({required this.characterId, super.key});

  /// Id da ficha aberta.
  final String characterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final character =
        ref.watch(sheetProvider(characterId)).requireValue;
    final vm = ref.read(sheetProvider(characterId).notifier);

    final sorted = [...character.poderes]
      ..sort(
        (a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()),
      );

    return SectionCard(
      title: 'Poderes Paranormais',
      trailing: SmallButton(
        label: '+ Novo Poder',
        onPressed: () => _abrirCatalogo(context, vm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final poder in sorted)
            _PowerRow(
              poder: poder,
              afinidadeAtiva: normalizeElement(character.afinidadeElemento)
                      ?.name ==
                  normalizeElement(poder.elemento)?.name,
              onTap: () => _abrirModal(context, vm, character.poderes.indexOf(poder)),
              onDelete: () => vm.removePoder(character.poderes.indexOf(poder)),
            ),
        ],
      ),
    );
  }

  /// Abre o catálogo de poderes; "Criar novo poder" cai no formulário
  /// manual, como no web.
  void _abrirCatalogo(BuildContext context, SheetViewModel vm) {
    unawaited(
      showAppModal(
        context: context,
        title: 'Adicionar Poderes Paranormais',
        builder: (dialogContext) => PowerPicker(
          onSelect: (poder) {
            Navigator.of(dialogContext).pop();
            if (poder.nome.isEmpty) {
              unawaited(
                Future<void>.delayed(Duration.zero),
              );
              _abrirModal(context, vm, null);
            } else {
              unawaited(vm.addPoder(poder));
            }
          },
        ),
      ),
    );
  }

  void _abrirModal(BuildContext context, SheetViewModel vm, int? index) {
    unawaited(
      showAppModal(
        context: context,
        title: index == null
            ? 'Novo Poder Paranormal'
            : 'Editar Poder Paranormal',
        builder: (dialogContext) => _PowerForm(
          initial: index == null ? null : vm.current.poderes[index],
          onSave: (poder) async {
            if (index == null) {
              await vm.addPoder(poder);
            } else {
              await vm.setPoder(index, poder);
            }
            if (dialogContext.mounted) {
              Navigator.of(dialogContext).pop();
            }
          },
        ),
      ),
    );
  }
}

class _PowerRow extends StatelessWidget {
  const _PowerRow({
    required this.poder,
    required this.afinidadeAtiva,
    required this.onTap,
    required this.onDelete,
  });

  final Power poder;
  final bool afinidadeAtiva;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final elemento = poder.element;
    final color = elemento?.color ?? AppColors.text;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.box),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.only(
          left: 16,
          right: 42,
          top: 14,
          bottom: 14,
        ),
        foregroundDecoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: color, width: 4),
          ),
          borderRadius: BorderRadius.circular(AppRadii.box),
        ),
        decoration: BoxDecoration(
          color: AppColors.inputBg,
          border: Border.all(color: AppColors.inputBorder),
          borderRadius: BorderRadius.circular(AppRadii.box),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  poder.nome.isEmpty ? '(Sem Nome)' : poder.nome,
                  style: TextStyle(
                    color: color,
                    fontSize: 15.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  [poder.elemento, poder.prereq]
                      .where((s) => s.isNotEmpty)
                      .join(' · '),
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                if (poder.efeito.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    poder.efeito,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12.5,
                      height: 1.45,
                    ),
                  ),
                ],
                if (poder.afinidade.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.only(top: 7),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: AppColors.cardBorder),
                      ),
                    ),
                    child: Text(
                      'Bônus de Afinidade: ${poder.afinidade}',
                      style: TextStyle(
                        color: afinidadeAtiva
                            ? AppColors.gold
                            : AppColors.textMuted,
                        fontSize: 12.5,
                        height: 1.45,
                        fontWeight:
                            afinidadeAtiva ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: DeleteCardButton(onPressed: onDelete),
            ),
          ],
        ),
      ),
    );
  }
}

class _PowerForm extends StatefulWidget {
  const _PowerForm({required this.onSave, this.initial});

  final Power? initial;
  final ValueChanged<Power> onSave;

  @override
  State<_PowerForm> createState() => _PowerFormState();
}

class _PowerFormState extends State<_PowerForm> {
  late final TextEditingController _nome;
  late String _elemento;
  late final TextEditingController _prereq;
  late final TextEditingController _custo;
  late final TextEditingController _alcance;
  late final TextEditingController _efeito;
  late final TextEditingController _afinidade;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _nome = TextEditingController(text: initial?.nome ?? '');
    _elemento = initial == null || initial.elemento.isEmpty
        ? 'Sangue'
        : initial.elemento;
    _prereq = TextEditingController(text: initial?.prereq ?? '');
    _custo = TextEditingController(text: initial?.custo ?? '');
    _alcance = TextEditingController(text: initial?.alcance ?? '');
    _efeito = TextEditingController(text: initial?.efeito ?? '');
    _afinidade = TextEditingController(text: initial?.afinidade ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: FieldLabel(
                label: 'Nome do Poder',
                child: TextField(
                  controller: _nome,
                  style: const TextStyle(color: Colors.white, fontSize: 15.2),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: FieldLabel(
                label: 'Elemento',
                child: AppDropdown(
                  value: _elemento,
                  items: const [
                    ('Sangue', 'Sangue'),
                    ('Morte', 'Morte'),
                    ('Energia', 'Energia'),
                    ('Conhecimento', 'Conhecimento'),
                  ],
                  onChanged: (value) => setState(() => _elemento = value),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: FieldLabel(
                label: 'Pré-requisito',
                child: TextField(
                  controller: _prereq,
                  style: const TextStyle(color: Colors.white, fontSize: 15.2),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: FieldLabel(
                label: 'Custo',
                child: TextField(
                  controller: _custo,
                  style: const TextStyle(color: Colors.white, fontSize: 15.2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        FieldLabel(
          label: 'Alcance',
          child: TextField(
            controller: _alcance,
            style: const TextStyle(color: Colors.white, fontSize: 15.2),
          ),
        ),
        const SizedBox(height: 15),
        const Text(
          'Efeito',
          style: TextStyle(color: AppColors.textMuted, fontSize: 13.6),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: _efeito,
          minLines: 4,
          maxLines: 8,
          style: const TextStyle(color: Colors.white, fontSize: 15.2),
        ),
        const SizedBox(height: 15),
        const Text(
          'Bônus de Afinidade',
          style: TextStyle(color: AppColors.textMuted, fontSize: 13.6),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: _afinidade,
          minLines: 3,
          maxLines: 6,
          style: const TextStyle(color: Colors.white, fontSize: 15.2),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            DangerButton(
              label: 'Cancelar',
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 10),
            AppButton(
              label: 'Adicionar poder',
              onPressed: () {
                widget.onSave(
                  Power(
                    nome: _nome.text.trim(),
                    elemento: _elemento,
                    prereq: _prereq.text.trim(),
                    custo: _custo.text.trim(),
                    alcance: _alcance.text.trim(),
                    efeito: _efeito.text,
                    afinidade: _afinidade.text.trim(),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
