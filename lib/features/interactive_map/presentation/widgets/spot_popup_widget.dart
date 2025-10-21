import 'package:flutter/material.dart';
import '../../../interactive_map/data/models/spot_model.dart';

class SpotPopupWidget extends StatelessWidget {
  final Spot spot;
  final double width;
  final double height;
  final VoidCallback onClose;
  final VoidCallback onViewDetails;
  final Color backgroundColor;

  const SpotPopupWidget({
    super.key,
    required this.spot,
    required this.width,
    required this.height,
    required this.onClose,
    required this.onViewDetails,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    const triangleHeight = 12.0;
    return SizedBox(
      width: width,
      height: height + triangleHeight,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: height,
            child: CustomPaint(
              painter: _PopupPainter(color: backgroundColor, radius: 12.0, triangleHeight: triangleHeight),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10 + triangleHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            spot.nombre,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (spot.valoracionMedia != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.yellow,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.star, size: 14, color: _ratingColor(spot)),
                                const SizedBox(width: 4),
                                Text(
                                  spot.valoracionMedia!.toStringAsFixed(1),
                                  style: TextStyle(color: _ratingColor(spot), fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        spot.descripcion ?? '',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: onClose,
                          child: const Text('Cerrar', style: TextStyle(color: Colors.white70)),
                        ),
                        const SizedBox(width: 6),
                        ElevatedButton(
                          onPressed: onViewDetails,
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                          child: const Text('Ver detalles'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _ratingColor(Spot s) {
    if (s.valoracionMedia == null) return Colors.grey;
    if (s.valoracionMedia! >= 4.5) return Colors.green;
    if (s.valoracionMedia! >= 3.5) return Colors.orange;
    return Colors.red;
  }
}

class _PopupPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double triangleHeight;

  _PopupPainter({required this.color, required this.radius, required this.triangleHeight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height - triangleHeight);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final path = Path()..addRRect(rrect);
    final triangleWidth = triangleHeight * 2;
    final tx = (size.width - triangleWidth) / 2;
    path.moveTo(tx, size.height - triangleHeight);
    path.relativeLineTo(triangleWidth / 2, triangleHeight);
    path.relativeLineTo(triangleWidth / 2, -triangleHeight);
    path.close();
    canvas.drawShadow(path, Colors.black, 6.0, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
