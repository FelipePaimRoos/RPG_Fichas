import 'dart:async';

import 'package:app_flutter/app/theme/tokens.dart';
import 'package:app_flutter/features/characters/presentation/viewmodels/sheet_view_model.dart';
import 'package:app_flutter/shared/widgets/app_field.dart';
import 'package:app_flutter/shared/widgets/auto_grid.dart';
import 'package:app_flutter/shared/widgets/section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Card sem título entre Ferimentos e Defesa: VIDA, SANIDADE e DEFESA —
/// réplica das barras, bolinhas de morte/loucura e escudo do web.
class VitalsSection extends ConsumerStatefulWidget {
  /// Cria a seção.
  const VitalsSection({required this.characterId, super.key});

  /// Id da ficha aberta.
  final String characterId;

  @override
  ConsumerState<VitalsSection> createState() => _VitalsSectionState();
}

class _VitalsSectionState extends ConsumerState<VitalsSection> {
  int _rodadasMorte = 0;
  int _rodadasLoucura = 0;

  @override
  Widget build(BuildContext context) {
    final character = ref
        .watch(sheetProvider(widget.characterId))
        .requireValue;
    final vm = ref.read(sheetProvider(widget.characterId).notifier);

    return SectionCard(
      child: AutoGrid.grid3([
        // ---------- VIDA ----------
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _FlexHeader(
              label: 'VIDA',
              auto: character.autoVida,
              onAutoChanged: (value) => vm.setAutoVida(value: value),
            ),
            if (character.vidaAtual > 0) ...[
              StatusBar(
                label: 'vida',
                atual: character.vidaAtual,
                max: character.vidaMax,
                gradient: const [
                  AppColors.lifeFillStart,
                  AppColors.accentRed,
                ],
                onAtualChanged: vm.setVidaAtual,
                onMaxChanged: vm.setVidaMax,
                onDelta: (delta) {
                  var value = delta;
                  // Cura com Vigor debilitado rende metade.
                  if (delta > 0 &&
                      character.atributos
                          .firstWhere((a) => a.nome == 'vigor')
                          .debilitado) {
                    value = (delta / 2).floor();
                  }
                  unawaited(
                    vm.setVidaAtual(
                      (character.vidaAtual + value).clamp(0, 9999),
                    ),
                  );
                },
              ),
            ] else
              _DeathBox(
                rodadas: _rodadasMorte,
                onRodada: (rodada) =>
                    setState(() => _rodadasMorte = rodada),
                onReviver: () {
                  unawaited(vm.setVidaAtual(1));
                  setState(() => _rodadasMorte = 0);
                },
              ),
          ],
        ),
        // ---------- SANIDADE ----------
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _FlexHeader(
              label: 'SANIDADE',
              auto: character.autoSanidade,
              onAutoChanged: (value) => vm.setAutoSanidade(value: value),
            ),
            if (character.sanidadeAtual > 0) ...[
              StatusBar(
                label: 'sanidade',
                atual: character.sanidadeAtual,
                max: character.sanidadeMax,
                gradient: const [
                  AppColors.sanityFillStart,
                  AppColors.accentCyan,
                ],
                onAtualChanged: vm.setSanidadeAtual,
                onMaxChanged: vm.setSanidadeMax,
                onDelta: (delta) => unawaited(
                  vm.setSanidadeAtual(
                    (character.sanidadeAtual + delta).clamp(0, 9999),
                  ),
                ),
              ),
            ] else
              _MadnessBox(
                rodadas: _rodadasLoucura,
                onRodada: (rodada) =>
                    setState(() => _rodadasLoucura = rodada),
                onRestaurar: () {
                  unawaited(vm.setSanidadeAtual(1));
                  setState(() => _rodadasLoucura = 0);
                },
              ),
          ],
        ),
        // ---------- DEFESA ----------
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _FlexHeader(
              label: 'DEFESA',
              auto: character.autoDefesa,
              onAutoChanged: (value) => vm.setAutoDefesa(value: value),
            ),
            Center(
              child: ShieldBox(
                value: character.defesaAtual,
                onChanged: vm.setDefesa,
              ),
            ),
          ],
        ),
      ]),
    );
  }
}

class _FlexHeader extends StatelessWidget {
  const _FlexHeader({
    required this.label,
    required this.auto,
    required this.onAutoChanged,
  });

