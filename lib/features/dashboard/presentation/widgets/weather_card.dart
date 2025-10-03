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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '${weather.temperature?.toStringAsFixed(0)} °C',
                style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text('Humedad: ${weather.humidity}%', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
              const SizedBox(height: 4),
              Text('Nubosidad: ${weather.cloudCoverage}%', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
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
                  Text('Parcialmente Nublado', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                ],
              ),
              const SizedBox(height: 12),
              Text('Viento: 10 km/h SW', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
