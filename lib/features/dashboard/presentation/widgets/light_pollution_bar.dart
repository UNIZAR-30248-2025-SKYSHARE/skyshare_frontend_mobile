import 'package:flutter/material.dart';

class LightPollutionBar extends StatelessWidget {
  final double value;

  const LightPollutionBar({required this.value, super.key});

  Color _bortleColor(double scale) {
    if (scale <= 1) return Colors.black;
    if (scale <= 2) return const Color.fromARGB(255, 85, 85, 85);
    if (scale <= 3) return Colors.blue;
    if (scale <= 4) return Colors.green;
    if (scale <= 5) return Colors.yellow;
    if (scale <= 6) return Colors.orange;
    if (scale <= 7) return Colors.red;
    if (scale <= 8) return Colors.white;
    return Colors.white70;
  }

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(1.0, 9.0);
    final fraction = (clamped - 1.0) / 8.0;
    final markerColor = _bortleColor(clamped);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Contaminación Lumínica',
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final barWidth = constraints.maxWidth;
            final markerLeft =
                (barWidth * fraction - 6).clamp(0.0, barWidth - 12);

            final fillWidth = (barWidth * fraction).clamp(0.0, barWidth);

            return Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Container(
                  height: 22,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFF2A2E43),
                  ),
                ),
                Container(
                  width: fillWidth,
                  height: 22,
                  decoration: BoxDecoration(
                    borderRadius: fraction >= 1.0
                        ? BorderRadius.circular(12)
                        : const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                    color: markerColor,
                  ),
                ),
                Positioned(
                  left: markerLeft,
                  top: 26,
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: markerColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: markerColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          clamped.toStringAsFixed(1),
                          style: TextStyle(
                            color: markerColor.computeLuminance() > 0.5
                                ? Colors.black
                                : Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 10),
        Row(
          children: const <Widget>[
            Text('1', style: TextStyle(color: Colors.white70)),
            Spacer(),
            Text('9', style: TextStyle(color: Colors.white70)),
          ],
        ),
      ],
    );
  }
}
