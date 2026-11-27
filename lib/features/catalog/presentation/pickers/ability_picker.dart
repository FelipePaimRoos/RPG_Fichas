import 'package:app_flutter/app/providers.dart';
import 'package:app_flutter/features/catalog/catalog.dart';
import 'package:app_flutter/features/catalog/presentation/pickers/catalog_picker_shell.dart';
import 'package:app_flutter/shared/widgets/app_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


/// Modal "Nova Habilidade": filtros de Tier + busca + lista do catálogo.
/// O item selecionado abre o formulário (comportamento do web: clicar no
/// card preenche os dados e permite salvar/editar).
class AbilityPicker extends ConsumerStatefulWidget {
  /// Cria o picker.
  const AbilityPicker({required this.onSelect, super.key});

  /// Recebe a habilidade escolhida do catálogo.
  final ValueChanged<Ability> onSelect;

  @override
  ConsumerState<AbilityPicker> createState() => _AbilityPickerState();
}

class _AbilityPickerState extends ConsumerState<AbilityPicker> {
  String _tier = '';
  String _busca = '';

  @override
  Widget build(BuildContext context) {
    final catalogo = ref.watch(habilidadesCatalogoProvider);

    return catalogo.when(
      loading: () =>
          const EmptyCatalogMessage(mensagem: 'Carregando habilidades...'),
      error: (_, stack) =>
          const EmptyCatalogMessage(mensagem: 'Erro ao carregar o catálogo.'),
      data: (habilidades) {
        final filtradas = habilidades.where((habilidade) {
          if (_tier.isNotEmpty && habilidade.classificacao != _tier) {
            return false;
          }
          if (_busca.isNotEmpty) {
            final alvo =
                '${habilidade.nome} ${habilidade.prereq}'.toLowerCase();
            if (!alvo.contains(_busca.toLowerCase())) {
              return false;
            }
          }
          return true;
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilterChipsRow(
              options: const ['', 'Tier I', 'Tier II', 'Tier III', 'Tier IV'],
              selected: _tier,
              onSelect: (value) => setState(() => _tier = value),
            ),
            const SizedBox(height: 10),
            BoundTextField(
              value: _busca,
              hint: 'Buscar por nome ou pré-requisito...',
              expanded: true,
              onChanged: (value) => setState(() => _busca = value),
            ),
            const SizedBox(height: 10),
            CatalogListArea(
              maxHeight: 220,
              children: [
                if (filtradas.isEmpty)
                  const EmptyCatalogMessage(
                    mensagem: 'Nenhuma habilidade encontrada.',
                  )
                else
                  for (final habilidade in filtradas)
                    CatalogResultRow(
                      title: habilidade.nome,
                      subtitle: habilidade.classificacao,
                      details: [
                        'Pré-requisito: ${habilidade.prereq}',
                        'Custo: ${habilidade.custo}',
                        if (habilidade.alcance.isNotEmpty)
                          'Alcance: ${habilidade.alcance}',
                      ],
                      description:
                          habilidade.efeito.isEmpty ? null : habilidade.efeito,
                      onSelect: () => widget.onSelect(habilidade),
                    ),
              ],
            ),
          ],
        );
      },
    );
  }
}
