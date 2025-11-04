import 'package:flutter/material.dart';
import 'package:skyshare_frontend_mobile/features/guia_constelacion/presentation/guia_constelacion_screen.dart';
import 'package:provider/provider.dart';
import 'package:skyshare_frontend_mobile/features/guia_constelacion/providers/guia_constelacion_provider.dart';
import 'package:skyshare_frontend_mobile/features/guia_constelacion/data/repository/guia_repository.dart';
import '../../data/models/visible_sky_model.dart';
import 'constellation_card.dart';

String _seasonForDate(DateTime date) {
  // Simplified: return only 'invierno' (Dec-Feb) or 'verano' (all other months)
  final m = date.month;
  if (m == 12 || m == 1 || m == 2) return 'invierno';
  return 'verano';
}

class VisibleSkySection extends StatelessWidget {
  final List<VisibleSkyItem> constellations;

  const VisibleSkySection({
    required this.constellations,
    super.key,
  });

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
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: constellations.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index < constellations.length - 1 ? 16 : 0,
                ),
                child: ConstellationCard(
                  constellation: constellations[index],
                  onTap: () {
                    final nombre = constellations[index].name;
                    final hoy = DateTime.now();
                    final temporada = _seasonForDate(hoy);
                    // Wrap the screen with a provider so `context.read<GuiaConstelacionProvider>()`
                    // inside the screen's initState can find the provider.
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider<GuiaConstelacionProvider>(
                        create: (_) => GuiaConstelacionProvider(
                          guiaRepo: GuiaConstelacionRepository(),
                        ),
                        child: GuiaConstelacionScreen(
                          nombreConstelacion: nombre,
                          temporada: temporada,
                          fecha: hoy,
                        ),
                      ),
                    ));
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}