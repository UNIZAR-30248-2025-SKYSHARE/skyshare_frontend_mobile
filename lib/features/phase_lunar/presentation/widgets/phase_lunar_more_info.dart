import 'package:flutter/material.dart';
import 'package:skyshare_frontend_mobile/core/i18n/app_localizations.dart';

class PhaseLunarMoreInfo extends StatelessWidget {
  final double distance = 384.400 ;
  final String description;

  const PhaseLunarMoreInfo({super.key, required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min, // Evita que ocupe todo el espacio
        children: [
          ElevatedButton(
            onPressed: () {},
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              child: Text(AppLocalizations.of(context)?.t('phase_lunar.more_info') ?? 'More info'),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            (AppLocalizations.of(context)?.t('phase_lunar.mock_details') ?? 'Mock details:\n- Distance: {distance}\n- Phase description: {desc}')
                .replaceAll('{distance}', distance.toString())
                .replaceAll('{desc}', description),
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
