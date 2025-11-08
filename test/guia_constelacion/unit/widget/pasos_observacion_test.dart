import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/guia_constelacion/data/models/guia_model.dart';
import 'package:skyshare_frontend_mobile/features/guia_constelacion/presentation/widgets/pasos_observacion.dart';

void main() {
  testWidgets('PasosObservacion muestra correctamente los pasos', (WidgetTester tester) async {
    final guia = GuiaConstelacion(
      idGuia: 1,
      nombreConstelacion: 'Orión',
      temporada: 'invierno',
      paso1: 'Busca las tres estrellas alineadas del cinturón.',
      paso2: 'Identifica Betelgeuse y Rigel.',
      paso3: 'Ubica la nebulosa de Orión.',
      paso4: 'Observa con prismáticos.',
      paso5: 'Toma notas de las estrellas visibles.',
      paso6: null, // Paso opcional vacío
      referencia: 'Guía de astronomía',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PasosObservacion(guia: guia),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verifica el título y el icono
    expect(find.text('Pasos para Observar'), findsOneWidget);
    expect(find.byIcon(Icons.visibility), findsOneWidget);

    // Verifica que cada paso con contenido se muestre
    expect(find.textContaining('Busca las tres estrellas'), findsOneWidget);
    expect(find.textContaining('Identifica Betelgeuse'), findsOneWidget);
    expect(find.textContaining('Ubica la nebulosa'), findsOneWidget);
    expect(find.textContaining('Observa con prismáticos'), findsOneWidget);
    expect(find.textContaining('Toma notas de las estrellas'), findsOneWidget);

    // Paso6 es null, no debe mostrarse
    expect(find.textContaining('null'), findsNothing);

    // Verifica que los números de pasos aparezcan
    for (var i = 1; i <= 5; i++) {
      expect(find.text('$i'), findsOneWidget);
    }
  });

  testWidgets('PasosObservacion omite pasos vacíos', (WidgetTester tester) async {
  final guia = GuiaConstelacion(
    idGuia: 2,
    nombreConstelacion: 'Cygnet',
    temporada: 'verano',
    paso1: '',                     // vacío
    paso2: 'Solo paso 2 válido',   // válido
    paso3: '   ',                  // vacío
    paso4: '   ',                  // vacío
    referencia: 'Referencia',
  );

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: PasosObservacion(guia: guia),
      ),
    ),
  );

  await tester.pumpAndSettle();

  // Solo debe mostrarse el paso válido
  expect(find.textContaining('Solo paso 2 válido'), findsOneWidget);

  // El número del paso visible siempre será 1 (primer paso de la lista filtrada)
  expect(find.text('1'), findsOneWidget);
  expect(find.text('2'), findsNothing);
  expect(find.text('3'), findsNothing);
});

}
