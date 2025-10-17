import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skyshare_frontend_mobile/features/phase_lunar/providers/lunar_phase_provider.dart';
import 'package:skyshare_frontend_mobile/features/phase_lunar/data/models/lunar_phase_model.dart';
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
  String _locationName = 'Loading...';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = Provider.of<LunarPhaseProvider>(context, listen: false);
      _loadLocationName();
      provider.loadNext7Days();
    });
  }

  Future<void> _loadLocationName() async {
    try {
      final provider = Provider.of<LunarPhaseProvider>(context, listen: false);
      final locations = await provider.locationRepo.getSavedLocations(1);
      if (locations.isNotEmpty) {
        setState(() {
          _locationName = locations.first['nombre'] as String? ?? 'Unknown location';
        });
      }
    } catch (e) {
      setState(() {
        _locationName = 'Unknown location';
      });
    }
  }

  String _formatDate(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";

  String _weekdayName(DateTime d) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[d.weekday - 1];
  }

  void _navigateToDetail(LunarPhase phase, int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening ${phase.fase} details...'),
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
          child: Consumer<LunarPhaseProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (provider.error != null) {
                return Center(child: Text('Error: ${provider.error}'));
              }

              final phases = provider.phases;
              if (phases.isEmpty) {
                return const Center(child: Text('No lunar phases available'));
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
                        const Text(
                          'Next 7 days',
                          style: TextStyle(
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
                              _locationName,
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