import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:skyshare_frontend_mobile/features/interactive_map/data/models/spot_model.dart';
import 'package:skyshare_frontend_mobile/features/interactive_map/presentation/spot_detail_screen.dart';

void main() {
  group('SpotDetailScreen', () {
    final testSpot = Spot(
      id: 1,
      ubicacionId: 1,
      creadorId: "1",
      nombre: 'Test Spot',
      lat: 40.4168,
      lng: -3.7038,
      ciudad: 'Madrid',
      pais: 'España',
      descripcion: 'Test description',
      valoracionMedia: 4.5,
      totalValoraciones: 10,
      urlImagen: 'https://example.com/image.jpg',
    );

    testWidgets('should render all main components', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SpotDetailScreen(spot: testSpot),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(CustomScrollView), findsOneWidget);
      expect(find.byType(SpotDetailScreen), findsOneWidget);
    });

    testWidgets('should have correct background color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SpotDetailScreen(spot: testSpot),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFF13121A));
    });

    testWidgets('should pass spot data to children', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SpotDetailScreen(spot: testSpot),
        ),
      );

      expect(find.text('Test Spot'), findsOneWidget);
      expect(find.text('Madrid, España'), findsOneWidget);
    });
  });
}