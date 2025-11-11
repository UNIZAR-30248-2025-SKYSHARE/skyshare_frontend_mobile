import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/observation-chats/data/models/group_info_model.dart';

void main() {
  group('GroupInfo.fromJson', () {
    final tDateTime = DateTime.now();
    final tJsonMap = {
      'id_grupo': 1,
      'nombre': 'Grupo Info',
      'descripcion': 'Descripción de prueba',
      'fecha_creacion': tDateTime.toIso8601String(),
    };

    test('debe parsear correctamente un JSON válido', () {
      final result = GroupInfo.fromJson(tJsonMap);

      expect(result.idGrupo, 1);
      expect(result.nombre, 'Grupo Info');
      expect(result.descripcion, 'Descripción de prueba');
      expect(result.fechaCreacion, tDateTime);
    });

    test('debe manejar descripción nula', () {
      final jsonConNulos = {
        'id_grupo': 2,
        'nombre': 'Otro Grupo',
        'descripcion': null,
        'fecha_creacion': tDateTime.toIso8601String(),
      };

      final result = GroupInfo.fromJson(jsonConNulos);

      expect(result.idGrupo, 2);
      expect(result.nombre, 'Otro Grupo');
      expect(result.descripcion, isNull);
      expect(result.fechaCreacion, tDateTime);
    });
  });
}