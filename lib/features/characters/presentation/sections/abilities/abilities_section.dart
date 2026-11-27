import 'dart:async';

import 'package:app_flutter/app/providers.dart';
import 'package:app_flutter/app/theme/tokens.dart';
import 'package:app_flutter/features/catalog/catalog.dart'
    show Ability;
import 'package:app_flutter/features/catalog/presentation/pickers/ability_picker.dart';
import 'package:app_flutter/features/characters/presentation/viewmodels/sheet_view_model.dart';
import 'package:app_flutter/shared/widgets/app_button.dart';
import 'package:app_flutter/shared/widgets/app_field.dart';
import 'package:app_flutter/shared/widgets/app_modal.dart';
import 'package:app_flutter/shared/widgets/delete_card_button.dart';
import 'package:app_flutter/shared/widgets/section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
/// 10. Habilidades — contador de slots + lista de cards em linha
/// (manuais + automáticas de origem/perfil).
class AbilitiesSection extends ConsumerWidget {
  /// Cria a seção.
  const AbilitiesSection({required this.characterId, super.key});

  /// Id da ficha aberta.
  final String characterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final character =
        ref.watch(sheetProvider(characterId)).requireValue;
    final vm = ref.read(sheetProvider(characterId).notifier);
    final progressao =
        ref.watch(progressaoProvider).value ?? const [];

    final slotsLiberados = progressao
        .where((row) => row.categoria == 'Habilidade' && row.nivel <= character.nivel)
        .length;
    final slotsUsados = character.habilidades
        .where((habilidade) => !habilidade.automatico)
        .length;
    final slotsLivres = (slotsLiberados - slotsUsados).clamp(0, slotsLiberados);

    return SectionCard(
      title: 'Habilidades',
      trailing: SmallButton(
        label: '+ Nova Habilidade',
        onPressed: () => _abrirCatalogo(context, vm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Slots de habilidades — ocupados: $slotsUsados; '
            'livres: $slotsLivres; total liberado: $slotsLiberados.',
            style: const TextStyle(color: AppColors.text, fontSize: 16),
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < character.habilidades.length; i++)
            _AbilityCard(
              habilidade: character.habilidades[i],
              onTap: () => _abrirModal(context, vm, i),
              onDelete: character.habilidades[i].automatico
                  ? null
                  : () => vm.removeHabilidade(i),
            ),
        ],
      ),
    );
  }

  /// Abre o catálogo de habilidades; o clique preenche o formulário
  /// (comportamento do web).
  void _abrirCatalogo(BuildContext context, SheetViewModel vm) {
    unawaited(
      showAppModal(
        context: context,
        title: 'Nova Habilidade',
        builder: (dialogContext) => AbilityPicker(
          onSelect: (habilidade) {
            Navigator.of(dialogContext).pop();
            _abrirModal(context, vm, null, inicial: habilidade);
          },
        ),
      ),
    );
  }

  void _abrirModal(
    BuildContext context,
    SheetViewModel vm,
    int? index, {
    Ability? inicial,
  }) {
    final character = vm.current;
    final isEdit = index != null;
    final initial = isEdit ? character.habilidades[index] : null;
    if (!isEdit && inicial != null) {
      // Fluxo do catálogo: pré-preencher e deixar o usuário salvar.
    }
    final readOnly = initial != null && initial.automatico;
    final titulo = !isEdit
        ? 'Nova Habilidade'
        : readOnly
            ? _tituloAutomatica(initial)
            : 'Editar Habilidade';
    unawaited(
      showAppModal(
        context: context,
        title: titulo,
        builder: (dialogContext) => _AbilityForm(
          initial: initial,
          readOnly: readOnly,
          onSave: (habilidade) async {
            if (isEdit) {
              await vm.setHabilidade(index, habilidade);
            } else {
              await vm.addHabilidade(habilidade);
            }
            if (dialogContext.mounted) {
              Navigator.of(dialogContext).pop();
            }
          },
        ),
      ),
    );
  }

  static String _tituloAutomatica(Ability habilidade) {
    final classificacao = habilidade.classificacao;
    if (classificacao.startsWith('Habilidade de Origem')) {
      return '${habilidade.nome} · Origem';
    }
    if (classificacao.startsWith('Habilidade de Perfil')) {
      return '${habilidade.nome} · Perfil';
    }
    return '${habilidade.nome} · Arquétipo';
  }
}

class _AbilityCard extends StatelessWidget {
  const _AbilityCard({
    required this.habilidade,
    required this.onTap,
    required this.onDelete,
  });

