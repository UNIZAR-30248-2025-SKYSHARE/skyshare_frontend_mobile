import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skyshare_frontend_mobile/features/profile/presentation/widgets/user_search_list_widget.dart';
import 'package:skyshare_frontend_mobile/core/models/user_model.dart';
import 'package:skyshare_frontend_mobile/features/profile/data/repositories/follows_repository.dart';
import 'package:skyshare_frontend_mobile/features/profile/data/repositories/my_profile_repository.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../../../helpers/fake_localizations_delegate.dart';

class MockFollowsRepository extends Mock implements FollowsRepository {}
class MockMyProfileRepository extends Mock implements MyProfileRepository {}

void main() {
  late MockFollowsRepository mockFollowsRepo;
  late MockMyProfileRepository mockProfileRepo;

  setUp(() {
    mockFollowsRepo = MockFollowsRepository();
    mockProfileRepo = MockMyProfileRepository();
    registerFallbackValue(AppUser(id: '1', username: 'Test', email: 'test@example.com'));
  });

  Future<void> pumpWidget(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: [
          FakeLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(
          body: UserSearchList(
            followsRepository: mockFollowsRepo,
            profileRepository: mockProfileRepo,
          ),
        ),
      ),
    );
  }

  testWidgets('muestra mensaje de carga y luego usuarios', (tester) async {
    final users = [
      AppUser(id: '2', username: 'Alice', email: 'alice@test.com'),
      AppUser(id: '3', username: 'Bob', email: 'bob@test.com'),
    ];

    when(() => mockProfileRepo.getCurrentUserProfile())
        .thenAnswer((_) async => AppUser(id: '1', username: 'Current', email: 'current@test.com'));
    when(() => mockFollowsRepo.getAllUsers()).thenAnswer((_) async => users);
    when(() => mockFollowsRepo.isFollowing(any(), any())).thenAnswer((_) async => false);

    await pumpWidget(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    expect(find.descendant(of: find.byType(ListView), matching: find.text('Alice')), findsOneWidget);
    expect(find.descendant(of: find.byType(ListView), matching: find.text('Bob')), findsOneWidget);
  });

  testWidgets('filtra usuarios según la búsqueda', (tester) async {
    final users = [
      AppUser(id: '2', username: 'Alice', email: 'alice@test.com'),
      AppUser(id: '3', username: 'Bob',   email: 'bob@test.com'),
    ];

    when(() => mockProfileRepo.getCurrentUserProfile())
        .thenAnswer((_) async => AppUser(id: '1', username: 'Current', email: 'current@test.com'));
    when(() => mockFollowsRepo.getAllUsers()).thenAnswer((_) async => users);
    when(() => mockFollowsRepo.isFollowing(any(), any())).thenAnswer((_) async => false);

    await pumpWidget(tester);
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('userSearchField')), 'Alice');
    await tester.pumpAndSettle();

    expect(find.descendant(of: find.byType(ListView), matching: find.text('Alice')), findsOneWidget);
    expect(find.descendant(of: find.byType(ListView), matching: find.text('Bob')), findsNothing);
  });

  testWidgets('toggle follow button llama a métodos correctos', (tester) async {
    final user = AppUser(id: '2', username: 'Alice', email: 'alice@test.com');

    when(() => mockProfileRepo.getCurrentUserProfile())
        .thenAnswer((_) async => AppUser(id: '1', username: 'Current', email: 'current@test.com'));
    when(() => mockFollowsRepo.getAllUsers()).thenAnswer((_) async => [user]);
    when(() => mockFollowsRepo.isFollowing('1', '2')).thenAnswer((_) async => false);
    when(() => mockFollowsRepo.followUser('1', '2')).thenAnswer((_) async {});

    await pumpWidget(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    final followButton = find.byKey(const Key('followButton_2'));
    expect(followButton, findsOneWidget);

    await tester.tap(followButton);
    await tester.pumpAndSettle();

    verify(() => mockFollowsRepo.followUser('1', '2')).called(1);
  });
}