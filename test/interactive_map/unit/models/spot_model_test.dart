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
  test('parses nested ubicacion correctamente (caso base)', () {
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

  test('maneja strings numéricos e ints/doubles', () {
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

  test('si falta ubicacion, lat y lng son 0.0 y descripcion es null si no existe', () {
    final map = {
      'id_spot': 20,
      'id_usuario_creador': 7,
      'id_ubicacion': 8,
      'nombre': 'SinUbicacion',
    };
    final spot = Spot.fromMap(map);
    expect(spot.lat, 0.0);
    expect(spot.lng, 0.0);
    expect(spot.descripcion, isNull);
  });

  test('valoracion ausente deja valoracionMedia null y totalValoraciones 0 y texto "Sin valorar"', () {
    final map = {
      'id_spot': 30,
      'id_usuario_creador': 9,
      'id_ubicacion': 10,
      'nombre': 'NoValorado',
      'ubicacion': {'latitud': 1, 'longitud': 2},
    };
    final spot = Spot.fromMap(map);
    expect(spot.valoracionMedia, isNull);
    expect(spot.totalValoraciones, 0);
    expect(spot.valoracionTexto, 'Sin valorar');
  });

  test('lista de valoraciones vacía produce valoracionMedia null y totalValoraciones 0', () {
    final map = {
      'id_spot': 31,
      'id_usuario_creador': 9,
      'id_ubicacion': 10,
      'nombre': 'Vacia',
      'ubicacion': {'latitud': 1, 'longitud': 2},
      'valoracion': <Map<String, dynamic>>[],
    };
    final spot = Spot.fromMap(map);
    expect(spot.valoracionMedia, isNull);
    expect(spot.totalValoraciones, 0);
    expect(spot.valoracionTexto, 'Sin valorar');
  });

  test('calcula media con valoraciones mixtas (int, double, string y no numérico)', () {
    final map = {
      'id_spot': 40,
      'id_usuario_creador': 11,
      'id_ubicacion': 12,
      'nombre': 'Mixto',
      'ubicacion': {'latitud': 10, 'longitud': 20},
      'valoracion': [
        {'puntuacion': '5'},
        {'puntuacion': 4},
        {'puntuacion': 3.5},
        {'puntuacion': 'no'}, 
      ],
    };
    final spot = Spot.fromMap(map);
    expect(spot.totalValoraciones, 4);
    expect(spot.valoracionMedia, closeTo(3.125, 0.0001));
    expect(spot.valoracionTexto, '3.1 ⭐');
  });

  test('descripcion preservada cuando existe y null cuando no', () {
    final withDesc = {
      'id_spot': 50,
      'id_usuario_creador': 13,
      'id_ubicacion': 14,
      'nombre': 'ConDesc',
      'descripcion': 'Desc corta',
      'ubicacion': {'latitud': 1, 'longitud': 1},
    };
    final withoutDesc = {
      'id_spot': 51,
      'id_usuario_creador': 14,
      'id_ubicacion': 15,
      'nombre': 'SinDesc',
      'ubicacion': {'latitud': 1, 'longitud': 1},
    };
    final spotWith = Spot.fromMap(withDesc);
    final spotWithout = Spot.fromMap(withoutDesc);
    expect(spotWith.descripcion, 'Desc corta');
    expect(spotWithout.descripcion, isNull);
  });
}
