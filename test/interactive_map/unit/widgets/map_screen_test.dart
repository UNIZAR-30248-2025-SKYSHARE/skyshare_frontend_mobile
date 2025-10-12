import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/interactive_map/presentation/map_screen.dart';
import 'package:latlong2/latlong.dart';

void main() {
  group('CreateSpotScreen - UI', () {
    testWidgets('muestra campos obligatorios correctamente', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreateSpotScreen(position: LatLng(40.4168, -3.7038)),
        ),
      );

      expect(find.text('Nombre del spot *'), findsOneWidget);
      expect(find.text('Descripción *'), findsOneWidget);
      expect(find.text('Añadir foto'), findsOneWidget);
      expect(find.text('Crear Spot'), findsOneWidget);
    });

    testWidgets('muestra error si se intenta guardar sin completar datos', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreateSpotScreen(position: LatLng(40.4168, -3.7038)),
        ),
      );

      await tester.tap(find.text('Crear Spot'));
      await tester.pump();

      expect(find.text('El nombre es obligatorio'), findsOneWidget);
      expect(find.text('La descripción es obligatoria'), findsOneWidget);
    });

    testWidgets('permite ingresar datos válidos en el formulario', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreateSpotScreen(position: LatLng(40.4168, -3.7038)),
        ),
      );

      await tester.enterText(find.byType(TextFormField).at(0), 'Mirador del Pico');
      await tester.enterText(find.byType(TextFormField).at(1), 'Lugar con una vista increíble');
      await tester.pump();

      expect(find.text('Mirador del Pico'), findsOneWidget);
      expect(find.text('Lugar con una vista increíble'), findsOneWidget);
    });
  });
}
