import 'package:app_flutter/app/theme/tokens.dart';
import 'package:flutter/material.dart';

/// Réplica do modal do web (`.modal-overlay` + `.modal-content`):
/// overlay 75% preto, card com borda, raio 8, padding 20, título em
/// `--primary` com borda inferior.
Future<T?> showAppModal<T>({
  required BuildContext context,
  required String title,
  required WidgetBuilder builder,
  double maxWidth = 600,
  bool showCloseButton = true,
  VoidCallback? onClose,
}) {
  return showDialog<T>(
    context: context,
    barrierColor: const Color(0xC0000000),
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
            maxHeight: MediaQuery.of(dialogContext).size.height * 0.9,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ModalTitle(
                  title: title,
                  showCloseButton: showCloseButton,
                  onClose: onClose ??
                      () => Navigator.of(dialogContext).pop(),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    child: builder(dialogContext),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _ModalTitle extends StatelessWidget {
  const _ModalTitle({
    required this.title,
    required this.showCloseButton,
    required this.onClose,
  });

  final String title;
  final bool showCloseButton;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(bottom: 8),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.cardBorder),
                ),
              ),
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 18.7,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          if (showCloseButton) ...[
            const SizedBox(width: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                minimumSize: const Size(36, 32),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              onPressed: onClose,
              child: const Text('×', style: TextStyle(fontSize: 16)),
            ),
          ],
        ],
      ),
    );
  }
}
