import 'package:app_flutter/app/theme/tokens.dart';
import 'package:flutter/material.dart';

/// Botão de excluir dos cards de item (`.btn-delete-card` do web):
/// 22×22, fundo `#a83232`, canto superior direito.
class DeleteCardButton extends StatelessWidget {
  /// Cria o botão.
  const DeleteCardButton({required this.onPressed, super.key});

  /// Ação de remover.
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: AppColors.danger,
            borderRadius: BorderRadius.circular(AppRadii.input),
          ),
          alignment: Alignment.center,
          child: const Text(
            'X',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
