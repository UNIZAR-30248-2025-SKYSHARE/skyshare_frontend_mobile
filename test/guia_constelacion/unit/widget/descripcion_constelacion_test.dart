import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/guia_constelacion/data/models/guia_model.dart';
import 'package:skyshare_frontend_mobile/features/guia_constelacion/presentation/widgets/descripcion_constelacion.dart';

void main() {
  testWidgets('DescripcionConstelacion muestra nombre, temporada y descripción', (WidgetTester tester) async {
    // Creamos una instancia de GuiaConstelacion de ejemplo
    final guia = GuiaConstelacion(
      idGuia: 1,
      nombreConstelacion: 'Orión',
      temporada: 'invierno',
      descripcionGeneral: 'Una de las constelaciones más brillantes del cielo nocturno.',
      paso1: 'Paso 1',
      paso2: 'Paso 2',
      paso3: 'Paso 3',
      paso4: 'Paso 4',
      referencia: 'Referencia',
    );

    // Renderizamos el widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DescripcionConstelacion(guia: guia),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verificamos que el nombre de la constelación aparezca
    expect(find.text('Orión'), findsOneWidget);

    // Verificamos que la temporada aparezca
    expect(find.text('invierno'), findsOneWidget);

    // Verificamos que la descripción aparezca
    expect(find.text('Una de las constelaciones más brillantes del cielo nocturno.'), findsOneWidget);

    // Verificamos que se muestre el icono correcto para invierno
    final iconFinder = find.byIcon(Icons.ac_unit);
    expect(iconFinder, findsOneWidget);
  });

  testWidgets('DescripcionConstelacion usa icono por defecto si temporada no válida', (WidgetTester tester) async {
    final guia = GuiaConstelacion(
      idGuia: 2,
      nombreConstelacion: 'Cygnet',
      temporada: 'primavera',
      descripcionGeneral: 'Descripción ejemplo.',
      paso1: 'Paso 1',
      paso2: 'Paso 2',
      paso3: 'Paso 3',
      paso4: 'Paso 4',
      referencia: 'Referencia',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DescripcionConstelacion(guia: guia),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Debe usar icono por defecto
    expect(find.byIcon(Icons.star), findsOneWidget);
  });
}
