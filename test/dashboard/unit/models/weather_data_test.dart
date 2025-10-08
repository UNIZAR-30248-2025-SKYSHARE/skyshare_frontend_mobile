import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/dashboard/data/models/weather_model.dart';

void main() {
  group('WeatherData', () {
    test('fromMap parses all fields correctly', () {
      final map = {
        'id_info_meteorologica': 1,
        'id_ubicacion': 2,
        'ultima_actualizacion': '2023-01-01T10:30:00Z',
        'temperatura': 25.5,
        'humedad': 60.0,
        'viento': 15.0,
        'nubosidad': 30.0,
        'contaminacion_luminica': 4.0,
        'indicador_general_sobre_el_cielo': 75.0,
      };
      final weather = WeatherData.fromMap(map);
      expect(weather.id, 1);
      expect(weather.locationId, 2);
      expect(weather.temperature, 25.5);
      expect(weather.humidity, 60.0);
      expect(weather.wind, 15.0);
      expect(weather.cloudCoverage, 30.0);
      expect(weather.lightPollution, 4.0);
      expect(weather.skyIndicator, 75.0);
    });

    test('fromMap handles null values', () {
      final map = {
        'id_info_meteorologica': 1,
        'id_ubicacion': 2,
        'ultima_actualizacion': '2023-01-01T10:30:00Z',
      };
      final weather = WeatherData.fromMap(map);
      expect(weather.temperature, isNull);
      expect(weather.humidity, isNull);
      expect(weather.wind, isNull);
      expect(weather.cloudCoverage, isNull);
      expect(weather.lightPollution, isNull);
      expect(weather.skyIndicator, isNull);
    });

    test('fromMap handles numeric values from int', () {
      final map = {
        'id_info_meteorologica': 1,
        'id_ubicacion': 2,
        'ultima_actualizacion': '2023-01-01T10:30:00Z',
        'temperatura': 25,
        'humedad': 60,
      };
      final weather = WeatherData.fromMap(map);
      expect(weather.temperature, 25.0);
      expect(weather.humidity, 60.0);
    });

    test('bortleLabel returns correct labels', () {
      expect(WeatherData.bortleLabel(1), 'Excelente (Clase 1)');
      expect(WeatherData.bortleLabel(2), 'Muy bueno (Clase 2)');
      expect(WeatherData.bortleLabel(3), 'Rural (Clase 3)');
      expect(WeatherData.bortleLabel(4), 'Transición rural-suburbano (Clase 4)');
      expect(WeatherData.bortleLabel(5), 'Suburbano (Clase 5)');
      expect(WeatherData.bortleLabel(6), 'Suburbano brillante (Clase 6)');
      expect(WeatherData.bortleLabel(7), 'Transición suburbano-urbano (Clase 7)');
      expect(WeatherData.bortleLabel(8), 'Urbano (Clase 8)');
      expect(WeatherData.bortleLabel(9), 'Urbano interior (Clase 9)');
      expect(WeatherData.bortleLabel(10), 'Urbano interior (Clase 9)');
    });

    test('toMap converts back to map correctly', () {
      final weather = WeatherData(
        id: 1,
        locationId: 2,
        timestamp: DateTime(2023, 1, 1, 10, 30),
        temperature: 25.5,
        humidity: 60.0,
        wind: 15.0,
        cloudCoverage: 30.0,
        lightPollution: 4.0,
        skyIndicator: 75.0,
      );
      final map = weather.toMap();
      expect(map['id_info_meteorologica'], 1);
      expect(map['id_ubicacion'], 2);
      expect(map['temperatura'], 25.5);
      expect(map['humedad'], 60.0);
      expect(map['viento'], 15.0);
      expect(map['nubosidad'], 30.0);
      expect(map['contaminacion_luminica'], 4.0);
      expect(map['indicador_general_sobre_el_cielo'], 75.0);
    });
  });
}
