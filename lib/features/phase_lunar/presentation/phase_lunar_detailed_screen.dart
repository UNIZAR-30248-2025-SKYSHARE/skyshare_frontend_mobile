import 'package:flutter/material.dart';
import 'package:skyshare_frontend_mobile/features/phase_lunar/data/models/lunar_phase_model.dart';
import 'package:skyshare_frontend_mobile/features/phase_lunar/data/repositories/lunar_phase_repository.dart' as phase_lunar_repo;
import '../../../core/widgets/star_background.dart';
import 'widgets/moon_phase_widget.dart';

class PhaseLunarDetailedScreen extends StatefulWidget {
  final int lunarPhaseId;
  final DateTime date;

  const PhaseLunarDetailedScreen({
    Key? key,
    required this.lunarPhaseId,
    required this.date,
  }) : super(key: key);

  @override
  State<PhaseLunarDetailedScreen> createState() =>
      _PhaseLunarDetailedScreenState();
}

class _PhaseLunarDetailedScreenState extends State<PhaseLunarDetailedScreen> {
  late Future<LunarPhase?> _detailedPhaseFuture;

  @override
  void initState() {
    super.initState();
    _detailedPhaseFuture = _fetchDetailedMoonData();
  }

  Future<LunarPhase?> _fetchDetailedMoonData() async {
    debugPrint( '🌙 Fetching lunar phase detail for id=${widget.lunarPhaseId}, date=${widget.date}');
  final repo = phase_lunar_repo.LunarPhaseRepository();
    return await repo.fetchLunarPhaseDetailByIdAndDate(
      lunarPhaseId: widget.lunarPhaseId,
      date: widget.date,
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return StarBackground(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Moon Details'),
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
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final phase = snapshot.data;
            if (phase == null) {
              return const Center(
                  child: Text('No data available for this date'));
            }

            final iluminacion = (phase.porcentajeIluminacion ?? 0).round();

            return SafeArea(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),

                    // Luna grande
                    Center(
                      child: MoonPhaseWidget(
                        percentage: iluminacion,
                        size: 200,
                        imageAssetPath: 'public/resources/luna_image.jpg',
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Fecha
                    Text(
                      _formatDate(widget.date),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Main information
                    _InfoCard(
                      title: 'Current Lunar Phase',
                      icon: Icons.nightlight_round,
                      children: [
                        _InfoRow(label: 'Phase', value: phase.fase),
                        _InfoRow(label: 'Illumination', value: '$iluminacion%'),
                        _InfoRow(
                            label: 'Lunar age',
                            value: phase.edadLunar != null
                                ? '${phase.edadLunar!.toStringAsFixed(1)} days'
                                : '—'),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Times
                    _InfoCard(
                      title: 'Times',
                      icon: Icons.access_time,
                      children: [
                        _InfoRow(label: 'Moonrise', value: phase.horaSalida ?? '—'),
                        _InfoRow(label: 'Moonset', value: phase.horaPuesta ?? '—'),
                        _InfoRow(
                            label: 'Current altitude',
                            value: phase.altitudActual != null
                                ? '${phase.altitudActual!.toStringAsFixed(1)}°'
                                : '—'),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Additional info
                    _InfoCard(
                      title: 'Additional info',
                      icon: Icons.info_outline,
                      children: [
                        _InfoRow(
                            label: 'Next important phase',
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
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
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
