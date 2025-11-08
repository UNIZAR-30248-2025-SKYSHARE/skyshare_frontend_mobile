import 'package:flutter/material.dart';

class ImagenPrincipal extends StatelessWidget {
  final dynamic guia;
  const ImagenPrincipal({super.key, required this.guia});

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
    final img = (guia.imagenUrl != null && guia.imagenUrl!.trim().isNotEmpty)
        ? guia.imagenUrl!
        : (guia.urlReferencia ?? '');

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: img.isEmpty
              ? _errorIcon()
              : img.startsWith('http')
                  ? Image.network(
                      img,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => _errorIcon(),
                    )
                  : Image.asset(
                      'public/resources/$img',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => _errorIcon(),
                    ),
        ),
      ),
    );
  }
}
