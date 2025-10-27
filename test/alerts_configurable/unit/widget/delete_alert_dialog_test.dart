import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/alerts_configurable/presentation/widgets/delete_alert_dialog.dart';

void main() {
  testWidgets('Muestra título, contenido y botones correctamente', (tester) async {
    bool confirmed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => DeleteAlertDialog(
                onConfirm: () => confirmed = true,
              ),
            ),
            child: const Text('Open Dialog'),
          ),
        ),
      ),
    );

    // Abrir el dialog
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    // Verifica que título y contenido estén presentes
    expect(find.text('Delete alert?'), findsOneWidget);
    expect(find.text('This action cannot be undone. The alert will be permanently deleted.'), findsOneWidget);

    // Botones
    final cancelBtn = find.byKey(const Key('delete_dialog_cancel'));
    final confirmBtn = find.byKey(const Key('delete_dialog_confirm'));
    expect(cancelBtn, findsOneWidget);
    expect(confirmBtn, findsOneWidget);

    // Probar acción de confirm
    await tester.tap(confirmBtn);
    await tester.pumpAndSettle();
    expect(confirmed, isTrue);
  });
}
