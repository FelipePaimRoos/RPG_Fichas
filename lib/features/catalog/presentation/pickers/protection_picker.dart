import 'package:app_flutter/app/providers.dart';
import 'package:app_flutter/app/theme/tokens.dart';
import 'package:app_flutter/features/catalog/catalog.dart';
import 'package:app_flutter/features/catalog/presentation/pickers/catalog_picker_shell.dart';
import 'package:app_flutter/shared/widgets/app_button.dart';
import 'package:app_flutter/shared/widgets/app_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


/// Modal "Adicionar Proteção": lista do catálogo + criação manual.
class ProtectionPicker extends ConsumerWidget {
  /// Cria o picker.
  const ProtectionPicker({required this.onSelect, super.key});

  /// Recebe a proteção escolhida/criada.
  final ValueChanged<Protection> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogo = ref.watch(protecoesCatalogoProvider);

    return catalogo.when(
      loading: () =>
          const EmptyCatalogMessage(mensagem: 'Carregando proteções...'),
      error: (_, stack) =>
          const EmptyCatalogMessage(mensagem: 'Erro ao carregar o catálogo.'),
      data: (protecoes) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CatalogListArea(
              children: [
                if (protecoes.isEmpty)
                  const EmptyCatalogMessage(
                    mensagem: 'Nenhuma proteção encontrada.',
                  )
                else
                  for (final protecao in protecoes)
                    CatalogResultRow(
                      title: protecao.nome,
                      subtitle: protecao.tipo,
                      details: [
                        'Bônus: ${protecao.bonusDefesa.isEmpty ? '—' : protecao.bonusDefesa}',
                        'Espaço: ${protecao.espaco.toInt()}',
                        if (protecao.penalidade.isNotEmpty)
                          'Penalidade: ${protecao.penalidade}',
                      ],
                      description: protecao.descricao.isEmpty
                          ? null
                          : protecao.descricao,
                      onSelect: () =>
                          onSelect(protecao.copyWith(personalizada: false)),
                    ),
              ],
            ),
            const Divider(height: 32, thickness: 1),
            const Text(
              'Criar Nova Proteção (só nesta ficha)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            ProtectionForm(
              onSave: (protecao) =>
                  onSelect(protecao.copyWith(personalizada: true)),
            ),
          ],
        );
      },
    );
  }
}

/// Formulário de proteção manual ("Criar Nova Proteção").
class ProtectionForm extends StatefulWidget {
  /// Cria o formulário.
  const ProtectionForm({required this.onSave, this.initial, super.key});

  /// Proteção inicial (edição).
  final Protection? initial;

  /// Salvar.
  final ValueChanged<Protection> onSave;

  @override
  State<ProtectionForm> createState() => _ProtectionFormState();
}

class _ProtectionFormState extends State<ProtectionForm> {
  late final Map<String, TextEditingController> _text;
  late int _espaco;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _text = {
      'nome': TextEditingController(text: initial?.nome ?? ''),
      'bonus': TextEditingController(text: initial?.bonusDefesa ?? ''),
      'rd': TextEditingController(text: initial?.resistenciaDano ?? ''),
      'penalidade': TextEditingController(text: initial?.penalidade ?? ''),
      'descricao': TextEditingController(text: initial?.descricao ?? ''),
    };
    _espaco = initial?.espaco.toInt() ?? 1;
  }

  @override
  Widget build(BuildContext context) {
    Widget field(String label, String key, {String? hint}) => Expanded(
          child: FieldLabel(
            label: label,
            child: TextField(
              controller: _text[key],
              style: const TextStyle(color: Colors.white, fontSize: 15.2),
              decoration: InputDecoration(hintText: hint),
            ),
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            field('Nome', 'nome', hint: 'Ex: Colete Reforçado'),
            const SizedBox(width: 15),
            field('Bônus de Defesa', 'bonus', hint: 'Ex: +2'),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            FieldLabel(
              label: 'Espaço (carga)',
              child: BoundNumberField(
                value: _espaco,
                width: 80,
                onChanged: (value) => setState(() => _espaco = value),
              ),
            ),
            const SizedBox(width: 15),
            field('Resistência a Dano', 'rd', hint: 'Ex: RD 1 contra Balístico'),
          ],
        ),
        const SizedBox(height: 15),
        field('Penalidade', 'penalidade', hint: 'Ex: Nenhuma'),
        const SizedBox(height: 15),
        const Text(
          'Descrição',
          style: TextStyle(color: AppColors.textMuted, fontSize: 13.6),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: _text['descricao'],
          minLines: 2,
          maxLines: 4,
          style: const TextStyle(color: Colors.white, fontSize: 12.8),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AppButton(
              label: 'Salvar Proteção no Inventário',
              onPressed: () {
                widget.onSave(
                  Protection(
                    nome: _text['nome']!.text.trim(),
                    bonusDefesa: _text['bonus']!.text.trim(),
                    espaco: _espaco.toDouble(),
                    resistenciaDano: _text['rd']!.text.trim(),
                    penalidade: _text['penalidade']!.text.trim(),
                    descricao: _text['descricao']!.text,
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
