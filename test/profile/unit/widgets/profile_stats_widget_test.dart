import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/profile/presentation/widgets/profile_stats_widget.dart';

void main() {
  group('ProfileStats Widget', () {
    testWidgets('muestra los valores correctos', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileStats(
              spots: 10,
              followers: 20,
              following: 30,
            ),
          ),
        ),
      );

      expect(find.text('10'), findsOneWidget);
      expect(find.text('20'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);

      expect(find.text('Spots'), findsOneWidget);
      expect(find.text('Followers'), findsOneWidget);
      expect(find.text('Following'), findsOneWidget);
    });

    testWidgets('ejecuta los callbacks cuando se toca cada sección', (tester) async {
      bool spotsTapped = false;
      bool followersTapped = false;
      bool followingTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileStats(
              spots: 10,
              followers: 20,
              following: 30,
              onSpotsTap: () => spotsTapped = true,
              onFollowersTap: () => followersTapped = true,
              onFollowingTap: () => followingTapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Spots'));
      await tester.pump();
      expect(spotsTapped, true);

      await tester.tap(find.text('Followers'));
      await tester.pump();
      expect(followersTapped, true);

      await tester.tap(find.text('Following'));
      await tester.pump();
      expect(followingTapped, true);
    });
  });
}
