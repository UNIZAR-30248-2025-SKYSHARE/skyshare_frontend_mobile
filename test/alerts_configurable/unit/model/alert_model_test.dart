import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/alerts_configurable/data/model/alert_model.dart';

void main() {
  group('AlertModel', () {
    final sampleMap = {
      'id_alerta': 1,
      'id_usuario': 'user123',
      'id_ubicacion': 10,
      'tipo_alerta': 'TEMPERATURA',
      'parametro_objetivo': 'temp',
      'tipo_repeticion': 'DIARIA',
      'fecha_objetivo': '2025-10-27T00:00:00.000Z',
      'hora_objetivo': '2025-10-27T15:30:00.000Z',
      'valor_minimo': 20.5,
      'valor_maximo': 30.5,
      'activa': true,
    };

    test('fromMap crea una instancia válida', () {
      final alert = AlertModel.fromMap(sampleMap);

      expect(alert.idAlerta, 1);
      expect(alert.idUsuario, 'user123');
      expect(alert.idUbicacion, 10);
      expect(alert.tipoAlerta, 'TEMPERATURA');
      expect(alert.parametroObjetivo, 'temp');
      expect(alert.tipoRepeticion, 'DIARIA');
      expect(alert.fechaObjetivo, DateTime.parse('2025-10-27T00:00:00.000Z'));
      expect(alert.horaObjetivo, '15:30');
      expect(alert.valorMinimo, 20.5);
      expect(alert.valorMaximo, 30.5);
      expect(alert.activa, isTrue);
    });

    test('toMap devuelve el mapa correcto', () {
      final alert = AlertModel.fromMap(sampleMap);
      final map = alert.toMap();

      expect(map['id_alerta'], 1);
      expect(map['id_usuario'], 'user123');
      expect(map['id_ubicacion'], 10);
      expect(map['tipo_alerta'], 'TEMPERATURA');
      expect(map['parametro_objetivo'], 'temp');
      expect(map['tipo_repeticion'], 'DIARIA');
      expect(map['fecha_objetivo'], isA<String>());
      expect(map['hora_objetivo'], '15:30');
      expect(map['valor_minimo'], 20.5);
      expect(map['valor_maximo'], 30.5);
      expect(map['activa'], isTrue);
    });

    test('copyWith modifica solo los campos indicados', () {
      final alert = AlertModel.fromMap(sampleMap);
      final modified = alert.copyWith(
        tipoAlerta: 'HUMEDAD',
        activa: false,
      );

      expect(modified.tipoAlerta, 'HUMEDAD');
      expect(modified.activa, isFalse);
      expect(modified.idUsuario, alert.idUsuario); // sin cambio
    });

    test('ubicacionDisplay devuelve el texto esperado', () {
      final alert = AlertModel.fromMap(sampleMap);
      expect(alert.ubicacionDisplay, 'Ubicación #10');
    });

    test('fromMap maneja hora_objetivo inválida sin lanzar excepción', () {
      final mapWithInvalidTime = {
        ...sampleMap,
        'hora_objetivo': 'no-es-una-fecha',
      };

      final alert = AlertModel.fromMap(mapWithInvalidTime);
      expect(alert.horaObjetivo, 'no-es-una-fecha');
    });

    test('fromMap usa valores por defecto correctamente', () {
      final minimalMap = {
        'id_alerta': 99,
        'id_usuario': 'u1',
        'id_ubicacion': 5,
        'tipo_alerta': 'GENERAL',
        'fecha_objetivo': '2025-12-01T00:00:00.000Z',
      };

      final alert = AlertModel.fromMap(minimalMap);

      expect(alert.tipoRepeticion, 'UNICA');
      expect(alert.activa, isTrue);
      expect(alert.parametroObjetivo, isNull);
      expect(alert.valorMinimo, isNull);
      expect(alert.valorMaximo, isNull);
    });
  });
}
