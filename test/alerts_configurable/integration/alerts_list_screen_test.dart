import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:skyshare_frontend_mobile/features/alerts_configurable/data/model/alert_model.dart';
import 'package:skyshare_frontend_mobile/features/alerts_configurable/presentation/alerts_list_screen.dart';
import 'package:skyshare_frontend_mobile/features/alerts_configurable/presentation/widgets/alert_card_widget.dart';
import 'package:skyshare_frontend_mobile/features/alerts_configurable/presentation/widgets/delete_alert_dialog.dart';
import 'package:skyshare_frontend_mobile/features/alerts_configurable/providers/alert_provider.dart';

// Mock de AlertProvider
class MockAlertProvider extends Mock implements AlertProvider {}

void main() {
  late MockAlertProvider mockProvider;

  setUp(() {
    mockProvider = MockAlertProvider();

    final alert1 = AlertModel(
      idAlerta: 1,
      idUsuario: 'user123',
      idUbicacion: 1,
      tipoAlerta: 'estrellas',
      tipoRepeticion: 'Once',
      fechaObjetivo: DateTime.now(),
      activa: true,
    );

    final alert2 = AlertModel(
      idAlerta: 2,
      idUsuario: 'user123',
      idUbicacion: 2,
      tipoAlerta: 'planetas',
      tipoRepeticion: 'Once',
      fechaObjetivo: DateTime.now().add(const Duration(days: 1)),
      activa: false,
    );

    when(() => mockProvider.isLoading).thenReturn(false);
    when(() => mockProvider.error).thenReturn(null);
    when(() => mockProvider.alerts).thenReturn([alert1, alert2]);
    when(() => mockProvider.activeAlertsCount).thenReturn(1);

    when(() => mockProvider.loadAlerts()).thenAnswer((_) async {});
    when(() => mockProvider.deleteAlert(any())).thenAnswer((_) async {});
    when(() => mockProvider.toggleAlert(any(), any())).thenAnswer((_) async {});
  });

  testWidgets('AlertsListScreen happy path: lista de alertas y FAB', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AlertProvider>.value(
        value: mockProvider,
        child: const MaterialApp(home: AlertsListScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(AlertCardWidget), findsNWidgets(2));

    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);

    final firstSwitch = find.byType(Switch).first;
    await tester.tap(firstSwitch);
    await tester.pumpAndSettle();
    verify(() => mockProvider.toggleAlert(1, false)).called(1);

    final deleteButtons = find.byIcon(Icons.delete_outline);
    expect(deleteButtons, findsNWidgets(2));

    await tester.tap(deleteButtons.first);
    await tester.pumpAndSettle();

    expect(find.byType(DeleteAlertDialog), findsOneWidget);

    final eliminarButton = find.widgetWithText(ElevatedButton, 'Delete');
    await tester.tap(eliminarButton);
    await tester.pumpAndSettle();
    verify(() => mockProvider.deleteAlert(1)).called(1);
  });
}
