import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skyshare_frontend_mobile/features/phase_lunar/providers/lunar_phase_provider.dart';
import 'package:skyshare_frontend_mobile/features/phase_lunar/data/models/lunar_phase_model.dart';
import '../../../core/widgets/star_background.dart';
import '../../../core/i18n/app_localizations.dart';
import 'widgets/moon_phase_widget.dart';

class PhaseLunarDetailedScreen extends StatefulWidget {
  final int lunarPhaseId;
  final DateTime date;

  const PhaseLunarDetailedScreen({
    super.key,
    required this.lunarPhaseId,
    required this.date,
  });

  @override
  State<PhaseLunarDetailedScreen> createState() =>
      _PhaseLunarDetailedScreenState();
}

class _PhaseLunarDetailedScreenState extends State<PhaseLunarDetailedScreen> {
  late Future<LunarPhase?> _detailedPhaseFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<LunarPhaseProvider>(context, listen: false);
      setState(() {
        _detailedPhaseFuture = provider.fetchDetail(widget.lunarPhaseId, widget.date);
      });
    });

    _detailedPhaseFuture = Future<LunarPhase?>.value(null);
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return StarBackground(
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)?.t('phase_lunar.moon_details') ?? 'Moon Details'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        body: FutureBuilder<LunarPhase?>(
          future: _detailedPhaseFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text((AppLocalizations.of(context)?.t('error_generic') ?? 'Error: {err}').replaceAll('{err}', snapshot.error.toString())));
            }

            final phase = snapshot.data;
            if (phase == null) {
              return Center(
                  child: Text(AppLocalizations.of(context)?.t('phase_lunar.no_data_for_date') ?? 'No data available for this date'));
            }

            final iluminacion = (phase.porcentajeIluminacion ?? 0).round();

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    Center(
                      child: MoonPhaseWidget(
                        percentage: iluminacion,
                        size: 200,
                        imageAssetPath: 'public/resources/luna_image.jpg',
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _formatDate(widget.date),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _InfoCard(
                      title: AppLocalizations.of(context)?.t('phase_lunar.current_lunar_phase') ?? 'Current Lunar Phase',
                      icon: Icons.nightlight_round,
                      children: [
                        _InfoRow(label: AppLocalizations.of(context)?.t('phase_lunar.phase') ?? 'Phase', value: phase.fase),
                        _InfoRow(label: AppLocalizations.of(context)?.t('phase_lunar.illumination') ?? 'Illumination', value: '$iluminacion%'),
                        _InfoRow(
                            label: AppLocalizations.of(context)?.t('phase_lunar.lunar_age') ?? 'Lunar age',
                            value: phase.edadLunar != null
                                ? '${phase.edadLunar!.toStringAsFixed(1)} days'
                                : '—'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _InfoCard(
                      title: AppLocalizations.of(context)?.t('phase_lunar.times') ?? 'Times',
                      icon: Icons.access_time,
                      children: [
                        _InfoRow(label: AppLocalizations.of(context)?.t('phase_lunar.moonrise') ?? 'Moonrise', value: phase.horaSalida ?? '—'),
                        _InfoRow(label: AppLocalizations.of(context)?.t('phase_lunar.moonset') ?? 'Moonset', value: phase.horaPuesta ?? '—'),
                        _InfoRow(
                            label: AppLocalizations.of(context)?.t('phase_lunar.current_altitude') ?? 'Current altitude',
                            value: phase.altitudActual != null
                                ? '${phase.altitudActual!.toStringAsFixed(1)}°'
                                : '—'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _InfoCard(
                      title: AppLocalizations.of(context)?.t('phase_lunar.additional_info') ?? 'Additional info',
                      icon: Icons.info_outline,
                      children: [
                        _InfoRow(
                            label: AppLocalizations.of(context)?.t('phase_lunar.next_important_phase') ?? 'Next important phase',
                            value: phase.proximaFase ?? '—'),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x0FFFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0x14FFFFFF),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.white70),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
