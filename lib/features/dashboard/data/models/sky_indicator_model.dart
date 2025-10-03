class SkyIndicator {
  final double score;
  final int astronomicalEvents;
  final double cloudCoverage;
  final double humidity;
  final double moonIllumination;
  final int bortleScale;

  SkyIndicator({
    required this.score,
    required this.astronomicalEvents,
    required this.cloudCoverage,
    required this.humidity,
    required this.moonIllumination,
    required this.bortleScale,
  });

  factory SkyIndicator.calculate({
    required int astronomicalEvents,
    required double cloudCoverage,
    required double humidity,
    required double moonIllumination,
    required int bortleScale,
  }) {
    const wA = 0.40;
    const wNubes = 0.25;
    const wLuz = 0.20;
    const wLuna = 0.10;
    const wHum = 0.05;

    final a = astronomicalEvents / 10.0;
    final nubes = (cloudCoverage / 100.0).clamp(0.0, 1.0);
    final hum = (humidity / 100.0).clamp(0.0, 1.0);
    final luna = (moonIllumination / 100.0).clamp(0.0, 1.0);
    final luz = ((bortleScale - 1) / 8.0).clamp(0.0, 1.0);

    final nubesScore = (1.0 - nubes).clamp(0.0, 1.0);
    final humScore = (1.0 - hum).clamp(0.0, 1.0);
    final lunaScore = (1.0 - luna).clamp(0.0, 1.0);
    final luzScore = (1.0 - luz).clamp(0.0, 1.0);

    final s = wA * a + wNubes * nubesScore + wLuz * luzScore + wLuna * lunaScore + wHum * humScore;
    final indicator = (s * 10.0 * 10.0).roundToDouble() / 10.0;

    return SkyIndicator(
      score: indicator,
      astronomicalEvents: astronomicalEvents,
      cloudCoverage: (cloudCoverage).toDouble(),
      humidity: (humidity).toDouble(),
      moonIllumination: (moonIllumination).toDouble(),
      bortleScale: bortleScale,
    );
  }

  String get qualityLabel {
    if (score >= 9.0) return 'Excelente';
    if (score >= 7.5) return 'Muy bueno';
    if (score >= 6.0) return 'Bueno';
    if (score >= 4.5) return 'Moderado';
    if (score >= 3.0) return 'Regular';
    return 'Malo';
  }

  Map<String, dynamic> toMap() {
    return {
      'score': score,
      'astronomical_events': astronomicalEvents,
      'cloud_coverage': cloudCoverage,
      'humidity': humidity,
      'moon_illumination': moonIllumination,
      'bortle_scale': bortleScale,
    };
  }
}
