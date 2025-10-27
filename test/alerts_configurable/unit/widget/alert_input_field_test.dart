import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/alerts_configurable/presentation/widgets/alert_input_field.dart';

void main() {
  group('AlertInputField', () {
    late TextEditingController controller;

    setUp(() {
      controller = TextEditingController();
    });

    testWidgets('muestra hintText correctamente', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlertInputField(
              hintText: 'Ingrese texto',
              controller: controller,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Ingrese texto'), findsOneWidget);
    });

    testWidgets('muestra el texto del controller', (tester) async {
      controller.text = 'Hola Mundo';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlertInputField(
              hintText: 'Ingrese texto',
              controller: controller,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Hola Mundo'), findsOneWidget);
    });

    testWidgets('muestra suffixIcon si se proporciona', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlertInputField(
              hintText: 'Ingrese texto',
              controller: controller,
              suffixIcon: const Icon(Icons.clear),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('campo readonly y deshabilitado', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlertInputField(
              hintText: 'Ingrese texto',
              controller: controller,
              enabled: false,
              readOnly: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      final tfWidget = tester.widget<TextField>(textField);
      expect(tfWidget.enabled, isFalse);
      expect(tfWidget.readOnly, isTrue);
    });
  });
}
