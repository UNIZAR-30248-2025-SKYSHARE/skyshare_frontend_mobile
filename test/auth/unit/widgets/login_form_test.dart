import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:skyshare_frontend_mobile/features/auth/presentation/widgets/login_form.dart';
import 'package:skyshare_frontend_mobile/features/auth/providers/auth_provider.dart';

class MockAuthProvider extends Mock implements AuthProvider, ChangeNotifier {}

void main() {
  late MockAuthProvider mockAuth;

  setUp(() {
    mockAuth = MockAuthProvider();
  });

  testWidgets('LoginForm - normal login calls signIn with email and password', (tester) async {
    when(() => mockAuth.signIn(email: any(named: 'email'), password: any(named: 'password')))
      .thenAnswer((_) async {});

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AuthProvider>.value(
          value: mockAuth,
          child: const Scaffold(body: LoginForm(onRegisterTap: SizedBox.new)),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret123');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    verify(() => mockAuth.signIn(email: 'test@example.com', password: 'secret123')).called(1);
  });

  testWidgets('LoginForm - tapping Google button calls signInWithGoogle', (tester) async {
    when(() => mockAuth.signInWithGoogle()).thenAnswer((_) async {});

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AuthProvider>.value(
          value: mockAuth,
          child: const Scaffold(body: LoginForm(onRegisterTap: SizedBox.new)),
        ),
      ),
    );

    await tester.tap(find.byType(OutlinedButton));
    await tester.pumpAndSettle();

    verify(() => mockAuth.signInWithGoogle()).called(1);
  });
}
