import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:skyshare_frontend_mobile/features/interactive_map/presentation/spot_detail_screen.dart';
import 'package:skyshare_frontend_mobile/features/interactive_map/data/models/spot_model.dart';

void main() {
  group('SpotDetailScreen Integration Tests', () {
    final spotWithImage = Spot(
      id: 1,
      ubicacionId: 1,
      creadorId: "1",
      nombre: 'Mirador Excelente',
      lat: 40.4168,
      lng: -3.7038,
      ciudad: 'Madrid',
      pais: 'España',
      descripcion: 'Un mirador con vistas espectaculares a la ciudad',
      valoracionMedia: 4.8,
      totalValoraciones: 20,
      urlImagen: 'https://example.com/image.jpg',
    );

    final spotWithoutImage = Spot(
      id: 2,
      ubicacionId: 2,
      creadorId: "2",
      nombre: 'Pico Montañoso',
      lat: 40.5123,
      lng: -3.8123,
      ciudad: 'Segovia',
      pais: 'España',
      descripcion: null,
      valoracionMedia: 3.2,
      totalValoraciones: 5,
      urlImagen: null,
    );

    final spotWithoutRating = Spot(
      id: 3,
      ubicacionId: 3,
      creadorId: "3",
      nombre: 'Llanura Desconocida',
      lat: 40.6123,
      lng: -3.9123,
      ciudad: 'Toledo',
      pais: 'España',
      descripcion: 'Un lugar tranquilo y poco conocido',
      valoracionMedia: null,
      totalValoraciones: 0,
      urlImagen: 'https://example.com/another-image.jpg',
    );

    testWidgets('debería mostrar todos los detalles del spot con imagen', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SpotDetailScreen(spot: spotWithImage),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Mirador Excelente'), findsOneWidget);
      expect(find.text('Madrid, España'), findsOneWidget);
      expect(find.text('Un mirador con vistas espectaculares a la ciudad'), findsOneWidget);
      
      expect(find.text('4.8'), findsOneWidget);
      expect(find.text('20 valoraciones'), findsOneWidget);
      
      expect(find.text('Descripción'), findsOneWidget);
      expect(find.text('Valoración'), findsOneWidget);
      expect(find.text('Comentarios'), findsOneWidget);
      
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byType(CustomScrollView), findsOneWidget);
    });

    testWidgets('debería mostrar placeholder cuando no hay imagen', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SpotDetailScreen(spot: spotWithoutImage),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.image_not_supported), findsOneWidget);
      expect(find.text('Sin imagen'), findsOneWidget);
    });

    testWidgets('debería manejar spots sin valoración', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SpotDetailScreen(spot: spotWithoutRating),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('—'), findsOneWidget); 
      expect(find.text('0 valoraciones'), findsOneWidget);
    });

    testWidgets('debería mostrar "Sin descripción" cuando no hay descripción', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SpotDetailScreen(spot: spotWithoutImage),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Sin descripción'), findsOneWidget);
    });

    testWidgets('debería mostrar comentarios de ejemplo', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SpotDetailScreen(spot: spotWithImage),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('First comment'), findsOneWidget);
      expect(find.text('Second comment'), findsOneWidget);
      expect(find.text('Hace 2 h'), findsOneWidget);
      expect(find.text('Hace 3 h'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsAtLeastNWidgets(2));
    });

    testWidgets('debería tener botón de retroceso', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SpotDetailScreen(spot: spotWithImage),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('debería mostrar las estrellas de valoración correctamente', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SpotDetailScreen(spot: spotWithImage),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.star), findsAtLeastNWidgets(4));
    });

    testWidgets('debería manejar scroll correctamente', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SpotDetailScreen(spot: spotWithImage),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(CustomScrollView), findsOneWidget);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(find.text('Mirador Excelente'), findsOneWidget);
      expect(find.text('Comentarios'), findsOneWidget);
    });

    testWidgets('debería mostrar información de ubicación correctamente', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SpotDetailScreen(spot: spotWithImage),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.location_on), findsOneWidget);
      expect(find.text('Madrid, España'), findsOneWidget);
    });

    testWidgets('debería mantener el estado al reconstruirse', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SpotDetailScreen(spot: spotWithImage),
        ),
      );

      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MaterialApp(
          home: SpotDetailScreen(spot: spotWithImage),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Mirador Excelente'), findsOneWidget);
      expect(find.text('Madrid, España'), findsOneWidget);
    });

    testWidgets('debería mostrar elementos de tarjeta de rating', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SpotDetailScreen(spot: spotWithImage),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Valoración'), findsOneWidget);
      expect(find.text('4.8'), findsOneWidget);
      expect(find.text('20 valoraciones'), findsOneWidget);
    });

    testWidgets('debería tener una estructura de layout completa', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SpotDetailScreen(spot: spotWithImage),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(CustomScrollView), findsOneWidget);
      expect(find.byType(SliverAppBar), findsOneWidget);
      expect(find.byType(SliverToBoxAdapter), findsOneWidget);
    });
  });
}