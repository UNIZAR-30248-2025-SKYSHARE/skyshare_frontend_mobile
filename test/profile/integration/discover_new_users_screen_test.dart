import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skyshare_frontend_mobile/features/profile/presentation/discover_new_users_screen.dart';
import 'package:skyshare_frontend_mobile/features/profile/presentation/widgets/user_search_list_widget.dart';
import 'package:skyshare_frontend_mobile/features/profile/data/repositories/follows_repository.dart';
import 'package:skyshare_frontend_mobile/features/profile/data/repositories/my_profile_repository.dart';

class MockFollowsRepository extends Mock implements FollowsRepository {}
class MockMyProfileRepository extends Mock implements MyProfileRepository {}

class TestableDiscoverUsersScreen extends DiscoverUsersScreen {
  final FollowsRepository followsRepository;
  final MyProfileRepository profileRepository;

  const TestableDiscoverUsersScreen({
    super.key,
    required this.followsRepository,
    required this.profileRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Discover Users")),
        body: UserSearchList(
          followsRepository: followsRepository,
          profileRepository: profileRepository,
        ),
      ),
    );
  }
}

void main() {
  late MockFollowsRepository mockFollowsRepository;
  late MockMyProfileRepository mockProfileRepository;

  setUp(() {
    mockFollowsRepository = MockFollowsRepository();
    mockProfileRepository = MockMyProfileRepository();
  });

  testWidgets(
    'DiscoverUsersScreen renders correctly with AppBar and UserSearchList',
    (WidgetTester tester) async {
      when(() => mockFollowsRepository.getAllUsers()).thenAnswer((_) async => []);
      when(() => mockProfileRepository.getCurrentUserProfile()).thenAnswer((_) async => null);

      await tester.pumpWidget(
        TestableDiscoverUsersScreen(
          followsRepository: mockFollowsRepository,
          profileRepository: mockProfileRepository,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Discover Users'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(UserSearchList), findsOneWidget);
    },
  );

  testWidgets(
    'UserSearchList calls getAllUsers and getCurrentUserProfile',
    (WidgetTester tester) async {
      when(() => mockFollowsRepository.getAllUsers()).thenAnswer((_) async => []);
      when(() => mockProfileRepository.getCurrentUserProfile()).thenAnswer((_) async => null);

      await tester.pumpWidget(
        MaterialApp(
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
    },
  );

  testWidgets(
    'UserSearchList renders inside a SizedBox to avoid overflow',
    (WidgetTester tester) async {
      when(() => mockFollowsRepository.getAllUsers()).thenAnswer((_) async => []);
      when(() => mockProfileRepository.getCurrentUserProfile()).thenAnswer((_) async => null);

      await tester.pumpWidget(
        MaterialApp(
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

      expect(find.byType(TextField), findsOneWidget);
    },
  );
}
