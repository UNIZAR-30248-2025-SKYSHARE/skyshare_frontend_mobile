import 'package:flutter/material.dart';
import 'package:skyshare_frontend_mobile/core/i18n/app_localizations.dart';

class PhaseLunarInfoRow extends StatelessWidget {
  final String rise;
  final String set;
  final String illumination;

  const PhaseLunarInfoRow({super.key, required this.rise, required this.set, required this.illumination});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              const Icon(Icons.nights_stay, size: 20),
              const SizedBox(height: 6),
              Text((AppLocalizations.of(context)?.t('phase_lunar.rise') ?? 'Rise\n{time}').replaceAll('{time}', rise), textAlign: TextAlign.center),
            ],
          ),
          Column(
            children: [
              const Icon(Icons.wb_twighlight, size: 20),
              const SizedBox(height: 6),
              Text((AppLocalizations.of(context)?.t('phase_lunar.set') ?? 'Set\n{time}').replaceAll('{time}', set), textAlign: TextAlign.center),
            ],
          ),
          Column(
            children: [
              const Icon(Icons.light_mode, size: 20),
              const SizedBox(height: 6),
              Text((AppLocalizations.of(context)?.t('phase_lunar.illum') ?? 'Illum.\n{value}').replaceAll('{value}', illumination), textAlign: TextAlign.center),
            ],
          ),
        ],
      ),
    );
  }
}
