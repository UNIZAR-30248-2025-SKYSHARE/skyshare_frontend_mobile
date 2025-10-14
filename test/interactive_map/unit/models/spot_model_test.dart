import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/interactive_map/data/models/spot_model.dart';

void main() {
  test('Spot.fromMap parses nested ubicacion correctly', () {
    final map = {
      'id_spot': 10,
      'id_usuario_creador': 5,
      'id_ubicacion': 3,
      'nombre': 'Mirador',
      'descripcion': 'Vista preciosa',
      'ubicacion': {
        'latitud': 40.1234,
        'longitud': -3.5678,
      }
    };
    final spot = Spot.fromMap(map);
    expect(spot.id, 10);
    expect(spot.creadorId, 5);
    expect(spot.ubicacionId, 3);
    expect(spot.nombre, 'Mirador');
    expect(spot.descripcion, 'Vista preciosa');
    expect(spot.lat, 40.1234);
    expect(spot.lng, -3.5678);
  });

  test('Spot.fromMap handles numeric strings and ints/doubles', () {
    final map = {
      'id_spot': '11',
      'id_usuario_creador': '6',
      'id_ubicacion': 4,
      'nombre': 'Pico',
      'ubicacion': {
        'latitud': '41.0000',
        'longitud': 2,
      }
    };
    final spot = Spot.fromMap(map);
    expect(spot.id, 11);
    expect(spot.creadorId, 6);
    expect(spot.ubicacionId, 4);
    expect(spot.nombre, 'Pico');
    expect(spot.lat, 41.0);
    expect(spot.lng, 2.0);
  });
}
