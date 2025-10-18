import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/auth/presentation/widgets/auth_buttons.dart';

void main() {
  testWidgets('GoogleButton shows label and triggers onPressed (image or icon allowed)', (tester) async {
    var pressed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GoogleButton(label: 'Sign in with Google', onPressed: () { pressed = true; }),
        ),
      ),
    );

    expect(find.text('Sign in with Google'), findsOneWidget);
    expect(find.byType(OutlinedButton), findsOneWidget);

    final hasIcon = find.byType(Icon);
    final hasImage = find.byType(Image);
    expect(hasIcon.evaluate().isNotEmpty || hasImage.evaluate().isNotEmpty, isTrue);

    await tester.tap(find.byType(OutlinedButton));
    await tester.pumpAndSettle();

    expect(pressed, isTrue);
  });
}
