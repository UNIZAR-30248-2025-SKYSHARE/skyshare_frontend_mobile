import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/observation-chats/data/models/chat_preview_model.dart';

void main() {
  group('ChatPreview.fromJson', () {
    final tDateTime = DateTime.now();
    final tJsonMap = {
      'id_grupo': 1,
      'nombre_grupo': 'Grupo de Test',
      'ultimo_mensaje_texto': 'Este es el último mensaje',
      'ultimo_mensaje_fecha': tDateTime.toIso8601String(),
      'ultimo_mensaje_sender_nombre': 'Sender Name',
    };

    test('debe parsear correctamente un JSON válido con todos los campos', () {
      // Act
      final result = ChatPreview.fromJson(tJsonMap);

      // Assert
      expect(result.idGrupo, 1);
      expect(result.nombreGrupo, 'Grupo de Test');
      expect(result.ultimoMensajeTexto, 'Este es el último mensaje');
      expect(result.ultimoMensajeFecha, tDateTime);
      expect(result.ultimoMensajeSenderNombre, 'Sender Name');
    });

    test('debe manejar campos opcionales nulos', () {
      // Arrange
      final jsonConNulos = {
        'id_grupo': 2,
        'nombre_grupo': 'Grupo Nuevo',
        'ultimo_mensaje_texto': null,
        'ultimo_mensaje_fecha': null,
        'ultimo_mensaje_sender_nombre': null,
      };

      // Act
      final result = ChatPreview.fromJson(jsonConNulos);

      // Assert
      expect(result.idGrupo, 2);
      expect(result.nombreGrupo, 'Grupo Nuevo');
      expect(result.ultimoMensajeTexto, isNull);
      expect(result.ultimoMensajeFecha, isNull);
      expect(result.ultimoMensajeSenderNombre, isNull);
    });
  });
}