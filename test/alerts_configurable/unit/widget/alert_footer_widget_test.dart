import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/alerts_configurable/presentation/widgets/alert_footer_widget.dart';

void main() {
  group('AlertFooterWidget', () {
    late bool deleted;

    setUp(() {
      deleted = false;
    });

    testWidgets('muestra fecha correctamente cuando es hoy', (tester) async {
      final today = DateTime.now();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlertFooterWidget(
              date: today,
              isActive: true,
              onDelete: () {},
            ),
          ),
        ),
      );

      // Espera a renderizar
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('alert_footer_date')), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('muestra fecha correctamente cuando es mañana', (tester) async {
      final tomorrow = DateTime.now().add(const Duration(days: 1));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlertFooterWidget(
              date: tomorrow,
              isActive: true,
              onDelete: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Tomorrow'), findsOneWidget);
    });

    testWidgets('llama onDelete al presionar el botón', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlertFooterWidget(
              date: DateTime.now(),
              isActive: true,
              onDelete: () {
                deleted = true;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final deleteButton = find.byKey(const Key('alert_footer_delete'));
      expect(deleteButton, findsOneWidget);

      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      expect(deleted, isTrue);
    });

    testWidgets('muestra fecha en formato dd/MM/yyyy cuando es mayor a 30 días', (tester) async {
      final futureDate = DateTime.now().add(const Duration(days: 40));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlertFooterWidget(
              date: futureDate,
              isActive: true,
              onDelete: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final formatted = '${futureDate.day.toString().padLeft(2, '0')}/'
          '${futureDate.month.toString().padLeft(2, '0')}/'
          '${futureDate.year}';
      expect(find.text(formatted), findsOneWidget);
    });
  });
}
