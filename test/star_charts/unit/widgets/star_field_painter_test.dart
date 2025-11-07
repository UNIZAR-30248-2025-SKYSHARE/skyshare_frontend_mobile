import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import 'package:skyshare_frontend_mobile/features/star_charts/presentation/widgets/star_field_painter.dart';
import 'package:skyshare_frontend_mobile/features/star_charts/presentation/widgets/background_star_3d.dart';

void main() {
  group('StarFieldPainter', () {
    final deviceOrientation = vm.Quaternion.identity();
    final stars = <Map<String, dynamic>>[];
    final backgroundStars = <BackgroundStar3D>[];
    final projectionCache = <String, Offset>{};

    test('shouldRepaint returns true when device orientation changes', () {
      final oldPainter = StarFieldPainter(
        deviceOrientation: vm.Quaternion.identity(),
        stars: stars,
        backgroundStars: backgroundStars,
        frameCount: 0,
        calculationFrameInterval: 3,
        projectionCache: projectionCache,
      );

      final newPainter = StarFieldPainter(
        deviceOrientation: vm.Quaternion.axisAngle(vm.Vector3(1, 0, 0), 1.0),
        stars: stars,
        backgroundStars: backgroundStars,
        frameCount: 0,
        calculationFrameInterval: 3,
        projectionCache: projectionCache,
      );

      expect(newPainter.shouldRepaint(oldPainter), true);
    });

    test('shouldRepaint returns true when stars change', () {
      final oldPainter = StarFieldPainter(
        deviceOrientation: deviceOrientation,
        stars: stars,
        backgroundStars: backgroundStars,
        frameCount: 0,
        calculationFrameInterval: 3,
        projectionCache: projectionCache,
      );

      final newPainter = StarFieldPainter(
        deviceOrientation: deviceOrientation,
        stars: [{'name': 'New Star'}],
        backgroundStars: backgroundStars,
        frameCount: 0,
        calculationFrameInterval: 3,
        projectionCache: projectionCache,
      );

      expect(newPainter.shouldRepaint(oldPainter), true);
    });

    test('shouldRepaint returns true when selectedObject changes', () {
      final oldPainter = StarFieldPainter(
        deviceOrientation: deviceOrientation,
        stars: stars,
        backgroundStars: backgroundStars,
        selectedObject: null,
        frameCount: 0,
        calculationFrameInterval: 3,
        projectionCache: projectionCache,
      );

      final newPainter = StarFieldPainter(
        deviceOrientation: deviceOrientation,
        stars: stars,
        backgroundStars: backgroundStars,
        selectedObject: {'name': 'Selected Star'},
        frameCount: 0,
        calculationFrameInterval: 3,
        projectionCache: projectionCache,
      );

      expect(newPainter.shouldRepaint(oldPainter), true);
    });

    test('shouldRepaint returns true when frameCount modulo changes', () {
      final oldPainter = StarFieldPainter(
        deviceOrientation: deviceOrientation,
        stars: stars,
        backgroundStars: backgroundStars,
        frameCount: 0,
        calculationFrameInterval: 3,
        projectionCache: projectionCache,
      );

      final newPainter = StarFieldPainter(
        deviceOrientation: deviceOrientation,
        stars: stars,
        backgroundStars: backgroundStars,
        frameCount: 1,
        calculationFrameInterval: 3,
        projectionCache: projectionCache,
      );

      expect(newPainter.shouldRepaint(oldPainter), true);
    });

    test('shouldRepaint returns false when nothing relevant changes', () {
      final oldPainter = StarFieldPainter(
        deviceOrientation: deviceOrientation,
        stars: stars,
        backgroundStars: backgroundStars,
        frameCount: 0,
        calculationFrameInterval: 3,
        projectionCache: projectionCache,
      );

      final newPainter = StarFieldPainter(
        deviceOrientation: deviceOrientation,
        stars: stars,
        backgroundStars: backgroundStars,
        frameCount: 3,
        calculationFrameInterval: 3,
        projectionCache: projectionCache,
      );

      expect(newPainter.shouldRepaint(oldPainter), false);
    });

    test('correctAz returns rawAz when no initialHeading', () {
      final painter = StarFieldPainter(
        deviceOrientation: deviceOrientation,
        stars: stars,
        backgroundStars: backgroundStars,
        frameCount: 0,
        calculationFrameInterval: 3,
        projectionCache: projectionCache,
        initialHeading: null,
      );

      expect(painter.correctAz(45.0), 45.0);
      expect(painter.correctAz(180.0), 180.0);
      expect(painter.correctAz(360.0), 360.0);
    });

    test('correctAz subtracts initialHeading and wraps around 360', () {
      final painter = StarFieldPainter(
        deviceOrientation: deviceOrientation,
        stars: stars,
        backgroundStars: backgroundStars,
        frameCount: 0,
        calculationFrameInterval: 3,
        projectionCache: projectionCache,
        initialHeading: 90.0,
      );

      expect(painter.correctAz(180.0), 90.0);
      expect(painter.correctAz(45.0), 315.0);
      expect(painter.correctAz(450.0), 0.0);
    });

    test('project calculates correct offset for positive z', () {
      final painter = StarFieldPainter(
        deviceOrientation: deviceOrientation,
        stars: stars,
        backgroundStars: backgroundStars,
        frameCount: 0,
        calculationFrameInterval: 3,
        projectionCache: projectionCache,
      );

      final center = const Offset(100, 100);
      final vector = vm.Vector3(10, 20, -50);
      final result = painter.project(vector, center);

      expect(result.dx, 140.0);
      expect(result.dy, 180.0);
    });

    test('generateConstellationPattern creates consistent pattern for same name', () {
      final painter = StarFieldPainter(
        deviceOrientation: deviceOrientation,
        stars: stars,
        backgroundStars: backgroundStars,
        frameCount: 0,
        calculationFrameInterval: 3,
        projectionCache: projectionCache,
      );

      final pattern1 = painter.generateConstellationPattern('Orion', 100.0, 30.0);
      final pattern2 = painter.generateConstellationPattern('Orion', 100.0, 30.0);

      expect(pattern1.length, pattern2.length);
      expect(pattern1[0]['az'], 100.0);
      expect(pattern1[0]['alt'], 30.0);
      expect(pattern1[0]['isMain'], 1.0);
      expect(pattern1[0]['mag'], 1.5);
    });

    test('generateConstellationPattern creates different patterns for different names', () {
      final painter = StarFieldPainter(
        deviceOrientation: deviceOrientation,
        stars: stars,
        backgroundStars: backgroundStars,
        frameCount: 0,
        calculationFrameInterval: 3,
        projectionCache: projectionCache,
      );

      final pattern1 = painter.generateConstellationPattern('Orion', 100.0, 30.0);
      final pattern2 = painter.generateConstellationPattern('Ursa Major', 100.0, 30.0);

      expect(pattern1, isNot(equals(pattern2)));
    });

    test('generateConstellationPattern creates correct number of stars', () {
      final painter = StarFieldPainter(
        deviceOrientation: deviceOrientation,
        stars: stars,
        backgroundStars: backgroundStars,
        frameCount: 0,
        calculationFrameInterval: 3,
        projectionCache: projectionCache,
      );

      final pattern = painter.generateConstellationPattern('Test', 100.0, 30.0);
      
      expect(pattern.length, inInclusiveRange(4, 6));
    });
  });
}