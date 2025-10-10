import 'package:flutter/material.dart';
import 'package:skyshare_frontend_mobile/features/phase_lunar/data/models/lunar_phase_model.dart';
import 'package:skyshare_frontend_mobile/features/phase_lunar/data/repositories/lunar_phase_repository.dart' as phase_lunar_repo;
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
  late Future<List<LunarPhase>> _futurePhases;
  final String _locationName = 'Zaragoza';
  final int _locationId = 10; 
  final phase_lunar_repo.LunarPhaseRepository repo = phase_lunar_repo.LunarPhaseRepository();

  @override
  void initState() {
    super.initState();
    _futurePhases = _loadPhasesFromDatabase();
  }

  Future<List<LunarPhase>> _loadPhasesFromDatabase() async {
  try {
    final dashPhases = await repo.fetchNext7DaysSimple(_locationId);
    debugPrint('dashPhases fetched: ${dashPhases.length} items');

    return dashPhases.map((d) {
      return LunarPhase(
        idLuna: d.idLuna,
        idUbicacion: _locationId,
        fase: (d.fase.isNotEmpty) ? d.fase : 'Unknown phase',
        fecha: d.fecha,
        porcentajeIluminacion: (d.porcentajeIluminacion ?? 0).toDouble(),
      );
    }).toList();
  } catch (e, st) {
    debugPrint('Error loading lunar phases: $e\n$st');
    rethrow;
  }
}

  String _formatDate(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";

  String _weekdayName(DateTime d) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[d.weekday - 1];
  }

  void _navigateToDetail(LunarPhase phase, int index) {
    debugPrint('═══════════════════════════════════════');
    debugPrint('NAVIGATION TRIGGERED for phase: ${phase.fase}');
    debugPrint('Phase ID: ${phase.idLuna}, Index: $index');
    debugPrint('═══════════════════════════════════════');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening ${phase.fase} details...'),
        duration: const Duration(milliseconds: 800),
      ),
    );

    Future.delayed(const Duration(milliseconds: 50), () {
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
          child: FutureBuilder<List<LunarPhase>>(
            future: _futurePhases,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return Center(child: Text('Error: ${snap.error}'));
              }

              final phases = snap.data ?? [];
              if (phases.isEmpty) {
                return const Center(child: Text('No lunar phases available'));
              }

              final todayPhase = phases.first;
              final percentage =
                  (todayPhase.porcentajeIluminacion ?? 0).round();

              return Column(
                children: [
                  // Header con luna grande y ubicación
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

                  // Lista de fases
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: phases.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
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
