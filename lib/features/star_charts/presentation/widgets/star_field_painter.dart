import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import 'background_star_3d.dart';

class StarFieldPainter extends CustomPainter {
  final vm.Quaternion deviceOrientation;
  final List<Map<String, dynamic>> stars;
  final List<BackgroundStar3D> backgroundStars;
  final Map<String, dynamic>? selectedObject;
  final int frameCount;
  final int calculationFrameInterval;
  final Map<String, Offset> projectionCache;
  final double? initialHeading;

  const StarFieldPainter({
    required this.deviceOrientation,
    required this.stars,
    required this.backgroundStars,
    this.selectedObject,
    required this.frameCount,
    required this.calculationFrameInterval,
    required this.projectionCache,
    this.initialHeading,
  });

  static const double radius = 25.0;
  static const double focal = 200.0;

  double correctAz(double rawAz) {
    if (initialHeading == null) return rawAz;
    return (rawAz - initialHeading!) % 360;
  }

  Offset project(vm.Vector3 p, Offset center) {
    const eps = 0.0001;
    final z = p.z.abs() < eps ? (p.z < 0 ? -eps : eps) : p.z;
    return Offset(center.dx + (p.x / -z) * focal, center.dy + (p.y / -z) * focal);
  }

  List<Map<String, double>> generateConstellationPattern(String name, double azDeg, double altDeg) {
    final seed = name.hashCode;
    final random = math.Random(seed);
    final starCount = 4 + (seed.abs() % 3);
    final pattern = <Map<String, double>>[];
    pattern.add({'az': azDeg, 'alt': altDeg, 'mag': 1.5, 'isMain': 1.0});
    for (int i = 1; i < starCount; i++) {
      final azOffset = (random.nextDouble() - 0.5) * 45;
      final altOffset = (random.nextDouble() - 0.5) * 45;
      final mag = 2.5 + random.nextDouble() * 2.0;
      pattern.add({'az': azDeg + azOffset, 'alt': altDeg + altOffset, 'mag': mag, 'isMain': 0.0});
    }
    return pattern;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rot = deviceOrientation.asRotationMatrix();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final shouldCalculate = frameCount % calculationFrameInterval == 0;
    if (shouldCalculate) {
      projectionCache.clear();
      _drawBackground3D(canvas, center, rot, size, timestamp);
      _drawConstellations(canvas, center, rot, size);
      _drawStars(canvas, center, rot, size);
    } else {
      _drawCachedBackground(canvas, timestamp);
      _drawCachedObjects(canvas);
    }
  }

