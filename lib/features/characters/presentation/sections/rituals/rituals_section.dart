import 'dart:async';

import 'package:app_flutter/app/theme/tokens.dart';
import 'package:app_flutter/features/catalog/catalog.dart'
    show Ritual;
import 'package:app_flutter/features/catalog/presentation/pickers/ritual_picker.dart';
import 'package:app_flutter/features/characters/presentation/viewmodels/sheet_view_model.dart';
import 'package:app_flutter/shared/domain/element.dart';
import 'package:app_flutter/shared/widgets/app_button.dart';
import 'package:app_flutter/shared/widgets/app_field.dart';
import 'package:app_flutter/shared/widgets/app_modal.dart';
import 'package:app_flutter/shared/widgets/delete_card_button.dart';
import 'package:app_flutter/shared/widgets/section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 11. Rituais — grid de cards com cor por elemento + modal.
class RitualsSection extends ConsumerWidget {
  /// Cria a seção.
  const RitualsSection({required this.characterId, super.key});

  /// Id da ficha aberta.
  final String characterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final character =
        ref.watch(sheetProvider(characterId)).requireValue;
    final vm = ref.read(sheetProvider(characterId).notifier);

    return SectionCard(
      title: 'Rituais',
      trailing: SmallButton(
        label: '+ Novo Ritual',
        onPressed: () => _abrirCatalogo(context, vm),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (var i = 0; i < character.rituais.length; i++)
            _RitualCard(
              ritual: character.rituais[i],
              onTap: () => _abrirModal(context, vm, i),
              onDelete: () => vm.removeRitual(i),
            ),
        ],
      ),
    );
  }

  /// Abre o catálogo de rituais; item vazio do botão "Criar ritual novo"
  /// cai no formulário manual, como no web.
  void _abrirCatalogo(BuildContext context, SheetViewModel vm) {
    unawaited(
      showAppModal(
        context: context,
        title: 'Adicionar Ritual',
        maxWidth: 750,
        builder: (dialogContext) => RitualPicker(
          onSelect: (ritual) {
            if (ritual.nome.isEmpty) {
              Navigator.of(dialogContext).pop();
              _abrirModal(context, vm, null, inicial: ritual);
            } else {
              unawaited(vm.addRitual(ritual));
              Navigator.of(dialogContext).pop();
            }
          },
        ),
      ),
    );
  }

  void _abrirModal(
    BuildContext context,
    SheetViewModel vm,
    int? index, {
    Ritual? inicial,
  }) {
    unawaited(
      showAppModal(
        context: context,
        title: index == null ? 'Novo Ritual' : 'Editar Ritual',
        maxWidth: 750,
        builder: (dialogContext) => _RitualForm(
          initial: inicial ?? (index == null ? null : vm.current.rituais[index]),
          onSave: (ritual) async {
            if (index == null) {
              await vm.addRitual(ritual);
            } else {
              await vm.setRitual(index, ritual);
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

class _RitualCard extends StatelessWidget {
  const _RitualCard({
    required this.ritual,
    required this.onTap,
    required this.onDelete,
  });

  final Ritual ritual;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final elemento = ritual.detectarElemento();
    final color = elemento?.color;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.box),
      child: Container(
        width: 340,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.inputBg,
          border: Border.all(color: AppColors.inputBorder),
          borderRadius: BorderRadius.circular(AppRadii.box),
          boxShadow: [
            if (color != null)
              BoxShadow(color: color.withAlpha(0)),
          ],
        ),
        // Borda esquerda colorida de 4px (classes .ritual-*).
        foregroundDecoration: color == null
            ? null
            : BoxDecoration(
                border: Border(
                  left: BorderSide(color: color, width: 4),
                ),
                borderRadius: BorderRadius.circular(AppRadii.box),
              ),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ritual.nome.isEmpty ? '(Sem Nome)' : ritual.nome,
                  style: TextStyle(
                    color: color ?? AppColors.text,
                    fontSize: 15.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (ritual.classificacao.isNotEmpty ||
                    ritual.elemento.isNotEmpty)
                  Text(
                    [
                      ritual.elemento,
                      ritual.classificacao,
                    ].where((s) => s.isNotEmpty).join(' · '),
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                if (ritual.efeito.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    ritual.efeito,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12.5,
                      height: 1.45,
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

class _RitualForm extends StatefulWidget {
  const _RitualForm({required this.onSave, this.initial});

  final Ritual? initial;
  final ValueChanged<Ritual> onSave;

  @override
  State<_RitualForm> createState() => _RitualFormState();
}

class _RitualFormState extends State<_RitualForm> {
  late final TextEditingController _nome;
  late String _circulo;
  late String _elemento;
  late String _execucao;
  late final TextEditingController _custo;
  late final TextEditingController _alcance;
  late final TextEditingController _efeito;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _nome = TextEditingController(text: initial?.nome ?? '');
    _circulo = initial?.classificacao ?? '1° Círculo';
    _elemento = initial?.elemento ?? 'Sangue';
    _execucao = 'Padrão';
    _custo = TextEditingController(text: initial?.custo ?? '');
    _alcance = TextEditingController(text: initial?.alcance ?? '');
    _efeito = TextEditingController(text: initial?.efeito ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: FieldLabel(label: 'Nome', child: TextField(controller: _nome, style: const TextStyle(color: Colors.white, fontSize: 15.2)))),
            const SizedBox(width: 15),
            Expanded(
              child: FieldLabel(
                label: 'Círculo',
                child: AppDropdown(
                  value: _circulo,
                  items: const [
                    ('1° Círculo', '1° Círculo'),
                    ('2° Círculo', '2° Círculo'),
                    ('3° Círculo', '3° Círculo'),
                    ('4° Círculo', '4° Círculo'),
                  ],
                  onChanged: (value) => setState(() => _circulo = value),
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
            const SizedBox(width: 15),
            Expanded(
              child: FieldLabel(
                label: 'Execução',
                child: AppDropdown(
                  value: _execucao,
                  items: const [
                    ('Padrão', 'Padrão'),
                    ('Completa', 'Completa'),
                    ('Livre', 'Livre'),
                    ('Reação', 'Reação'),
                    ('Cena', 'Cena'),
                  ],
                  onChanged: (value) => setState(() => _execucao = value),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(child: FieldLabel(label: 'Custo (SAN)', child: TextField(controller: _custo, style: const TextStyle(color: Colors.white, fontSize: 15.2)))),
            const SizedBox(width: 15),
            Expanded(child: FieldLabel(label: 'Alcance', child: TextField(controller: _alcance, style: const TextStyle(color: Colors.white, fontSize: 15.2)))),
          ],
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
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            DangerButton(
              label: 'Cancelar',
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 10),
            AppButton(
              label: 'Salvar na ficha',
              onPressed: () {
                widget.onSave(
                  Ritual(
                    nome: _nome.text.trim(),
                    classificacao: _circulo,
                    elemento: _elemento,
                    custo: _custo.text.trim(),
                    alcance: _alcance.text.trim(),
                    efeito: _efeito.text,
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
