import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/phase_lunar/presentation/widgets/phase_lunar_more_info.dart';

void main() {
  group('PhaseLunarMoreInfo Widget', () {
    const description = 'This is a test description';

    testWidgets('muestra el botón More info', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PhaseLunarMoreInfo(description: description),
          ),
        ),
      );

      expect(find.widgetWithText(ElevatedButton, 'More info'), findsOneWidget);
    });

    testWidgets('muestra la información de distancia y descripción', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PhaseLunarMoreInfo(description: description),
          ),
        ),
      );

      expect(find.textContaining('Distance: 384.4'), findsOneWidget);
      expect(find.textContaining('Phase description: $description'), findsOneWidget);
    });
  });
}
