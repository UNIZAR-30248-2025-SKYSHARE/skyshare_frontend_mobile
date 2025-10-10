import 'package:flutter/material.dart';
import '../../data/models/lunar_phase_model.dart';
import 'moon_phase_widget.dart';

/// Widget que representa una fila con información básica de una fase lunar.
/// Muestra:
/// - Imagen de la fase (iluminación)
/// - Nombre de la fase
/// - Día y fecha formateada
/// - Porcentaje de iluminación
class LunarPhaseItem extends StatelessWidget {
  final LunarPhase phase;
  final String weekday;
  final String dateStr;
  final double imageSize;
  final VoidCallback? onTap;

  const LunarPhaseItem({
    Key? key,
    required this.phase,
    required this.weekday,
    required this.dateStr,
    this.imageSize = 44,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use real model fields
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
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
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
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.7),
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
                    color: Colors.white.withOpacity(0.12),
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
                  color: Colors.white.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
