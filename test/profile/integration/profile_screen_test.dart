import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skyshare_frontend_mobile/features/profile/presentation/profile_screen.dart';
import 'package:skyshare_frontend_mobile/features/profile/data/repositories/my_profile_repository.dart';
import 'package:skyshare_frontend_mobile/features/profile/data/repositories/follows_repository.dart';
import 'package:skyshare_frontend_mobile/features/interactive_map/data/repositories/spot_repository.dart';
import 'package:skyshare_frontend_mobile/core/models/user_model.dart';
import 'package:skyshare_frontend_mobile/core/i18n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../../helpers/fake_localizations_delegate.dart';

class MockMyProfileRepository extends Mock implements MyProfileRepository {}
class MockFollowsRepository extends Mock implements FollowsRepository {}
class MockSpotRepository extends Mock implements SpotRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockMyProfileRepository mockProfileRepo;
  late MockFollowsRepository mockFollowsRepo;
  late MockSpotRepository mockSpotRepo;
  late AppUser currentUser;
  late AppUser viewedUser;

  setUp(() {
    mockProfileRepo = MockMyProfileRepository();
    mockFollowsRepo = MockFollowsRepository();
    mockSpotRepo = MockSpotRepository();
    currentUser = AppUser(id: '1', username: 'currentUser');
    viewedUser = AppUser(id: '2', username: 'otherUser');
  });

  Future<void> pumpProfileScreen(WidgetTester tester, String userId) async {
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
        home: ProfileScreen(
          userId: userId,
          profileRepository: mockProfileRepo,
          followsRepository: mockFollowsRepo,
          spotRepository: mockSpotRepo,
        ),
      ),
    );
  }

  testWidgets('Carga y muestra correctamente el perfil de otro usuario', (tester) async {
    when(() => mockProfileRepo.getCurrentUserProfile()).thenAnswer((_) async => currentUser);
    when(() => mockProfileRepo.getUserProfileById(any())).thenAnswer((_) async => viewedUser);
    when(() => mockProfileRepo.getFollowersData(any())).thenAnswer((_) async => {'followers': 5, 'following': 3});
    when(() => mockProfileRepo.getSpotsCount(any())).thenAnswer((_) async => 2);
    when(() => mockFollowsRepo.isFollowing(any(), any())).thenAnswer((_) async => false);

    await pumpProfileScreen(tester, '2');
    await tester.pumpAndSettle();

    expect(find.text('otherUser'), findsOneWidget);
    expect(find.text('profile.follow_button'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('Follow -> Following -> Unfollow funciona correctamente', (tester) async {
    when(() => mockProfileRepo.getCurrentUserProfile()).thenAnswer((_) async => currentUser);
    when(() => mockProfileRepo.getUserProfileById('2')).thenAnswer((_) async => viewedUser);
    when(() => mockProfileRepo.getFollowersData('2')).thenAnswer((_) async => {'followers': 5, 'following': 3});
    when(() => mockProfileRepo.getSpotsCount('2')).thenAnswer((_) async => 10);
    when(() => mockFollowsRepo.isFollowing('1', '2')).thenAnswer((_) async => false);
    when(() => mockFollowsRepo.followUser('1', '2')).thenAnswer((_) async {});
    when(() => mockFollowsRepo.unfollowUser('1', '2')).thenAnswer((_) async {});

    await pumpProfileScreen(tester, '2');
    await tester.pumpAndSettle();

    expect(find.text('otherUser'), findsOneWidget);

    final followButton = find.byKey(const ValueKey('followButton'));
    expect(followButton, findsOneWidget);

    await tester.tap(followButton);
    await tester.pumpAndSettle();
    expect(find.descendant(of: followButton, matching: find.text('profile.following_button')), findsOneWidget);

    await tester.tap(followButton);
    await tester.pumpAndSettle();
    expect(find.descendant(of: followButton, matching: find.text('profile.follow_button')), findsOneWidget);

    verify(() => mockFollowsRepo.followUser('1', '2')).called(1);
    verify(() => mockFollowsRepo.unfollowUser('1', '2')).called(1);
  });

  testWidgets('Muestra pantalla vacía si no puede cargar usuario', (tester) async {
    when(() => mockProfileRepo.getCurrentUserProfile()).thenAnswer((_) async => currentUser);
    when(() => mockProfileRepo.getUserProfileById(any())).thenAnswer((_) async => null);

    await pumpProfileScreen(tester, '2');
    await tester.pumpAndSettle();

    expect(find.text('profile.no_load_error'), findsOneWidget);
  });
}