// widgets/empty_alerts_widget.dart
import 'package:flutter/material.dart';

class EmptyAlertsWidget extends StatelessWidget {
  const EmptyAlertsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono de estrella grande con Key
            Icon(
              Icons.notifications_off_outlined,
              key: const Key('empty_alerts_icon'),
              size: 120,
              color: Colors.white.withAlpha((0.3 * 255).toInt()),
            ),
            const SizedBox(height: 24),
            
            const Text(
              'You don\'t have alerts',
              key: Key('empty_alerts_title'),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            Text(
              ' Make your first astronomical alert \nso you don\'t miss any event',
              key: const Key('empty_alerts_subtitle'),
              style: TextStyle(
                fontSize: 16,
              color: Colors.white.withAlpha((0.7 * 255).toInt()),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
