import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/dashboard/presentation/widgets/location_header.dart';

void main() {
  group('LocationHeader', () {
    testWidgets('muestra el nombre de la ciudad', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LocationHeader(
              cityName: 'Madrid',
              countryName: 'España',
            ),
          ),
        ),
      );

      expect(find.text('Madrid'), findsOneWidget);
    });

    testWidgets('muestra el nombre del país', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LocationHeader(
              cityName: 'Madrid',
              countryName: 'España',
            ),
          ),
        ),
      );

      expect(find.text('España'), findsOneWidget);
    });

    testWidgets('aplica los estilos correctos', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LocationHeader(
              cityName: 'Madrid',
              countryName: 'España',
            ),
          ),
        ),
      );

      final cityText = tester.widget<Text>(find.text('Madrid'));
      final countryText = tester.widget<Text>(find.text('España'));

      expect(cityText.style?.fontSize, 44);
      expect(countryText.style?.fontSize, 16);
    });
  });
}