  final Ability habilidade;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  String get _subtitulo {
    if (!habilidade.automatico) {
      return '';
    }
    final classificacao = habilidade.classificacao;
    if (classificacao.startsWith('Habilidade de Origem')) {
      return 'Origem';
    }
    if (classificacao.startsWith('Habilidade de Perfil')) {
      return 'Perfil';
    }
    final nivel = habilidade.nivelDesbloqueio;
    return 'Arquétipo · Nível ${nivel ?? '?'}';
  }

  @override
  Widget build(BuildContext context) {
    final detalhes = <String>[
      if (!habilidade.automatico && habilidade.classificacao.isNotEmpty)
        habilidade.classificacao,
      if (habilidade.prereq.isNotEmpty) 'Pré-requisito: ${habilidade.prereq}',
      if (habilidade.custo.isNotEmpty) 'Custo: ${habilidade.custo}',
      if (habilidade.alcance.isNotEmpty) 'Alcance: ${habilidade.alcance}',
    ];
    final efeito = habilidade.efeito;

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
                  habilidade.nome.isEmpty ? '(Sem Nome)' : habilidade.nome,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (_subtitulo.isNotEmpty)
                  Text(
                    _subtitulo,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                if (detalhes.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: [
                      for (final detalhe in detalhes)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.detailBg,
                            borderRadius:
                                BorderRadius.circular(AppRadii.input),
                          ),
                          child: Text(
                            detalhe,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12.2,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
                if (efeito.isNotEmpty) ...[
                  const SizedBox(height: 9),
                  Text(
                    efeito,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: _densidadeTexto(efeito.length),
                      height: 1.45,
                    ),
                  ),
                ],
              ],
            ),
            if (onDelete != null)
              Positioned(
                top: 0,
                right: 0,
                child: DeleteCardButton(onPressed: onDelete!),
              ),
          ],
        ),
      ),
    );
  }

  static double _densidadeTexto(int length) {
    if (length > 700) {
      return 11.8;
    }
    if (length > 350) {
      return 12.8;
    }
    if (length > 160) {
      return 13.8;
    }
    return 14.7;
  }
}

/// Formulário do modal de habilidades (catálogo chega com o pipeline de
/// assets; hoje aceita criação manual, como o botão "Criar novo" do web).
class _AbilityForm extends StatefulWidget {
  const _AbilityForm({
    required this.onSave,
    this.initial,
    this.readOnly = false,
  });

  final Ability? initial;
  final ValueChanged<Ability> onSave;
  final bool readOnly;

  @override
  State<_AbilityForm> createState() => _AbilityFormState();
}

class _AbilityFormState extends State<_AbilityForm> {
  late final TextEditingController _nome;
  late final TextEditingController _classificacao;
  late final TextEditingController _prereq;
  late final TextEditingController _custo;
  late final TextEditingController _alcance;
  late final TextEditingController _efeito;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _nome = TextEditingController(text: initial?.nome ?? '');
    _classificacao =
        TextEditingController(text: initial?.classificacao ?? '');
    _prereq = TextEditingController(text: initial?.prereq ?? '');
    _custo = TextEditingController(text: initial?.custo ?? '');
    _alcance = TextEditingController(text: initial?.alcance ?? '');
    _efeito = TextEditingController(text: initial?.efeito ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final readOnly = widget.readOnly;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _labeled('Nome', _nome, readOnly),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _labeled('Classificação', _classificacao, readOnly),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(child: _labeled('Pré-requisitos', _prereq, readOnly)),
            const SizedBox(width: 15),
            Expanded(child: _labeled('Custo', _custo, readOnly)),
          ],
        ),
        const SizedBox(height: 15),
        _labeled('Alcance', _alcance, readOnly),
        const SizedBox(height: 15),
        const Text(
          'Efeito',
          style: TextStyle(color: AppColors.textMuted, fontSize: 13.6),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: _efeito,
          readOnly: readOnly,
          minLines: 4,
          maxLines: 8,
          style: const TextStyle(color: Colors.white, fontSize: 15.2),
          decoration: const InputDecoration(
            hintText: 'Descreva os efeitos da habilidade...',
          ),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            DangerButton(
              label: readOnly ? 'Fechar' : 'Cancelar',
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 10),
            if (!readOnly)
              AppButton(
                label: 'Salvar',
                onPressed: () {
                  widget.onSave(
                    Ability(
                      nome: _nome.text.trim(),
                      classificacao: _classificacao.text.trim(),
                      prereq: _prereq.text.trim(),
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

  Widget _labeled(
    String label,
    TextEditingController controller,
    bool readOnly,
  ) {
    return FieldLabel(
      label: label,
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        style: const TextStyle(color: Colors.white, fontSize: 15.2),
      ),
    );
  }
}
