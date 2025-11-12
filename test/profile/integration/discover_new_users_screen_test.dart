import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skyshare_frontend_mobile/features/profile/presentation/discover_new_users_screen.dart';
import 'package:skyshare_frontend_mobile/features/profile/presentation/widgets/user_search_list_widget.dart';
import 'package:skyshare_frontend_mobile/features/profile/data/repositories/follows_repository.dart';
import 'package:skyshare_frontend_mobile/features/profile/data/repositories/my_profile_repository.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../../helpers/fake_localizations_delegate.dart';

class MockFollowsRepository extends Mock implements FollowsRepository {}
class MockMyProfileRepository extends Mock implements MyProfileRepository {}

void main() {
  late MockFollowsRepository mockFollowsRepository;
  late MockMyProfileRepository mockProfileRepository;

  setUp(() {
    mockFollowsRepository = MockFollowsRepository();
    mockProfileRepository = MockMyProfileRepository();
  });

  Future<void> pumpDiscoverScreen(WidgetTester tester) async {
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
        home: DiscoverUsersScreen(
          followsRepository: mockFollowsRepository,
          profileRepository: mockProfileRepository,
        ),
      ),
    );
  }

  testWidgets('DiscoverUsersScreen renders correctly with AppBar and UserSearchList', (tester) async {
    when(() => mockFollowsRepository.getAllUsers()).thenAnswer((_) async => []);
    when(() => mockProfileRepository.getCurrentUserProfile()).thenAnswer((_) async => null);

    await pumpDiscoverScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('profile.discover_screen.title'), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(UserSearchList), findsOneWidget);
  });

  testWidgets('UserSearchList calls getAllUsers and getCurrentUserProfile', (tester) async {
    when(() => mockFollowsRepository.getAllUsers()).thenAnswer((_) async => []);
    when(() => mockProfileRepository.getCurrentUserProfile()).thenAnswer((_) async => null);

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
            followsRepository: mockFollowsRepository,
            profileRepository: mockProfileRepository,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    verify(() => mockFollowsRepository.getAllUsers()).called(1);
    verify(() => mockProfileRepository.getCurrentUserProfile()).called(1);
  });

  testWidgets('UserSearchList renders inside a SizedBox to avoid overflow', (tester) async {
    when(() => mockFollowsRepository.getAllUsers()).thenAnswer((_) async => []);
    when(() => mockProfileRepository.getCurrentUserProfile()).thenAnswer((_) async => null);

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
          body: SizedBox(
            height: 600,
            child: UserSearchList(
              followsRepository: mockFollowsRepository,
              profileRepository: mockProfileRepository,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('userSearchField')), findsOneWidget);
  });
}