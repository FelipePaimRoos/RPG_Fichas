import 'package:app_flutter/app/providers.dart';
import 'package:app_flutter/app/theme/tokens.dart';
import 'package:app_flutter/features/catalog/catalog.dart';
import 'package:app_flutter/features/catalog/presentation/pickers/catalog_picker_shell.dart';
import 'package:app_flutter/shared/widgets/app_button.dart';
import 'package:app_flutter/shared/widgets/app_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


/// Modal "Adicionar Arma": filtros do web (proficiência, tipo, busca),
/// lista do catálogo e formulário de criação manual.
class WeaponPicker extends ConsumerStatefulWidget {
  /// Cria o picker.
  const WeaponPicker({required this.onSelect, super.key});

  /// Recebe a arma escolhida/criada.
  final ValueChanged<Weapon> onSelect;

  @override
  ConsumerState<WeaponPicker> createState() => _WeaponPickerState();
}

class _WeaponPickerState extends ConsumerState<WeaponPicker> {
  String _proficiencia = '';
  String _tipo = '';
  String _busca = '';

  @override
  Widget build(BuildContext context) {
    final catalogo = ref.watch(armasCatalogoProvider);

    return catalogo.when(
      loading: () => const EmptyCatalogMessage(mensagem: 'Carregando armas...'),
      error: (_, stack) =>
          const EmptyCatalogMessage(mensagem: 'Erro ao carregar o catálogo.'),
      data: (armas) {
        final filtradas = armas.where((arma) {
          if (_proficiencia.isNotEmpty &&
              arma.proficiencia != _proficiencia) {
            return false;
          }
          if (_tipo.isNotEmpty &&
              !arma.tipo.toLowerCase().contains(_tipo.toLowerCase())) {
            return false;
          }
          if (_busca.isNotEmpty &&
              !arma.nome.toLowerCase().contains(_busca.toLowerCase())) {
            return false;
          }
          return true;
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilterChipsRow(
              options: const ['', 'Simples', 'Tática', 'Pesada'],
              selected: _proficiencia,
              onSelect: (value) => setState(() => _proficiencia = value),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: FieldLabel(
                    label: 'Filtrar por tipo',
                    child: AppDropdown(
                      value: _tipo,
                      items: const [
                        ('', 'Todos os tipos'),
                        ('corpo a corpo', 'Corpo a Corpo'),
                        ('arremesso', 'Arremesso'),
                        ('disparo', 'Disparo'),
                        ('fogo', 'Fogo'),
                      ],
                      onChanged: (value) =>
                          setState(() => _tipo = value.toLowerCase()),
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
                if (filtradas.isEmpty)
                  const EmptyCatalogMessage(mensagem: 'Nenhuma arma encontrada.')
                else
                  for (final arma in filtradas)
                    CatalogResultRow(
                      title: arma.nome,
                      subtitle:
                          '${arma.proficiencia} · ${arma.tipo} · ${arma.empunhadura}',
                      details: [
                        'Dano: ${arma.danoBase}',
                        'Crítico: ${arma.critico}',
                        'Espaço: ${arma.espaco.toInt()}',
                      ],
                      description: arma.habilidades.isEmpty
                          ? null
                          : arma.habilidades,
                      onSelect: () => widget.onSelect(
                        arma.copyWith(personalizada: false),
                      ),
                    ),
              ],
            ),
            const Divider(
                color: AppColors.cardBorder, height: 32, thickness: 1),
            const Text(
              'Criar Nova Arma (só nesta ficha)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            WeaponForm(
              onSave: (arma) =>
                  widget.onSelect(arma.copyWith(personalizada: true)),
            ),
          ],
        );
      },
    );
  }
}

/// Formulário de arma manual ("Criar Nova Arma (só nesta ficha)").
class WeaponForm extends StatefulWidget {
  /// Cria o formulário.
  const WeaponForm({required this.onSave, this.initial, super.key});

