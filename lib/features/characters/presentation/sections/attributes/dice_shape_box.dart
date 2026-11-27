import 'dart:math' as math;

import 'package:app_flutter/app/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Formas dos dados de atributo — portagem dos `clip-path` do web
/// (`.d4`, `.d6`, `.d8`, `.d10`, `.d12`, `.d20`, `.d-none`).
enum DiceShape { d4, d6, d8, d10, d12, d20, none }

/// Caixa de atributo: rótulo bold, dado de 65px com o valor dentro e a DT.
class DiceShapeBox extends StatelessWidget {
  /// Cria a caixa do dado.
  const DiceShapeBox({
    required this.shape,
    required this.value,
    required this.dt,
    required this.onChanged,
    required this.label,
    super.key,
  });

  /// Forma do dado conforme o valor.
  final DiceShape shape;

  /// Valor do atributo.
  final int value;

  /// DT calculada (5 + valor + nível).
  final int dt;

  /// Alteração do valor.
  final ValueChanged<int> onChanged;

  /// Rótulo do atributo.
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(AppRadii.box),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(
            width: 65,
            height: 65,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _DiceShapePainter(shape),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    key: ValueKey('atr-$shape-$value'),
                    controller: TextEditingController(text: '$value'),
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                    ],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25.6,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: const InputDecoration(
                      filled: false,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isCollapsed: true,
                    ),
                    onChanged: (text) {
                      final parsed = int.tryParse(text);
                      if (parsed != null && parsed >= 1) {
                        onChanged(parsed);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'DT: $dt',
            style: const TextStyle(color: Color(0xFF888888), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _DiceShapePainter extends CustomPainter {
  const _DiceShapePainter(this.shape);

  final DiceShape shape;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.primary;
    final w = size.width;
    final h = size.height;

    switch (shape) {
      case DiceShape.d4:
        canvas.drawPath(
          _path(size, [
            const Offset(0.50, 0.05),
            const Offset(0.05, 0.95),
            const Offset(0.95, 0.95),
          ]),
          paint,
        );
      case DiceShape.d6:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.10, h * 0.10, w * 0.80, h * 0.80),
            const Radius.circular(8),
          ),
          paint,
        );
      case DiceShape.d8:
        canvas.drawPath(
          _path(size, [
            const Offset(0.50, 0),
            const Offset(1, 0.50),
            const Offset(0.50, 1),
            const Offset(0, 0.50),
          ]),
          paint,
        );
      case DiceShape.d10:
        canvas.drawPath(
          _path(size, [
            const Offset(0.50, 0),
            const Offset(1, 0.35),
            const Offset(0.50, 1),
            const Offset(0, 0.35),
          ]),
          paint,
        );
      case DiceShape.d12:
        canvas.drawPath(
          _path(size, [
            const Offset(0.50, 0),
            const Offset(1, 0.38),
            const Offset(0.81, 1),
            const Offset(0.19, 1),
            const Offset(0, 0.38),
          ]),
          paint,
        );
      case DiceShape.d20:
        canvas.drawPath(
          _path(size, [
            const Offset(0.50, 0),
            const Offset(0.95, 0.25),
            const Offset(0.95, 0.75),
            const Offset(0.50, 1),
            const Offset(0.05, 0.75),
            const Offset(0.05, 0.25),
          ]),
          paint,
        );
      case DiceShape.none:
        canvas.drawCircle(Offset(w / 2, h / 2), math.min(w, h) * 0.40,
            Paint()..color = const Color(0xFF444444));
    }
  }

  Path _path(Size size, List<Offset> fractions) {
    final path = Path();
    for (var i = 0; i < fractions.length; i++) {
      final point = Offset(
        fractions[i].dx * size.width,
        fractions[i].dy * size.height,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(_DiceShapePainter oldDelegate) =>
      oldDelegate.shape != shape;
}

/// Converte o valor do atributo na forma do dado (para o painter).
DiceShape diceShapeForValue(int value) => switch (value) {
      1 => DiceShape.d4,
      2 => DiceShape.d6,
      3 => DiceShape.d8,
      4 => DiceShape.d10,
      5 => DiceShape.d12,
      >= 6 => DiceShape.d20,
      _ => DiceShape.none,
    };
