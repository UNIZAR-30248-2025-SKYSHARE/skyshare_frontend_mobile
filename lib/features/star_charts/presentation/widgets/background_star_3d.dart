import 'dart:math' as math;

class BackgroundStar3D {
  final double az;
  final double alt;
  final double size;
  double brightness;
  final double twinkleSpeed;
  final double baseBrightness;

  BackgroundStar3D({
    required this.az,
    required this.alt,
    required this.size,
    required this.brightness,
    required this.twinkleSpeed,
    required this.baseBrightness,
  });

  void update(int timestamp) {
    final timeFactor = timestamp / 1000;
    final twinkle = math.sin(timeFactor * twinkleSpeed) * 0.3 + 0.7;
    brightness = baseBrightness * twinkle.clamp(0.3, 1.0);
  }
}