class SkyIndicator {
  final double value;
  final String quality;
  final String description;

  SkyIndicator({
    required this.value,
    required this.quality,
    required this.description,
  });

  factory SkyIndicator.fromValue(double dbValue) {
    final quality = _getQuality(dbValue);
    final description = _getDescription(dbValue);
    
    return SkyIndicator(
      value: dbValue,
      quality: quality,
      description: description,
    );
  }

  factory SkyIndicator.calculate({
    required int astronomicalEvents,
    required double cloudCoverage,
    required double humidity,
    required double moonIllumination,
    required double bortleScale,
  }) {
    final normalizedClouds = (100 - cloudCoverage) / 100;
    final normalizedHumidity = (100 - humidity) / 100;
    final normalizedMoon = (100 - moonIllumination) / 100;
    final normalizedBortle = (10 - bortleScale) / 9;
    final normalizedEvents = (astronomicalEvents / 10).clamp(0.0, 1.0);

    const cloudWeight = 0.30;
    const humidityWeight = 0.15;
    const moonWeight = 0.20;
    const bortleWeight = 0.25;
    const eventsWeight = 0.10;

    final rawScore = (normalizedClouds * cloudWeight) +
        (normalizedHumidity * humidityWeight) +
        (normalizedMoon * moonWeight) +
        (normalizedBortle * bortleWeight) +
        (normalizedEvents * eventsWeight);

    final value = (rawScore * 100).clamp(0.0, 100.0);
    final quality = _getQuality(value);
    final description = _getDescription(value);

    return SkyIndicator(
      value: value,
      quality: quality,
      description: description,
    );
  }

  static String _getQuality(double value) {
    if (value >= 80) return 'Excelente';
    if (value >= 60) return 'Buena';
    if (value >= 40) return 'Aceptable';
    if (value >= 20) return 'Pobre';
    return 'Muy Pobre';
  }

  static String _getDescription(double value) {
    if (value >= 80) {
      return 'Condiciones óptimas para observación astronómica';
    } else if (value >= 60) {
      return 'Buenas condiciones para observación';
    } else if (value >= 40) {
      return 'Condiciones moderadas';
    } else if (value >= 20) {
      return 'Condiciones difíciles para observación';
    } else {
      return 'Condiciones muy desfavorables';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'value': value,
      'quality': quality,
      'description': description,
    };
  }
}