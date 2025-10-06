import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/dashboard/data/models/sky_indicator_model.dart';

void main() {
  group('SkyIndicator', () {
    test('fromValue creates correct indicator for excellent quality', () {
      final indicator = SkyIndicator.fromValue(85.0);
      expect(indicator.value, 85.0);
      expect(indicator.quality, 'Excelente');
      expect(indicator.description, 'Condiciones óptimas para observación astronómica');
    });

    test('fromValue creates correct indicator for poor quality', () {
      final indicator = SkyIndicator.fromValue(15.0);
      expect(indicator.quality, 'Muy Pobre');
      expect(indicator.description, 'Condiciones muy desfavorables');
    });

    test('calculate computes correct value with weights', () {
      final indicator = SkyIndicator.calculate(
        astronomicalEvents: 8,
        cloudCoverage: 20.0,
        humidity: 30.0,
        moonIllumination: 40.0,
        bortleScale: 3.0,
      );
      expect(indicator.value, greaterThanOrEqualTo(0.0));
      expect(indicator.value, lessThanOrEqualTo(100.0));
      expect(indicator.quality, isNotEmpty);
      expect(indicator.description, isNotEmpty);
    });

    test('quality labels via fromValue for thresholds', () {
      expect(SkyIndicator.fromValue(90.0).quality, 'Excelente');
      expect(SkyIndicator.fromValue(70.0).quality, 'Buena');
      expect(SkyIndicator.fromValue(50.0).quality, 'Aceptable');
      expect(SkyIndicator.fromValue(30.0).quality, 'Pobre');
      expect(SkyIndicator.fromValue(10.0).quality, 'Muy Pobre');
    });

    test('toMap converts to correct map structure', () {
      final indicator = SkyIndicator.fromValue(75.0);
      final map = indicator.toMap();
      expect(map['value'], 75.0);
      expect(map['quality'], 'Buena');
      expect(map['description'], isNotEmpty);
    });

    test('calculate handles edge cases (all zeros) as clear sky', () {
      final indicator = SkyIndicator.calculate(
        astronomicalEvents: 0,
        cloudCoverage: 0.0,
        humidity: 0.0,
        moonIllumination: 0.0,
        bortleScale: 0.0,
      );
      expect(indicator.value, greaterThan(90.0));
      expect(indicator.value, lessThanOrEqualTo(100.0));
    });

    test('calculate handles maximum values', () {
      final indicator = SkyIndicator.calculate(
        astronomicalEvents: 15,
        cloudCoverage: 100.0,
        humidity: 100.0,
        moonIllumination: 100.0,
        bortleScale: 10.0,
      );
      expect(indicator.value, lessThanOrEqualTo(100.0));
    });
  });
}
