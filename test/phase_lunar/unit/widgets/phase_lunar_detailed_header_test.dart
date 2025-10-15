import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/phase_lunar/presentation/widgets/phase_lunar_detailed_header.dart';
import 'package:skyshare_frontend_mobile/features/phase_lunar/presentation/widgets/moon_phase_widget.dart';

class MockPhase {
  final DateTime date;
  final int percentage;
  final String phaseName;

  MockPhase({required this.date, required this.percentage, required this.phaseName});
}

void main() {
  group('PhaseLunarDetailedHeader', () {
    testWidgets('muestra MoonPhaseWidget, fecha y nombre de fase correctamente', (tester) async {
      final mockPhase = MockPhase(
        date: DateTime(2025, 10, 11),
        percentage: 75,
        phaseName: 'Luna Creciente',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhaseLunarDetailedHeader(
              phase: mockPhase,
              size: 200,
            ),
          ),
        ),
      );

      // Verifica que MoonPhaseWidget está presente
      expect(find.byType(MoonPhaseWidget), findsOneWidget);

      // Verifica que la fecha se muestra correctamente
      expect(find.text('11/10/2025'), findsOneWidget);

      // Verifica que el nombre de la fase se muestra
      expect(find.text('Luna Creciente'), findsOneWidget);
    });

    testWidgets('muestra texto por defecto si el nombre de fase está vacío', (tester) async {
      final mockPhase = MockPhase(
        date: DateTime(2025, 10, 12),
        percentage: 50,
        phaseName: '',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhaseLunarDetailedHeader(
              phase: mockPhase,
            ),
          ),
        ),
      );

      expect(find.text('Phase unknown'), findsOneWidget);
    });
  });
}
