import 'package:flutter/material.dart';
// Asegúrate de que esta importación sea correcta
import '../../../interactive_map/data/models/spot_model.dart';
// Asegúrate de que estas importaciones sean correctas
import '../../../interactive_map/data/models/comment_model.dart';
import '../../../interactive_map/data/models/rating_model.dart';
import '../../../interactive_map/data/repositories/comment_repository.dart';
import '../../../interactive_map/data/repositories/rating_repository.dart';
import '../../../interactive_map/data/repositories/spot_repository.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart';
import 'spot_edit_dialog.dart'; 

class SpotPopupWidget extends StatelessWidget {
  final Spot spot;
  final double width;
  final double height;
  final VoidCallback onClose;
  final VoidCallback onViewDetails;
  final Color backgroundColor;
  final VoidCallback? onSpotUpdated; 
  
  final dynamic onEdit;
  final dynamic onDelete;

  SpotPopupWidget({
    super.key,
    required this.spot,
    required this.width,
    required this.height,
    required this.onClose,
    required this.onViewDetails,
    required this.backgroundColor,
    this.onSpotUpdated,
    this.onEdit,
    this.onDelete,
  });

  final ComentarioRepository _comentarioRepo = ComentarioRepository();
  final RatingRepository _ratingRepo = RatingRepository();
  final SpotRepository _spotRepo = SpotRepository(); 

  // Función para abrir el diálogo de edición
  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return SpotEditDialog(
          spot: spot,
          onSpotUpdated: onSpotUpdated ?? () {},
          spotRepo: _spotRepo,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final BuildContext widgetContext = context; 

    const triangleHeight = 12.0;
    const borderRadius = 12.0;

    final bool isMySpot = spot.esMio; // Condición clave

    return SizedBox(
      width: width,
      height: height + triangleHeight,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 20,
            height: height,
            child: ClipPath(
              clipper: _PopupClipper(
                  radius: borderRadius, triangleHeight: triangleHeight),
              child: Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  image: spot.urlImagen != null && spot.urlImagen!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(spot.urlImagen!), 
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.5), 
                            BlendMode.darken,
                          ),
                        )
                      : null,
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.fromLTRB(12, 10, 12, 10 + triangleHeight),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Encabezado (Título y Rating)
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
                      // Descripción / Texto corto
                      Expanded(
                        child: Text(
                          spot.descripcion ?? 'Muy chulo',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // --- FILA 1: ACCIÓN PRINCIPAL (EDITAR o COMENTAR/PUNTUAR) ---
                      Row(
                        mainAxisAlignment: isMySpot ? MainAxisAlignment.end : MainAxisAlignment.start,
                        children: [
                          if (isMySpot)
                            ElevatedButton.icon(
                              icon: const Icon(Icons.edit, size: 16),
                              label: const Text('Editar'),
                              onPressed: () => _showEditDialog(widgetContext),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[700],
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              ),
                            )
                          else ...[
                            // Botones para usuarios ajenos
                            ElevatedButton(
                              onPressed: () => _showCommentDialog(widgetContext),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF334155),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              ),
                              child: const Text('Comentar'),
                            ),
                            const SizedBox(width: 6),
                            ElevatedButton(
                              onPressed: () => _showRatingDialog(widgetContext),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF334155),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              ),
                              child: const Text('Puntuar'),
                            ),
                          ],
                        ],
                      ),
                      
                      const SizedBox(height: 6),
                      
                      // --- FILA 2: VER DETALLES Y CERRAR ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Botón 'Ver detalles' (ElevatedButton para más visibilidad)
                          ElevatedButton(
                            onPressed: onViewDetails,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E293B),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8)),
                            child: const Text('Ver detalles'),
                          ),
                          const SizedBox(width: 8),
                          // Botón 'Cerrar' (TextButton para menos énfasis)
                          TextButton(
                            onPressed: onClose,
                            child: const Text('Cerrar',
                                style: TextStyle(color: Colors.white70)),
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
    );
  }
  
  // --- MÉTODOS AUXILIARES Y DIÁLOGOS ---
  // Se mantienen para la funcionalidad estándar

  Color _ratingColor(Spot s) {
    if (s.valoracionMedia == null) return Colors.grey;
    if (s.valoracionMedia! >= 4.5) return Colors.green;
    if (s.valoracionMedia! >= 3.5) return Colors.orange;
    return Colors.red;
  }

  void _showCommentDialog(BuildContext widgetContext) {
    final TextEditingController _controller = TextEditingController();
    showDialog(
      context: widgetContext, 
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E2E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Comentar spot', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: _controller,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Escribe tu comentario aquí...',
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: const Color(0xFF2A2A3C),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () async {
                final content = _controller.text.trim();
                if (content.isEmpty) return;
                Navigator.pop(dialogContext); 
                try {
                  final user = Supabase.instance.client.auth.currentUser;
                  if (user == null) return;
                  final comentario = Comment(id: 0, spotId: spot.id, userId: 1, text: content, createdAt: DateTime.now());
                  final success = await _comentarioRepo.insertComentario(comentario);
                      
                  if (success) {
                    if (onSpotUpdated != null) onSpotUpdated!(); 
                    if (!widgetContext.mounted) return; 
                    ScaffoldMessenger.of(widgetContext).showSnackBar(const SnackBar(content: Text('Comentario enviado correctamente!'), backgroundColor: Colors.green));
                  } else {
                    if (!widgetContext.mounted) return;
                    throw Exception('No se pudo insertar el comentario');
                  }
                } catch (e) {
                  if (!widgetContext.mounted) return;
                  ScaffoldMessenger.of(widgetContext).showSnackBar(SnackBar(content: Text('Error al enviar comentario: $e'), backgroundColor: Colors.red));
                }
              },
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );
  }

  void _showRatingDialog(BuildContext widgetContext) {
    int rating = 0; 
    showDialog(
      context: widgetContext, 
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E2E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Valorar spot', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Selecciona tu valoración:', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (stfContext, setState) { 
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starIndex = index + 1;
                      return IconButton(
                        icon: Icon(starIndex <= rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 36),
                        onPressed: () {setState(() {rating = starIndex;});},
                      );
                    }),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () async {
                if (rating == 0) return;
                Navigator.pop(dialogContext); 
                try {
                  final user = Supabase.instance.client.auth.currentUser;
                  if (user == null) return;
                  final valoracion = Rating(spotId: spot.id, userId: user.id, value: rating, createdAt: DateTime.now());
                  final success = await _ratingRepo.insertRating(valoracion);
                  
                  if (success) {
                    if (onSpotUpdated != null) onSpotUpdated!(); 
                    if (!widgetContext.mounted) return; 
                    ScaffoldMessenger.of(widgetContext).showSnackBar(const SnackBar(content: Text('Valoración enviada correctamente!'), backgroundColor: Colors.green));
                  } else {
                    if (!widgetContext.mounted) return;
                    throw Exception('No se pudo insertar la valoración');
                  }
                } catch (e) {
                  if (!widgetContext.mounted) return;
                  ScaffoldMessenger.of(widgetContext).showSnackBar(SnackBar(content: Text('Error al enviar valoración: $e'), backgroundColor: Colors.red));
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

class _PopupClipper extends CustomClipper<Path> {
  final double radius;
  final double triangleHeight;

  _PopupClipper({required this.radius, required this.triangleHeight});

  @override
  Path getClip(Size size) {
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

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}