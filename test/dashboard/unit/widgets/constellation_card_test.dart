import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:skyshare_frontend_mobile/features/dashboard/data/models/visible_sky_model.dart';
import 'package:skyshare_frontend_mobile/features/dashboard/presentation/widgets/constellation_card.dart';

class MockVoidCallback extends Mock {
  void call();
}

void main() {
  group('ConstellationCard', () {
    late VisibleSkyItem mockConstellation;
    late VoidCallback onTap;

    setUp(() {
      onTap = MockVoidCallback();
      mockConstellation = VisibleSkyItem(
        id: 1,
        locationId: 1,
        timestamp: DateTime(2024, 1, 15, 20, 30),
        name: 'Orión',
        tipo: 'Constelación',
        descripcion: 'Constelación del cazador',
      );
    });

    testWidgets('muestra el nombre de la constelación', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConstellationCard(
              constellation: mockConstellation,
              onTap: onTap,
            ),
          ),
        ),
      );

      expect(find.text('Orión'), findsOneWidget);
    });

    testWidgets('muestra la fecha formateada correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConstellationCard(
              constellation: mockConstellation,
              onTap: onTap,
            ),
          ),
        ),
      );

      expect(find.text('15/01/2024 20:30'), findsOneWidget);
    });

    testWidgets('ejecuta onTap cuando se hace tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConstellationCard(
              constellation: mockConstellation,
              onTap: onTap,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ConstellationCard));
      verify(onTap()).called(1);
    });

    testWidgets('tiene el icono de estrella', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConstellationCard(
              constellation: mockConstellation,
              onTap: onTap,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
    });
  });
}