import 'package:skyshare_frontend_mobile/core/models/location_model.dart';
import 'package:skyshare_frontend_mobile/features/dashboard/data/models/weather_model.dart';

class LightPollution {
  final int bortleScale;
  final double sourceValue;
  final Location location;
  final String label;

  LightPollution({
    required this.bortleScale,
    required this.sourceValue,
    required this.location,
    required this.label,
  });

  factory LightPollution.fromWeatherData(WeatherData w, Location location) {
    final bortleFromDB = (w.lightPollution ?? 1.0).round().clamp(1, 9);
    final label = _bortleLabel(bortleFromDB);
    
    return LightPollution(
      bortleScale: bortleFromDB,
      sourceValue: w.lightPollution ?? 0.0,
      location: location,
      label: label,
    );
  }

  static int calculateBortleFromRaw(double rawValue) {
    if (rawValue <= 0.5) return 1;
    if (rawValue <= 1.5) return 2;
    if (rawValue <= 2.5) return 3;
    if (rawValue <= 3.5) return 4;
    if (rawValue <= 4.5) return 5;
    if (rawValue <= 5.5) return 6;
    if (rawValue <= 6.5) return 7;
    if (rawValue <= 7.5) return 8;
    return 9;
  }

  static String _bortleLabel(int b) {
    switch (b) {
      case 1:
        return 'Excelente (Clase 1)';
      case 2:
        return 'Muy bueno (Clase 2)';
      case 3:
        return 'Rural (Clase 3)';
      case 4:
        return 'Transición rural-suburbano (Clase 4)';
      case 5:
        return 'Suburbano (Clase 5)';
      case 6:
        return 'Suburbano brillante (Clase 6)';
      case 7:
        return 'Transición suburbano-urbano (Clase 7)';
      case 8:
        return 'Urbano (Clase 8)';
      case 9:
      default:
        return 'Urbano interior (Clase 9)';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'bortle_scale': bortleScale,
      'source_value': sourceValue,
      'location': location.toMap(),
      'label': label,
    };
  }
}