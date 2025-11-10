import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/observation-chats/data/models/chat_message_model.dart';

void main() {
  group('ChatMessage.fromJson', () {
    final tDateTime = DateTime.now();
    final tJsonMap = {
      'id': '12345678901234567890',
      'created_at': tDateTime.toIso8601String(),
      'id_usuario': 'user-uuid-123',
      'texto': 'Hola mundo',
      'nombre_usuario': 'Test User',
    };

    test('debe parsear correctamente un JSON válido', () {
      final result = ChatMessage.fromJson(tJsonMap);
      expect(result.id, BigInt.parse('12345678901234567890'));
      expect(result.idUsuario, 'user-uuid-123');
      expect(result.texto, 'Hola mundo');
    });

    test('debe manejar valores nulos con valores por defecto', () {
      final jsonConNulos = {
        'id': '1',
        'created_at': tDateTime.toIso8601String(),
        'id_usuario': null,
        'texto': null,
        'nombre_usuario': null,
      };
      final result = ChatMessage.fromJson(jsonConNulos);
      expect(result.idUsuario, 'id_usuario_nulo');
      expect(result.texto, '');
      expect(result.nombreUsuario, 'Usuario Desconocido');
    });
  });
}