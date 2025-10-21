import 'package:flutter/material.dart';
import '../data/models/spot_model.dart';
import 'widgets/spot_image_header.dart';
import 'widgets/spot_content.dart';

class SpotDetailScreen extends StatelessWidget {
  final Spot spot;
  const SpotDetailScreen({super.key, required this.spot});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13121A),
      body: CustomScrollView(
        slivers: [
          SpotImageHeader(spot: spot),
          SpotContent(spot: spot),
        ],
      ),
    );
  }
}