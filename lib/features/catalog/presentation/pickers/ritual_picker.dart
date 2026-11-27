import 'package:app_flutter/app/providers.dart';
import 'package:app_flutter/features/catalog/catalog.dart';
import 'package:app_flutter/features/catalog/presentation/pickers/catalog_picker_shell.dart';
import 'package:app_flutter/shared/domain/element.dart';
import 'package:app_flutter/shared/widgets/app_button.dart';
import 'package:app_flutter/shared/widgets/app_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


/// Modal "Adicionar Ritual": filtros de círculo/elemento/busca + manual.
class RitualPicker extends ConsumerStatefulWidget {
  /// Cria o picker.
  const RitualPicker({required this.onSelect, super.key});

  /// Recebe o ritual escolhido/criado.
  final ValueChanged<Ritual> onSelect;

  @override
  ConsumerState<RitualPicker> createState() => _RitualPickerState();
}

class _RitualPickerState extends ConsumerState<RitualPicker> {
  String _circulo = '';
  String _elemento = '';
  String _busca = '';

  @override
  Widget build(BuildContext context) {
    final catalogo = ref.watch(rituaisCatalogoProvider);

    return catalogo.when(
      loading: () => const EmptyCatalogMessage(mensagem: 'Carregando rituais...'),
      error: (_, stack) =>
          const EmptyCatalogMessage(mensagem: 'Erro ao carregar o catálogo.'),
      data: (rituais) {
        final filtrados = rituais.where((ritual) {
          if (_circulo.isNotEmpty && ritual.classificacao != _circulo) {
            return false;
          }
          if (_elemento.isNotEmpty) {
            final elementoRitual = ritual.detectarElemento();
            if (elementoRitual != normalizeElement(_elemento)) {
              return false;
            }
          }
          if (_busca.isNotEmpty &&
              !ritual.nome.toLowerCase().contains(_busca.toLowerCase())) {
            return false;
          }
          return true;
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilterChipsRow(
              options: const [
                '',
                '1° Círculo',
                '2° Círculo',
                '3° Círculo',
                '4° Círculo',
              ],
              selected: _circulo,
              onSelect: (value) => setState(() => _circulo = value),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: FieldLabel(
                    label: 'Filtrar por elemento',
                    child: AppDropdown(
                      value: _elemento,
                      items: const [
                        ('', 'Todos os elementos'),
                        ('sangue', 'Sangue'),
                        ('morte', 'Morte'),
                        ('energia', 'Energia'),
                        ('conhecimento', 'Conhecimento'),
                      ],
                      onChanged: (value) => setState(() => _elemento = value),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: FieldLabel(
                    label: 'Buscar',
                    child: BoundTextField(
                      value: _busca,
                      hint: 'Buscar por nome...',
                      onChanged: (value) => setState(() => _busca = value),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            CatalogListArea(
              children: [
                if (filtrados.isEmpty)
                  const EmptyCatalogMessage(
                    mensagem: 'Nenhum ritual encontrado.',
                  )
                else
                  for (final ritual in filtrados)
                    CatalogResultRow(
                      title: ritual.nome,
                      subtitle: [
                        ritual.elemento,
                        ritual.classificacao,
                        ritual.execucao,
                      ].where((s) => s.isNotEmpty).join(' · '),
                      details: [
                        if (ritual.custo.isNotEmpty) 'Custo: ${ritual.custo}',
                        if (ritual.alcance.isNotEmpty)
                          'Alcance: ${ritual.alcance}',
                      ],
                      description:
                          ritual.efeito.isEmpty ? null : ritual.efeito,
                      titleColor: ritual.detectarElemento()?.color,
                      onSelect: () => widget.onSelect(ritual),
                    ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppButton(
                  label: 'Criar ritual novo',
                  onPressed: () => widget.onSelect(
                    Ritual(
                      classificacao:
                          _circulo.isEmpty ? '1° Círculo' : _circulo,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
