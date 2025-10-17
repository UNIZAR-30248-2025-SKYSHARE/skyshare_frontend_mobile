import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/interactive_map/presentation/widgets/search_bar_widget.dart';

void main() {
  group('SearchBarWidget', () {
    late String searchValue;
    late bool clearCalled;

    setUp(() {
      searchValue = '';
      clearCalled = false;
    });

    Future<void> pumpSearchBarWidget(WidgetTester tester, {bool isExpanded = false}) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                const SizedBox(width: 400, height: 800),
                SearchBarWidget(
                  onSearchChanged: (value) {
                    searchValue = value;
                  },
                  onClear: () => clearCalled = true,
                ),
              ],
            ),
          ),
        ),
      );

      if (isExpanded) {
        await tester.tap(find.byIcon(Icons.search));
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
      }
    }

    testWidgets('renderiza botón de búsqueda cuando no está expandido', (tester) async {
      await pumpSearchBarWidget(tester);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('se expande al hacer tap y muestra campo de texto', (tester) async {
      await pumpSearchBarWidget(tester);
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('llama onSearchChanged al escribir en el campo de texto', (tester) async {
      await pumpSearchBarWidget(tester, isExpanded: true);
      await tester.enterText(find.byType(TextField), 'test search');
      await tester.pump();
      expect(searchValue, 'test search');
    });

    testWidgets('muestra botón de limpiar cuando hay texto', (tester) async {
      await pumpSearchBarWidget(tester, isExpanded: true);
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      final clearIconFinder = find.byIcon(Icons.clear);
      final clearButtonFinder = find.descendant(
        of: find.byType(SearchBarWidget),
        matching: find.byWidgetPredicate((widget) {
          return widget is IconButton &&
              (widget.icon is Icon) &&
              (widget.icon as Icon).icon == Icons.clear;
        }),
      );
      expect(clearIconFinder.hitTestable().evaluate().isNotEmpty ||
          clearButtonFinder.hitTestable().evaluate().isNotEmpty, isTrue);
    });

    testWidgets('llama onClear al presionar el botón de limpiar', (tester) async {
      await pumpSearchBarWidget(tester, isExpanded: true);
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      final clearIconFinder = find.byIcon(Icons.clear);
      final clearButtonFinder = find.descendant(
        of: find.byType(SearchBarWidget),
        matching: find.byWidgetPredicate((widget) {
          return widget is IconButton &&
              (widget.icon is Icon) &&
              (widget.icon as Icon).icon == Icons.clear;
        }),
      );
      if (clearIconFinder.hitTestable().evaluate().isNotEmpty) {
        await tester.tap(clearIconFinder);
      } else if (clearButtonFinder.hitTestable().evaluate().isNotEmpty) {
        await tester.tap(clearButtonFinder);
      } else {
        final anyClearFinder = find.byWidgetPredicate((widget) {
          if (widget is Icon) return widget.icon == Icons.clear;
          if (widget is IconButton) {
            return widget.icon is Icon && (widget.icon as Icon).icon == Icons.clear;
          }
          return false;
        });
        if (anyClearFinder.hitTestable().evaluate().isNotEmpty) {
          await tester.tap(anyClearFinder);
        } else {
          fail('No se pudo encontrar el botón de limpiar');
        }
      }
      await tester.pump();
      expect(clearCalled, isTrue);
    });

    testWidgets('se colapsa al presionar el botón cerrar', (tester) async {
      await pumpSearchBarWidget(tester, isExpanded: true);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      expect(find.byType(TextField), findsNothing);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('limpia el texto y colapsa al cerrar', (tester) async {
      await pumpSearchBarWidget(tester, isExpanded: true);
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      expect(find.byType(TextField), findsNothing);
      expect(clearCalled, isTrue);
    });

    testWidgets('expande y contrae correctamente', (tester) async {
      await pumpSearchBarWidget(tester);
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      expect(find.byType(TextField), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      expect(find.byType(TextField), findsNothing);
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
