import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/dashboard/presentation/widgets/light_pollution_bar.dart';

void main() {
  group('LightPollutionBar', () {
    testWidgets('muestra el título correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LightPollutionBar(value: 5.0),
          ),
        ),
      );

      expect(find.text('Contaminación Lumínica'), findsOneWidget);
    });

    testWidgets('muestra los valores extremos 1 y 9', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LightPollutionBar(value: 5.0),
          ),
        ),
      );

      expect(find.text('1'), findsOneWidget);
      expect(find.text('9'), findsOneWidget);
    });

    testWidgets('muestra el valor numérico correcto', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LightPollutionBar(value: 3.5),
          ),
        ),
      );

      expect(find.text('3.5'), findsOneWidget);
    });

    testWidgets('clampa valores fuera de rango', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LightPollutionBar(value: 15.0),
          ),
        ),
      );

      expect(find.text('9.0'), findsOneWidget);
    });
  });
}