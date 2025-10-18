import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/auth/presentation/widgets/auth_buttons.dart';

void main() {
  testWidgets('PrimaryButton shows label and triggers onPressed', (tester) async {
    var pressed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PrimaryButton(label: 'Ok', onPressed: () { pressed = true; }, isLoading: false),
        ),
      ),
    );

    expect(find.text('Ok'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(pressed, isTrue);
  });

  testWidgets('PrimaryButton shows loader when isLoading true', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PrimaryButton(label: 'Ok', onPressed: () {}, isLoading: true),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Ok'), findsNothing);
  });
}
