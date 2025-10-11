import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/phase_lunar/presentation/widgets/moon_phase_widget.dart';

void main() {
  group('MoonPhaseWidget', () {
    testWidgets('renderiza con porcentaje 0 mostrando solo fondo negro', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MoonPhaseWidget(percentage: 0, size: 50),
          ),
        ),
      );

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('renderiza con porcentaje 50 mostrando imagen parcialmente', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MoonPhaseWidget(percentage: 50, size: 50),
          ),
        ),
      );

      expect(find.byType(ClipPath), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('renderiza con porcentaje 100 mostrando imagen completa', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MoonPhaseWidget(percentage: 100, size: 50),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('muestra fallback gris si la imagen falla', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MoonPhaseWidget(
              percentage: 50,
              size: 50,
              imageAssetPath: 'ruta/incorrecta.jpg', // forzar error
            ),
          ),
        ),
      );

      final fallbackFinder = find.descendant(
        of: find.byType(MoonPhaseWidget),
        matching: find.byType(Container),
      );

      expect(fallbackFinder, findsWidgets);
    });

    testWidgets('puede renderizar de derecha a izquierda', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MoonPhaseWidget(percentage: 50, size: 50, leftToRight: false),
          ),
        ),
      );

      expect(find.byType(ClipPath), findsOneWidget);
    });
  });
}
