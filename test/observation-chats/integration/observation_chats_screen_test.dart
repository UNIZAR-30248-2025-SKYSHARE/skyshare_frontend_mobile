import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart'; 
import 'package:provider/provider.dart';
import 'package:skyshare_frontend_mobile/features/observation-chats/data/models/chat_preview_model.dart';
import 'package:skyshare_frontend_mobile/features/observation-chats/data/models/group_info_model.dart';
import 'package:skyshare_frontend_mobile/features/observation-chats/data/repositories/observation_chats_repository.dart';
import 'package:skyshare_frontend_mobile/features/observation-chats/presentation/observation_chats_screen.dart';
import 'package:skyshare_frontend_mobile/features/observation-chats/providers/observation_chats_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockObservationChatsProvider extends Mock implements ObservationChatsProvider {}
class MockObservationChatsRepository extends Mock implements ObservationChatsRepository {}
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockUser extends Mock implements User {}

void main() {
  late MockObservationChatsProvider mockProvider;
  late MockObservationChatsRepository mockRepository;
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockAuth;
  late MockUser mockUser;

  final mockGroupChats = [
    ChatPreview(idGrupo: 1, nombreGrupo: 'Mi Grupo 1'),
  ];
  final mockDiscoverableGroups = [
    GroupInfo(idGrupo: 2, nombre: 'Grupo Público', fechaCreacion: DateTime.now()),
  ];

  setUpAll(() {
    registerFallbackValue(ChatFilter.misGrupos); 
  });

  setUp(() {
    mockProvider = MockObservationChatsProvider();
    mockRepository = MockObservationChatsRepository();
    mockSupabaseClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    mockUser = MockUser();

    when(() => mockProvider.isLoading).thenReturn(false);
    when(() => mockProvider.currentFilter).thenReturn(ChatFilter.misGrupos);
    when(() => mockProvider.groupChats).thenReturn(mockGroupChats);
    when(() => mockProvider.discoverableGroups).thenReturn([]);
    when(() => mockProvider.setFilter(any())).thenAnswer((_) async {});
    when(() => mockProvider.joinGroup(any())).thenAnswer((_) async => true);

    when(() => mockSupabaseClient.auth).thenReturn(mockAuth);
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.id).thenReturn('fake-id');
  });

  Widget createTestScreen() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ObservationChatsProvider>.value(
          value: mockProvider,
        ),
        Provider<ObservationChatsRepository>.value(value: mockRepository),
        Provider<SupabaseClient>.value(value: mockSupabaseClient),
      ],
      child: const MaterialApp(
        home: ObservationChatsScreen(),
      ),
    );
  }

  testWidgets('muestra "Mis Grupos" por defecto', (tester) async {
    await tester.pumpWidget(createTestScreen());
    expect(find.text('Mi Grupo 1'), findsOneWidget);
  });

  testWidgets('muestra el diálogo "Unirse" al pulsar el botón', (tester) async {
    when(() => mockProvider.currentFilter).thenReturn(ChatFilter.todos);
    when(() => mockProvider.groupChats).thenReturn([]);
    when(() => mockProvider.discoverableGroups).thenReturn(mockDiscoverableGroups);

    await tester.pumpWidget(createTestScreen());
    
    await tester.tap(find.text('Unirse'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    
    await tester.tap(find.widgetWithText(ElevatedButton, 'Unirme'));
    await tester.pumpAndSettle();
    
    verify(() => mockProvider.joinGroup(2)).called(1);
  });
}