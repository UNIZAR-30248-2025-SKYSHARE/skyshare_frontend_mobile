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
    final raw = w.lightPollution ?? 0.0;
    final mapped = _mapContaminationToBortle(raw);
    final label = _bortleLabel(mapped);
    return LightPollution(bortleScale: mapped, sourceValue: raw, location: location, label: label);
  }

  static int _mapContaminationToBortle(double value) {
    final v = value;
    if (v <= 0.5) return 1;
    if (v <= 1.5) return 2;
    if (v <= 2.5) return 3;
    if (v <= 3.5) return 4;
    if (v <= 4.5) return 5;
    if (v <= 5.5) return 6;
    if (v <= 6.5) return 7;
    if (v <= 7.5) return 8;
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
