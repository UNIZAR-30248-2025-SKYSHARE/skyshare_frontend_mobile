import 'package:flutter/material.dart';
import 'package:skyshare_frontend_mobile/core/i18n/app_localizations.dart';
import 'package:skyshare_frontend_mobile/features/phase_lunar/data/models/lunar_phase_model.dart';
import 'moon_phase_widget.dart';

class LunarPhaseItem extends StatelessWidget {
  final LunarPhase phase;
  final String weekday;
  final String dateStr;
  final double imageSize;
  final VoidCallback? onTap;

  const LunarPhaseItem({
    super.key,
    required this.phase,
    required this.weekday,
    required this.dateStr,
    this.imageSize = 44,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (phase.porcentajeIluminacion ?? 0).round();
    final percentageText = percentage > 0 ? '$percentage%' : '–';

    return Card(
      child: ListTile(
        leading: MoonPhaseWidget(
          percentage: percentage,
          size: imageSize,
        ),
        title: Text(phase.fase),
  subtitle: Text((AppLocalizations.of(context)?.t('phase_lunar.date_format') ?? '{weekday}, {date}').replaceAll('{weekday}', weekday).replaceAll('{date}', dateStr)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              percentageText,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}