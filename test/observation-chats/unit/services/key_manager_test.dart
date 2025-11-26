import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:skyshare_frontend_mobile/features/observation-chats/service/key_manager.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockUser extends Mock implements User {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class FakePostgrestFilterBuilder extends Fake implements PostgrestFilterBuilder<PostgrestList> {
  @override
  Future<S> then<S>(FutureOr<S> Function(PostgrestList) onValue, {Function? onError}) async {
    return onValue([]);
  }
}

void main() {
  late KeyManager keyManager;
  late MockSupabaseClient mockSupabase;
  late MockGoTrueClient mockAuth;
  late MockUser mockUser;
  late MockSupabaseQueryBuilder mockQueryBuilder;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'read') return null;
        if (methodCall.method == 'write') return null;
        return null;
      },
    );
  });

  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    mockUser = MockUser();
    mockQueryBuilder = MockSupabaseQueryBuilder();

    when(() => mockSupabase.auth).thenReturn(mockAuth);
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.id).thenReturn('my-user-id');

    when(() => mockSupabase.from(any())).thenAnswer((_) => mockQueryBuilder);

    when(() => mockQueryBuilder.upsert(any())).thenAnswer((_) => FakePostgrestFilterBuilder());

    keyManager = KeyManager(supabase: mockSupabase);
  });

  test('getDeviceId genera un ID si no existe', () async {
    final id = await keyManager.getDeviceId();
    expect(id, isNotEmpty);
    expect(id.length, 36);
  });

  test('initDeviceBundle genera claves y las sube a Supabase', () async {
    await keyManager.initDeviceBundle();

    final captured = verify(() => mockQueryBuilder.upsert(captureAny())).captured;
    final payload = captured.first as Map<String, dynamic>;

    expect(payload['id_usuario'], 'my-user-id');
    expect(payload['registration_id'], isNotNull);
    expect(payload['identity_key'], isNotNull);
    expect(payload['signed_prekey'], isNotNull);
    expect((payload['one_time_prekeys'] as List).length, 10);
  });
}