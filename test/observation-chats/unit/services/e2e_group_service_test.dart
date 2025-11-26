import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:skyshare_frontend_mobile/features/observation-chats/service/e2ee_group_service.dart';
import 'package:skyshare_frontend_mobile/features/observation-chats/service/key_manager.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockKeyManager extends Mock implements KeyManager {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder<PostgrestList> {}
class MockPostgrestTransformBuilder extends Mock implements PostgrestTransformBuilder<PostgrestMap?> {}

class FakePostgrestTransformBuilder extends Fake implements PostgrestTransformBuilder<PostgrestMap?> {
  final PostgrestMap? _data;
  FakePostgrestTransformBuilder(this._data);

  @override
  Future<S> then<S>(FutureOr<S> Function(PostgrestMap?) onValue, {Function? onError}) async {
    return onValue(_data);
  }
}

void main() {
  late E2EGroupService e2eService;
  late MockSupabaseClient mockSupabase;
  late MockKeyManager mockKeyManager;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;

  final Map<String, String> memoryStorage = {};

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (MethodCall methodCall) async {
        final args = methodCall.arguments as Map<dynamic, dynamic>;
        final key = args['key'] as String?;

        switch (methodCall.method) {
          case 'read':
            if (key == null) return null;
            return memoryStorage[key];
          case 'write':
            if (key != null) memoryStorage[key] = args['value'] as String;
            return null;
          case 'delete':
            if (key != null) memoryStorage.remove(key);
            return null;
          default:
            return null;
        }
      },
    );
  });

  setUp(() {
    memoryStorage.clear();
    mockSupabase = MockSupabaseClient();
    mockKeyManager = MockKeyManager();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder();

    when(() => mockKeyManager.getDeviceId()).thenAnswer((_) async => 'device-test-1');
    
    when(() => mockSupabase.from(any())).thenAnswer((_) => mockQueryBuilder); 
    
    when(() => mockQueryBuilder.select(any())).thenAnswer((_) => mockFilterBuilder); 
    when(() => mockFilterBuilder.eq(any(), any())).thenAnswer((_) => mockFilterBuilder); 
    
    when(() => mockFilterBuilder.maybeSingle())
        .thenAnswer((_) => FakePostgrestTransformBuilder(null));

    e2eService = E2EGroupService(
      supabase: mockSupabase,
      keyManager: mockKeyManager,
    );
  });

  group('E2E Logic Roundtrip', () {
    test('Debe ser capaz de encriptar y desencriptar un mensaje (Ciclo completo)', () async {
      const groupId = 99;
      const originalText = "Mensaje Top Secret 🚀";
      
      final fakeKeyId = 'key-uuid-123';
      final fakeSecretBytes = List<int>.generate(32, (i) => i); 
      final fakePayload = {
        'id': fakeKeyId,
        'secret': base64Encode(fakeSecretBytes),
        'created_at': DateTime.now().toIso8601String()
      };
      
      memoryStorage['senderkey_${groupId}_device-test-1'] = jsonEncode(fakePayload);

      final ciphertext = await e2eService.encryptGroupMessage(groupId, originalText);
      
      expect(ciphertext, isNotEmpty);
      expect(ciphertext, isNot(equals(originalText)));

      final msgRow = {
        'ciphertext': ciphertext,
        'sender_device': 'device-test-1',
        'sender_key_id': fakeKeyId,
        'id_grupo': groupId,
      };

      final decrypted = await e2eService.decryptGroupMessageRow(msgRow);

      expect(decrypted, originalText);
    });

    test('Decrypt devuelve null si faltan datos o clave incorrecta', () async {
      final msgRow = {
        'ciphertext': 'basura',
        'sender_device': 'device-test-1',
        'sender_key_id': 'key-no-existe',
        'id_grupo': 99,
      };

      final decrypted = await e2eService.decryptGroupMessageRow(msgRow);
      expect(decrypted, null);
    });
  });
}