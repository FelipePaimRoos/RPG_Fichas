import 'package:app_flutter/app/providers.dart';
import 'package:app_flutter/features/catalog/catalog.dart';
import 'package:app_flutter/features/catalog/presentation/pickers/catalog_picker_shell.dart';
import 'package:app_flutter/shared/domain/element.dart';
import 'package:app_flutter/shared/widgets/app_button.dart';
import 'package:app_flutter/shared/widgets/app_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


/// Modal "Adicionar Poderes Paranormais": filtros de elemento/grau, busca,
/// avisos de pré-requisito e criação manual.
class PowerPicker extends ConsumerStatefulWidget {
  /// Cria o picker.
  const PowerPicker({required this.onSelect, super.key});

  /// Recebe o poder escolhido/criado.
  final ValueChanged<Power> onSelect;

  @override
  ConsumerState<PowerPicker> createState() => _PowerPickerState();
}

class _PowerPickerState extends ConsumerState<PowerPicker> {
  String _elemento = '';
  String _grao = '';
  String _busca = '';

  @override
  Widget build(BuildContext context) {
    final catalogo = ref.watch(poderesCatalogoProvider);

    return catalogo.when(
      loading: () => const EmptyCatalogMessage(mensagem: 'Carregando poderes...'),
      error: (_, stack) =>
          const EmptyCatalogMessage(mensagem: 'Erro ao carregar o catálogo.'),
      data: (poderes) {
        final filtrados = poderes.where((poder) {
          if (_elemento.isNotEmpty &&
              normalizeElement(poder.elemento) !=
                  normalizeElement(_elemento)) {
            return false;
          }
          if (_grao.isNotEmpty) {
            final grau = _graoDoPrereq(poder.prereq);
            if (_grao == 'special') {
              if (grau != null) {
                return false;
              }
            } else {
              final grauAlvo = int.tryParse(_grao);
              if (grau == null || grau != grauAlvo) {
                return false;
              }
            }
          }
          if (_busca.isNotEmpty &&
              !poder.nome.toLowerCase().contains(_busca.toLowerCase())) {
            return false;
          }
          return true;
        }).toList()
          ..sort(
            (a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()),
          );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                    label: 'Filtrar por pré-requisito',
                    child: AppDropdown(
                      value: _grao,
                      items: const [
                        ('', 'Todos os pré-requisitos'),
                        ('1', 'Grau 1'),
                        ('2', 'Grau 2'),
                        ('3', 'Grau 3'),
                        ('special', 'Requisitos especiais'),
                      ],
                      onChanged: (value) => setState(() => _grao = value),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            BoundTextField(
              value: _busca,
              hint: 'Buscar por nome...',
              expanded: true,
              onChanged: (value) => setState(() => _busca = value),
            ),
            const SizedBox(height: 10),
            CatalogListArea(
              maxHeight: 480,
              children: [
                if (filtrados.isEmpty)
                  const EmptyCatalogMessage(
                    mensagem: 'Nenhum poder encontrado.',
                  )
                else
                  for (final poder in filtrados)
                    CatalogResultRow(
                      title: poder.nome,
                      subtitle: [poder.elemento, poder.prereq]
                          .where((s) => s.isNotEmpty)
                          .join(' · '),
                      details: [
                        if (poder.custo.isNotEmpty) 'Custo: ${poder.custo}',
                        if (poder.alcance.isNotEmpty)
                          'Alcance: ${poder.alcance}',
                      ],
                      description:
                          poder.efeito.isEmpty ? null : poder.efeito,
                      titleColor: normalizeElement(poder.elemento)?.color,
                      onSelect: () => widget.onSelect(poder),
                    ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppButton(
                  label: 'Criar novo poder',
                  onPressed: () =>
                      widget.onSelect(const Power()),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  static int? _graoDoPrereq(String prereq) {
    final match = RegExp(r'Grau (\d)').firstMatch(prereq);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }
    // "Elemento N" do livro.
    final elemento = RegExp(r'Elemento (\d)').firstMatch(prereq);
    return elemento == null ? null : int.tryParse(elemento.group(1)!);
  }
}
