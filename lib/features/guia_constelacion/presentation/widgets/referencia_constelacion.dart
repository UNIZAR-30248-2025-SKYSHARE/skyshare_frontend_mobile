import 'package:flutter/material.dart';

class ReferenciaConstelacion extends StatelessWidget {
  final dynamic guia;
  const ReferenciaConstelacion({super.key, required this.guia});

  Widget _errorIcon() => Container(
        color: Colors.white10,
        child: const Center(
          child: Icon(
            Icons.image_not_supported,
            size: 50,
            color: Colors.white70,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (guia.referencia.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.map, color: Color(0xFF8A2BE2), size: 24),
            SizedBox(width: 8),
            Text(
              'Referencia',
              style: TextStyle(
                color: Color(0xFF8A2BE2),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2A1B4A).withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF8A2BE2).withValues(alpha: 0.3),
            ),
          ),
          child: (guia.urlReferencia != null &&
                  guia.urlReferencia!.trim().isNotEmpty)
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: guia.urlReferencia!.startsWith('http')
                      ? Image.network(
                          guia.urlReferencia!,
                          fit: BoxFit.cover,
                          height: 340,
                          errorBuilder:
                              (context, error, stackTrace) => _errorIcon(),
                        )
                      : Image.asset(
                          'public/resources/${guia.urlReferencia!}',
                          fit: BoxFit.cover,
                          height: 280,
                          errorBuilder:
                              (context, error, stackTrace) => _errorIcon(),
                        ),
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
