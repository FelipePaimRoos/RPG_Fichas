import 'package:app_flutter/app/providers.dart';
import 'package:app_flutter/features/catalog/catalog.dart';
import 'package:app_flutter/features/catalog/presentation/pickers/catalog_picker_shell.dart';
import 'package:app_flutter/shared/widgets/app_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


/// Modal "Adicionar item do catálogo": categoria + busca + lista.
class InventoryItemPicker extends ConsumerStatefulWidget {
  /// Cria o picker.
  const InventoryItemPicker({required this.onSelect, super.key});

  /// Recebe o item escolhido (convertido em item de inventário).
  final ValueChanged<CatalogItem> onSelect;

  @override
  ConsumerState<InventoryItemPicker> createState() =>
      _InventoryItemPickerState();
}

class _InventoryItemPickerState extends ConsumerState<InventoryItemPicker> {
  String _categoria = 'operacionais';
  String _busca = '';

  @override
  Widget build(BuildContext context) {
    final catalogo = ref.watch(itensCatalogoProvider(_categoria));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FieldLabel(
          label: 'Categoria',
          child: AppDropdown(
            value: _categoria,
            items: const [
              ('operacionais', 'Itens operacionais'),
              ('acessorios', 'Acessórios'),
              ('explosivos', 'Explosivos'),
              ('amaldiçoados', 'Itens amaldiçoados'),
              ('paranormais', 'Itens paranormais'),
              ('medicamentos', 'Medicamentos'),
              ('municoes', 'Munições'),
            ],
            onChanged: (value) => setState(() => _categoria = value),
          ),
        ),
        const SizedBox(height: 10),
        FieldLabel(
          label: 'Buscar item',
          child: BoundTextField(
            value: _busca,
            hint: 'Digite o nome do item',
            expanded: true,
            onChanged: (value) => setState(() => _busca = value),
          ),
        ),
        const SizedBox(height: 10),
        catalogo.when(
          loading: () =>
              const EmptyCatalogMessage(mensagem: 'Carregando itens...'),
          error: (_, stack) => const EmptyCatalogMessage(
            mensagem: 'Erro ao carregar o catálogo.',
          ),
          data: (itens) {
            final filtrados = itens
                .where(
                  (item) => _busca.isEmpty ||
                      item.nome
                          .toLowerCase()
                          .contains(_busca.toLowerCase()),
                )
                .toList();
            return CatalogListArea(
              children: [
                if (filtrados.isEmpty)
                  const EmptyCatalogMessage(
                    mensagem: 'Nenhum item encontrado.',
                  )
                else
                  for (final item in filtrados)
                    CatalogResultRow(
                      title: item.nome,
                      subtitle: item.descricao.isEmpty ? null : item.descricao,
                      details: [
                        'Espaço: ${item.espaco % 1 == 0 ? item.espaco.toInt() : item.espaco}',
                      ],
                      onSelect: () => widget.onSelect(item),
                    ),
              ],
            );
          },
        ),
      ],
    );
  }
}
