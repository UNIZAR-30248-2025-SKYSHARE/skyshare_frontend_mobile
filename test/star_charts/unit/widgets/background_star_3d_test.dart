import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/star_charts/presentation/widgets/background_star_3d.dart';

void main() {
  group('BackgroundStar3D', () {
    test('update modifies brightness with twinkle effect', () {
      final star = BackgroundStar3D(
        az: 45.0,
        alt: 30.0,
        size: 1.5,
        brightness: 0.8,
        twinkleSpeed: 1.0,
        baseBrightness: 0.8,
      );

      final initialBrightness = star.brightness;

      star.update(1000);

      expect(star.brightness, isNot(equals(initialBrightness)));
      expect(star.brightness, inInclusiveRange(0.0, 1.0));
    });

    test('update keeps brightness within expected multiplier bounds', () {
      final base = 0.1;
      final star = BackgroundStar3D(
        az: 45.0,
        alt: 30.0,
        size: 1.5,
        brightness: base,
        twinkleSpeed: 10.0,
        baseBrightness: base,
      );

      star.update(1000);

      final expectedMin = base * 0.4;
      final expectedMax = base * 1.0;

      expect(star.brightness, greaterThanOrEqualTo(expectedMin));
      expect(star.brightness, lessThanOrEqualTo(expectedMax));
    });
  });
}
