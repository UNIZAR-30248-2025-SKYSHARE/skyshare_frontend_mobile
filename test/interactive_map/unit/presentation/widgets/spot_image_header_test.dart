import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:skyshare_frontend_mobile/features/interactive_map/data/models/spot_model.dart';
import 'package:skyshare_frontend_mobile/features/interactive_map/presentation/widgets/spot_image_header.dart';

void main() {
  group('SpotImageHeader', () {
    final spotWithImage = Spot(
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

    final spotWithoutImage = Spot(
      id: 2,
      ubicacionId: 2,
      creadorId: "2",
      nombre: 'Test Spot 2',
      lat: 40.4178,
      lng: -3.7048,
      ciudad: 'Barcelona',
      pais: 'España',
      descripcion: 'Test description 2',
      valoracionMedia: 3.5,
      totalValoraciones: 5,
      urlImagen: null,
    );

    testWidgets('should render back button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SpotImageHeader(spot: spotWithImage),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('should render image when urlImagen is provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SpotImageHeader(spot: spotWithImage),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('should render placeholder when urlImagen is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SpotImageHeader(spot: spotWithoutImage),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.image_not_supported), findsOneWidget);
      expect(find.text('Sin imagen'), findsOneWidget);
    });

    testWidgets('should have correct expanded height', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SpotImageHeader(spot: spotWithImage),
              ],
            ),
          ),
        ),
      );

      final sliverAppBar = tester.widget<SliverAppBar>(find.byType(SliverAppBar));
      expect(sliverAppBar.expandedHeight, 300);
    });

    testWidgets('should have gradient at bottom', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SpotImageHeader(spot: spotWithImage),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(Positioned), findsNWidgets(2));
      
      final gradientContainerFinder = find.byWidgetPredicate(
        (widget) => widget is Container &&
            widget.decoration != null &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).gradient != null,
      );

      expect(gradientContainerFinder, findsOneWidget);

      final gradientContainer = tester.widget<Container>(gradientContainerFinder);
      final decoration = gradientContainer.decoration as BoxDecoration;
      final gradient = decoration.gradient as LinearGradient;
      
      expect(gradient.colors.length, 3);
      expect(gradient.begin, Alignment.bottomCenter);
      expect(gradient.end, Alignment.topCenter);
    });

    testWidgets('should have correct background color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SpotImageHeader(spot: spotWithImage),
              ],
            ),
          ),
        ),
      );

      final sliverAppBar = tester.widget<SliverAppBar>(find.byType(SliverAppBar));
      expect(sliverAppBar.backgroundColor, const Color(0xFF13121A));
    });

    testWidgets('should have stretch enabled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SpotImageHeader(spot: spotWithImage),
              ],
            ),
          ),
        ),
      );

      final sliverAppBar = tester.widget<SliverAppBar>(find.byType(SliverAppBar));
      expect(sliverAppBar.stretch, true);
    });
  });
}