import 'package:flutter/material.dart';
import 'dart:math';

class StarBackground extends StatelessWidget {
  final Widget child;
  final int stars;
  final int seed;

  const StarBackground({required this.child, this.stars = 90, this.seed = 42, super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF020215), Color(0xFF0A0E27), Color(0xFF161426)],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: _StarPainter(stars: stars, seed: seed),
          ),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}

class _StarPainter extends CustomPainter {
  final int stars;
  final int seed;

  _StarPainter({this.stars = 90, this.seed = 42});

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = Random(seed);
    for (var i = 0; i < stars; i++) {
      final dx = rnd.nextDouble() * size.width;
      final dy = rnd.nextDouble() * size.height;
      final radius = rnd.nextDouble() * 1.6 + 0.25;
      final opacity = (rnd.nextDouble() * 0.7 + 0.12).clamp(0.12, 1.0);
      final paint = Paint()..color = Colors.white.withOpacity(opacity);
      if (rnd.nextDouble() < 0.07) {
        paint.maskFilter = MaskFilter.blur(BlurStyle.normal, rnd.nextDouble() * 2.6 + 0.6);
      }
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }

    final nebulaPaint = Paint()
      ..shader = RadialGradient(colors: [Colors.white.withOpacity(0.04), Colors.transparent]).createShader(
        Rect.fromCircle(center: Offset(size.width * 0.8, size.height * 0.22), radius: size.width * 0.16),
      );
    canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.8, size.height * 0.22), width: size.width * 0.32, height: size.height * 0.14), nebulaPaint);

    final nebulaPaint2 = Paint()
      ..shader = RadialGradient(colors: [Colors.white.withOpacity(0.03), Colors.transparent]).createShader(
        Rect.fromCircle(center: Offset(size.width * 0.18, size.height * 0.72), radius: size.width * 0.20),
      );
    canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.18, size.height * 0.72), width: size.width * 0.40, height: size.height * 0.18), nebulaPaint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
