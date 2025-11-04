import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/guia_constelacion/data/models/guia_model.dart';

void main() {
  group('GuiaConstelacion', () {
    final sampleMap = {
      'id_guia': 1,
      'nombre_constelacion': 'Orión',
      'temporada': 'invierno',
      'descripcion_general': 'Una de las constelaciones más brillantes del cielo nocturno.',
      'paso_1': 'Busca las tres estrellas alineadas del cinturón.',
      'paso_2': 'Identifica Betelgeuse y Rigel en los extremos.',
      'paso_3': 'Ubica la nebulosa de Orión bajo el cinturón.',
      'paso_4': 'Observa con prismáticos o telescopio.',
      'referencia': 'Guía de astronomía básica',
      'url_referencia': 'https://astro.example.com/orion',
      'imagen_url': 'https://astro.example.com/orion.jpg',
      'fecha_creacion': '2025-10-30T00:00:00.000Z',
      'paso_5': 'Toma notas de las estrellas visibles.',
      'paso_6': 'Registra la hora y condiciones meteorológicas.',
    };

    test('fromMap crea una instancia válida', () {
      final guia = GuiaConstelacion.fromMap(sampleMap);

      expect(guia.idGuia, 1);
      expect(guia.nombreConstelacion, 'Orión');
      expect(guia.temporada, 'invierno');
      expect(guia.descripcionGeneral, contains('brillantes'));
      expect(guia.paso1, startsWith('Busca'));
      expect(guia.paso2, isNotEmpty);
      expect(guia.paso3, contains('nebulosa'));
      expect(guia.paso4, isNotEmpty);
      expect(guia.referencia, equals('Guía de astronomía básica'));
      expect(guia.urlReferencia, startsWith('https'));
      expect(guia.imagenUrl, endsWith('.jpg'));
      expect(guia.fechaCreacion, DateTime.parse('2025-10-30T00:00:00.000Z'));
      expect(guia.paso5, isNotNull);
      expect(guia.paso6, isNotNull);
    });

    test('toMap devuelve el mapa correcto', () {
      final guia = GuiaConstelacion.fromMap(sampleMap);
      final map = guia.toMap();

      expect(map['id_guia'], 1);
      expect(map['nombre_constelacion'], 'Orión');
      expect(map['temporada'], 'invierno');
      expect(map['descripcion_general'], contains('brillantes'));
      expect(map['paso_1'], isNotEmpty);
      expect(map['referencia'], 'Guía de astronomía básica');
      expect(map['url_referencia'], startsWith('https'));
      expect(map['imagen_url'], isA<String>());
      expect(map['fecha_creacion'], isA<String>());
      expect(map['paso_5'], isA<String>());
      expect(map['paso_6'], isA<String>());
    });

    test('toBasicMap devuelve solo los campos básicos', () {
      final guia = GuiaConstelacion.fromMap(sampleMap);
      final basicMap = guia.toBasicMap();

      expect(basicMap.keys, containsAll(['id_guia', 'nombre_constelacion', 'temporada', 'referencia']));
      expect(basicMap.keys.length, 4);
      expect(basicMap['nombre_constelacion'], 'Orión');
    });

    test('fromMap maneja fecha_creacion inválida sin lanzar excepción', () {
      final invalidMap = {
        ...sampleMap,
        'fecha_creacion': 'no-es-una-fecha',
      };

      final guia = GuiaConstelacion.fromMap(invalidMap);
      expect(guia.fechaCreacion, isNull);
    });

    test('fromMap maneja tipos no esperados en id_guia', () {
      final mapWithNum = {
        ...sampleMap,
        'id_guia': 2.0,
      };
      final guia = GuiaConstelacion.fromMap(mapWithNum);
      expect(guia.idGuia, 2);
    });

    test('fromMap usa valores por defecto correctamente', () {
      final minimalMap = {
        'id_guia': 10,
        'nombre_constelacion': 'Cruz del Sur',
        'temporada': 'verano',
        'paso_1': 'Ubica la constelación cerca del polo sur celeste.',
        'paso_2': 'Identifica sus estrellas principales.',
        'paso_3': 'Observa su orientación.',
        'paso_4': 'Anota su posición.',
        'referencia': 'Guía del cielo austral',
      };

      final guia = GuiaConstelacion.fromMap(minimalMap);

      expect(guia.idGuia, 10);
      expect(guia.nombreConstelacion, 'Cruz del Sur');
      expect(guia.descripcionGeneral, isNull);
      expect(guia.urlReferencia, isNull);
      expect(guia.paso5, isNull);
      expect(guia.paso6, isNull);
      expect(guia.fechaCreacion, isNull);
    });
  });
}
