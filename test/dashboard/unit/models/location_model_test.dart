import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/core/models/location_model.dart';

void main() {
  group('Location', () {
    test('fromMap parses all fields correctly', () {
      final map = {
        'id_ubicacion': 1,
        'nombre': 'Madrid',
        'pais': 'Spain',
        'latitud': 40.4168,
        'longitud': -3.7038,
      };
      final location = Location.fromMap(map);
      expect(location.id, 1);
      expect(location.name, 'Madrid');
      expect(location.country, 'Spain');
      expect(location.latitude, 40.4168);
      expect(location.longitude, -3.7038);
    });

    test('fromMap handles alternative field names', () {
      final map = {
        'id': 1,
        'name': 'Madrid',
        'country': 'Spain',
        'latitud': 40.4168,
        'longitud': -3.7038,
      };
      final location = Location.fromMap(map);
      expect(location.id, 1);
      expect(location.name, 'Madrid');
      expect(location.country, 'Spain');
    });

    test('fromMap handles idLocation field', () {
      final map = {
        'idLocation': 1,
        'name': 'Madrid',
        'country': 'Spain',
        'latitud': 40.4168,
        'longitud': -3.7038,
      };
      final location = Location.fromMap(map);
      expect(location.id, 1);
    });

    test('toMap converts back to map correctly', () {
      final location = const Location(
        id: 1,
        name: 'Madrid',
        country: 'Spain',
        latitude: 40.4168,
        longitude: -3.7038,
      );
      final map = location.toMap();
      expect(map['id_ubicacion'], 1);
      expect(map['nombre'], 'Madrid');
      expect(map['pais'], 'Spain');
      expect(map['latitud'], 40.4168);
      expect(map['longitud'], -3.7038);
    });
  });
}
