import 'package:app_flutter/app/theme/tokens.dart';
import 'package:flutter/material.dart';

/// Card de seção da ficha — réplica de `.card-secao`: fundo `--card-bg`,
/// borda `--card-border`, raio 8, padding 18, sombra.
class SectionCard extends StatelessWidget {
  /// Cria o card; [title] renderiza o `h2` quando informado.
  const SectionCard({
    required this.child,
    super.key,
    this.title,
    this.trailing,
    this.padding = const EdgeInsets.all(AppSpacing.cardPadding),
  });

  /// Conteúdo.
  final Widget child;

  /// Título (h2, caixa alta, borda inferior).
  final String? title;

  /// Widget à direita do título (botão "+ Adicionar").
  final Widget? trailing;

  /// Padding interno.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: AppRadii.cardShadow,
      ),
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            SectionTitle(title: title!, trailing: trailing)
          else ?trailing,
          child,
        ],
      ),
    );
  }
}

/// Título de seção (`h2` do web): 1.2rem, caixa alta, letter-spacing,
/// borda inferior de 2px.
class SectionTitle extends StatelessWidget {
  /// Cria o título.
  const SectionTitle({required this.title, super.key, this.trailing});

  /// Texto do título.
  final String title;

  /// Ação à direita (botão "+ Adicionar…").
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(bottom: 6),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.cardBorder, width: 2),
                ),
              ),
              child: Text(
                title.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19.2,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ],
        ],
      ),
    );
  }
}
