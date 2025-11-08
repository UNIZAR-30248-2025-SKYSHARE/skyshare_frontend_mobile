import 'package:flutter/material.dart';

class BannerConstelacionDelegate extends SliverPersistentHeaderDelegate {
  final dynamic guia;

  @override
  final double minExtent;

  @override
  final double maxExtent;

  BannerConstelacionDelegate({
    required this.guia,
    required this.minExtent,
    required this.maxExtent,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'public/resources/constelations.jpg',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              'public/resources/constelacionestudio.jpg',
              fit: BoxFit.cover,
            );
          },
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withValues(alpha: 0.6),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.5),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Guía Constelación de ${guia.nombreConstelacion}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: const [
                      Shadow(
                        blurRadius: 8,
                        color: Colors.black87,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}
