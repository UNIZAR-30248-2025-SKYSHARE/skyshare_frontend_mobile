import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/alerts_configurable/presentation/widgets/alert_info_row_widget.dart';

void main() {
  group('AlertInfoRowWidget', () {
    testWidgets('muestra icono, título y subtítulo correctamente', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlertInfoRowWidget(
              icon: const Icon(Icons.notifications),
              title: 'Alerta importante',
              subtitle: 'Subtítulo de prueba',
              isActive: true,
              switchValue: false,
              onSwitchChanged: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.notifications), findsOneWidget);
      expect(find.text('Alerta importante'), findsOneWidget);
      expect(find.text('Subtítulo de prueba'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('cambia el valor del switch correctamente', (tester) async {
      bool switchChanged = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlertInfoRowWidget(
              icon: const Icon(Icons.notifications),
              title: 'Alerta',
              subtitle: 'Subtítulo',
              isActive: true,
              switchValue: false,
              onSwitchChanged: (value) => switchChanged = value,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);

      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(switchChanged, isTrue);
    });
  });
}
