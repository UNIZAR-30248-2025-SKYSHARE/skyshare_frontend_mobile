import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:skyshare_frontend_mobile/features/observation-chats/providers/chat_detail_provider.dart';
import 'package:skyshare_frontend_mobile/features/observation-chats/service/e2ee_group_service.dart';
import 'package:skyshare_frontend_mobile/features/observation-chats/service/key_manager.dart';
import 'package:skyshare_frontend_mobile/features/observation-chats/data/repositories/observation_chats_repository.dart';
import 'package:skyshare_frontend_mobile/features/observation-chats/data/models/chat_message_model.dart';

class MockObservationChatsRepository extends Mock implements ObservationChatsRepository {}
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockE2EGroupService extends Mock implements E2EGroupService {}
class MockKeyManager extends Mock implements KeyManager {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockUser extends Mock implements User {}
class MockRealtimeChannel extends Mock implements RealtimeChannel {}
class MockPostgresChangePayload extends Mock implements PostgresChangePayload {}
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
  late ChatDetailProvider provider;
  late MockObservationChatsRepository mockRepo;
  late MockSupabaseClient mockSupabase;
  late MockE2EGroupService mockE2E;
  late MockKeyManager mockKeyManager;
  late MockGoTrueClient mockAuth;
  late MockUser mockUser;
  late MockRealtimeChannel mockChannel;

