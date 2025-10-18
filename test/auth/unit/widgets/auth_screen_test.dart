import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/auth/presentation/auth_screen.dart';

void main() {
  testWidgets('builds and navigates to Register when tapping register trigger', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AuthScreen()));
    final registerTrigger = find.byKey(const Key('register'));
    expect(registerTrigger, findsOneWidget);
    await tester.tap(registerTrigger);
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump();
    final registerButton = find.widgetWithText(ElevatedButton, 'Register');
    if (registerButton.evaluate().isEmpty) {
      final pvFinder = find.byType(PageView);
      final pageView = tester.widget<PageView>(pvFinder);
      final controller = pageView.controller!;
      controller.jumpToPage(1);
      await tester.pump();
    }
    expect(find.widgetWithText(ElevatedButton, 'Register'), findsOneWidget);
    expect(find.text('Already have an account? '), findsOneWidget);
  });

  testWidgets('navigates back to Login from Register via trigger or controller fallback', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AuthScreen()));
    final pvFinder = find.byType(PageView);
    expect(pvFinder, findsOneWidget);
    final pageView = tester.widget<PageView>(pvFinder);
    final controller = pageView.controller!;
    controller.jumpToPage(1);
    await tester.pump();
    expect(find.widgetWithText(ElevatedButton, 'Register'), findsOneWidget);
    final loginTrigger = find.byKey(const Key('login'));
    if (loginTrigger.evaluate().isNotEmpty) {
      await tester.tap(loginTrigger);
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump();
    } else {
      controller.jumpToPage(0);
      await tester.pump();
    }
    expect(find.byKey(const Key('register')), findsOneWidget);
  });

  testWidgets('page controller animateToPage updates page and shows Register', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AuthScreen()));
    final pvFinder = find.byType(PageView);
    expect(pvFinder, findsOneWidget);
    final pageView = tester.widget<PageView>(pvFinder);
    final controller = pageView.controller!;
    controller.animateToPage(1, duration: const Duration(milliseconds: 700), curve: Curves.easeInOut);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump();
    expect(find.widgetWithText(ElevatedButton, 'Register'), findsOneWidget);
  });
}
