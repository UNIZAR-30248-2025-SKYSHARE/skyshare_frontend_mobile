import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/alerts_configurable/presentation/widgets/alert_form_field.dart';

void main() {
  group('AlertFormField', () {
    testWidgets('muestra label y child correctamente', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AlertFormField(
              label: 'Nombre de la alerta',
              child: Text('Campo de prueba'),
            ),
          ),
        ),
      );

      // Busca el label usando la key generada automáticamente
      final labelFinder = find.byKey(const Key('alert_form_label_Nombre de la alerta'));
      expect(labelFinder, findsOneWidget);
      expect(find.text('NOMBRE DE LA ALERTA'), findsOneWidget);

      // Busca el child usando la key generada automáticamente
      final childFinder = find.byKey(const Key('alert_form_child_Nombre de la alerta'));
      expect(childFinder, findsOneWidget);
      expect(find.text('Campo de prueba'), findsOneWidget);
    });

    testWidgets('permite padding personalizado', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AlertFormField(
              label: 'Test padding',
              padding: EdgeInsets.all(32),
              child: SizedBox(),
            ),
          ),
        ),
      );

      final containerFinder = find.byKey(const Key('alert_form_child_Test padding'));
      expect(containerFinder, findsOneWidget);

      final paddingWidget = tester.widget<Padding>(find.ancestor(of: containerFinder, matching: find.byType(Padding)));
      expect(paddingWidget.padding, const EdgeInsets.all(32));
    });
  });
}
