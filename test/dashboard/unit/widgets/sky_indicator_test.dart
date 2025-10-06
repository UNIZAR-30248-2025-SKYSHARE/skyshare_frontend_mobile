import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/dashboard/presentation/widgets/sky_indicator.dart';

void main() {
  group('SkyIndicator', () {
    testWidgets('muestra el título correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkyIndicator(value: 7.5),
          ),
        ),
      );

      expect(find.text('Sky Quality Index'), findsOneWidget);
    });

    testWidgets('muestra el valor formateado correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkyIndicator(value: 7.5),
          ),
        ),
      );

      expect(find.text('7.5 / 10'), findsOneWidget);
    });

    testWidgets('clampa valores fuera de rango', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkyIndicator(value: 15.0),
          ),
        ),
      );

      expect(find.text('10.0 / 10'), findsOneWidget);
    });

    testWidgets('usa color verde para valores altos', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkyIndicator(value: 8.0),
          ),
        ),
      );

      final valueText = tester.widget<Text>(find.text('8.0 / 10'));
      expect(valueText.style?.color, Colors.green);
    });
  });
}