import 'package:flutter/material.dart';
import '../../data/models/spot_model.dart';
import 'star_rating.dart';
import 'comment_item.dart';

class SpotContent extends StatelessWidget {
  final Spot spot;

  const SpotContent({super.key, required this.spot});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderInfo(),
            const SizedBox(height: 20),
            const Divider(color: Colors.white10),
            const SizedBox(height: 20),
            _buildDescription(),
            const SizedBox(height: 24),
            _buildRatingCard(),
            const SizedBox(height: 28),
            _buildCommentsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                spot.nombre,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.white70),
                  const SizedBox(width: 4),
                  Text(
                    '${spot.ciudad}, ${spot.pais}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        StarRating(rating: spot.valoracionMedia),
      ],
    );
  }

  Widget _buildDescription() {
    if (spot.descripcion != null && spot.descripcion!.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Descripción',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            spot.descripcion!,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      );
    } else {
      return const Text(
        'Sin descripción',
        style: TextStyle(color: Colors.white24),
      );
    }
  }

  Widget _buildRatingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E28),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Valoración',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                spot.valoracionMedia != null
                    ? spot.valoracionMedia!.toStringAsFixed(1)
                    : '—',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${spot.totalValoraciones} valoraciones',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              StarRating(rating: spot.valoracionMedia),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsSection() {
    final exampleComments = [
      {'author': 'Second comment', 'time': '2 h'},
      {'author': 'First comment', 'time': '3 h'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Comentarios',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ...exampleComments.map((c) {
          return CommentItem(
            author: c['author']!,
            time: c['time']!,
          );
        }).toList(),
      ],
    );
  }
}