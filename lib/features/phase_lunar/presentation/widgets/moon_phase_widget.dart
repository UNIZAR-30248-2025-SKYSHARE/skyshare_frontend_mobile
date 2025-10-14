import 'package:flutter/material.dart';

/// Muestra la luna iluminada según [percentage].
/// - La imagen se toma de 'public/resources/luna_image.jpg' (asegúrate de añadirla a pubspec.yaml)
/// - La parte no iluminada permanece negra.
class MoonPhaseWidget extends StatelessWidget {
  final int percentage;
  final double size;
  final String imageAssetPath;
  final bool leftToRight;

  const MoonPhaseWidget({
    super.key,
    required this.percentage,
    this.size = 44,
    this.imageAssetPath = 'public/resources/luna_image.jpg',
    this.leftToRight = true,
  });

  @override
  Widget build(BuildContext context) {
    final pct = percentage.clamp(0, 100);

    // fondo negro (parte no iluminada)
    final base = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black,
      ),
    );

    if (pct <= 0) return base;

    // Render the illuminated portion by showing the image and covering
    // the unlit part with a black rectangle clipped to the circle.
    final normalized = pct / 100.0;
    final visibleFraction = normalized;

    return Stack(
      alignment: Alignment.center,
      children: [
        // black circular base
        base,

        // Clip the moon image to the intersection of the circle and a
        // left/right-aligned rectangle whose width is visibleFraction*size.
        ClipPath(
          clipper: _RectInCircleClipper(visibleFraction, leftToRight),
          child: Image.asset(
            imageAssetPath,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
// Note: previous custom clipper removed in favor of a simpler width-based mask

class _RectInCircleClipper extends CustomClipper<Path> {
  final double visibleFraction; // 0..1
  final bool leftToRight;

  _RectInCircleClipper(this.visibleFraction, this.leftToRight);

  @override
  Path getClip(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final circle = Path()..addOval(Rect.fromCircle(center: center, radius: radius));

    final visibleWidth = (visibleFraction.clamp(0.0, 1.0)) * size.width;
    final left = leftToRight ? 0.0 : (size.width - visibleWidth);

    final rect = Path()..addRect(Rect.fromLTWH(left, 0, visibleWidth, size.height));

    // intersect the circle and the rectangle so the visible area grows
    // strictly from left to right (or viceversa)
    return Path.combine(PathOperation.intersect, circle, rect);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
