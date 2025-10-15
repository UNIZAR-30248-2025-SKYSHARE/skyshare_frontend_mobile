import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/phase_lunar/data/models/lunar_phase_model.dart';
import 'package:skyshare_frontend_mobile/features/phase_lunar/presentation/widgets/lunar_phase_item.dart';
import 'package:skyshare_frontend_mobile/features/phase_lunar/presentation/widgets/moon_phase_widget.dart';

void main() {
  group('LunarPhaseItem Widget', () {
    late LunarPhase mockPhase;

    setUp(() {
      mockPhase = LunarPhase(
        idLuna: 1,
        fase: 'Luna Llena',
        porcentajeIluminacion: 99.5,
        fecha: DateTime(2025, 10, 11),
      );
    });

    testWidgets('muestra los datos básicos correctamente', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LunarPhaseItem(
              phase: mockPhase,
              weekday: 'Sábado',
              dateStr: '11 Oct 2025',
            ),
          ),
        ),
      );

      expect(find.text('Luna Llena'), findsOneWidget);
      expect(find.text('Sábado, 11 Oct 2025'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
      expect(find.byType(MoonPhaseWidget), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);
    });

    testWidgets('muestra guion si porcentaje es nulo o 0', (tester) async {
      final phaseWithoutIllumination = LunarPhase(
        idLuna: 2,
        fase: 'Luna Nueva',
        porcentajeIluminacion: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LunarPhaseItem(
              phase: phaseWithoutIllumination,
              weekday: 'Lunes',
              dateStr: '13 Oct 2025',
            ),
          ),
        ),
      );

      expect(find.text('–'), findsOneWidget);
    });

    testWidgets('ejecuta onTap al hacer tap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LunarPhaseItem(
              phase: mockPhase,
              weekday: 'Domingo',
              dateStr: '12 Oct 2025',
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      final tappableFinder = find.byType(ListTile).first;
      await tester.tap(tappableFinder);
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}