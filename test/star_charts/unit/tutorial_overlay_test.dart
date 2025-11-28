import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/star_charts/tutorial/presentation/tutorial_overlay.dart';
import 'package:skyshare_frontend_mobile/features/star_charts/tutorial/data/tutorial_data.dart';

void main() {
  Widget makeTestable(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  group('TutorialOverlay Widget Tests', () {
    testWidgets('No muestra nada cuando el tutorial está completado',
        (tester) async {
      await tester.pumpWidget(
        makeTestable(
          TutorialOverlay(
            currentStep: TutorialStep.completed,
            isTargetVisible: false,
            onNextStep: () {},
            onSkip: () {},
          ),
        ),
      );

      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('Muestra el panel inferior con instrucciones',
        (tester) async {
      await tester.pumpWidget(
        makeTestable(
          TutorialOverlay(
            currentStep: TutorialStep.intro,
            isTargetVisible: false,
            onNextStep: () {},
            onSkip: () {},
          ),
        ),
      );

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('Botón habilitado en el paso intro', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        makeTestable(
          TutorialOverlay(
            currentStep: TutorialStep.intro,
            isTargetVisible: false,
            onNextStep: () => pressed = true,
            onSkip: () {},
          ),
        ),
      );

      final button = find.byType(ElevatedButton);
      await tester.tap(button);
      await tester.pump();

      expect(pressed, true);
    });

    testWidgets('Botón deshabilitado si NO está visible en paso de búsqueda',
        (tester) async {
      await tester.pumpWidget(
        makeTestable(
          TutorialOverlay(
            currentStep: TutorialStep.searchLeft,
            isTargetVisible: false,
            onNextStep: () {},
            onSkip: () {},
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('Botón habilitado si objeto visible en paso de búsqueda',
        (tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        makeTestable(
          TutorialOverlay(
            currentStep: TutorialStep.searchLeft,
            isTargetVisible: true,
            onNextStep: () => pressed = true,
            onSkip: () {},
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(pressed, true);
    });

    testWidgets('Muestra flecha hacia la derecha en searchRight',
        (tester) async {
      await tester.pumpWidget(
        makeTestable(
          TutorialOverlay(
            currentStep: TutorialStep.searchRight,
            isTargetVisible: false,
            onNextStep: () {},
            onSkip: () {},
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);
    });

    testWidgets('Esconde flecha si targetVisible = true', (tester) async {
      await tester.pumpWidget(
        makeTestable(
          TutorialOverlay(
            currentStep: TutorialStep.searchUp,
            isTargetVisible: true,
            onNextStep: () {},
            onSkip: () {},
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_upward), findsNothing);
    });

    testWidgets('Botón Skip llama a onSkip', (tester) async {
      bool skipped = false;

      await tester.pumpWidget(
        makeTestable(
          TutorialOverlay(
            currentStep: TutorialStep.intro,
            isTargetVisible: false,
            onNextStep: () {},
            onSkip: () => skipped = true,
          ),
        ),
      );

      await tester.tap(find.text('Skip'));
      await tester.pump();

      expect(skipped, true);
    });
  });
}
