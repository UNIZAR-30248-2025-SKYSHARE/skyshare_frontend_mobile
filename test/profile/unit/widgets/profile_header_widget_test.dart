import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/profile/presentation/widgets/profile_header_widget.dart';
import 'package:skyshare_frontend_mobile/core/models/user_model.dart';
import 'package:skyshare_frontend_mobile/features/profile/presentation/widgets/photo_profile_widget.dart';

void main() {
  group('ProfileHeader', () {
        testWidgets('muestra el icono por defecto cuando photoUrl es null',
        (WidgetTester tester) async {
      final user = AppUser(
        id: '2',
        username: 'Bob',
        email: 'bob@test.com',
        photoUrl: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileHeader(user: user),
          ),
        ),
      );

      final photoWidget = tester.widget<PhotoProfileWidget>(
        find.byType(PhotoProfileWidget),
      );
      expect(photoWidget.photoUrl, isNull);

      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('bob@test.com'), findsOneWidget);
    });

    testWidgets('muestra el icono por defecto cuando photoUrl está vacío',
        (WidgetTester tester) async {
      final user = AppUser(
        id: '3',
        username: 'Charlie',
        email: 'charlie@test.com',
        photoUrl: '',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileHeader(user: user),
          ),
        ),
      );

      final photoWidget = tester.widget<PhotoProfileWidget>(
        find.byType(PhotoProfileWidget),
      );
      expect(photoWidget.photoUrl, equals(''));

      expect(find.text('Charlie'), findsOneWidget);
      expect(find.text('charlie@test.com'), findsOneWidget);
    });
  });
}
