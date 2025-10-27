import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/alerts_configurable/presentation/widgets/alert_dropdown.dart';

void main() {
  group('AlertDropdown', () {
    late String? selectedValue;

    setUp(() {
      selectedValue = null;
    });

    List<DropdownMenuItem<String>> buildItems() {
      return const [
        DropdownMenuItem(value: 'op1', child: Text('Opción 1')),
        DropdownMenuItem(value: 'op2', child: Text('Opción 2')),
        DropdownMenuItem(value: 'op3', child: Text('Opción 3')),
      ];
    }

    testWidgets('muestra el hint cuando no hay valor seleccionado', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlertDropdown<String>(
              hintText: 'Selecciona una opción',
              value: null,
              items: buildItems(),
              onChanged: (v) => selectedValue = v,
            ),
          ),
        ),
      );

      expect(find.text('Selecciona una opción'), findsOneWidget);
    });

    testWidgets('muestra los items al abrir el dropdown', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlertDropdown<String>(
              hintText: 'Selecciona una opción',
              value: null,
              items: buildItems(),
              onChanged: (v) => selectedValue = v,
            ),
          ),
        ),
      );

      // Abrir dropdown
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      expect(find.text('Opción 1'), findsOneWidget);
      expect(find.text('Opción 2'), findsOneWidget);
      expect(find.text('Opción 3'), findsOneWidget);
    });

    testWidgets('llama onChanged al seleccionar un item', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlertDropdown<String>(
              hintText: 'Selecciona una opción',
              value: null,
              items: buildItems(),
              onChanged: (v) => selectedValue = v,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Opción 2').last);
      await tester.pumpAndSettle();

      expect(selectedValue, 'op2');
      expect(find.text('Opción 2'), findsOneWidget);
    });

    testWidgets('muestra el valor inicial seleccionado', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlertDropdown<String>(
              hintText: 'Selecciona una opción',
              value: 'op3',
              items: buildItems(),
              onChanged: (v) => selectedValue = v,
            ),
          ),
        ),
      );

      expect(find.text('Opción 3'), findsOneWidget);
    });

    testWidgets('no permite cambiar valor cuando enabled es false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlertDropdown<String>(
              hintText: 'Selecciona una opción',
              value: null,
              enabled: false,
              items: buildItems(),
              onChanged: (v) => selectedValue = v,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      expect(find.text('Opción 1'), findsNothing);
      expect(find.text('Opción 2'), findsNothing);
    });
  });
}
