import 'package:flutter/material.dart';
import 'alert_style.dart';

class AlertsHeaderWidget extends StatelessWidget {
  final int totalAlerts;
  final int activeAlerts;

  const AlertsHeaderWidget({
    super.key,
    required this.totalAlerts,
    required this.activeAlerts,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        // make header slightly transparent so the star background is visible
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _InfoChip(
            icon: Icons.notifications,
            label: '$totalAlerts ${totalAlerts == 1 ? 'alerta' : 'alertas'}',
            color: Colors.white70,
          ),
          _InfoChip(
            icon: Icons.check_circle,
            label: '$activeAlerts activas',
            color: kAlertAccentDark,
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}