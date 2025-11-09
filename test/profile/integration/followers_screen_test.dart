import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skyshare_frontend_mobile/features/profile/presentation/followers_screen.dart';
import 'package:skyshare_frontend_mobile/core/models/user_model.dart';
import 'package:skyshare_frontend_mobile/features/profile/data/repositories/follows_repository.dart';
import 'package:skyshare_frontend_mobile/features/profile/data/repositories/my_profile_repository.dart';
import 'package:skyshare_frontend_mobile/features/profile/presentation/profile_screen.dart';

class MockFollowsRepository extends Mock implements FollowsRepository {}
class MockMyProfileRepository extends Mock implements MyProfileRepository {}

void main() {
  late MockFollowsRepository mockFollowsRepo;
  late MockMyProfileRepository mockProfileRepo;

  setUp(() {
    mockFollowsRepo = MockFollowsRepository();
    mockProfileRepo = MockMyProfileRepository();
  });

  AppUser makeUser({String id = 'user1', String username = 'User 1'}) {
    return AppUser(
      id: id,
      username: username,
      email: '$username@example.com',
      photoUrl: null,
    );
  }

  Future<void> pumpFollowersScreen(
      WidgetTester tester, String userId, bool showFollowers) async {
    await tester.pumpWidget(
      MaterialApp(
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

    expect(find.byType(ListView), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('You have no followers yet'), findsOneWidget);
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
        .thenAnswer((_) async => true);
    when(() => mockFollowsRepo.unfollowUser('user1', 'user2'))
        .thenAnswer((_) async => true);

    await pumpFollowersScreen(tester, 'user123', true);

    await tester.pumpAndSettle();

    expect(find.text('Follow'), findsOneWidget);
    await tester.tap(find.text('Follow'));
    await tester.pumpAndSettle();

    verify(() => mockFollowsRepo.followUser('user1', 'user2')).called(1);
  });
}
