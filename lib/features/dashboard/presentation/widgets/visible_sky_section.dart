import 'package:flutter/material.dart';
import '../../data/models/cielo_visible_model.dart';
import 'constellation_card.dart';

class VisibleSkySection extends StatelessWidget {
  final List<Constellation> constellations;

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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Navegando a guía de ${constellations[index].name}',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
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