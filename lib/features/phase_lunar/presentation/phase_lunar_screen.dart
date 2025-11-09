import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skyshare_frontend_mobile/features/phase_lunar/providers/lunar_phase_provider.dart';
import 'package:skyshare_frontend_mobile/features/phase_lunar/data/models/lunar_phase_model.dart';
import 'package:skyshare_frontend_mobile/features/dashboard/providers/dashboard_provider.dart';
import 'package:skyshare_frontend_mobile/core/i18n/app_localizations.dart';
import 'widgets/moon_phase_widget.dart';
import 'widgets/lunar_phase_item.dart';
import '../../../core/widgets/star_background.dart';
import 'phase_lunar_detailed_screen.dart';

class PhaseLunarScreen extends StatefulWidget {
  const PhaseLunarScreen({super.key});

  @override
  State<PhaseLunarScreen> createState() => _PhaseLunarScreenState();
}

class _PhaseLunarScreenState extends State<PhaseLunarScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = Provider.of<LunarPhaseProvider>(context, listen: false);
      provider.loadNext7Days();
    });
  }

  String _formatDate(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";

  String _weekdayName(DateTime d) {
    // Use localized weekday short names when available, fall back to English
    final loc = AppLocalizations.of(context);
    final names = [
      loc?.t('weekday.mon') ?? 'Mon',
      loc?.t('weekday.tue') ?? 'Tue',
      loc?.t('weekday.wed') ?? 'Wed',
      loc?.t('weekday.thu') ?? 'Thu',
      loc?.t('weekday.fri') ?? 'Fri',
      loc?.t('weekday.sat') ?? 'Sat',
      loc?.t('weekday.sun') ?? 'Sun',
    ];
    return names[d.weekday - 1];
  }

  void _navigateToDetail(LunarPhase phase, int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text((AppLocalizations.of(context)?.t('opening_details') ?? 'Opening {name} details...').replaceAll('{name}', phase.fase)),
        duration: const Duration(milliseconds: 800),
      ),
    );

    Future.delayed(const Duration(milliseconds: 50), () {
      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return PhaseLunarDetailedScreen(
              lunarPhaseId: phase.idLuna,
              date: phase.fecha!,
            );
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return StarBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Consumer2<LunarPhaseProvider, DashboardProvider>(
            builder: (context, lunarProvider, dashboardProvider, _) {
              final locationName = dashboardProvider.selectedLocation?.name ?? 'Unknown location';

              if (lunarProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (lunarProvider.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Error: ${lunarProvider.error}',
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          lunarProvider.loadNext7Days();
                        },
                        child: Text(AppLocalizations.of(context)?.t('retry') ?? 'Reintentar'),
                      ),
                    ],
                  ),
                );
              }

              if (lunarProvider.shouldShowRetry) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.nightlight_round, color: Colors.orange, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)?.t('phases_loading_slow') ?? 'Las fases lunares están tardando en cargar',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          lunarProvider.loadNext7Days();
                        },
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                );
              }

              final phases = lunarProvider.phases;
              if (phases.isEmpty && !lunarProvider.isLoading) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.nightlight_round, color: Colors.grey, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)?.t('no_lunar_data') ?? 'No hay datos de fases lunares disponibles',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          lunarProvider.loadNext7Days();
                        },
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                );
              }

              final todayPhase = phases.first;
              final percentage = (todayPhase.porcentajeIluminacion ?? 0).round();

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Column(
                      children: [
                        MoonPhaseWidget(
                          percentage: percentage,
                          size: 120,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AppLocalizations.of(context)?.t('next_7_days') ?? 'Next 7 days',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              locationName,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: phases.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final p = phases[i];
                        final date = p.fecha;
                        final weekday = date != null ? _weekdayName(date) : '';
                        final dateStr = date != null ? _formatDate(date) : '';
                        return LunarPhaseItem(
                          phase: p,
                          weekday: weekday,
                          dateStr: dateStr,
                          imageSize: 44,
                          onTap: () => _navigateToDetail(p, i),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}