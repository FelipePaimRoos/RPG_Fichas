import 'package:app_flutter/app/theme/tokens.dart';
import 'package:app_flutter/shared/widgets/app_field.dart';
import 'package:app_flutter/shared/widgets/auto_grid.dart';
import 'package:app_flutter/shared/widgets/section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 6. Calculadora de Vantagem / Desvantagem — estado efêmero (o web não
/// persiste estes campos), réplica de `calcularVantagens`.
class AdvantagesSection extends ConsumerStatefulWidget {
  /// Cria a seção.
  const AdvantagesSection({required this.characterId, super.key});

  /// Id da ficha aberta.
  final String characterId;

  @override
  ConsumerState<AdvantagesSection> createState() => _AdvantagesSectionState();
}

class _AdvantagesSectionState extends ConsumerState<AdvantagesSection> {
  int _vantagens = 0;
  int _desvantagens = 0;

  @override
  Widget build(BuildContext context) {
    final saldo = _vantagens - _desvantagens;
    final dados = ['', '1d4', '1d6', '1d8', '1d10', '1d12'];
    String resultado;
    Color cor;
    if (saldo == 0) {
      resultado = 'Nenhum';
      cor = AppColors.text;
    } else {
      final tipoDado = dados[saldo.abs().clamp(0, 5)];
      resultado = saldo > 0 ? '+ $tipoDado' : '- $tipoDado';
      cor = saldo > 0 ? AppColors.primary : AppColors.error;
    }

    return SectionCard(
      title: 'Calculadora de Vantagem / Desvantagem',
      child: AutoGrid.grid3([
        FieldLabel(
          label: 'Qtd. Vantagens (+)',
          child: BoundNumberField(
            value: _vantagens,
            onChanged: (value) => setState(() =>
                _vantagens = value < 0 ? 0 : value),
          ),
        ),
        FieldLabel(
          label: 'Qtd. Desvantagens (-)',
          child: BoundNumberField(
            value: _desvantagens,
            onChanged: (value) =>
                setState(() => _desvantagens = value < 0 ? 0 : value),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dado de Modificador Resultante',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 13.6,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              constraints: const BoxConstraints(minHeight: 48),
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.inputBg,
                border: Border.all(color: AppColors.inputBorder),
                borderRadius: BorderRadius.circular(AppRadii.box),
              ),
              child: Text(
                resultado,
                style: TextStyle(
                  color: cor,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ]),
    );
  }
}
