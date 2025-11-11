import 'package:flutter/material.dart';
import 'package:skyshare_frontend_mobile/features/dashboard/data/models/weather_model.dart';
import 'package:skyshare_frontend_mobile/core/i18n/app_localizations.dart';

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
          colors: [Color(0x001a1f3a), Color(0x0026273a)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.06), width: 1),
        boxShadow: [
          const BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.25),
            blurRadius: 10,
            offset: Offset(0, 6),
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
                '${AppLocalizations.of(context)?.t('weather.humidity') ?? 'Humedad'}: $humidity%',
                style: const TextStyle(
                  color: Color.fromRGBO(255, 255, 255, 0.8),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${AppLocalizations.of(context)?.t('weather.cloudiness') ?? 'Nubosidad'}: $clouds%',
                style: const TextStyle(
                  color: Color.fromRGBO(255, 255, 255, 0.8),
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
                    _getSkyConditionLabel(context, weather.cloudCoverage),
                    style: const TextStyle(
                      color: Color.fromRGBO(255, 255, 255, 0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${AppLocalizations.of(context)?.t('weather.wind') ?? 'Viento'}: $wind km/h',
                style: const TextStyle(
                  color: Color.fromRGBO(255, 255, 255, 0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getSkyConditionLabel(BuildContext context, double? cloudCoverage) {
    final t = AppLocalizations.of(context);
    if (cloudCoverage == null) return t?.t('weather.unknown_condition') ?? 'Condición desconocida';
    if (cloudCoverage < 20) return t?.t('weather.clear') ?? 'Despejado';
    if (cloudCoverage < 50) return t?.t('weather.partial_clouds') ?? 'Parcialmente nublado';
    if (cloudCoverage < 80) return t?.t('weather.cloudy') ?? 'Nublado';
    return t?.t('weather.very_cloudy') ?? 'Muy nublado';
  }
}
