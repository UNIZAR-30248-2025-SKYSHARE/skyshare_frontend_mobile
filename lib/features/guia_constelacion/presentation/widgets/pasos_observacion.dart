import 'package:flutter/material.dart';

class PasosObservacion extends StatelessWidget {
  final dynamic guia;
  const PasosObservacion({super.key, required this.guia});

  List<String> _getPasos(dynamic guia) {
    final pasos = [
      guia.paso1,
      guia.paso2,
      guia.paso3,
      guia.paso4,
      if (guia.paso5 != null) guia.paso5!,
      if (guia.paso6 != null) guia.paso6!,
    ];
    return pasos
        .where((p) => p != null && p.toString().trim().isNotEmpty)
        .cast<String>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final pasos = _getPasos(guia);

    if (pasos.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05), 
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1), 
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.visibility, color: Colors.lightBlueAccent, size: 28),
              SizedBox(width: 12),
              Text(
                'Pasos para Observar',
                style: TextStyle(
                  color: Colors.lightBlueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Column(
            children: pasos.asMap().entries.map((entry) {
              final i = entry.key + 1;
              final texto = entry.value;
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08), 
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.lightBlueAccent.withValues(alpha: 0.3), 
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Colors.lightBlueAccent,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$i',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        texto,
                        style: const TextStyle(
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
