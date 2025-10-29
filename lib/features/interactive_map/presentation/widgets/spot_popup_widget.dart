import 'package:flutter/material.dart';
import '../../../interactive_map/data/models/spot_model.dart';
import '../../../interactive_map/data/repositories/spot_repository.dart';
import 'spot_edit_dialog.dart';

class SpotPopupWidget extends StatefulWidget {
  final Spot spot;
  final double width;
  final VoidCallback onClose;
  final VoidCallback onViewDetails;
  final Color backgroundColor;
  final VoidCallback? onSpotUpdated;
  final dynamic onEdit;
  final dynamic onDelete;

  const SpotPopupWidget({
    super.key,
    required this.spot,
    required this.width,
    required this.onClose,
    required this.onViewDetails,
    required this.backgroundColor,
    this.onSpotUpdated,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<SpotPopupWidget> createState() => _SpotPopupWidgetState();
}

class _SpotPopupWidgetState extends State<SpotPopupWidget> {
  final SpotRepository _spotRepo = SpotRepository();

  @override
  void initState() {
    super.initState();
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return SpotEditDialog(
          spot: widget.spot,
          onSpotUpdated: widget.onSpotUpdated ?? () {},
          spotRepo: _spotRepo,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const triangleHeight = 12.0;
    const borderRadius = 12.0;
    final bool isMySpot = widget.spot.esMio;
    
    return IntrinsicHeight(
      child: SizedBox(
        width: widget.width,
        child: Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 20,
              child: ClipPath(
                clipper: _PopupClipper(radius: borderRadius, triangleHeight: triangleHeight),
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.backgroundColor,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10 + triangleHeight),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.spot.nombre,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (widget.spot.valoracionMedia != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.yellow,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.star, size: 14, color: _ratingColor(widget.spot)),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.spot.valoracionMedia!.toStringAsFixed(1),
                                      style: TextStyle(color: _ratingColor(widget.spot), fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.spot.descripcion ?? 'Muy chulo',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        if (isMySpot) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton.icon(
                                icon: const Icon(Icons.edit, size: 16),
                                label: const Text('Editar'),
                                onPressed: () => _showEditDialog(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[700],
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: widget.onViewDetails,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E293B),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                              child: const Text('Ver detalles'),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: widget.onClose,
                              child: const Text('Cerrar', style: TextStyle(color: Colors.white70)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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

class _PopupClipper extends CustomClipper<Path> {
  final double radius;
  final double triangleHeight;

  _PopupClipper({required this.radius, required this.triangleHeight});

  @override
  Path getClip(Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height - triangleHeight);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final path = Path()..addRRect(rrect);
    final triangleWidth = triangleHeight * 2;
    final tx = (size.width - triangleWidth) / 2;
    path.moveTo(tx, size.height - triangleHeight);
    path.relativeLineTo(triangleWidth / 2, triangleHeight);
    path.relativeLineTo(triangleWidth / 2, -triangleHeight);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}