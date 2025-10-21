import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double? rating;

  const StarRating({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    final r = rating ?? 0.0;
    final full = r.floor();
    final half = ((r - full) >= 0.5) ? 1 : 0;
    final empty = 5 - full - half;
    final stars = <Widget>[];

    for (var i = 0; i < full; i++) {
      stars.add(const Icon(Icons.star, size: 20, color: Colors.white));
    }
    if (half == 1) {
      stars.add(const Icon(Icons.star_half, size: 20, color: Colors.white));
    }
    for (var i = 0; i < empty; i++) {
      stars.add(const Icon(Icons.star_border, size: 20, color: Colors.white70));
    }

    return Row(children: stars);
  }
}