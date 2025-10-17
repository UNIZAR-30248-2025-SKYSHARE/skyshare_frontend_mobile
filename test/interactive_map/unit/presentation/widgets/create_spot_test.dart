import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skyshare_frontend_mobile/features/interactive_map/presentation/widgets/create_spot.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockNavigatorObserver mockObserver;
  const testPosition = LatLng(40.4168, -3.7038);

  setUp(() {
    mockObserver = MockNavigatorObserver();
  });

  Future<void> pumpCreateSpotScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const CreateSpotScreen(position: testPosition),
        navigatorObservers: [mockObserver],
      ),
    );
  }

  testWidgets('renderiza todos los elementos del formulario', (tester) async {
    await pumpCreateSpotScreen(tester);

    expect(find.text('Crear Nuevo Spot'), findsOneWidget);
    expect(find.text('Nombre del spot *'), findsOneWidget);
    expect(find.text('Descripción *'), findsOneWidget);
    expect(find.text('Añadir foto'), findsOneWidget);
    expect(find.text('Crear Spot'), findsOneWidget);
    expect(find.byType(Form), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });

  testWidgets('muestra coordenadas de ubicación', (tester) async {
    await pumpCreateSpotScreen(tester);

    expect(find.text('Lat: 40.41680'), findsOneWidget);
    expect(find.text('Lng: -3.70380'), findsOneWidget);
  });

  testWidgets('valida campos obligatorios', (tester) async {
    await pumpCreateSpotScreen(tester);

    await tester.tap(find.text('Crear Spot'));
    await tester.pump();

    expect(find.text('El nombre es obligatorio'), findsOneWidget);
    expect(find.text('La descripción es obligatoria'), findsOneWidget);
  });

  testWidgets('permite ingresar texto en los campos', (tester) async {
    await pumpCreateSpotScreen(tester);

    await tester.enterText(find.byType(TextFormField).at(0), 'Mirador del Pico');
    await tester.enterText(find.byType(TextFormField).at(1), 'Vista increíble');

    expect(find.text('Mirador del Pico'), findsOneWidget);
    expect(find.text('Vista increíble'), findsOneWidget);
  });

  testWidgets('muestra snackbar cuando no hay imagen', (tester) async {
    await pumpCreateSpotScreen(tester);

    await tester.enterText(find.byType(TextFormField).at(0), 'Test Spot');
    await tester.enterText(find.byType(TextFormField).at(1), 'Test Description');
    await tester.tap(find.text('Crear Spot'));
    await tester.pump();

    expect(find.text('Por favor, añade una foto'), findsOneWidget);
  });

  testWidgets('contiene círculo para añadir foto', (tester) async {
    await pumpCreateSpotScreen(tester);

    final container = tester.widget<Container>(find.descendant(
      of: find.byType(GestureDetector),
      matching: find.byType(Container),
    ).first);

    expect(container.decoration, isA<BoxDecoration>());
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.shape, BoxShape.circle);
  });
}