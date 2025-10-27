import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:skyshare_frontend_mobile/features/alerts_configurable/presentation/alert_form_screen.dart';
import 'package:skyshare_frontend_mobile/features/alerts_configurable/presentation/alerts_list_screen.dart';
import 'package:skyshare_frontend_mobile/features/alerts_configurable/presentation/widgets/alert_card_widget.dart';
import 'package:skyshare_frontend_mobile/features/alerts_configurable/presentation/widgets/alert_dropdown.dart';
import 'package:skyshare_frontend_mobile/features/alerts_configurable/presentation/widgets/delete_alert_dialog.dart';
import 'package:skyshare_frontend_mobile/features/alerts_configurable/providers/alert_provider.dart';
import 'package:skyshare_frontend_mobile/features/alerts_configurable/data/model/alert_model.dart';

// -------------------- MOCKS Y FAKES --------------------

// Mock de AlertProvider
class MockAlertProvider extends Mock implements AlertProvider {}

// Fake para AlertModel, requerido por mocktail para any<AlertModel>()
class AlertModelFake extends Fake implements AlertModel {}

void main() {
  late MockAlertProvider mockProvider;

  setUpAll(() {
    registerFallbackValue(AlertModelFake());
  });

  setUp(() {
    mockProvider = MockAlertProvider();

    final alert1 = AlertModel(
      idAlerta: 1,
      idUsuario: 'user123',
      idUbicacion: 1,
      tipoAlerta: 'estrellas',
      parametroObjetivo: 'Virgo',
      tipoRepeticion: 'UNICA',
      fechaObjetivo: DateTime.now(),
      activa: true,
    );

    final alert2 = AlertModel(
      idAlerta: 2,
      idUsuario: 'user123',
      idUbicacion: 1,
      tipoAlerta: 'planetas',
      parametroObjetivo: 'Marte',
      tipoRepeticion: 'UNICA',
      fechaObjetivo: DateTime.now(),
      activa: false,
    );

    when(() => mockProvider.isLoading).thenReturn(false);
    when(() => mockProvider.error).thenReturn(null);
    when(() => mockProvider.alerts).thenReturn([alert1, alert2]);
    when(() => mockProvider.activeAlertsCount).thenReturn(1);

    when(() => mockProvider.loadAlerts()).thenAnswer((_) async {});
    when(() => mockProvider.deleteAlert(any())).thenAnswer((_) async {});
    when(() => mockProvider.toggleAlert(any(), any())).thenAnswer((_) async {});
    when(() => mockProvider.addAlert(any())).thenAnswer((_) async {});
    when(() => mockProvider.updateAlert(any(), any())).thenAnswer((_) async {});
  });

  testWidgets('AlertsListScreen happy path including navigation to AlertFormScreen', (tester) async {
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

    expect(find.text('2 alerts'), findsOneWidget);
    expect(find.text('1 activas'), findsOneWidget);

    final firstSwitch = find.byType(Switch).first;
    await tester.tap(firstSwitch);
    await tester.pumpAndSettle();

    verify(() => mockProvider.toggleAlert(1, false)).called(1);

    final deleteButtons = find.byIcon(Icons.delete_outline);
    expect(deleteButtons, findsNWidgets(2));

    await tester.tap(deleteButtons.first);
    await tester.pumpAndSettle();

    expect(find.byType(DeleteAlertDialog), findsOneWidget);

    final eliminarButton = find.widgetWithText(ElevatedButton, 'Eliminar');
    await tester.tap(eliminarButton);
    await tester.pumpAndSettle();

    verify(() => mockProvider.deleteAlert(1)).called(1);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.textContaining('CREATE ALERT'), findsOneWidget);

  });
  testWidgets('Shows loading indicator when provider is loading', (tester) async {
  when(() => mockProvider.isLoading).thenReturn(true);

  await tester.pumpWidget(
    ChangeNotifierProvider<AlertProvider>.value(
      value: mockProvider,
      child: const MaterialApp(home: AlertsListScreen()),
    ),
  );

  await tester.pump();

  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});

testWidgets('AlertFormScreen shows type-specific fields correctly', (tester) async {
  await tester.pumpWidget(
    const MaterialApp(
      home: AlertFormScreen(alertType: 'fase lunar'),
    ),
  );

  await tester.pumpAndSettle();

  // Should show lunar phase dropdown
  expect(find.text('LUNAR PHASE'), findsOneWidget);

  // Switch to Weather type
  await tester.tap(find.byType(AlertDropdown<String>).first);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Weather').last);
  await tester.pumpAndSettle();

  expect(find.text('WEATHER PARAMETER'), findsOneWidget);
  expect(find.text('MINIMUM VALUE'), findsOneWidget);
  expect(find.text('MAXIMUM VALUE'), findsOneWidget);

  // Switch to Stars type
  await tester.tap(find.byType(AlertDropdown<String>).first);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Stars').last);
  await tester.pumpAndSettle();

  expect(find.text('CONSTELLATION'), findsOneWidget);
});

}
