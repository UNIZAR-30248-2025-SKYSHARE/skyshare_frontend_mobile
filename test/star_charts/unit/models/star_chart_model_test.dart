import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/star_charts/data/models/star_chart_model.dart';

void main() {
  group('StarChartModel', () {
    test('fromJson parses all fields correctly', () {
      final json = {
        'imageUrl': 'https://example.com/chart.jpg',
        'cached': true,
        'cachedKey': 'chart_123',
        'expiresAt': '2024-12-31T23:59:59Z',
      };

      final model = StarChartModel.fromJson(json);

      expect(model.imageUrl, 'https://example.com/chart.jpg');
      expect(model.cached, true);
      expect(model.cachedKey, 'chart_123');
      expect(model.expiresAt, DateTime.parse('2024-12-31T23:59:59Z'));
      expect(model.generatedAt, isA<DateTime>());
    });

    test('fromJson uses default value for cached', () {
      final json = {
        'imageUrl': 'https://example.com/chart.jpg',
        'cachedKey': 'chart_123',
        'expiresAt': '2024-12-31T23:59:59Z',
      };

      final model = StarChartModel.fromJson(json);

      expect(model.cached, false);
    });

    test('isExpired returns true when expired', () {
      final model = StarChartModel(
        imageUrl: 'https://example.com/chart.jpg',
        cached: false,
        cachedKey: 'chart_123',
        expiresAt: DateTime.now().subtract(const Duration(days: 1)),
        generatedAt: DateTime.now(),
      );

      expect(model.isExpired, true);
    });

    test('isExpired returns false when not expired', () {
      final model = StarChartModel(
        imageUrl: 'https://example.com/chart.jpg',
        cached: false,
        cachedKey: 'chart_123',
        expiresAt: DateTime.now().add(const Duration(days: 1)),
        generatedAt: DateTime.now(),
      );

      expect(model.isExpired, false);
    });
  });
}