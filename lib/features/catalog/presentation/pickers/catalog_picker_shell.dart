import 'package:app_flutter/app/theme/tokens.dart';
import 'package:flutter/material.dart';


/// Linha de resultado de catálogo — réplica de `.power-catalog-row`:
/// nome + info à esquerda, botão "+" à direita.
class CatalogResultRow extends StatelessWidget {
  /// Cria a linha.
  const CatalogResultRow({
    required this.title,
    required this.onSelect,
    super.key,
    this.subtitle,
    this.details = const [],
    this.description,
    this.warning,
    this.titleColor,
    this.enabled = true,
  });

  /// Título (nome do item).
  final String title;

  /// Subtítulo (elemento, círculo, tipo…).
  final String? subtitle;

  /// Chips de detalhes (classificação, pré-requisito, custo, alcance).
  final List<String> details;

  /// Descrição/efeito.
  final String? description;

  /// Aviso (ex.: pré-requisito não cumprido) em amarelo.
  final String? warning;

  /// Cor do título (elemento).
  final Color? titleColor;

  /// Ação ao selecionar.
  final VoidCallback onSelect;

  /// Linha habilitada (poderes já adquiridos ficam desabilitados).
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.only(left: 12, right: 8, top: 6, bottom: 6),
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(AppRadii.input),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: titleColor ?? AppColors.text,
                    fontSize: 14.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty)
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                if (details.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 5,
                    runSpacing: 4,
                    children: [
                      for (final detail in details)
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
                            detail,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12.2,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
                if (description != null && description!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    description!,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12.5,
                      height: 1.45,
                    ),
                  ),
                ],
                if (warning != null && warning!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    warning!,
                    style: const TextStyle(
                      color: AppColors.infoYellow,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          _AddButton(onSelect: enabled ? onSelect : null),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onSelect});

  final VoidCallback? onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34,
      height: 34,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size(34, 34),
          disabledBackgroundColor: AppColors.primary.withAlpha(100),
        ),
        onPressed: onSelect,
        child: const Text(
          '+',
          style: TextStyle(fontSize: 20, height: 1),
        ),
      ),
    );
  }
}

/// Fileira de botões de filtro (Tier I–IV, círculos, proficiências).
class FilterChipsRow extends StatelessWidget {
  /// Cria a fileira.
  const FilterChipsRow({
    required this.options,
    required this.selected,
    required this.onSelect,
    super.key,
  });

  /// Opções ('' para "Todos").
  final List<String> options;

  /// Valor selecionado.
  final String selected;

  /// Seleção.
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final option in options)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: selected == option
                  ? const Color(0xFF4B5E9D)
                  : AppColors.primary,
              minimumSize: const Size(0, 32),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12.5,
              ),
            ),
            onPressed: () => onSelect(option),
            child: Text(option),
          ),
      ],
    );
  }
}

/// Lista rolável dos resultados do catálogo (max-height do web).
class CatalogListArea extends StatelessWidget {
  /// Cria a área de lista.
  const CatalogListArea({
    required this.children,
    super.key,
    this.maxHeight = 320,
  });

  /// Filhos (linhas de resultado).
  final List<Widget> children;

  /// Altura máxima da lista.
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}

/// Mensagem de lista vazia, como no web ("Carregando…" quando indisponível).
class EmptyCatalogMessage extends StatelessWidget {
  /// Cria a mensagem.
  const EmptyCatalogMessage({required this.mensagem, super.key});

  /// Texto exibido.
  final String mensagem;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        mensagem,
        style: const TextStyle(
          color: Color(0xFFAAAAAA),
          fontSize: 14.4,
        ),
      ),
    );
  }
}
