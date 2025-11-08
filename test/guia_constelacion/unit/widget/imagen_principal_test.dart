import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/guia_constelacion/data/models/guia_model.dart';
import 'package:skyshare_frontend_mobile/features/guia_constelacion/presentation/widgets/imagen_principal.dart';

void main() {
  testWidgets('ImagenPrincipal muestra imagen desde imagenUrl', (WidgetTester tester) async {
    final guia = GuiaConstelacion(
      idGuia: 1,
      nombreConstelacion: 'Orión',
      temporada: 'invierno',
      paso1: 'Paso 1',
      paso2: 'Paso 2',
      paso3: 'Paso 3',
      paso4: 'Paso 4',
      referencia: 'Referencia',
      imagenUrl: 'https://example.com/orion.jpg',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ImagenPrincipal(guia: guia),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verificamos que se renderice Image.network
    final networkImageFinder = find.byType(Image);
    expect(networkImageFinder, findsOneWidget);
    final imageWidget = tester.widget<Image>(networkImageFinder);
    expect(imageWidget.image, isA<NetworkImage>());
  });

  testWidgets('ImagenPrincipal muestra imagen desde urlReferencia si imagenUrl está vacío', (WidgetTester tester) async {
    final guia = GuiaConstelacion(
      idGuia: 2,
      nombreConstelacion: 'Cygnet',
      temporada: 'verano',
      paso1: 'Paso 1',
      paso2: 'Paso 2',
      paso3: 'Paso 3',
      paso4: 'Paso 4',
      referencia: 'Referencia',
      imagenUrl: '',
      urlReferencia: 'https://example.com/cygnet.jpg',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ImagenPrincipal(guia: guia),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final networkImageFinder = find.byType(Image);
    expect(networkImageFinder, findsOneWidget);
    final imageWidget = tester.widget<Image>(networkImageFinder);
    expect(imageWidget.image, isA<NetworkImage>());
  });

  testWidgets('ImagenPrincipal muestra icono de error si no hay imagen', (WidgetTester tester) async {
    final guia = GuiaConstelacion(
      idGuia: 3,
      nombreConstelacion: 'Lyra',
      temporada: 'verano',
      paso1: 'Paso 1',
      paso2: 'Paso 2',
      paso3: 'Paso 3',
      paso4: 'Paso 4',
      referencia: 'Referencia',
      imagenUrl: null,
      urlReferencia: null,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ImagenPrincipal(guia: guia),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Debe mostrar el Icon de error
    expect(find.byIcon(Icons.image_not_supported), findsOneWidget);
  });
}