  /// Arma inicial (edição).
  final Weapon? initial;

  /// Salvar (não fecha o modal — quem chama decide).
  final ValueChanged<Weapon> onSave;

  @override
  State<WeaponForm> createState() => _WeaponFormState();
}

class _WeaponFormState extends State<WeaponForm> {
  late final Map<String, TextEditingController> _text;
  late String _proficiencia;
  late String _tipo;
  late String _empunhadura;
  late int _espaco;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _text = {
      'nome': TextEditingController(text: initial?.nome ?? ''),
      'dano': TextEditingController(text: initial?.danoBase ?? ''),
      'critico': TextEditingController(text: initial?.critico ?? 'x2'),
      'tipo_dano': TextEditingController(text: initial?.tipoDano ?? ''),
      'alcance': TextEditingController(text: initial?.alcance ?? ''),
      'habilidades': TextEditingController(text: initial?.habilidades ?? ''),
    };
    _proficiencia = initial?.proficiencia ?? 'Simples';
    _tipo = initial?.tipo ?? 'Corpo a Corpo';
    _empunhadura = initial?.empunhadura ?? 'Uma Mão';
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
            field('Nome', 'nome', hint: 'Ex: Lâmina Voraz'),
            const SizedBox(width: 15),
            FieldLabel(
              label: 'Proficiência',
              child: AppDropdown(
                value: _proficiencia,
                items: const [
                  ('Simples', 'Simples'),
                  ('Tática', 'Tática'),
                  ('Pesada', 'Pesada'),
                  ('Exótica', 'Exótica'),
                  ('Nenhuma', 'Nenhuma'),
                ],
                onChanged: (value) => setState(() => _proficiencia = value),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            FieldLabel(
              label: 'Tipo',
              child: AppDropdown(
                value: _tipo,
                items: const [
                  ('Corpo a Corpo', 'Corpo a Corpo'),
                  ('Arremesso', 'Arremesso'),
                  ('Disparo', 'Disparo'),
                  ('Fogo', 'Fogo'),
                ],
                onChanged: (value) => setState(() => _tipo = value),
              ),
            ),
            const SizedBox(width: 15),
            FieldLabel(
              label: 'Empunhadura',
              child: AppDropdown(
                value: _empunhadura,
                items: const [
                  ('Uma Mão', 'Uma Mão'),
                  ('Duas Mãos', 'Duas Mãos'),
                ],
                onChanged: (value) => setState(() => _empunhadura = value),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            field('Dano Base', 'dano', hint: 'Ex: 1d6'),
            const SizedBox(width: 15),
            field('Crítico', 'critico', hint: 'Ex: x2'),
            const SizedBox(width: 15),
            field('Tipo de Dano', 'tipo_dano', hint: 'Ex: Corte'),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            field('Alcance', 'alcance', hint: 'Ex: Curto (6m)'),
            const SizedBox(width: 15),
            FieldLabel(
              label: 'Espaço (carga)',
              child: BoundNumberField(
                value: _espaco,
                width: 80,
                onChanged: (value) => setState(() => _espaco = value),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        const Text(
          'Habilidades / Descrição',
          style: TextStyle(color: AppColors.textMuted, fontSize: 13.6),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: _text['habilidades'],
          minLines: 2,
          maxLines: 4,
          style: const TextStyle(color: Colors.white, fontSize: 12.8),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AppButton(
              label: 'Salvar Arma no Inventário',
              onPressed: () {
                widget.onSave(
                  Weapon(
                    nome: _text['nome']!.text.trim(),
                    proficiencia: _proficiencia,
                    tipo: _tipo,
                    empunhadura: _empunhadura,
                    danoBase: _text['dano']!.text.trim(),
                    critico: _text['critico']!.text.trim(),
                    tipoDano: _text['tipo_dano']!.text.trim(),
                    alcance: _text['alcance']!.text.trim(),
                    espaco: _espaco.toDouble(),
                    habilidades: _text['habilidades']!.text,
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
