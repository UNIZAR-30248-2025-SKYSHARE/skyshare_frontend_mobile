import 'dart:math';
import 'package:flutter/material.dart';

class SunMoonHeader extends StatelessWidget {
  final double page;
  final AnimationController pulse;

  const SunMoonHeader({required this.page, required this.pulse, super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final size = min(constraints.maxWidth, constraints.maxHeight);
      final sunSize = size * 0.6;
      final travel = constraints.maxWidth * 1.1;
      final moonOffsetX = lerpDouble(travel, 0.0, page)!;

      return Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: pulse,
            builder: (context, _) {
              final glow = 6 + 6 * pulse.value;
              return Center(
                child: Container(
                  width: sunSize,
                  height: sunSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Colors.amber.shade300, Colors.orange.shade900],
                      stops: const [0.0, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.22),
                        blurRadius: glow,
                        spreadRadius: glow * 0.25,
                      ),
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.07),
                        blurRadius: glow * 4,
                        spreadRadius: glow,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Center(
            child: Container(
              width: sunSize * 1.38,
              height: sunSize * 1.38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Colors.amber.withOpacity(0.12), Colors.transparent],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(moonOffsetX, 0),
            child: Center(
              child: Container(
                width: sunSize,
                height: sunSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.yellow.shade700.withOpacity(0.9 - (page * 0.7)),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: CustomPaint(
                  painter: _MoonRimPainter(progress: page),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _MoonRimPainter extends CustomPainter {
  final double progress;
  _MoonRimPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final rimPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.yellow.shade100.withOpacity(0.9 * (1 - progress)), Colors.transparent],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(size.width * 0.1, size.height * 0.5), radius: size.width * 0.7));

    if (progress > 0 && progress < 1.0) {
      canvas.drawCircle(Offset(size.width * 0.12, size.height * 0.5), size.width * 0.5, rimPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MoonRimPainter oldDelegate) => oldDelegate.progress != progress;
}

double? lerpDouble(num a, num b, double t) => a + (b - a) * t;