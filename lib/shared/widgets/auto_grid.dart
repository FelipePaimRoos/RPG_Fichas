import 'package:app_flutter/app/theme/tokens.dart';
import 'package:flutter/material.dart';

/// Réplica dos grids do web (`grid-2`, `grid-3`, `grid-5`):
/// `repeat(auto-fit, minmax(N, 1fr))`. Calcula quantas colunas cabem na
/// largura disponível e distribui os filhos em faixas de mesma altura.
class AutoGrid extends StatelessWidget {
  /// Cria o grid com largura mínima por coluna.
  const AutoGrid({
    required this.minItemWidth,
    required this.children,
    super.key,
    this.gap = AppSpacing.grid,
  });

  /// Grid de 2 colunas (min 280px, gap 15).
  const AutoGrid.grid2(this.children, {super.key})
      : minItemWidth = 280,
        gap = AppSpacing.grid;

  /// Grid de 3 colunas (min 220px, gap 15).
  const AutoGrid.grid3(this.children, {super.key})
      : minItemWidth = 220,
        gap = AppSpacing.grid;

  /// Grid de 5 colunas (min 130px, gap 12).
  const AutoGrid.grid5(this.children, {super.key})
      : minItemWidth = 130,
        gap = AppSpacing.grid5;

  /// Largura mínima de cada coluna.
  final double minItemWidth;

  /// Espaço entre colunas/linhas.
  final double gap;

  /// Filhos.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        var columns = ((maxWidth + gap) / (minItemWidth + gap)).floor();
        columns = columns.clamp(1, children.isEmpty ? 1 : children.length);
        final itemWidth = (maxWidth - gap * (columns - 1)) / columns;

        final rows = <Widget>[];
        for (var i = 0; i < children.length; i += columns) {
          final band = children.sublist(
            i,
            (i + columns).clamp(0, children.length),
          );
          rows.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var j = 0; j < columns; j++) ...[
                  if (j > 0) SizedBox(width: gap),
                  if (j < band.length)
                    SizedBox(width: itemWidth, child: band[j])
                  else
                    const SizedBox(),
                ],
              ],
            ),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0) SizedBox(height: gap),
              rows[i],
            ],
          ],
        );
      },
    );
  }
}
