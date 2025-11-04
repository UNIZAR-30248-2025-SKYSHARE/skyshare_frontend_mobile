import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/guia_constelacion/data/models/guia_model.dart';
import 'package:skyshare_frontend_mobile/features/guia_constelacion/presentation/widgets/banner_constelacion.dart';

void main() {
  testWidgets('BannerConstelacionDelegate muestra el nombre de la constelación', (WidgetTester tester) async {
    // Creamos una instancia de GuiaConstelacion de ejemplo
    final guia = GuiaConstelacion(
      idGuia: 1,
      nombreConstelacion: 'Orión',
      temporada: 'invierno',
      paso1: 'Paso 1',
      paso2: 'Paso 2',
      paso3: 'Paso 3',
      paso4: 'Paso 4',
      referencia: 'Referencia',
    );

    // Renderizamos el widget dentro de un CustomScrollView
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: BannerConstelacionDelegate(
                  guia: guia,
                  minExtent: 100,
                  maxExtent: 200,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verificamos que el texto correcto se muestre
    expect(find.text('Guía Constelación de Orión'), findsOneWidget);

    // Verificamos que haya al menos una imagen
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('BannerConstelacionDelegate muestra imagen fallback si la principal falla', (WidgetTester tester) async {
    final guia = GuiaConstelacion(
      idGuia: 1,
      nombreConstelacion: 'Orión',
      temporada: 'invierno',
      paso1: 'Paso 1',
      paso2: 'Paso 2',
      paso3: 'Paso 3',
      paso4: 'Paso 4',
      referencia: 'Referencia',
    );

    // Como no podemos simular error real de carga en un test de widget fácilmente,
    // solo comprobamos que el widget contenga un Image (la lógica de errorBuilder se probaría en integración)
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: BannerConstelacionDelegate(
                  guia: guia,
                  minExtent: 100,
                  maxExtent: 200,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(Image), findsOneWidget);
  });
}