  setUpAll(() {
    registerFallbackValue(PostgresChangeEvent.insert);
    registerFallbackValue(
      PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'dummy',
        value: 'dummy',
      ),
    );
    registerFallbackValue(MockPostgresChangePayload());
  });

  setUp(() {
    mockRepo = MockObservationChatsRepository();
    mockSupabase = MockSupabaseClient();
    mockE2E = MockE2EGroupService();
    mockKeyManager = MockKeyManager();
    mockAuth = MockGoTrueClient();
    mockUser = MockUser();
    mockChannel = MockRealtimeChannel();

    when(() => mockSupabase.auth).thenReturn(mockAuth);
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.id).thenReturn('my-user-id');

    when(() => mockKeyManager.initDeviceBundleIfNeeded()).thenAnswer((_) async {});
    when(() => mockKeyManager.getDeviceId()).thenAnswer((_) async => 'device-123');

    when(() => mockSupabase.channel(any())).thenReturn(mockChannel);

    when(() => mockChannel.onPostgresChanges(
      event: any(named: 'event'),
      schema: any(named: 'schema'),
      table: any(named: 'table'),
      filter: any(named: 'filter'),
      callback: any(named: 'callback'),
    )).thenReturn(mockChannel);

    when(() => mockChannel.subscribe()).thenReturn(mockChannel);
  });

  test('fetchMessages debe descifrar mensajes cifrados', () async {
    final rawMessage = ChatMessage(
      id: BigInt.from(1),
      createdAt: DateTime.now(),
      idUsuario: 'other-user',
      texto: '',
      nombreUsuario: 'Other',
      isEncrypted: true,
      ciphertext: 'secret-cipher',
      idGrupo: 1,
    );

    when(() => mockRepo.getMessages(1)).thenAnswer((_) async => [rawMessage]);

    when(() => mockE2E.decryptGroupMessageRow(any()))
        .thenAnswer((_) async => 'Hola Mundo');

    provider = ChatDetailProvider(
      repository: mockRepo,
      supabaseClient: mockSupabase,
      e2eService: mockE2E,
      keyManager: mockKeyManager,
      groupId: 1,
    );

    await Future.delayed(Duration.zero);

    expect(provider.messages.first.texto, 'Hola Mundo');
    expect(provider.hasUndecipherableMessages, false);
    verify(() => mockE2E.decryptGroupMessageRow(any())).called(1);
  });

  test('sendMessage debe cifrar el texto antes de llamar al repositorio', () async {
    when(() => mockE2E.ensureSenderKeyForGroup(1)).thenAnswer((_) async => 'key-id-1');

    when(() => mockE2E.encryptGroupMessage(1, 'Hola'))
        .thenAnswer((_) async => 'encrypted-Hola');

    when(() => mockRepo.sendMessageEncrypted(
          1,
          'encrypted-Hola',
          senderDeviceId: 'device-123',
          senderKeyId: 'key-id-1',
        )).thenAnswer((_) async {});

    when(() => mockRepo.getMessages(1)).thenAnswer((_) async => []);

    provider = ChatDetailProvider(
      repository: mockRepo,
      supabaseClient: mockSupabase,
      e2eService: mockE2E,
      keyManager: mockKeyManager,
      groupId: 1,
    );

    await Future.delayed(Duration.zero);

    await provider.sendMessage('Hola');

    verify(() => mockE2E.encryptGroupMessage(1, 'Hola')).called(1);
    verify(() => mockRepo.sendMessageEncrypted(
          1,
          'encrypted-Hola',
          senderDeviceId: any(named: 'senderDeviceId'),
          senderKeyId: any(named: 'senderKeyId'),
        )).called(1);

    expect(provider.messages.first.texto, 'Hola');
  });

  test('Si decrypt falla, el mensaje debe mostrar [Mensaje cifrado]', () async {
    final rawMessage = ChatMessage(
      id: BigInt.from(2),
      createdAt: DateTime.now(),
      idUsuario: 'other',
      texto: '',
      nombreUsuario: 'Other',
      isEncrypted: true,
      ciphertext: 'bad-cipher',
      idGrupo: 1,
    );

    when(() => mockRepo.getMessages(1)).thenAnswer((_) async => [rawMessage]);

    when(() => mockE2E.decryptGroupMessageRow(any())).thenAnswer((_) async => null);

    provider = ChatDetailProvider(
      repository: mockRepo,
      supabaseClient: mockSupabase,
      e2eService: mockE2E,
      keyManager: mockKeyManager,
      groupId: 1,
    );

    await Future.delayed(Duration.zero);

    expect(provider.messages.first.texto, '[Mensaje cifrado]');
    expect(provider.undecipherableMessageIds.contains(BigInt.from(2)), true);
  });

  test('sendMessage debe manejar errores silenciosamente si falla la encriptación o el envío', () async {
    when(() => mockE2E.ensureSenderKeyForGroup(any())).thenThrow(Exception('Error fatal'));
    when(() => mockRepo.getMessages(any())).thenAnswer((_) async => []);

    provider = ChatDetailProvider(
      repository: mockRepo,
      supabaseClient: mockSupabase,
      e2eService: mockE2E,
      keyManager: mockKeyManager,
      groupId: 1,
    );
    await Future.delayed(Duration.zero);

    await provider.sendMessage('Texto que fallará');

    expect(provider.messages.length, 1);
    expect(provider.messages.first.texto, 'Texto que fallará');
    
    verifyNever(() => mockRepo.sendMessageEncrypted(
      any(), 
      any(), 
      senderDeviceId: any(named: 'senderDeviceId'), 
      senderKeyId: any(named: 'senderKeyId')
    ));
  });

  test('sendMessage no debe hacer nada si el texto está vacío', () async {
    when(() => mockRepo.getMessages(any())).thenAnswer((_) async => []);

    provider = ChatDetailProvider(
      repository: mockRepo,
      supabaseClient: mockSupabase,
      e2eService: mockE2E,
      keyManager: mockKeyManager,
      groupId: 1,
    );
    await Future.delayed(Duration.zero);

    await provider.sendMessage('   ');

    expect(provider.messages.isEmpty, true);
    verifyNever(() => mockE2E.encryptGroupMessage(any(), any()));
  });

  test('retryDecryptPending no hace nada si no hay mensajes indecifrables', () async {
    when(() => mockRepo.getMessages(any())).thenAnswer((_) async => []);

    provider = ChatDetailProvider(
      repository: mockRepo,
      supabaseClient: mockSupabase,
      e2eService: mockE2E,
      keyManager: mockKeyManager,
      groupId: 1,
    );
    await Future.delayed(Duration.zero);

    await provider.retryDecryptPending();

    verify(() => mockRepo.getMessages(1)).called(1);
  });

  test('retryDecryptPending recarga mensajes si hay ids pendientes', () async {
    final rawMessage = ChatMessage(
      id: BigInt.from(1),
      createdAt: DateTime.now(),
      idUsuario: 'other',
      texto: '',
      nombreUsuario: 'Other',
      isEncrypted: true,
      ciphertext: 'fail',
      idGrupo: 1,
    );

    when(() => mockRepo.getMessages(1)).thenAnswer((_) async => [rawMessage]);
    when(() => mockE2E.decryptGroupMessageRow(any())).thenAnswer((_) async => null);

    provider = ChatDetailProvider(
      repository: mockRepo,
      supabaseClient: mockSupabase,
      e2eService: mockE2E,
      keyManager: mockKeyManager,
      groupId: 1,
    );
    await Future.delayed(Duration.zero);

    expect(provider.hasUndecipherableMessages, true);

    await provider.retryDecryptPending();

    verify(() => mockRepo.getMessages(1)).called(2);
  });

  test('Realtime: Debe procesar mensaje entrante cifrado y descifrarlo', () async {
    final mockQueryBuilder = MockSupabaseQueryBuilder();
    final mockFilterBuilder = MockPostgrestFilterBuilder();

    when(() => mockSupabase.from('usuario')).thenAnswer((_) => mockQueryBuilder);
    
    when(() => mockQueryBuilder.select('nombre_usuario')).thenAnswer((_) => mockFilterBuilder);
    when(() => mockFilterBuilder.eq('id_usuario', 'sender-id')).thenAnswer((_) => mockFilterBuilder);
    
    when(() => mockFilterBuilder.maybeSingle())
        .thenAnswer((_) => FakePostgrestTransformBuilder({'nombre_usuario': 'Sender'}));

    when(() => mockRepo.getMessages(1)).thenAnswer((_) async => []);
    when(() => mockE2E.decryptGroupMessageRow(any())).thenAnswer((_) async => 'Descifrado Realtime');

    provider = ChatDetailProvider(
      repository: mockRepo,
      supabaseClient: mockSupabase,
      e2eService: mockE2E,
      keyManager: mockKeyManager,
      groupId: 1,
    );
    await Future.delayed(Duration.zero);

    final captured = verify(() => mockChannel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: any(named: 'schema'),
      table: 'mensajes',
      filter: any(named: 'filter'),
      callback: captureAny(named: 'callback'),
    )).captured;

    final callback = captured.first as void Function(PostgresChangePayload);
    final mockPayload = MockPostgresChangePayload();

    when(() => mockPayload.newRecord).thenReturn({
      'id': '99',
      'created_at': DateTime.now().toIso8601String(),
      'id_usuario': 'sender-id',
      'is_encrypted': true,
      'ciphertext': 'cipher',
      'id_grupo': 1,
    });

    callback(mockPayload);
    
    await Future.delayed(Duration.zero);

    expect(provider.messages.first.texto, 'Descifrado Realtime');
    expect(provider.messages.first.nombreUsuario, 'Sender');
    verify(() => mockE2E.decryptGroupMessageRow(any())).called(1);
  });

  test('Realtime: Debe ignorar mensaje propio', () async {
    when(() => mockRepo.getMessages(1)).thenAnswer((_) async => []);

    provider = ChatDetailProvider(
      repository: mockRepo,
      supabaseClient: mockSupabase,
      e2eService: mockE2E,
      keyManager: mockKeyManager,
      groupId: 1,
    );
    await Future.delayed(Duration.zero);

    final captured = verify(() => mockChannel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: any(named: 'schema'),
      table: 'mensajes',
      filter: any(named: 'filter'),
      callback: captureAny(named: 'callback'),
    )).captured;

    final callback = captured.first as void Function(PostgresChangePayload);
    final mockPayload = MockPostgresChangePayload();

    when(() => mockPayload.newRecord).thenReturn({
      'id_usuario': 'my-user-id',
    });

    callback(mockPayload);
    await Future.delayed(Duration.zero);

    expect(provider.messages.isEmpty, true);
  });

  test('Realtime Key Distribution: Debe recargar mensajes al recibir clave', () async {
    when(() => mockRepo.getMessages(1)).thenAnswer((_) async => []);

    provider = ChatDetailProvider(
      repository: mockRepo,
      supabaseClient: mockSupabase,
      e2eService: mockE2E,
      keyManager: mockKeyManager,
      groupId: 1,
    );
    await Future.delayed(Duration.zero);

    final captured = verify(() => mockChannel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: any(named: 'schema'),
      table: 'group_key_distribution',
      filter: any(named: 'filter'),
      callback: captureAny(named: 'callback'),
    )).captured;

    final callback = captured.first as void Function(PostgresChangePayload);
    final mockPayload = MockPostgresChangePayload();
    when(() => mockPayload.newRecord).thenReturn({'id': 'key-update'});

    callback(mockPayload);
    await Future.delayed(Duration.zero);

    verify(() => mockRepo.getMessages(1)).called(2);
  });
}