  void _drawBackground3D(Canvas canvas, Offset center, vm.Matrix3 rot, Size size, int timestamp) {
    final gradient = ui.Gradient.radial(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.8,
      [const Color(0xFF0A0A2A), const Color(0xFF050515), Colors.black],
      [0.0, 0.4, 1.0],
    );
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..shader = gradient);
    for (final star in backgroundStars) {
      star.update(timestamp);
      final az = correctAz(star.az) * math.pi / 180.0;
      final alt = star.alt * math.pi / 180.0;
      final wx = math.cos(alt) * math.sin(az);
      final wy = -math.sin(alt);
      final wz = -math.cos(alt) * math.cos(az);
      final world = vm.Vector3(wx * radius, wy * radius, wz * radius);
      final rotated = rot * world;
      if (rotated.z >= 0) continue;
      final proj = project(rotated, center);
      if (proj.dx < -50 || proj.dx > size.width + 50 || proj.dy < -50 || proj.dy > size.height + 50) continue;
      final alpha = (star.brightness * 255).toInt().clamp(30, 180);
      final color = Color.fromARGB(alpha, 255, 255, 255);
      final paint = Paint()..color = color..style = PaintingStyle.fill;
      canvas.drawCircle(proj, star.size, paint);
      if (star.brightness > 0.6) {
        final haloPaint = Paint()
          ..color = color.withOpacity(0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.0);
        canvas.drawCircle(proj, star.size * 2.0, haloPaint);
      }
    }
    _drawGround3D(canvas, center, rot, size);
    _drawNebulae3D(canvas, center, rot, size);
  }

  void _drawGround3D(Canvas canvas, Offset center, vm.Matrix3 rot, Size size) {
    const double groundSize = 1000.0;
    const double groundY = 100.0;
    const int gridLines = 20;
    final wireframePaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    final gridStep = groundSize / gridLines;
    final halfGround = groundSize / 2;
    for (int i = 0; i <= gridLines; i++) {
      final x = -halfGround + i * gridStep;
      final pathX = ui.Path();
      bool firstPointX = true;
      for (int j = 0; j <= gridLines; j++) {
        final z = -halfGround + j * gridStep;
        final world = vm.Vector3(x, groundY, z);
        final rotated = rot * world;
        if (rotated.z >= 0) continue;
        final proj = project(rotated, center);
        if (firstPointX) {
          pathX.moveTo(proj.dx, proj.dy);
          firstPointX = false;
        } else {
          pathX.lineTo(proj.dx, proj.dy);
        }
      }
      if (!firstPointX) canvas.drawPath(pathX, wireframePaint);
      final pathZ = ui.Path();
      bool firstPointZ = true;
      for (int j = 0; j <= gridLines; j++) {
        final z = -halfGround + j * gridStep;
        final world = vm.Vector3(z, groundY, x);
        final rotated = rot * world;
        if (rotated.z >= 0) continue;
        final proj = project(rotated, center);
        if (firstPointZ) {
          pathZ.moveTo(proj.dx, proj.dy);
          firstPointZ = false;
        } else {
          pathZ.lineTo(proj.dx, proj.dy);
        }
      }
      if (!firstPointZ) canvas.drawPath(pathZ, wireframePaint);
    }
  }

  void _drawNebulae3D(Canvas canvas, Offset center, vm.Matrix3 rot, Size size) {
    final nebulae = [
      {'az': 120.0, 'alt': 30.0, 'radius': 60.0, 'color': const Color(0x102A4A7A)},
      {'az': 300.0, 'alt': 20.0, 'radius': 80.0, 'color': const Color(0x101A3A5A)},
      {'az': 60.0, 'alt': -10.0, 'radius': 50.0, 'color': const Color(0x10081A2A)},
    ];
    for (final nebula in nebulae) {
      final az = correctAz(nebula['az'] as double) * math.pi / 180.0;
      final alt = (nebula['alt'] as double) * math.pi / 180.0;
      final radius = nebula['radius'] as double;
      final color = nebula['color'] as Color;
      final wx = math.cos(alt) * math.sin(az);
      final wy = -math.sin(alt);
      final wz = -math.cos(alt) * math.cos(az);
      final world = vm.Vector3(wx * radius, wy * radius, wz * radius);
      final rotated = rot * world;
      if (rotated.z >= 0) continue;
      final proj = project(rotated, center);
      final nebulaGradient = ui.Gradient.radial(proj, radius, [color, Colors.transparent], [0.0, 1.0]);
      canvas.drawCircle(proj, radius, Paint()..shader = nebulaGradient..blendMode = BlendMode.plus);
    }
  }

  void _drawCachedBackground(Canvas canvas, int timestamp) {}

  void _drawConstellations(Canvas canvas, Offset center, vm.Matrix3 rot, Size size) {
    final constellations = stars.where((obj) => obj['type'] == 'constellation').toList();
    for (final constellation in constellations) {
      try {
        if (constellation['is_visible'] != true) continue;
        final name = constellation['name'] as String? ?? 'Unknown';
        final azDeg = correctAz((constellation['az'] as num?)?.toDouble() ?? 0.0);
        final altDeg = (constellation['alt'] as num?)?.toDouble() ?? 0.0;
        final pattern = generateConstellationPattern(name, azDeg, altDeg);
        final projections = <Offset>[];
        for (final star in pattern) {
          final az = star['az']! * math.pi / 180.0;
          final alt = star['alt']! * math.pi / 180.0;
          final wx = math.cos(alt) * math.sin(az);
          final wy = -math.sin(alt);
          final wz = -math.cos(alt) * math.cos(az);
          final world = vm.Vector3(wx * radius, wy * radius, wz * radius);
          final rotated = rot * world;
          if (rotated.z < 0) {
            final proj = project(rotated, center);
            if (proj.dx >= -50 && proj.dx <= size.width + 50 && proj.dy >= -50 && proj.dy <= size.height + 50) projections.add(proj);
          }
        }
        final isSelected = selectedObject != null && selectedObject!['name'] == name;
        if (projections.length >= 2) {
          final linePaint = Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = isSelected ? 2.0 : 1.5
            ..color = (isSelected ? const Color(0xFF6366F1) : const Color(0xFF4A9EFF)).withOpacity(0.5);
          for (int i = 1; i < projections.length; i++) canvas.drawLine(projections[0], projections[i], linePaint);
          if (projections.length >= 3) {
            for (int i = 2; i < projections.length; i++) if (i % 2 == 0) canvas.drawLine(projections[i - 1], projections[i], linePaint);
          }
        }
        for (int i = 0; i < pattern.length && i < projections.length; i++) {
          final mag = pattern[i]['mag']!;
          final isMain = pattern[i]['isMain']! > 0.5;
          final baseSize = isMain ? 3.5 : math.max(1.5, 3.0 - mag * 0.3);
          final color = isMain ? Colors.white.withOpacity(0.9) : const Color(0xFF8AB4F8).withOpacity(0.7);
          if (isMain) {
            final haloPaint = Paint()
              ..color = color.withOpacity(0.2)
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, baseSize * 1.2);
            canvas.drawCircle(projections[i], baseSize * 1.8, haloPaint);
          }
          final starPaint = Paint()..color = color..style = PaintingStyle.fill;
          canvas.drawCircle(projections[i], baseSize, starPaint);
          if (isMain) {
            final glowPaint = Paint()..color = Colors.white.withOpacity(0.6)..style = PaintingStyle.fill;
            canvas.drawCircle(projections[i], baseSize * 0.5, glowPaint);
          }
        }
        if (projections.isNotEmpty) {
          final tp = TextPainter(
            text: TextSpan(
              text: name,
              style: TextStyle(
                color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF4A9EFF),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                shadows: [Shadow(color: Colors.black.withOpacity(0.9), blurRadius: 10, offset: Offset(2, 2))],
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          final labelX = projections[0].dx - tp.width / 2;
          final labelY = projections[0].dy - 35;
          if (labelX >= 0 && labelX + tp.width <= size.width && labelY >= 0 && labelY + tp.height <= size.height) tp.paint(canvas, Offset(labelX, labelY));
        }
      } catch (e) {}
    }
  }

  void _drawStars(Canvas canvas, Offset center, vm.Matrix3 rot, Size size) {
    final celestialObjects = stars.where((obj) => obj['type'] != 'constellation').toList();
    for (final obj in celestialObjects) {
      try {
        if (obj['is_visible'] != true) continue;
        final azDeg = correctAz((obj['az'] as num?)?.toDouble() ?? 0.0);
        final altDeg = (obj['alt'] as num?)?.toDouble() ?? 0.0;
        final mag = (obj['mag'] as num?)?.toDouble() ?? 3.0;
        final name = obj['name'] as String? ?? 'Unknown';
        final az = azDeg * math.pi / 180.0;
        final alt = altDeg * math.pi / 180.0;
        final wx = math.cos(alt) * math.sin(az);
        final wy = -math.sin(alt);
        final wz = -math.cos(alt) * math.cos(az);
        final world = vm.Vector3(wx * radius, wy * radius, wz * radius);
        final rotated = rot * world;
        if (rotated.z >= 0) continue;
        final proj = project(rotated, center);
        if (proj.dx < -100 || proj.dx > size.width + 100 || proj.dy < -100 || proj.dy > size.height + 100) continue;
        final cacheKey = 'star_${obj['id']}_$name';
        projectionCache[cacheKey] = proj;
        _drawSingleStar(canvas, proj, mag, name, obj);
      } catch (e) {}
    }
  }

  void _drawCachedObjects(Canvas canvas) {
    projectionCache.forEach((key, proj) {
      if (key.startsWith('star_')) {
        final parts = key.split('_');
        final name = parts.sublist(2).join('_');
        _drawSingleStar(canvas, proj, 3.0, name, null);
      }
    });
  }

  void _drawSingleStar(Canvas canvas, Offset proj, double mag, String name, Map<String, dynamic>? obj) {
    final baseSize = math.max(2.5, 10.0 - mag.abs() * 0.9);
    final size = baseSize;
    final isSelected = selectedObject != null && obj != null && selectedObject!['name'] == name;
    Color color;
    if (mag < -0.5) {
      color = const Color(0xFFB0E0FF);
    } else if (mag < 1.0) {
      color = Colors.white;
    } else if (mag < 2.5) {
      color = const Color(0xFFFFFACD);
    } else {
      color = const Color(0xFFFFA500);
    }
    if (isSelected) {
      final selectionHalo = Paint()
        ..color = const Color(0xFF6366F1).withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);
      canvas.drawCircle(proj, size * 4, selectionHalo);
    }
    final haloPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, size * 1.3);
    canvas.drawCircle(proj, size * 2.2, haloPaint);
    final starPaint = Paint()
      ..color = color.withOpacity(0.9)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(proj, size, starPaint);
    final glowPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(proj, size * 0.4, glowPaint);
    if (mag < 2.0) {
      final tp = TextPainter(
        text: TextSpan(
          text: name,
          style: TextStyle(
            color: isSelected ? const Color(0xFF6366F1) : Colors.white.withOpacity(0.95),
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            shadows: [Shadow(color: Colors.black.withOpacity(0.9), blurRadius: 8, offset: Offset(2, 2))],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(proj.dx - tp.width / 2, proj.dy + size + 10));
    }
  }

  @override
  bool shouldRepaint(covariant StarFieldPainter old) =>
      old.deviceOrientation != deviceOrientation ||
      old.stars != stars ||
      old.selectedObject != selectedObject ||
      old.frameCount % old.calculationFrameInterval != frameCount % calculationFrameInterval;
}