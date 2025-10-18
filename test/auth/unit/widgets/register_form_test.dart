import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:skyshare_frontend_mobile/features/auth/presentation/widgets/register_form.dart';
import 'package:skyshare_frontend_mobile/features/auth/providers/auth_provider.dart';

class MockAuthProvider extends Mock implements AuthProvider, ChangeNotifier {}

void main() {
  late MockAuthProvider mockAuth;

  setUp(() {
    mockAuth = MockAuthProvider();
  });

  testWidgets('RegisterForm - tapping Register calls signUp', (tester) async {
    when(() => mockAuth.signUp(email: any(named: 'email'), password: any(named: 'password'), username: any(named: 'username')))
      .thenAnswer((_) async {});

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AuthProvider>.value(
          value: mockAuth,
          child: const Scaffold(body: RegisterForm(onLoginTap: SizedBox.new)),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'Name X');
    await tester.enterText(find.byType(TextFormField).at(1), 'new@example.com');
    await tester.enterText(find.byType(TextFormField).at(2), 'mypass');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
    await tester.pumpAndSettle();

    verify(() => mockAuth.signUp(email: 'new@example.com', password: 'mypass', username: 'Name X')).called(1);
  });

  testWidgets('RegisterForm - tapping Google calls signInWithGoogle', (tester) async {
    when(() => mockAuth.signInWithGoogle()).thenAnswer((_) async {});

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AuthProvider>.value(
          value: mockAuth,
          child: const Scaffold(body: RegisterForm(onLoginTap: SizedBox.new)),
        ),
      ),
    );

    await tester.tap(find.byType(OutlinedButton));
    await tester.pumpAndSettle();

    verify(() => mockAuth.signInWithGoogle()).called(1);
  });
}
