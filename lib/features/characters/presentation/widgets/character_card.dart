import 'package:app_flutter/app/theme/tokens.dart';
import 'package:app_flutter/features/characters/domain/character_summary.dart';
import 'package:app_flutter/shared/widgets/app_button.dart';
import 'package:flutter/material.dart';

/// Linha de ficha do dashboard — réplica de `.character-card`:
/// nome (h3), detalhes (`Nível X · conceito`) e ações à direita.
class CharacterCard extends StatelessWidget {
  /// Cria a linha.
  const CharacterCard({
    required this.character,
    required this.onOpen,
    required this.onExport,
    required this.onDelete,
    super.key,
  });

  /// Resumo exibido.
  final CharacterSummary character;

  /// Acessar a ficha.
  final VoidCallback onOpen;

  /// Exportar JSON.
  final VoidCallback onExport;

  /// Excluir (a tela confirma antes).
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  character.displayName,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 18.7,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  character.detailsLine,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppButton(label: 'Acessar', onPressed: onOpen),
              const SizedBox(width: 8),
              AppButton(label: 'Exportar', onPressed: onExport),
              const SizedBox(width: 8),
              DangerButton(label: 'Excluir', onPressed: onDelete),
            ],
          ),
        ],
      ),
    );
  }
}
