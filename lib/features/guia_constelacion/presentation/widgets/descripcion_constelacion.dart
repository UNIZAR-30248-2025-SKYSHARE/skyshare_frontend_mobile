import 'package:flutter/material.dart';
import 'package:skyshare_frontend_mobile/core/i18n/app_localizations.dart';

class DescripcionConstelacion extends StatelessWidget {
  final dynamic guia;
  const DescripcionConstelacion({super.key, required this.guia});

  IconData _getSeasonIcon(String temporada) {
    switch (temporada.toLowerCase()) {
      case 'invierno':
        return Icons.ac_unit;
      case 'verano':
        return Icons.wb_sunny;
      default:
        return Icons.star;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              guia.nombreConstelacion,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
            Row(
              children: [
                Icon(_getSeasonIcon(guia.temporada), color: Colors.white70, size: 26),
                const SizedBox(width: 6),
                Text(
                  guia.temporada,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          (AppLocalizations.of(context)?.t('que_es') ?? '¿Qué es {name}?').replaceAll('{name}', guia.nombreConstelacion),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          guia.descripcionGeneral ?? '',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white70,
                height: 1.5,
              ),
        ),
      ],
    );
  }
}
