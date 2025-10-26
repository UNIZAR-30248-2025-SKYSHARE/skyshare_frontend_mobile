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
            // Icono de estrella grande
            Icon(
              Icons.notifications_off_outlined,
              size: 120,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            
            // Texto principal
            const Text(
              'No tienes alertas',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // Texto secundario
            Text(
              'Crea tu primera alerta astronómica\npara no perderte ningún evento',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.7),
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