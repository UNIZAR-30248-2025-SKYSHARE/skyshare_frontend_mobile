class WeatherData {
  final int id;
  final int locationId;
  final DateTime timestamp;
  final double? temperature;
  final double? humidity;
  final double? wind;
  final double? cloudCoverage;
  final double? lightPollution;
  final double? skyIndicator;

  const WeatherData({
    required this.id,
    required this.locationId,
    required this.timestamp,
    this.temperature,
    this.humidity,
    this.wind,
    this.cloudCoverage,
    this.lightPollution,
    this.skyIndicator,
  });

  factory WeatherData.fromMap(Map<String, dynamic> map) {
    return WeatherData(
      id: (map['id_info_meteorologica'] ?? map['id'] ?? 0) as int,
      locationId: (map['id_ubicacion'] as int),
      timestamp: DateTime.parse((map['ultima_actualizacion'] as String)),
      temperature: map['temperatura'] != null ? (map['temperatura'] as num).toDouble() : null,
      humidity: map['humedad'] != null ? (map['humedad'] as num).toDouble() : null,
      wind: map['viento'] != null ? (map['viento'] as num).toDouble() : null,
      cloudCoverage: map['nubosidad'] != null ? (map['nubosidad'] as num).toDouble() : null,
      lightPollution: map['contaminacion_luminica'] != null ? (map['contaminacion_luminica'] as num).toDouble() : null,
      skyIndicator: map['indicador_general_sobre_el_cielo'] != null ? (map['indicador_general_sobre_el_cielo'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_info_meteorologica': id,
      'id_ubicacion': locationId,
      'ultima_actualizacion': timestamp.toIso8601String(),
      'temperatura': temperature,
      'humedad': humidity,
      'viento': wind,
      'nubosidad': cloudCoverage,
      'contaminacion_luminica': lightPollution,
      'indicador_general_sobre_el_cielo': skyIndicator,
    };
  }

  static String bortleLabel(int b) {
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
}
