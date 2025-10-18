import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/core/models/user_model.dart';

void main() {
  group('AppUser model', () {
    test('fromMap parses all fields correctly', () {
      final map = {
        'id_usuario': 'uid-123',
        'nombre_usuario': 'alice',
        'email': 'alice@example.com',
        'url_foto': 'https://example.com/photo.png',
        'created_at': '2025-10-17T12:34:56.000Z',
      };

      final user = AppUser.fromMap(map);

      expect(user.id, 'uid-123');
      expect(user.username, 'alice');
      expect(user.email, 'alice@example.com');
      expect(user.photoUrl, 'https://example.com/photo.png');
      expect(user.createdAt, isNotNull);
      expect(user.createdAt!.toUtc().toIso8601String(), '2025-10-17T12:34:56.000Z');
    });

    test('fromMap handles null created_at', () {
      final map = {
        'id_usuario': 'uid-456',
        'nombre_usuario': null,
        'email': 'bob@example.com',
        'url_foto': null,
        'created_at': null,
      };

      final user = AppUser.fromMap(map);

      expect(user.id, 'uid-456');
      expect(user.username, isNull);
      expect(user.email, 'bob@example.com');
      expect(user.photoUrl, isNull);
      expect(user.createdAt, isNull);
    });

    test('toMap includes ISO8601 created_at when present', () {
      final created = DateTime.utc(2025, 10, 17, 12, 34, 56);
      final user = AppUser(
        id: 'uid-789',
        username: 'carol',
        email: 'carol@example.com',
        photoUrl: 'https://example.com/p.png',
        createdAt: created,
      );

      final map = user.toMap();

      expect(map['id_usuario'], 'uid-789');
      expect(map['nombre_usuario'], 'carol');
      expect(map['email'], 'carol@example.com');
      expect(map['url_foto'], 'https://example.com/p.png');
      expect(map['created_at'], created.toIso8601String());
    });

    test('toMap preserves null optional fields', () {
      final user = AppUser(id: 'uid-000');

      final map = user.toMap();

      expect(map['id_usuario'], 'uid-000');
      expect(map['nombre_usuario'], isNull);
      expect(map['email'], isNull);
      expect(map['url_foto'], isNull);
      expect(map['created_at'], isNull);
    });

    test('toMap -> fromMap round trip retains values', () {
      final created = DateTime.utc(2025, 10, 17, 12, 34, 56);
      final original = AppUser(
        id: 'uid-trip',
        username: 'dave',
        email: 'dave@example.com',
        photoUrl: 'https://example.com/d.png',
        createdAt: created,
      );

      final map = original.toMap();
      final restored = AppUser.fromMap(map);

      expect(restored.id, original.id);
      expect(restored.username, original.username);
      expect(restored.email, original.email);
      expect(restored.photoUrl, original.photoUrl);
      expect(restored.createdAt, isNotNull);
      expect(restored.createdAt!.toUtc().toIso8601String(), original.createdAt!.toIso8601String());
    });
  });
}