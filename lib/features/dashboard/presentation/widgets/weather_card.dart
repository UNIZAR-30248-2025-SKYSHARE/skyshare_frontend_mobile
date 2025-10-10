import 'package:flutter/material.dart';
import '../../data/models/weather_model.dart';

class WeatherCard extends StatelessWidget {
  final WeatherData weather;

  const WeatherCard({
    required this.weather,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final temp = weather.temperature?.toStringAsFixed(0) ?? '--';
    final humidity = weather.humidity?.toStringAsFixed(0) ?? '--';
    final clouds = weather.cloudCoverage?.toStringAsFixed(0) ?? '--';
    final wind = weather.wind?.toStringAsFixed(1) ?? '--';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x1A1F3A), Color(0x26273A)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Row(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '$temp °C',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Humedad: $humidity%',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Nubosidad: $clouds%',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const Spacer(),

          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Icon(Icons.wb_sunny, color: Colors.amber, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    _getSkyConditionLabel(weather.cloudCoverage),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Viento: $wind km/h',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getSkyConditionLabel(double? cloudCoverage) {
    if (cloudCoverage == null) return 'Condición desconocida';
    if (cloudCoverage < 20) return 'Despejado';
    if (cloudCoverage < 50) return 'Parcialmente nublado';
    if (cloudCoverage < 80) return 'Nublado';
    return 'Muy nublado';
  }
}
