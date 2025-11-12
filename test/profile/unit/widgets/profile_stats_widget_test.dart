import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/profile/presentation/widgets/profile_stats_widget.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../../../helpers/fake_localizations_delegate.dart';
void main() {
  group('ProfileStats Widget', () {
    Future<void> pumpStats(WidgetTester tester, ProfileStats widget) async {
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
          home: Scaffold(body: widget),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('muestra los valores correctos', (tester) async {
      await pumpStats(
        tester,
        const ProfileStats(spots: 10, followers: 20, following: 30),
      );

      expect(find.text('10'), findsOneWidget);
      expect(find.text('20'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
      expect(find.text('profile.stats.spots'), findsOneWidget);
      expect(find.text('profile.stats.followers'), findsOneWidget);
      expect(find.text('profile.stats.following'), findsOneWidget);
    });

    testWidgets('ejecuta los callbacks cuando se toca cada sección', (tester) async {
      bool spotsTapped = false;
      bool followersTapped = false;
      bool followingTapped = false;

      await pumpStats(
        tester,
        ProfileStats(
          spots: 10,
          followers: 20,
          following: 30,
          onSpotsTap: () => spotsTapped = true,
          onFollowersTap: () => followersTapped = true,
          onFollowingTap: () => followingTapped = true,
        ),
      );

      await tester.tap(find.text('profile.stats.spots'));
      await tester.pump();
      expect(spotsTapped, true);

      await tester.tap(find.text('profile.stats.followers'));
      await tester.pump();
      expect(followersTapped, true);

      await tester.tap(find.text('profile.stats.following'));
      await tester.pump();
      expect(followingTapped, true);
    });
  });
}