  final String label;
  final bool auto;
  final ValueChanged<bool> onAutoChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13.6,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: Checkbox(
                  value: auto,
                  onChanged: (value) => onAutoChanged(value ?? true),
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'Auto',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13.6,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Barra de vida/sanidade do web (`.bar-container`).
class StatusBar extends StatelessWidget {
  /// Cria a barra.
  const StatusBar({
    required this.label,
    required this.atual,
    required this.max,
    required this.gradient,
    required this.onAtualChanged,
    required this.onMaxChanged,
    required this.onDelta,
    super.key,
  });

  final String label;
  final int atual;
  final int max;
  final List<Color> gradient;
  final ValueChanged<int> onAtualChanged;
  final ValueChanged<int> onMaxChanged;
  final ValueChanged<int> onDelta;

  @override
  Widget build(BuildContext context) {
    final pct = max <= 0 ? 0.0 : (atual / max).clamp(0.0, 1.0);
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: const Color(0xFF555555), width: 2),
        borderRadius: BorderRadius.circular(AppRadii.input),
      ),
      child: Stack(
        children: [
          FractionallySizedBox(
            widthFactor: pct,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Row(
              children: [
                const SizedBox(width: 5),
                _BarButton(label: '<<', onPressed: () => onDelta(-5)),
                const SizedBox(width: 2),
                _BarButton(label: '<', onPressed: () => onDelta(-1)),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BoundNumberField(
                        value: atual,
                        width: 45,
                        textAlign: TextAlign.center,
                        onChanged: onAtualChanged,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Text(
                        ' /',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17.6,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      BoundNumberField(
                        value: max,
                        width: 45,
                        textAlign: TextAlign.center,
                        onChanged: onMaxChanged,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                _BarButton(label: '>', onPressed: () => onDelta(1)),
                const SizedBox(width: 2),
                _BarButton(label: '>>', onPressed: () => onDelta(5)),
                const SizedBox(width: 5),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BarButton extends StatelessWidget {
  const _BarButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0x99000000),
            border: Border.all(color: const Color(0xFF444444)),
          ),
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12.8),
          ),
        ),
      ),
    );
  }
}

/// Bolinhas de morte (vida ≤ 0).
class _DeathBox extends StatelessWidget {
  const _DeathBox({
    required this.rodadas,
    required this.onRodada,
    required this.onReviver,
  });

  final int rodadas;
  final ValueChanged<int> onRodada;
  final VoidCallback onReviver;

  @override
  Widget build(BuildContext context) {
    final morto = rodadas >= 3;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        border: Border.all(color: AppColors.accentRed, width: 2),
        borderRadius: BorderRadius.circular(AppRadii.input),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            morto
                ? 'PERSONAGEM MORTO (3ª Rodada Expirada)'
                : 'Morrendo (0 de Vida - Contagem de Rodadas)',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: morto ? AppColors.error : AppColors.warnText,
              fontSize: 12.8,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 1; i <= 3; i++) ...[
                if (i > 1) const SizedBox(width: 15),
                WebCheckbox(
                  value: rodadas >= i,
                  label: '$iª Rodada${i == 3 ? ' (Morreu)' : ''}',
                  labelStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.8,
                  ),
                  onChanged: (_) => onRodada(i),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF333333),
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 3,
              ),
              minimumSize: const Size(0, 28),
              textStyle: const TextStyle(fontSize: 12),
            ),
            onPressed: onReviver,
            child: const Text('Levantar / Curar (Voltar)'),
          ),
        ],
      ),
    );
  }
}

/// Caixinhas de enlouquecimento (sanidade ≤ 0).
class _MadnessBox extends StatelessWidget {
  const _MadnessBox({
    required this.rodadas,
    required this.onRodada,
    required this.onRestaurar,
  });

  final int rodadas;
  final ValueChanged<int> onRodada;
  final VoidCallback onRestaurar;

  @override
  Widget build(BuildContext context) {
    final enlouqueceu = rodadas >= 3;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        border: Border.all(color: AppColors.accentCyan, width: 2),
        borderRadius: BorderRadius.circular(AppRadii.input),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            enlouqueceu
                ? 'ENLOUQUECEU COMPLETAMENTE (3ª Rodada Expirada)'
                : 'Enlouquecendo (0 de Sanidade - Contagem de Rodadas)',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: enlouqueceu ? AppColors.error : const Color(0xFF99FFFF),
              fontSize: 12.8,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 1; i <= 3; i++) ...[
                if (i > 1) const SizedBox(width: 15),
                WebCheckbox(
                  value: rodadas >= i,
                  label: '$iª Rodada${i == 3 ? ' (Enlouqueceu)' : ''}',
                  labelStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.8,
                  ),
                  onChanged: (_) => onRodada(i),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF333333),
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 3,
              ),
              minimumSize: const Size(0, 28),
              textStyle: const TextStyle(fontSize: 12),
            ),
            onPressed: onRestaurar,
            child: const Text('Restaurar Mente (Voltar)'),
          ),
        ],
      ),
    );
  }
}

/// Escudo de defesa do web (`.shield-box` com clip-path).
class ShieldBox extends StatelessWidget {
  /// Cria o escudo.
  const ShieldBox({required this.value, required this.onChanged, super.key});

  /// Defesa atual.
  final int value;

  /// Alteração.
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 90,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned.fill(
            child: _ShieldPainter(),
          ),
          Center(
            child: BoundNumberField(
              value: value,
              width: 50,
              textAlign: TextAlign.center,
              onChanged: onChanged,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28.8,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShieldPainter extends StatelessWidget {
  const _ShieldPainter();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ShieldPaint(),
      size: Size.infinite,
    );
  }
}

class _ShieldPaint extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.50, 0)
      ..lineTo(w * 1.00, h * 0.15)
      ..lineTo(w * 1.00, h * 0.70)
      ..lineTo(w * 0.50, h * 1.00)
      ..lineTo(w * 0.00, h * 0.70)
      ..lineTo(w * 0.00, h * 0.15)
      ..close();

    // Fundo com gradiente + borda: desenha maior primeiro (borda 3px).
    final borderPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF3A3A4A), Color(0xFF1A1A24)],
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas
      ..drawShadow(path, const Color(0x88000000), 4, true)
      ..drawPath(path, borderPaint);

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF3A3A4A), Color(0xFF1A1A24)],
      ).createShader(Offset.zero & size);
    canvas.drawPath(path, fillPaint);
  }

  @override
  bool shouldRepaint(_ShieldPaint oldDelegate) => false;
}
