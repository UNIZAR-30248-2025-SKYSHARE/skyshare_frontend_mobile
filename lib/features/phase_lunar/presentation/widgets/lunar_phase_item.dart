import 'package:flutter/material.dart';
import '../../data/models/lunar_phase_model.dart';
import 'moon_phase_widget.dart';

/// Widget que representa una fila con información básica de una fase lunar.
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
    int pct = ((phase.porcentajeIluminacion ?? 0)).round();
    if (pct < 0) pct = 0;
    if (pct > 100) pct = 100;
    final String phaseName = (phase.fase).isNotEmpty ? phase.fase : 'Unknown phase';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          debugPrint('───────────────────────────────');
          debugPrint('LunarPhaseItem TAPPED');
          debugPrint('Phase: $phaseName');
          debugPrint('ID: ${phase.idLuna}');
          debugPrint('───────────────────────────────');
          onTap?.call();
        },
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0x14FFFFFF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0x33FFFFFF),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Imagen de la luna
                MoonPhaseWidget(
                  percentage: pct,
                  size: imageSize,
                ),
                const SizedBox(width: 16),

                // Nombre y fecha
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        phaseName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$weekday, $dateStr',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xB2FFFFFF),
                        ),
                      ),
                    ],
                  ),
                ),

                // Porcentaje de iluminación
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0x1FFFFFFF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    pct > 0 ? '$pct%' : '–',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Icono de flecha
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: const Color(0x7FFFFFFF),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
