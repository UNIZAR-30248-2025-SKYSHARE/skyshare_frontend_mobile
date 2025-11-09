import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/profile/presentation/widgets/info_card_widget.dart';
import 'package:skyshare_frontend_mobile/core/models/user_model.dart';

void main() {
  group('InfoCard Widget', () {
    testWidgets('muestra la fecha de creación del usuario', (tester) async {
      final user = AppUser(
        id: '1',
        username: 'testuser',
        email: 'test@test.com',
        createdAt: DateTime(2023, 5, 10),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InfoCard(user: user),
          ),
        ),
      );

      expect(find.text('Account created on'), findsOneWidget);

      expect(find.text('2023-05-10'), findsOneWidget);

      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('muestra "Unknown" si createdAt es null', (tester) async {
      final user = AppUser(
        id: '1',
        username: 'testuser',
        email: 'test@test.com',
        createdAt: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InfoCard(user: user),
          ),
        ),
      );

      expect(find.text('Account created on'), findsOneWidget);
      expect(find.text('Unknown'), findsOneWidget);
    });
  });
}
