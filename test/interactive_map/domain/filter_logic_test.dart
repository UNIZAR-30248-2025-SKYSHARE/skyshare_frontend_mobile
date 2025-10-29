import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/interactive_map/data/models/spot_model.dart';

void main() {
  group('Filter Logic', () {
    final testSpots = [
      Spot(
        id: 1,
        ubicacionId: 1,
        creadorId: "1",
        nombre: 'Mirador Excelente',
        lat: 40.4168,
        lng: -3.7038,
        ciudad: 'Madrid',
        pais: 'España',
        valoracionMedia: 4.8,
        totalValoraciones: 20,
      ),
      Spot(
        id: 2,
        ubicacionId: 2,
        creadorId: "1",
        nombre: 'Pico Bueno',
        lat: 40.4178,
        lng: -3.7048,
        ciudad: 'Madrid',
        pais: 'España',
        valoracionMedia: 3.5,
        totalValoraciones: 8,
      ),
      Spot(
        id: 3,
        ubicacionId: 3,
        creadorId: "1",
        nombre: 'Llanura Regular',
        lat: 40.4158,
        lng: -3.7028,
        ciudad: 'Madrid',
        pais: 'España',
        valoracionMedia: 2.8,
        totalValoraciones: 3,
      ),
      Spot(
        id: 4,
        ubicacionId: 4,
        creadorId: "1",
        nombre: 'Sin Valorar',
        lat: 40.4198,
        lng: -3.7068,
        ciudad: 'Madrid',
        pais: 'España',
        valoracionMedia: null,
        totalValoraciones: 0,
      ),
    ];

    test('filtra por nombre correctamente', () {
      final filtered = testSpots.where((spot) => 
          spot.nombre.toLowerCase().contains('excelente')).toList();
      expect(filtered.length, 1);
      expect(filtered[0].nombre, 'Mirador Excelente');
    });

    test('filtra por valoración mínima', () {
      final minRating = 4.0;
      final filtered = testSpots.where((spot) {
        if (spot.valoracionMedia == null) return false;
        return spot.valoracionMedia! >= minRating;
      }).toList();
      expect(filtered.length, 1);
      expect(filtered[0].nombre, 'Mirador Excelente');
    });

    test('no incluye spots sin valoración al filtrar por rating', () {
      final minRating = 1.0;
      final filtered = testSpots.where((spot) {
        if (spot.valoracionMedia == null) return false;
        return spot.valoracionMedia! >= minRating;
      }).toList();
      expect(filtered.length, 3);
      expect(filtered.any((spot) => spot.nombre == 'Sin Valorar'), false);
    });

    test('filtro por nombre es case insensitive', () {
      final filtered = testSpots.where((spot) => 
          spot.nombre.toLowerCase().contains('pico')).toList();
      expect(filtered.length, 1);
      expect(filtered[0].nombre, 'Pico Bueno');
    });
  });
}