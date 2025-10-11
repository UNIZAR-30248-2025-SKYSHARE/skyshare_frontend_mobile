import 'package:flutter/material.dart';
import 'moon_phase_widget.dart';

class PhaseLunarDetailedHeader extends StatelessWidget {
  final dynamic phase; // LunarPhase, using dynamic here to avoid import cycles if any
  final double size;

  const PhaseLunarDetailedHeader({Key? key, required this.phase, this.size = 220}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateStr = '${phase.date.day.toString().padLeft(2, '0')}/${phase.date.month.toString().padLeft(2, '0')}/${phase.date.year}';

    return Column(
      children: [
        const SizedBox(height: 24),
        Center(
          child: MoonPhaseWidget(
            percentage: phase.percentage,
            size: size,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          dateStr,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          phase.phaseName.isNotEmpty ? phase.phaseName : 'Phase unknown',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
