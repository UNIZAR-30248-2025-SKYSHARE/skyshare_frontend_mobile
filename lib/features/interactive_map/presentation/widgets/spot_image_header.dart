import 'package:flutter/material.dart';
import '../../data/models/spot_model.dart';

class SpotImageHeader extends StatelessWidget {
  final Spot spot;

  const SpotImageHeader({super.key, required this.spot});

  @override
  Widget build(BuildContext context) {
    final hasImage = spot.urlImagen != null && spot.urlImagen!.isNotEmpty;

    return SliverAppBar(
      expandedHeight: 300,
      stretch: true,
      backgroundColor: const Color(0xFF13121A),
      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: CircleAvatar(
          backgroundColor: Colors.black.withValues(alpha: 0.5),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      flexibleSpace: Stack(
        children: [
          FlexibleSpaceBar(
            stretchModes: const [StretchMode.zoomBackground],
            background: hasImage
                ? Image.network(
                    spot.urlImagen!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: const Color(0xFF20202A),
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) =>
                        _buildPlaceholderImage(),
                  )
                : _buildPlaceholderImage(),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 60,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    // aquí también reemplazamos withOpacity
                    const Color(0xFF13121A).withValues(alpha: 0.9),
                    const Color(0xFF13121A).withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: const Color(0xFF20202A),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, size: 48, color: Colors.white30),
            SizedBox(height: 8),
            Text(
              'Sin imagen',
              style: TextStyle(color: Colors.white30),
            ),
          ],
        ),
      ),
    );
  }
}
