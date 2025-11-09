import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:skyshare_frontend_mobile/features/star_charts/utils/sensor_wrapper.dart';
import 'package:skyshare_frontend_mobile/core/i18n/app_localizations.dart';
import 'custom_back_button.dart';

class CalibrationGuide extends StatelessWidget {
  final VoidCallback onContinue;
  final SensorWrapper? sensorWrapper;

  const CalibrationGuide({
    super.key,
    required this.onContinue,
    this.sensorWrapper,
    
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        StreamBuilder<AccelerometerEvent>(
          stream: (sensorWrapper ?? SensorWrapper()).accelerometerEvents,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return _buildLoading(context);
            }

            final event = snapshot.data!;
            final gY = ((event.y / 9.8).clamp(-1.0, 1.0)).toDouble();
            final pitch = math.asin(-gY) * 180 / math.pi;
            final ok = (pitch.abs() > 80 && pitch.abs() < 95);

            return _buildCalibrationUI(context, pitch, ok);
          },
        ),
        const Positioned(
          top: 0,
          left: 0,
          child: CustomBackButton(),
        ),
      ],
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)?.t('calib.initializing_sensors') ?? 'Inicializando sensores...',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalibrationUI(BuildContext context, double pitch, bool ok) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              ok ? Icons.check_circle : Icons.screen_rotation,
              size: 100,
              color: ok ? Colors.green : Colors.white70,
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)?.t('calib.place_phone_straight') ?? 'Coloca el móvil recto y mirando al frente',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              (AppLocalizations.of(context)?.t('calib.inclination') ?? 'Inclinación: {value}°').replaceAll('{value}', pitch.toStringAsFixed(1)),
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              key: const Key('continue-button'),
              onPressed: ok ? onContinue : null,
              icon: const Icon(Icons.arrow_forward),
              label: Text(AppLocalizations.of(context)?.t('continue') ?? 'CONTINUAR'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ok ? Colors.indigo : Colors.grey,
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}