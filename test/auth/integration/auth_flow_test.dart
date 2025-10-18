import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:skyshare_frontend_mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:skyshare_frontend_mobile/features/auth/providers/auth_provider.dart';
import 'package:skyshare_frontend_mobile/core/models/user_model.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class FakeAuthState extends Fake implements AuthState {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeAuthState());
  });

  testWidgets('Integration: signInWithGoogle triggers authState change and UI updates', (tester) async {
    final mockRepo = MockAuthRepository();
    final controller = StreamController<AuthState>();

    when(() => mockRepo.authStateChanges).thenAnswer((_) => controller.stream);
    when(() => mockRepo.currentUser).thenReturn(null);
    when(() => mockRepo.signInWithGoogle()).thenAnswer((_) async {
      when(() => mockRepo.currentUser).thenReturn(
        AppUser(id: 'uid-123', username: 'u', email: 'a@b.com', photoUrl: null, createdAt: DateTime.now())
      );
      controller.add(FakeAuthState());
    });

    final provider = AuthProvider(authRepo: mockRepo);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthRepository>.value(value: mockRepo),
          ChangeNotifierProvider<AuthProvider>.value(value: provider),
        ],
        child: MaterialApp(
          home: Consumer<AuthProvider>(
            builder: (context, auth, _) {
              if (auth.isLoggedIn) return const Text('ROOT_APP');
              return const Text('AUTH_SCREEN');
            },
          ),
        ),
      ),
    );

    expect(find.text('AUTH_SCREEN'), findsOneWidget);
    expect(find.text('ROOT_APP'), findsNothing);

    await provider.signInWithGoogle();

    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('ROOT_APP'), findsOneWidget);

    await controller.close();
  });
}
