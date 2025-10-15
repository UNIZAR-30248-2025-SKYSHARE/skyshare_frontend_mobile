import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/interactive_map/presentation/widgets/filter_widget.dart';

void main() {
  group('FilterWidget', () {
    late FilterType selectedType;
    late String filterValue;
    late bool clearCalled;

    setUp(() {
      selectedType = FilterType.nombre;
      filterValue = '';
      clearCalled = false;
    });

    Future<void> pumpFilterWidget(WidgetTester tester, {bool isExpanded = false}) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                FilterWidget(
                  onFilterChanged: (type, value) {
                    selectedType = type;
                    filterValue = value;
                  },
                  onClear: () => clearCalled = true,
                ),
              ],
            ),
          ),
        ),
      );

      if (isExpanded) {
        await tester.tap(find.byIcon(Icons.filter_list));
        await tester.pumpAndSettle();
      }
    }

    testWidgets('renderiza botón de filtro cuando no está expandido', (tester) async {
      await pumpFilterWidget(tester);
      expect(find.byIcon(Icons.filter_list), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('se expande al hacer tap', (tester) async {
      await pumpFilterWidget(tester);
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('llama onFilterChanged al escribir texto', (tester) async {
      await pumpFilterWidget(tester, isExpanded: true);
      await tester.enterText(find.byType(TextField), 'test spot');
      expect(selectedType, FilterType.nombre);
      expect(filterValue, 'test spot');
    });

    testWidgets('llama onFilterChanged al seleccionar estrellas', (tester) async {
      await pumpFilterWidget(tester, isExpanded: true);
      await tester.tap(find.byIcon(Icons.star_border).first);
      expect(selectedType, FilterType.valoracion);
    });

    testWidgets('se colapsa al presionar cerrar', (tester) async {
      await pumpFilterWidget(tester, isExpanded: true);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsNothing);
      expect(clearCalled, isTrue);
    });
  });
}