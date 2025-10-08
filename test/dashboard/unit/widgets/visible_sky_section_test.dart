import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skyshare_frontend_mobile/features/dashboard/data/models/visible_sky_model.dart';
import 'package:skyshare_frontend_mobile/features/dashboard/presentation/widgets/visible_sky_section.dart';

class MockBuildContext extends Mock implements BuildContext {}

void main() {
  group('VisibleSkySection', () {
    late List<VisibleSkyItem> mockConstellations;

    setUp(() {
      mockConstellations = [
        VisibleSkyItem(
          id: 1,
          locationId: 1,
          timestamp: DateTime.now(),
          name: 'Orión',
          tipo: 'Constelación',
        ),
        VisibleSkyItem(
          id: 2,
          locationId: 1,
          timestamp: DateTime.now(),
          name: 'Osa Mayor',
          tipo: 'Constelación',
        ),
      ];
    });

    testWidgets('muestra el título correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VisibleSkySection(
              constellations: mockConstellations,
            ),
          ),
        ),
      );

      expect(find.text('Cielo Visible'), findsOneWidget);
    });

    testWidgets('muestra todas las constelaciones', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VisibleSkySection(
              constellations: mockConstellations,
            ),
          ),
        ),
      );

      expect(find.text('Orión'), findsOneWidget);
      expect(find.text('Osa Mayor'), findsOneWidget);
    });

    testWidgets('muestra SnackBar al hacer tap en una constelación', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VisibleSkySection(
              constellations: mockConstellations,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Orión').first);
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Navegando a guía de Orión'), findsOneWidget);
    });
  });
}