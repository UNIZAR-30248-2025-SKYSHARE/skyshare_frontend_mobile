import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skyshare_frontend_mobile/features/guia_constelacion/data/repository/guia_repository.dart';
import 'package:skyshare_frontend_mobile/features/guia_constelacion/presentation/guia_constelacion_screen.dart';
import 'package:skyshare_frontend_mobile/features/guia_constelacion/providers/guia_constelacion_provider.dart';

import '../../data/models/visible_sky_model.dart';
import 'constellation_card.dart';

String _seasonForDate(DateTime date) {
  final m = date.month;
  if (m == 11 || m == 12 || m == 1 || m == 2) return 'invierno';
  return 'verano';
}

class VisibleSkySection extends StatelessWidget {
  final List<VisibleSkyItem> constellations;

  const VisibleSkySection({
    required this.constellations,
    super.key,
  });

  void _navigateToGuia(BuildContext context, String nombre) {
    final hoy = DateTime.now();
    final temporada = _seasonForDate(hoy);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => GuiaConstelacionProvider(
            guiaRepo: GuiaConstelacionRepository(),
          ),
          child: GuiaConstelacionScreen(
            nombreConstelacion: nombre,
            temporada: temporada,
            fecha: hoy,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Cielo Visible',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 230,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: constellations.length,
            itemBuilder: (context, index) {
              final item = constellations[index];

              return Padding(
                padding: EdgeInsets.only(
                  right: index < constellations.length - 1 ? 16 : 0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ConstellationCard(
                        constellation: item,
                        onTap: () {
                          // Mantén este tap si quieres que también funcione al tocar la tarjeta completa
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 30,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => _navigateToGuia(context, item.name),
                        child: const Text(
                          'Ir a guía',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
