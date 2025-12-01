import 'package:flutter/material.dart';
import 'alert_style.dart';
import 'package:skyshare_frontend_mobile/core/i18n/app_localizations.dart';

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
    final loc = AppLocalizations.of(context);
    
    final String alertLabel = totalAlerts == 1
        ? (loc?.t('alerts.header.alert_singular') ?? 'alert')
        : (loc?.t('alerts.header.alert_plural') ?? 'alerts');
        
    final String activeLabel = loc?.t('alerts.header.active') ?? 'active';

    return Container(
      key: const Key('alerts_header_container'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(
          color: Colors.white.withAlpha((0.1 * 255).toInt()),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _InfoChip(
            key: const Key('alerts_header_total'),
            icon: Icons.notifications,
            label: '$totalAlerts $alertLabel',
            color: Colors.white70,
          ),
          _InfoChip(
            key: const Key('alerts_header_active'),
            icon: Icons.check_circle,
            label: '$activeAlerts $activeLabel',
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
    super.key,
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