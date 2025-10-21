import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:skyshare_frontend_mobile/features/interactive_map/data/models/spot_model.dart';
import 'package:skyshare_frontend_mobile/features/interactive_map/presentation/widgets/spot_content.dart';

void main() {
  group('SpotContent', () {
    final spotWithDescription = Spot(
      id: 1,
      ubicacionId: 1,
      creadorId: "1",
      nombre: 'Test Spot',
      lat: 40.4168,
      lng: -3.7038,
      ciudad: 'Madrid',
      pais: 'España',
      descripcion: 'This is a test description',
      valoracionMedia: 4.5,
      totalValoraciones: 10,
    );

    final spotWithoutDescription = Spot(
      id: 2,
      ubicacionId: 2,
      creadorId: "2",
      nombre: 'Test Spot 2',
      lat: 40.4178,
      lng: -3.7048,
      ciudad: 'Barcelona',
      pais: 'España',
      descripcion: null,
      valoracionMedia: null,
      totalValoraciones: 0,
    );

    Widget wrapWithSliver(Widget child) {
      return MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            slivers: [child],
          ),
        ),
      );
    }

    testWidgets('should render spot name and location', (tester) async {
      await tester.pumpWidget(
        wrapWithSliver(SpotContent(spot: spotWithDescription)),
      );

      expect(find.text('Test Spot'), findsOneWidget);
      expect(find.text('Madrid, España'), findsOneWidget);
    });

    testWidgets('should render description when available', (tester) async {
      await tester.pumpWidget(
        wrapWithSliver(SpotContent(spot: spotWithDescription)),
      );

      expect(find.text('Descripción'), findsOneWidget);
      expect(find.text('This is a test description'), findsOneWidget);
    });

    testWidgets('should render "Sin descripción" when no description', (tester) async {
      await tester.pumpWidget(
        wrapWithSliver(SpotContent(spot: spotWithoutDescription)),
      );

      expect(find.text('Sin descripción'), findsOneWidget);
    });

    testWidgets('should render rating card with correct values', (tester) async {
      await tester.pumpWidget(
        wrapWithSliver(SpotContent(spot: spotWithDescription)),
      );

      expect(find.text('Valoración'), findsOneWidget);
      expect(find.text('4.5'), findsOneWidget);
      expect(find.text('10 valoraciones'), findsOneWidget);
    });

    testWidgets('should render rating card with dash when no rating', (tester) async {
      await tester.pumpWidget(
        wrapWithSliver(SpotContent(spot: spotWithoutDescription)),
      );

      expect(find.text('—'), findsOneWidget);
      expect(find.text('0 valoraciones'), findsOneWidget);
    });

    testWidgets('should render comments section', (tester) async {
      await tester.pumpWidget(
        wrapWithSliver(SpotContent(spot: spotWithDescription)),
      );

      expect(find.text('Comentarios'), findsOneWidget);
      expect(find.text('First comment'), findsOneWidget);
      expect(find.text('Second comment'), findsOneWidget);
    });

    testWidgets('should render star rating in header', (tester) async {
      await tester.pumpWidget(
        wrapWithSliver(SpotContent(spot: spotWithDescription)),
      );

      expect(find.byIcon(Icons.star), findsAtLeastNWidgets(4));
      expect(find.byIcon(Icons.star_half), findsAtLeastNWidgets(1));
    });

    testWidgets('should render star rating in rating card', (tester) async {
      await tester.pumpWidget(
        wrapWithSliver(SpotContent(spot: spotWithDescription)),
      );

      expect(find.byIcon(Icons.star), findsAtLeastNWidgets(4));
    });

    testWidgets('should render location icon and city/country', (tester) async {
      await tester.pumpWidget(
        wrapWithSliver(SpotContent(spot: spotWithDescription)),
      );

      expect(find.byIcon(Icons.location_on), findsOneWidget);
      expect(find.text('Madrid, España'), findsOneWidget);
    });

    testWidgets('should render comment items with avatars', (tester) async {
      await tester.pumpWidget(
        wrapWithSliver(SpotContent(spot: spotWithDescription)),
      );

      expect(find.byType(CircleAvatar), findsAtLeastNWidgets(2));
      expect(find.byIcon(Icons.person), findsAtLeastNWidgets(2));
    });

    testWidgets('should have correct padding and layout structure', (tester) async {
      await tester.pumpWidget(
        wrapWithSliver(SpotContent(spot: spotWithDescription)),
      );

      expect(find.byType(SliverToBoxAdapter), findsOneWidget);
      expect(find.byType(Padding), findsWidgets);
      expect(find.byType(Column), findsWidgets);
    });
  });
}