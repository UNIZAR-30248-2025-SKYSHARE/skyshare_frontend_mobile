import 'package:flutter/material.dart';
import 'package:skyshare_frontend_mobile/core/i18n/app_localizations.dart';
import 'dart:math';

class SkyIndicator extends StatelessWidget {
  final double value;

  const SkyIndicator({required this.value, super.key});

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 10.0);
    final color = clamped >= 7 ? Colors.green : clamped >= 5 ? Colors.lightGreen : clamped >= 3 ? Colors.orange : Colors.red;
    return Row(
      children: <Widget>[
        SizedBox(
          width: 140,
          height: 90,
          child: CustomPaint(
            painter: _GaugePainter(clamped, color),
          ),
        ),
        const SizedBox(width: 48),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)?.t('dashboard.sky_score') ?? 'Puntuación del Cielo', style: const TextStyle(color: Color.fromRGBO(255, 255, 255, 0.85), fontSize: 16)),
            const SizedBox(height: 8),
            Text('${clamped.toStringAsFixed(1)} / 10', style: TextStyle(color: color, fontSize: 28, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double value;
  final Color color;

  _GaugePainter(this.value, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width * 0.45;
    final backgroundPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..shader = const SweepGradient(colors: [Colors.red, Colors.orange, Colors.yellow, Colors.lightGreen, Colors.green]).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), pi, pi, false, backgroundPaint);
    final angle = pi + (value / 10) * pi;
    final needlePaint = Paint()..color = Colors.white..strokeWidth = 3..strokeCap = StrokeCap.round;
    final needleEnd = Offset(center.dx + cos(angle) * radius, center.dy + sin(angle) * radius);
    canvas.drawLine(center, needleEnd, needlePaint);
    final knobPaint = Paint()..color = color;
    canvas.drawCircle(center, 6, knobPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
