import 'package:app_flutter/app/theme/tokens.dart';
import 'package:app_flutter/features/characters/presentation/viewmodels/save_status.dart';
import 'package:flutter/material.dart';

/// Indicador de status do autosave no topo do editor (`api_status_msg`).
class SaveStatusView extends StatelessWidget {
  /// Cria o indicador.
  const SaveStatusView({required this.status, super.key});

  /// Estado atual.
  final SaveStatus status;

  Color get _color => switch (status) {
        SaveStatus.ocioso => Colors.transparent,
        SaveStatus.salvando => AppColors.pending,
        SaveStatus.salvo => AppColors.good,
        SaveStatus.erro => AppColors.error,
      };

  @override
  Widget build(BuildContext context) {
    return Text(
      status.label,
      style: TextStyle(
        color: _color,
        fontSize: 13.6,
        height: 1.5,
      ),
    );
  }
}
