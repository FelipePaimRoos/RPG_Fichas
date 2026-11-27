import 'package:app_flutter/app/theme/tokens.dart';
import 'package:flutter/material.dart';

/// Botão padrão do web: fundo `--primary`, texto branco, bold, raio 4.
class AppButton extends StatelessWidget {
  /// Cria o botão.
  const AppButton({
    required this.label,
    super.key,
    this.onPressed,
    this.expanded = false,
  });

  /// Texto do botão.
  final String label;

  /// Ação; null desabilita.
  final VoidCallback? onPressed;

  /// Ocupa toda a largura disponível.
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
    );
    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Botão de perigo (`.btn-danger`): fundo `#a83232`.
class DangerButton extends StatelessWidget {
  /// Cria o botão de perigo.
  const DangerButton({
    required this.label,
    super.key,
    this.onPressed,
    this.expanded = false,
  });

  /// Texto do botão.
  final String label;

  /// Ação; null desabilita.
  final VoidCallback? onPressed;

  /// Ocupa toda a largura disponível.
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
      onPressed: onPressed,
      child: Text(label),
    );
    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Botão pequeno usado nos headers de seção ("+ Adicionar", "X" de cards).
class SmallButton extends StatelessWidget {
  /// Cria o botão pequeno.
  const SmallButton({
    required this.label,
    super.key,
    this.onPressed,
    this.danger = false,
  });

  /// Texto do botão.
  final String label;

  /// Ação; null desabilita.
  final VoidCallback? onPressed;

  /// Usa a cor de perigo.
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: danger ? AppColors.danger : AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        minimumSize: const Size(0, 32),
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
