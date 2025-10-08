import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/dashboard/data/models/visible_sky_model.dart';

void main() {
  group('VisibleSkyItem', () {
    test('fromMap handles different field names', () {
      final map = {
        'id_cielo_visible': 1,
        'id_ubicacion': 2,
        'ultima_actualizacion': '2023-01-01T10:30:00Z',
        'nombre': 'Orion',
        'tipo': 'Constelación',
        'descripcion': 'Descripción test'
      };
      final item = VisibleSkyItem.fromMap(map);
      expect(item.id, 1);
      expect(item.locationId, 2);
      expect(item.name, 'Orion');
      expect(item.tipo, 'Constelación');
      expect(item.descripcion, 'Descripción test');
    });

    test('fromMap handles integer timestamp', () {
      final map = {
        'id': 1,
        'id_ubicacion': 2,
        'ultima_actualizacion': 1672571400000,
        'nombre': 'Orion',
        'tipo': 'Constelación',
      };
      final item = VisibleSkyItem.fromMap(map);
      expect(item.id, 1);
      expect(item.timestamp, isA<DateTime>());
    });

    test('fromMap handles DateTime timestamp', () {
      final now = DateTime.now();
      final map = {
        'id': 1,
        'id_ubicacion': 2,
        'ultima_actualizacion': now,
        'nombre': 'Orion',
        'tipo': 'Constelación',
      };
      final item = VisibleSkyItem.fromMap(map);
      expect(item.timestamp, now);
    });

    test('fromMap uses current time for invalid timestamp', () {
      final map = {
        'id': 1,
        'id_ubicacion': 2,
        'ultima_actualizacion': 'invalid',
        'nombre': 'Orion',
        'tipo': 'Constelación',
      };
      final item = VisibleSkyItem.fromMap(map);
      expect(item.timestamp, isA<DateTime>());
    });

    test('toMap converts back to map correctly', () {
      final item = VisibleSkyItem(
        id: 1,
        locationId: 2,
        timestamp: DateTime(2023, 1, 1, 10, 30),
        name: 'Test',
        tipo: 'Test Type',
      );
      final map = item.toMap();
      expect(map['id_cielo_visible'], 1);
      expect(map['id_ubicacion'], 2);
      expect(map['nombre'], 'Test');
      expect(map['tipo'], 'Test Type');
      expect(map['ultima_actualizacion'], isA<String>());
    });

    test('toMap includes description when present', () {
      final item = VisibleSkyItem(
        id: 1,
        locationId: 2,
        timestamp: DateTime.now(),
        name: 'Test',
        tipo: 'Test Type',
        descripcion: 'Test Description',
      );
      final map = item.toMap();
      expect(map['descripcion'], 'Test Description');
    });
  });
}
