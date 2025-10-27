import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/alerts_configurable/presentation/widgets/alert_error_widget.dart';

void main() {
  group('AlertErrorWidget', () {
    testWidgets('displays title, message, and error icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlertErrorWidget(
              error: 'An error occurred', 
              onRetry: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Error loading alerts'), findsOneWidget); 
      expect(find.text('An error occurred'), findsOneWidget); 
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.byKey(const Key('alert_retry_button')), findsOneWidget);
    });

    testWidgets('calls onRetry when pressing the button', (tester) async {
      bool retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlertErrorWidget(
              error: 'An error occurred',
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final button = find.byKey(const Key('alert_retry_button'));
      expect(button, findsOneWidget);

      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(retried, isTrue);
    });
  });
}
