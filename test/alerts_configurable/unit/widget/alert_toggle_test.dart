import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/alerts_configurable/presentation/widgets/alert_toggle.dart';

void main() {
  group('AlertToggle', () {
    testWidgets('muestra label correctamente', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlertToggle(label: 'Notificación', value: false, onChanged: (_) {}),
          ),
        ),
      );

      expect(find.text('Notificación'), findsOneWidget);
    });

    testWidgets('llama onChanged al cambiar el switch', (tester) async {
      bool switchValue = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlertToggle(
              label: 'Notificación',
              value: switchValue,
              onChanged: (val) => switchValue = val,
            ),
          ),
        ),
      );

      final switchFinder = find.byKey(const Key('alert_toggle_switch'));
      expect(switchFinder, findsOneWidget);

      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(switchValue, isTrue);
    });
  });
}
