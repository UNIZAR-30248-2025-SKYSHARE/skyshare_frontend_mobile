import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/guia_constelacion/presentation/widgets/referencia_constelacion.dart';
import 'package:skyshare_frontend_mobile/features/guia_constelacion/data/models/guia_model.dart';

void main() {
  group('ReferenciaConstelacion', () {
    testWidgets('muestra la referencia con imagen de red válida', (tester) async {
      final guia = GuiaConstelacion(
        idGuia: 1,
        nombreConstelacion: 'Orión',
        temporada: 'invierno',
        paso1: 'Paso 1',
        paso2: 'Paso 2',
        paso3: 'Paso 3',
        paso4: 'Paso 4',
        referencia: 'Guía completa',
        urlReferencia: 'http://example.com/image.jpg',
      );

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: ReferenciaConstelacion(guia: guia))),
      );

      await tester.pumpAndSettle();

      // Verifica título e ícono
      expect(find.text('Referencia'), findsOneWidget);
      expect(find.byIcon(Icons.map), findsOneWidget);

      // Verifica que se haya intentado cargar una imagen de red
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('muestra imagen local cuando urlReferencia no empieza por http', (tester) async {
      final guia = GuiaConstelacion(
        idGuia: 2,
        nombreConstelacion: 'Cruz del Sur',
        temporada: 'verano',
        paso1: 'Paso 1',
        paso2: 'Paso 2',
        paso3: 'Paso 3',
        paso4: 'Paso 4',
        referencia: 'Referencia local',
        urlReferencia: 'imagen_local.png',
      );

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: ReferenciaConstelacion(guia: guia))),
      );

      await tester.pumpAndSettle();

      expect(find.text('Referencia'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('no muestra nada cuando referencia está vacía', (tester) async {
      final guia = GuiaConstelacion(
        idGuia: 3,
        nombreConstelacion: 'Casiopea',
        temporada: 'invierno',
        paso1: 'Paso 1',
        paso2: 'Paso 2',
        paso3: 'Paso 3',
        paso4: 'Paso 4',
        referencia: '', // referencia vacía
      );

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: ReferenciaConstelacion(guia: guia))),
      );

      await tester.pumpAndSettle();

      // No debe haber texto ni íconos de referencia
      expect(find.text('Referencia'), findsNothing);
      expect(find.byIcon(Icons.map), findsNothing);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('muestra contenedor vacío cuando urlReferencia es nula', (tester) async {
      final guia = GuiaConstelacion(
        idGuia: 4,
        nombreConstelacion: 'Andrómeda',
        temporada: 'invierno',
        paso1: 'Paso 1',
        paso2: 'Paso 2',
        paso3: 'Paso 3',
        paso4: 'Paso 4',
        referencia: 'Referencia sin imagen',
        urlReferencia: null, // no hay imagen
      );

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: ReferenciaConstelacion(guia: guia))),
      );

      await tester.pumpAndSettle();

      expect(find.text('Referencia'), findsOneWidget);
      // No hay imagen porque urlReferencia es nula
      expect(find.byType(Image), findsNothing);
    });
  });
}
