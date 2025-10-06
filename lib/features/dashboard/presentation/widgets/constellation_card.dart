import 'package:flutter/material.dart';
import '../../data/models/visible_sky_model.dart';

class ConstellationCard extends StatelessWidget {
  final VisibleSkyItem constellation;
  final VoidCallback onTap;

  const ConstellationCard({
    required this.constellation,
    required this.onTap,
    super.key,
  });

  String _formatTimestamp(DateTime t) {
    final dt = t.toLocal();
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year.toString();
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final ts = _formatTimestamp(constellation.timestamp);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 340,
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(255, 255, 255, 0.3),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color:const Color.fromRGBO(255, 255, 255, 0.12), width: 1.2),
          boxShadow: [const BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.35), blurRadius: 10, offset: Offset(0, 6))],
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    constellation.name,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ts,
                    style: const TextStyle(color: Color.fromRGBO(255, 255, 255, 0.6), fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color.fromRGBO(255, 255, 255, 0.03),
              ),
              child: const Icon(Icons.star, color: Colors.lightBlueAccent, size: 32),
            ),
          ],
        ),
      ),
    );
  }
}
