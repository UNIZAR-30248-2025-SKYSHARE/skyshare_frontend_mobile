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
      'id_grupo': 10,
    };

    test('debe parsear correctamente un JSON válido estándar', () {
      final result = ChatMessage.fromJson(tJsonMap);
      expect(result.id, BigInt.parse('12345678901234567890'));
      expect(result.idUsuario, 'user-uuid-123');
      expect(result.texto, 'Hola mundo');
      expect(result.idGrupo, 10);
      expect(result.isEncrypted, false);
    });

    test('debe manejar valores nulos con valores por defecto', () {
      final jsonConNulos = {
        'id': null, 
        'created_at': null,
        'id_usuario': null,
        'texto': null,
        'nombre_usuario': null,
      };
      final result = ChatMessage.fromJson(jsonConNulos);
      
      expect(result.id, BigInt.zero);
      expect(result.idUsuario, 'id_usuario_nulo');
      expect(result.texto, '');
      expect(result.nombreUsuario, 'Usuario Desconocido');
      expect(result.createdAt, isA<DateTime>()); 
    });

    test('debe manejar fechas con formato inválido usando DateTime.now()', () {
      final jsonBadDate = {
        ...tJsonMap,
        'created_at': 'esto-no-es-una-fecha',
      };
      final result = ChatMessage.fromJson(jsonBadDate);
      expect(result.createdAt, isA<DateTime>());
    });

    test('debe marcar el mensaje como cifrado y ocultar texto si is_encrypted es true', () {
      final jsonEncrypted = {
        'id': '2',
        'created_at': DateTime.now().toIso8601String(),
        'id_usuario': 'user-123',
        'texto': 'Este texto no debería verse', 
        'is_encrypted': true, 
        'ciphertext': 'base64ciphertext',
        'nombre_usuario': 'Test',
      };
      
      final result = ChatMessage.fromJson(jsonEncrypted);
      
      expect(result.isEncrypted, true);
      expect(result.ciphertext, 'base64ciphertext');
      expect(result.texto, '[Mensaje cifrado]'); 
    });

    test('debe interpretar correctamente las variantes "truthy" de is_encrypted (1, "true", "yes")', () {
      final jsonNum = {...tJsonMap, 'is_encrypted': 1, 'ciphertext': 'abc'};
      expect(ChatMessage.fromJson(jsonNum).isEncrypted, true);

      final jsonStr = {...tJsonMap, 'is_encrypted': 'true', 'ciphertext': 'abc'};
      expect(ChatMessage.fromJson(jsonStr).isEncrypted, true);

      final jsonYes = {...tJsonMap, 'is_encrypted': 'yes', 'ciphertext': 'abc'};
      expect(ChatMessage.fromJson(jsonYes).isEncrypted, true);
    });

    test('debe mapear campos alternativos (legacy support)', () {
      final jsonLegacy = {
        'id': '3',
        'text': 'Texto legacy',
        'is_encrypted': true,
        'ciphertext_b64': 'cipher-legacy', 
        'group_id': 50 
      };

      final result = ChatMessage.fromJson(jsonLegacy);

      expect(result.texto, '[Mensaje cifrado]'); 
      expect(result.ciphertext, 'cipher-legacy');
      expect(result.idGrupo, 50);
    });
    
    test('debe leer texto plano desde campo "text" si "texto" no existe y no está cifrado', () {
      final jsonLegacyPlain = {
        'id': '4',
        'text': 'Mensaje plano legacy',
        'is_encrypted': false,
      };
      
      final result = ChatMessage.fromJson(jsonLegacyPlain);
      expect(result.texto, 'Mensaje plano legacy');
    });
  });
}