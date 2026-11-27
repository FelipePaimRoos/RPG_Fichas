import 'package:app_flutter/app/providers.dart';
import 'package:app_flutter/app/theme/tokens.dart';
import 'package:app_flutter/features/catalog/catalog.dart'
    show ProgressionRow;
import 'package:app_flutter/features/characters/presentation/viewmodels/sheet_view_model.dart';
import 'package:app_flutter/shared/widgets/app_field.dart';
import 'package:app_flutter/shared/widgets/auto_grid.dart';
import 'package:app_flutter/shared/widgets/section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 1. Informações Gerais — réplica da primeira seção da ficha web.
class GeneralSection extends ConsumerWidget {
  /// Cria a seção.
  const GeneralSection({required this.characterId, super.key});

  /// Id da ficha aberta.
  final String characterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final character =
        ref.watch(sheetProvider(characterId)).requireValue;
    final vm = ref.read(sheetProvider(characterId).notifier);
    final origens = ref.watch(origensProvider).value ?? const [];
    final perfis = ref.watch(perfisProvider).value ?? const [];
    final progressao = ref.watch(progressaoProvider).value ?? const [];

    return SectionCard(
      title: 'Informações Gerais',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AutoGrid.grid3([
            FieldLabel(
              label: 'Nome do Personagem',
              child: BoundTextField(
                value: character.nome,
                onChanged: (value) => vm.set((c) => c.nome = value),
              ),
            ),
            FieldLabel(
              label: 'Jogador',
              child: BoundTextField(
                value: character.jogador,
                onChanged: (value) => vm.set((c) => c.jogador = value),
              ),
            ),
            FieldLabel(
              label: 'Nível',
              child: BoundNumberField(
                value: character.nivel,
                onChanged: (value) =>
                    vm.set((c) => c.nivel = value.clamp(1, 20)),
              ),
            ),
            FieldLabel(
              label: 'Conceito',
              child: BoundTextField(
                value: character.conceito,
                onChanged: (value) => vm.set((c) => c.conceito = value),
              ),
            ),
            FieldLabel(
              label: 'Origem',
              child: AppDropdown(
                value: character.origem,
                items: [
                  const ('', 'Selecione uma origem'),
                  for (final origem in origens) (origem.nome, origem.nome),
                ],
                onChanged: (value) => vm.setOrigem(
                  value,
                  origens.where((o) => o.nome == value).firstOrNull,
                ),
              ),
            ),
            FieldLabel(
              label: 'Perfil',
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppDropdown(
                    value: character.perfil,
                    items: [
                      const ('', 'Selecione um perfil'),
                      for (final perfil in perfis) (perfil.nome, perfil.nome),
                    ],
                    onChanged: (value) => vm.setPerfil(
                      value,
                      perfis.where((p) => p.nome == value).firstOrNull,
                    ),
                  ),
                  if (character.perfil.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'É necessário escolher um perfil para esta ficha.',
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 13.6,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (character.perfil == 'Analista')
              FieldLabel(
                label: 'Marcadores de Análise (0 a 4)',
                child: BoundNumberField(
                  value: character.marcadoresAnalise,
                  onChanged: (value) => vm.set(
                    (c) => c.marcadoresAnalise = value.clamp(0, 4),
                  ),
                ),
              ),
            if (character.perfil == 'Executor')
              _ImpetoSelector(
                valor: character.impeto,
                onChanged: (value) => vm.set((c) => c.impeto = value),
              ),
          ]),
          _ProgressaoNiveis(
            nivel: character.nivel,
            progressao: progressao,
          ),
        ],
      ),
    );
  }
}

class _ImpetoSelector extends StatelessWidget {
  const _ImpetoSelector({required this.valor, required this.onChanged});

  final int valor;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ímpeto',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            for (var espaco = 1; espaco <= 5; espaco++) ...[
              if (espaco > 1) const SizedBox(width: 6),
              Expanded(
                child: _ImpetoSegment(
                  label: '$espaco',
                  active: espaco <= valor,
                  onPressed: () => onChanged(espaco),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _ImpetoSegment extends StatelessWidget {
  const _ImpetoSegment({
    required this.label,
    required this.active,
    required this.onPressed,
  });

  final String label;
  final bool active;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? AppColors.impetoActive : AppColors.impetoBg,
            border: Border.all(
              color: active ? AppColors.impetoActiveBorder : AppColors.impetoBorder,
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ),
    );
  }
}

class _ProgressaoNiveis extends StatefulWidget {
  const _ProgressaoNiveis({required this.nivel, required this.progressao});

  final int nivel;
  final List<ProgressionRow> progressao;

  @override
  State<_ProgressaoNiveis> createState() => _ProgressaoNiveisState();
}

class _ProgressaoNiveisState extends State<_ProgressaoNiveis> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final atual = widget.progressao
        .where((row) => row.nivel == widget.nivel)
        .firstOrNull;
    final resumo = atual == null
        ? 'Carregando progressão...'
        : 'Nível ${widget.nivel}: ${atual.categoria} — ${atual.recurso}';

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => _open = !_open),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'Progressão de nível (1 a 20)',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  decoration: _open ? TextDecoration.none : null,
                ),
              ),
            ),
          ),
          if (_open) ...[
            Text(
              resumo,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 14.4,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 520),
                child: Table(
                  border: TableBorder.all(color: AppColors.cardBorder),
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    const TableRow(
                      decoration:
                          BoxDecoration(color: AppColors.inputBg),
                      children: [
                        _ThCell('Nível'),
                        _ThCell('Categoria do recurso'),
                        _ThCell('Recurso obtido'),
                      ],
                    ),
                    for (final row in widget.progressao)
                      TableRow(
                        decoration: BoxDecoration(
                          color: row.nivel == widget.nivel
                              ? const Color(0x2EFF5757)
                              : Colors.transparent,
                        ),
                        children: [
                          _TdCell('${row.nivel}', bold: row.nivel == widget.nivel),
                          _TdCell(row.categoria, bold: row.nivel == widget.nivel),
                          _TdCell(row.recurso, bold: row.nivel == widget.nivel),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ThCell extends StatelessWidget {
  const _ThCell(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: const TextStyle(color: AppColors.textMuted, fontSize: 13.6),
      ),
    );
  }
}

class _TdCell extends StatelessWidget {
  const _TdCell(this.text, {required this.bold});

  final String text;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.text,
          fontSize: 13.6,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
    );
  }
}
