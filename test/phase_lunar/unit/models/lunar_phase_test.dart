import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/phase_lunar/data/models/lunar_phase_model.dart';

void main() {
  group('LunarPhase', () {
    test('debería crear una instancia correctamente', () {
      final phase = LunarPhase(
        idLuna: 1,
        fase: 'Luna Llena',
        porcentajeIluminacion: 99.8,
        edadLunar: 14.5,
        horaSalida: '18:30',
        azimutSalida: 90.0,
        horaPuesta: '06:00',
        azimutPuesta: 270.0,
        altitudActual: 45.2,
        proximaFase: 'Cuarto Menguante',
        fecha: DateTime(2025, 10, 10),
      );

      expect(phase.idLuna, equals(1));
      expect(phase.fase, equals('Luna Llena'));
      expect(phase.porcentajeIluminacion, equals(99.8));
      expect(phase.proximaFase, equals('Cuarto Menguante'));
      expect(phase.fecha, equals(DateTime(2025, 10, 10)));
    });

    test('fromMap() debería parsear correctamente un Map válido', () {
      final map = {
        'id_luna': 2,
        'id_ubicacion': 15,
        'fase': 'Cuarto Creciente',
        'porcentaje_iluminacion': 45.5,
        'edad_lunar': 7.3,
        'hora_salida': '12:00',
        'azimut_salida': 100.2,
        'hora_puesta': '00:15',
        'azimut_puesta': 280.4,
        'altitud_actual': 30.1,
        'proxima_fase': 'Luna Llena',
        'fecha': '2025-10-11T00:00:00.000Z',
      };

      final phase = LunarPhase.fromMap(map);

      expect(phase.idLuna, 2);
      expect(phase.idUbicacion, 15);
      expect(phase.fase, 'Cuarto Creciente');
      expect(phase.porcentajeIluminacion, 45.5);
      expect(phase.azimutSalida, 100.2);
      expect(phase.proximaFase, 'Luna Llena');
      expect(phase.fecha, DateTime.parse('2025-10-11T00:00:00.000Z'));
    });

    test('fromMap() debería manejar valores nulos o tipos incorrectos', () {
      final map = {
        'id_luna': '3', // incorrecto (string)
        'fase': null,
        'porcentaje_iluminacion': 'no-numero', // incorrecto
        'fecha': 12345, // tipo incorrecto
      };

      final phase = LunarPhase.fromMap(map);

      expect(phase.idLuna, 0); // fallback a 0
      expect(phase.fase, ''); // fallback a string vacío
      expect(phase.fecha, isNull); // no se puede parsear
    });

    test('toMap() debería convertir correctamente a un Map', () {
      final date = DateTime(2025, 10, 11);
      final phase = LunarPhase(
        idLuna: 4,
        idUbicacion: 99,
        fase: 'Luna Nueva',
        porcentajeIluminacion: 0.2,
        edadLunar: 0.5,
        horaSalida: '06:00',
        azimutSalida: 80.0,
        horaPuesta: '18:30',
        azimutPuesta: 260.0,
        altitudActual: 10.0,
        proximaFase: 'Cuarto Creciente',
        fecha: date,
      );

      final map = phase.toMap();

      expect(map['id_luna'], 4);
      expect(map['id_ubicacion'], 99);
      expect(map['fase'], 'Luna Nueva');
      expect(map['porcentaje_iluminacion'], 0.2);
      expect(map['fecha'], date.toIso8601String());
    });

    test('toBasicMap() debería devolver un mapa reducido con datos clave', () {
      final date = DateTime(2025, 10, 11);
      final phase = LunarPhase(
        idLuna: 5,
        fase: 'Luna Llena',
        porcentajeIluminacion: 100,
        fecha: date,
      );

      final basicMap = phase.toBasicMap();

      expect(basicMap.containsKey('id_luna'), true);
      expect(basicMap.containsKey('fase'), true);
      expect(basicMap['fase'], 'Luna Llena');
      expect(basicMap['fecha'], date.toIso8601String());
    });
  });
}
