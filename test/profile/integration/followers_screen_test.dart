import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skyshare_frontend_mobile/features/profile/presentation/followers_screen.dart';
import 'package:skyshare_frontend_mobile/core/models/user_model.dart';
import 'package:skyshare_frontend_mobile/features/profile/data/repositories/follows_repository.dart';
import 'package:skyshare_frontend_mobile/features/profile/data/repositories/my_profile_repository.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../../helpers/fake_localizations_delegate.dart';

class MockFollowsRepository extends Mock implements FollowsRepository {}
class MockMyProfileRepository extends Mock implements MyProfileRepository {}

void main() {
  late MockFollowsRepository mockFollowsRepo;
  late MockMyProfileRepository mockProfileRepo;

  setUp(() {
    mockFollowsRepo = MockFollowsRepository();
    mockProfileRepo = MockMyProfileRepository();
  });

  AppUser makeUser({String id = 'user1', String username = 'User 1'}) =>
      AppUser(id: id, username: username, email: '$username@example.com');

  Future<void> pumpFollowersScreen(
      WidgetTester tester, String userId, bool showFollowers) async {
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
        home: FollowersScreen(
          userId: userId,
          showFollowers: showFollowers,
          followsRepository: mockFollowsRepo,
          profileRepository: mockProfileRepo,
        ),
      ),
    );
  }

  testWidgets('Muestra loader inicial y luego lista vacía', (tester) async {
    when(() => mockProfileRepo.getCurrentUserProfile())
        .thenAnswer((_) async => makeUser());
    when(() => mockFollowsRepo.getUsuariosSeguidores(any()))
        .thenAnswer((_) async => []);

    await pumpFollowersScreen(tester, 'user123', true);
    await tester.pumpAndSettle();

    expect(find.text('profile.followers_screen.empty'), findsOneWidget);
  });

  testWidgets('Permite seguir y dejar de seguir un usuario', (tester) async {
    final user = makeUser(id: 'user2', username: 'User 2');
    when(() => mockProfileRepo.getCurrentUserProfile())
        .thenAnswer((_) async => makeUser(id: 'user1'));
    when(() => mockFollowsRepo.getUsuariosSeguidores(any()))
        .thenAnswer((_) async => [user]);
    when(() => mockFollowsRepo.isFollowing('user1', 'user2'))
        .thenAnswer((_) async => false);
    when(() => mockFollowsRepo.followUser('user1', 'user2'))
        .thenAnswer((_) async {});
    when(() => mockFollowsRepo.unfollowUser('user1', 'user2'))
        .thenAnswer((_) async {});

    await pumpFollowersScreen(tester, 'user123', true);
    await tester.pumpAndSettle();

    expect(find.text('profile.follow_button'), findsOneWidget);
    await tester.tap(find.text('profile.follow_button'));
    await tester.pumpAndSettle();

    verify(() => mockFollowsRepo.followUser('user1', 'user2')).called(1);
  });
}