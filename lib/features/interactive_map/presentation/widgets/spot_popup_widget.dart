import 'package:flutter/material.dart';
import '../../../interactive_map/data/models/spot_model.dart';
import '../../../interactive_map/data/models/comment_model.dart';
import '../../../interactive_map/data/models/rating_model.dart';
import '../../../interactive_map/data/repositories/comment_repository.dart';
import '../../../interactive_map/data/repositories/rating_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SpotPopupWidget extends StatelessWidget {
  final Spot spot;
  final double width;
  final double height;
  final VoidCallback onClose;
  final VoidCallback onViewDetails;
  final Color backgroundColor;

  SpotPopupWidget({
    super.key,
    required this.spot,
    required this.width,
    required this.height,
    required this.onClose,
    required this.onViewDetails,
    required this.backgroundColor,
  });

  final ComentarioRepository _comentarioRepo = ComentarioRepository();
  final RatingRepository _ratingRepo = RatingRepository();

  @override
  Widget build(BuildContext context) {
    const triangleHeight = 12.0;
    return IntrinsicHeight(
      child: SizedBox(
      width: width,
      height: height+ triangleHeight,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 20,
            height: height,

            child: CustomPaint(
              painter: _PopupPainter(
                  color: backgroundColor,
                  radius: 12.0,
                  triangleHeight: triangleHeight),
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
                            spot.nombre,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (spot.valoracionMedia != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.yellow,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.star,
                                    size: 14, color: _ratingColor(spot)),
                                const SizedBox(width: 4),
                                Text(
                                  spot.valoracionMedia!.toStringAsFixed(1),
                                  style: TextStyle(
                                      color: _ratingColor(spot),
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(
                      //Text(
                        spot.descripcion ?? '',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                _showCommentDialog(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF334155),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                              ),
                              child: const Text('Comentar'),
                            ),
                            const SizedBox(width: 6),
                            ElevatedButton(
                              onPressed: onViewDetails,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E293B),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 8)),
                              child: const Text('Ver detalles'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton(
                                onPressed: onClose,
                                child: const Text('Cerrar',
                                    style: TextStyle(color: Colors.white70)),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () => _showRatingDialog(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF334155),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                ),
                                child: const Text('Puntuar'),
                              ),
                            ],
                          ),
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
      ),
    );
  }

  Color _ratingColor(Spot s) {
    if (s.valoracionMedia == null) return Colors.grey;
    if (s.valoracionMedia! >= 4.5) return Colors.green;
    if (s.valoracionMedia! >= 3.5) return Colors.orange;
    return Colors.red;
  }

  void _showCommentDialog(BuildContext context) {
    final TextEditingController _controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E2E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Comentar spot',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: _controller,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Escribe tu comentario aquí...',
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: const Color(0xFF2A2A3C),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                final content = _controller.text.trim();
                if (content.isEmpty) return;
                Navigator.pop(context);
                try {
                  final user = Supabase.instance.client.auth.currentUser;
                  if (user == null) {
                    // Manejar usuario no logueado
                    return;
                  }
                  final comentario = Comment(
                    id: 0, // Si es autoincrement en DB, se puede dejar 0
                    spotId: spot.id,
                    userId: 1, //userId: user.id,
                    text: content,
                    createdAt: DateTime.now(),
                  );
                  final success =
                      await _comentarioRepo.insertComentario(comentario);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Comentario enviado correctamente!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    throw Exception('No se pudo insertar el comentario');
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al enviar comentario: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );
  }

  void _showRatingDialog(BuildContext context) {
    int rating = 0; // Valor inicial
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E2E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Valorar spot',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Selecciona tu valoración:',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setState) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starIndex = index + 1;
                      return IconButton(
                        icon: Icon(
                          starIndex <= rating
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 36,
                        ),
                        onPressed: () {
                          setState(() {
                            rating = starIndex;
                          });
                        },
                      );
                    }),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                if (rating == 0) return;
                Navigator.pop(context);
                try {
                  final user = Supabase.instance.client.auth.currentUser;
                  if (user == null) {
                    // Manejar usuario no logueado
                    return;
                  }

                  // Crear objeto de valoración
                  final valoracion = Rating(
                    spotId: spot.id,
                    userId: user.id, // Aquí debes usar UUID si la tabla es UUID
                    value: rating,
                    createdAt: DateTime.now(),
                  );

                  // Insertar en la base de datos usando tu repositorio
                  final success = await _ratingRepo.insertRating(valoracion);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Valoración enviada correctamente!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    throw Exception('No se pudo insertar la valoración');
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al enviar valoración: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );
  }
}

class _PopupPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double triangleHeight;

  _PopupPainter(
      {required this.color, required this.radius, required this.triangleHeight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final rect =
        Rect.fromLTWH(0, 0, size.width, size.height - triangleHeight);
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
